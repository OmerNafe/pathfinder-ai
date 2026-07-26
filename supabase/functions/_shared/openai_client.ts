import { encodeBase64 } from "jsr:@std/encoding@1/base64";
import type { ExtractedDocumentFields } from "./document_review_types.ts";

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
  "documentType": string or null — a short label, e.g. "passport", "degree transcript",
  "detectedName": string or null — the full name printed on the document, if visible,
  "detectedDates": string[] — every date printed on the document, as it appears,
  "keyValues": object mapping string to string — other labeled fields visible, e.g. institution, credential number, issuing body,
  "legible": boolean — false if the document is too blurry, dark, cropped, or corrupted to read reliably,
  "legibilityIssue": string or null — plain-English reason when legible is false, null when legible is true
}`;

/**
 * The only function every caller uses for extraction. Sends the uploaded
 * file to a vision-capable OpenAI model via the Responses API, constrained
 * to the ExtractedDocumentFields shape with a JSON schema, then validates
 * the parsed response field-by-field before returning it -- the model's
 * output is never trusted just because it parsed as JSON.
 */
export async function extractDocumentFields({
  fileBytes,
  mimeType,
  requirementDescription,
}: {
  fileBytes: Uint8Array;
  mimeType: string;
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
    };
  }

  const base64 = encodeBase64(fileBytes);
  const promptText =
    "You are reviewing a document a skilled-migration applicant uploaded to satisfy this " +
    `requirement: "${requirementDescription}". Respond with ONLY a single JSON object, no ` +
    `other text, matching exactly this shape:\n${SHAPE_DESCRIPTION}\n\n` +
    "Only report what is actually visible on the document -- never guess or invent a name, " +
    "date, or value that isn't legibly present. If the scan is too blurry, dark, cropped, or " +
    "otherwise unreadable to extract fields with confidence, set legible to false and explain " +
    "why in legibilityIssue instead of guessing at the content.";

  const fileContent = isPdf
    ? { type: "input_file", filename: "document.pdf", file_data: `data:${mimeType};base64,${base64}` }
    : { type: "input_image", image_url: `data:${mimeType};base64,${base64}` };

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

  let parsed: unknown;
  try {
    parsed = JSON.parse(rawText);
  } catch {
    throw new Error("OpenAI response was not valid JSON");
  }

  return validateExtractedFields(parsed);
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

  return {
    documentType,
    detectedName,
    detectedDates: detectedDates as string[],
    keyValues: keyValues as Record<string, string>,
    legible,
    legibilityIssue,
  };
}
