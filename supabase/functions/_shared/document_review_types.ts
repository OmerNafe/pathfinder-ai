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
}

export interface DocumentReviewResult {
  extracted: ExtractedDocumentFields;
  /** "uncertain" is a real, first-class outcome — never forced to true/false
   *  when the deterministic comparison genuinely can't tell yet. */
  matchesRequirement: boolean | "uncertain";
  mismatchReason: string | null;
  confidence: "high" | "medium" | "low";
}
