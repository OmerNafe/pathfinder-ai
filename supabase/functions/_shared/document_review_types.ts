/**
 * The only shape a document-review result is allowed to take —
 * anti-hallucination rule 2 (structured output only for anything
 * factual). The model is asked to fill exactly this shape; anything that
 * doesn't parse into it is a failure, not a creative response to accept.
 */
export interface ExtractedDocumentFields {
  documentType: string | null;
  detectedName: string | null;
  detectedDates: string[];
  keyValues: Record<string, string>;
  legible: boolean;
  legibilityIssue: string | null;
  /** Whether what's visible actually looks like the kind of document this
   *  specific checklist item asked for -- e.g. a CV uploaded where a
   *  degree certificate was requested, or an unrelated photo, both come
   *  back false here. This is what stops the review from accepting any
   *  legible file as satisfying any requirement. */
  matchesDocumentType: boolean;
  documentTypeMismatchReason: string | null;
}

export interface DocumentReviewResult {
  extracted: ExtractedDocumentFields;
  /** "uncertain" is a real, first-class outcome — never forced to true/false
   *  when the deterministic comparison genuinely can't tell yet. */
  matchesRequirement: boolean | "uncertain";
  mismatchReason: string | null;
  confidence: "high" | "medium" | "low";
}

export interface WorkExperienceEntry {
  company: string;
  title: string;
  startDate: string | null;
  endDate: string | null;
  description: string | null;
}

export interface EducationEntry {
  institution: string;
  degree: string;
  fieldOfStudy: string | null;
  startDate: string | null;
  endDate: string | null;
}

export interface CertificationEntry {
  name: string;
  issuer: string | null;
  date: string | null;
}

/**
 * The foundation for the applicant profile pulled from a reviewed CV —
 * real, structured data extraction, not the job-matching feature itself
 * (that needs a job-listings source and matching logic that don't exist
 * yet). Every entry here is only ever what's actually printed on the CV,
 * same "never invent it" rule as document review.
 */
export interface ApplicantProfileExtraction {
  summary: string | null;
  workExperience: WorkExperienceEntry[];
  education: EducationEntry[];
  skills: string[];
  certifications: CertificationEntry[];
}
