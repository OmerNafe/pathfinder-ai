import { encodeBase64 } from "jsr:@std/encoding@1/base64";
import type {
  ApplicantProfileExtraction,
  CertificationEntry,
  EducationEntry,
  ExtractedDocumentFields,
  WorkExperienceEntry,
} from "./document_review_types.ts";

export class NotConfiguredError extends Error {}

const DEFAULT_MODEL = "gpt-4o-mini";

// OpenAI's vision input only accepts these image formats — HEIC/HEIF
// (which this app's own upload allowlist otherwise permits, since real
// phone cameras produce them) isn't one of them. Handled as an honest
// "not supported yet" review result below rather than sent to the API and
// left to fail with an opaque error.
const SUPPORTED_IMAGE_MIME_TYPES = new Set(["image/png", "image/jpeg", "image/webp", "image/gif"]);

// OpenAI's structured-output json_schema format went through two rounds of
// rejecting this exact shape -- first demanding additionalProperties: false
// at the root, then rejecting keyValues' open string-to-string dictionary
// entirely once that was added ("'required' is required to be... every key
// in properties. Extra required key 'keyValues' supplied"). Rather than
// keep guessing at validator quirks, this uses plain json_object mode (just
// "return valid JSON") and leans on validateExtractedFields below as the
// real shape guarantee -- consistent with this app's actual rule
// throughout: the model's output is never trusted just because it parsed,
// only after every field is independently confirmed.
const SHAPE_DESCRIPTION = `{
  "documentType": string or null — a short label for what this file actually is, e.g. "passport", "CV / resume", "unrelated photo",
  "detectedName": string or null — the full name printed on the document, if visible,
  "detectedDates": string[] — every date printed on the document, as it appears,
  "keyValues": object mapping string to string — other labeled fields visible, e.g. institution, credential number, issuing body,
  "legible": boolean — false if the document is too blurry, dark, cropped, or corrupted to read reliably,
  "legibilityIssue": string or null — plain-English reason when legible is false, null when legible is true,
  "matchesDocumentType": boolean — true only if this file is actually the kind of document the requirement below describes,
  "documentTypeMismatchReason": string or null — plain-English reason when matchesDocumentType is false (e.g. "This is a CV, not a passport"), null when it's true
}`;

/**
 * The only function every caller uses for extraction. Sends the uploaded
 * file to a vision-capable OpenAI model via the Responses API, then
 * validates the parsed response field-by-field before returning it -- the
 * model's output is never trusted just because it parsed as JSON.
 */
export async function extractDocumentFields({
  fileBytes,
  mimeType,
  requirementTitle,
  requirementDescription,
}: {
  fileBytes: Uint8Array;
  mimeType: string;
  requirementTitle: string;
  requirementDescription: string;
}): Promise<ExtractedDocumentFields> {
  const apiKey = Deno.env.get("OPENAI_API_KEY");
  if (!apiKey) {
    throw new NotConfiguredError(
      "OPENAI_API_KEY is not set — document AI review isn't connected yet.",
    );
  }

  const isPdf = mimeType === "application/pdf";
  if (!isPdf && !SUPPORTED_IMAGE_MIME_TYPES.has(mimeType)) {
    return {
      documentType: null,
      detectedName: null,
      detectedDates: [],
      keyValues: {},
      legible: false,
      legibilityIssue:
        `${mimeType || "This file type"} isn't supported for AI review yet — ` +
        "try uploading a PDF, JPG, or PNG instead.",
      matchesDocumentType: false,
      documentTypeMismatchReason: null,
    };
  }

  const base64 = encodeBase64(fileBytes);
  const promptText =
    "You are reviewing a document a skilled-migration applicant uploaded to satisfy this " +
    `specific checklist requirement:\nTitle: "${requirementTitle}"\nWhat's expected: ` +
    `"${requirementDescription}"\n\n` +
    "Look carefully at what was actually uploaded and compare it against that requirement. " +
    "Applicants sometimes upload the wrong file by mistake (a CV where a certificate was " +
    "asked for, a random photo, someone else's document, an unrelated screenshot or bill) -- " +
    "your job is to catch that, not to assume every upload is correct. Set matchesDocumentType " +
    "to false whenever the file is clearly not the kind of document described above, and explain " +
    "specifically what it looks like instead in documentTypeMismatchReason.\n\n" +
    `Respond with ONLY a single JSON object, no other text, matching exactly this shape:\n${SHAPE_DESCRIPTION}\n\n` +
    "Only report what is actually visible on the document -- never guess or invent a name, " +
    "date, or value that isn't legibly present. If the scan is too blurry, dark, cropped, or " +
    "otherwise unreadable to extract fields with confidence, set legible to false and explain " +
    "why in legibilityIssue instead of guessing at the content.";

  const parsed = await callOpenAiForJson({ apiKey, promptText, fileBytes: base64, mimeType, isPdf });
  return validateExtractedFields(parsed);
}

/** Shared request/parse plumbing for both extractDocumentFields and
 *  extractApplicantProfile below -- each caller supplies its own prompt and
 *  validates the shape it gets back itself. */
async function callOpenAiForJson({
  apiKey,
  promptText,
  fileBytes,
  mimeType,
  isPdf,
}: {
  apiKey: string;
  promptText: string;
  fileBytes: string;
  mimeType: string;
  isPdf: boolean;
}): Promise<unknown> {
  const fileContent = isPdf
    ? { type: "input_file", filename: "document.pdf", file_data: `data:${mimeType};base64,${fileBytes}` }
    : { type: "input_image", image_url: `data:${mimeType};base64,${fileBytes}` };

  const response = await fetch("https://api.openai.com/v1/responses", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${apiKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      model: Deno.env.get("OPENAI_MODEL") || DEFAULT_MODEL,
      input: [
        {
          role: "user",
          content: [{ type: "input_text", text: promptText }, fileContent],
        },
      ],
      text: {
        format: { type: "json_object" },
      },
    }),
  });

  if (!response.ok) {
    const body = await response.text();
    throw new Error(`OpenAI request failed (${response.status}): ${body}`);
  }

  const payload = await response.json();
  const rawText = typeof payload.output_text === "string" ? payload.output_text : findOutputText(payload);
  if (!rawText) {
    throw new Error("OpenAI response did not contain any output text");
  }

  try {
    return JSON.parse(rawText);
  } catch {
    throw new Error("OpenAI response was not valid JSON");
  }
}

/** Fallback for when output_text isn't present at the top level -- walks the
 *  Responses API's output array to find the first text content part. */
function findOutputText(payload: unknown): string | null {
  if (typeof payload !== "object" || payload === null || !("output" in payload)) return null;
  const output = (payload as { output: unknown }).output;
  if (!Array.isArray(output)) return null;
  for (const item of output) {
    if (typeof item !== "object" || item === null || !("content" in item)) continue;
    const content = (item as { content: unknown }).content;
    if (!Array.isArray(content)) continue;
    for (const part of content) {
      if (typeof part === "object" && part !== null && typeof (part as { text?: unknown }).text === "string") {
        return (part as { text: string }).text;
      }
    }
  }
  return null;
}

/**
 * Anti-hallucination rule 9 (AI extracts, code decides) starts here: the
 * model's raw output is only ever trusted after every field is confirmed
 * to have the right shape. Anything malformed throws rather than being
 * coerced or silently dropped.
 */
function validateExtractedFields(value: unknown): ExtractedDocumentFields {
  if (typeof value !== "object" || value === null) {
    throw new Error("OpenAI response was not a JSON object");
  }
  const v = value as Record<string, unknown>;

  const documentType = v.documentType;
  const detectedName = v.detectedName;
  const detectedDates = v.detectedDates;
  const keyValues = v.keyValues;
  const legible = v.legible;
  const legibilityIssue = v.legibilityIssue;
  const matchesDocumentType = v.matchesDocumentType;
  const documentTypeMismatchReason = v.documentTypeMismatchReason;

  if (documentType !== null && typeof documentType !== "string") {
    throw new Error("OpenAI response field documentType had an unexpected shape");
  }
  if (detectedName !== null && typeof detectedName !== "string") {
    throw new Error("OpenAI response field detectedName had an unexpected shape");
  }
  if (!Array.isArray(detectedDates) || detectedDates.some((d) => typeof d !== "string")) {
    throw new Error("OpenAI response field detectedDates had an unexpected shape");
  }
  if (
    typeof keyValues !== "object" ||
    keyValues === null ||
    Array.isArray(keyValues) ||
    Object.values(keyValues).some((val) => typeof val !== "string")
  ) {
    throw new Error("OpenAI response field keyValues had an unexpected shape");
  }
  if (typeof legible !== "boolean") {
    throw new Error("OpenAI response field legible had an unexpected shape");
  }
  if (legibilityIssue !== null && typeof legibilityIssue !== "string") {
    throw new Error("OpenAI response field legibilityIssue had an unexpected shape");
  }
  if (typeof matchesDocumentType !== "boolean") {
    throw new Error("OpenAI response field matchesDocumentType had an unexpected shape");
  }
  if (documentTypeMismatchReason !== null && typeof documentTypeMismatchReason !== "string") {
    throw new Error("OpenAI response field documentTypeMismatchReason had an unexpected shape");
  }

  return {
    documentType,
    detectedName,
    detectedDates: detectedDates as string[],
    keyValues: keyValues as Record<string, string>,
    legible,
    legibilityIssue,
    matchesDocumentType,
    documentTypeMismatchReason,
  };
}

const PROFILE_SHAPE_DESCRIPTION = `{
  "summary": string or null — a one or two sentence professional summary, only if the CV states or clearly implies one,
  "workExperience": array of { "company": string, "title": string, "startDate": string or null, "endDate": string or null, "description": string or null },
  "education": array of { "institution": string, "degree": string, "fieldOfStudy": string or null, "startDate": string or null, "endDate": string or null },
  "skills": string[] — individual skills listed on the CV,
  "certifications": array of { "name": string, "issuer": string or null, "date": string or null }
}`;

/**
 * The foundation for a real applicant profile, pulled from a reviewed CV --
 * not the job-matching/soft-landing feature itself (that needs a real job
 * listings source and matching logic, which don't exist yet), just the
 * actual structured extraction and storage. Only ever called for a
 * document that's already been confirmed legible and the right type by
 * extractDocumentFields -- there's no point profiling an illegible file or
 * one that isn't actually a CV.
 */
export async function extractApplicantProfile({
  fileBytes,
  mimeType,
}: {
  fileBytes: Uint8Array;
  mimeType: string;
}): Promise<ApplicantProfileExtraction> {
  const apiKey = Deno.env.get("OPENAI_API_KEY");
  if (!apiKey) {
    throw new NotConfiguredError("OPENAI_API_KEY is not set — profile extraction isn't connected yet.");
  }

  const isPdf = mimeType === "application/pdf";
  const base64 = encodeBase64(fileBytes);
  const promptText =
    "This is a skilled-migration applicant's CV/resume. Extract their work experience, " +
    "education, skills, and certifications, to help build their profile for later use in " +
    "job applications. Only report what is actually printed on the CV -- never invent an " +
    "employer, dates, a skill, or a qualification that isn't legibly present. If a field " +
    "genuinely isn't on the CV, leave it null or an empty array/list rather than guessing.\n\n" +
    `Respond with ONLY a single JSON object, no other text, matching exactly this shape:\n${PROFILE_SHAPE_DESCRIPTION}`;

  const parsed = await callOpenAiForJson({ apiKey, promptText, fileBytes: base64, mimeType, isPdf });
  return validateApplicantProfile(parsed);
}

function validateApplicantProfile(value: unknown): ApplicantProfileExtraction {
  if (typeof value !== "object" || value === null) {
    throw new Error("OpenAI profile response was not a JSON object");
  }
  const v = value as Record<string, unknown>;

  const summary = v.summary;
  if (summary !== null && summary !== undefined && typeof summary !== "string") {
    throw new Error("OpenAI profile response field summary had an unexpected shape");
  }

  const workExperience = validateArray(v.workExperience, "workExperience", (entry): WorkExperienceEntry => {
    const e = requireObject(entry, "workExperience entry");
    return {
      company: requireString(e.company, "workExperience.company"),
      title: requireString(e.title, "workExperience.title"),
      startDate: optionalString(e.startDate, "workExperience.startDate"),
      endDate: optionalString(e.endDate, "workExperience.endDate"),
      description: optionalString(e.description, "workExperience.description"),
    };
  });

  const education = validateArray(v.education, "education", (entry): EducationEntry => {
    const e = requireObject(entry, "education entry");
    return {
      institution: requireString(e.institution, "education.institution"),
      degree: requireString(e.degree, "education.degree"),
      fieldOfStudy: optionalString(e.fieldOfStudy, "education.fieldOfStudy"),
      startDate: optionalString(e.startDate, "education.startDate"),
      endDate: optionalString(e.endDate, "education.endDate"),
    };
  });

  const skillsRaw = v.skills;
  if (!Array.isArray(skillsRaw) || skillsRaw.some((s) => typeof s !== "string")) {
    throw new Error("OpenAI profile response field skills had an unexpected shape");
  }

  const certifications = validateArray(v.certifications, "certifications", (entry): CertificationEntry => {
    const e = requireObject(entry, "certifications entry");
    return {
      name: requireString(e.name, "certifications.name"),
      issuer: optionalString(e.issuer, "certifications.issuer"),
      date: optionalString(e.date, "certifications.date"),
    };
  });

  return {
    summary: (summary as string | null) ?? null,
    workExperience,
    education,
    skills: skillsRaw as string[],
    certifications,
  };
}

function validateArray<T>(value: unknown, field: string, mapEntry: (entry: unknown) => T): T[] {
  if (!Array.isArray(value)) {
    throw new Error(`OpenAI profile response field ${field} had an unexpected shape`);
  }
  return value.map(mapEntry);
}

function requireObject(value: unknown, field: string): Record<string, unknown> {
  if (typeof value !== "object" || value === null || Array.isArray(value)) {
    throw new Error(`OpenAI profile response ${field} had an unexpected shape`);
  }
  return value as Record<string, unknown>;
}

function requireString(value: unknown, field: string): string {
  if (typeof value !== "string") {
    throw new Error(`OpenAI profile response field ${field} had an unexpected shape`);
  }
  return value;
}

function optionalString(value: unknown, field: string): string | null {
  if (value === null || value === undefined) return null;
  if (typeof value !== "string") {
    throw new Error(`OpenAI profile response field ${field} had an unexpected shape`);
  }
  return value;
}
