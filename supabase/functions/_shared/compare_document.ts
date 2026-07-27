import type { DocumentReviewResult, ExtractedDocumentFields } from "./document_review_types.ts";

/**
 * The deterministic half of document review — anti-hallucination rule 9
 * (AI extracts, code decides). Takes whatever the model extracted and
 * applies plain comparison logic; never asks a model to judge pass/fail
 * for itself. This is the function the golden-set test in
 * compare_document.test.ts locks in place.
 *
 * Deliberately conservative for this first pass: a legible document is
 * "uncertain", not auto-approved — real pass/fail needs the actual
 * requirement schema (band scores, credit hours, etc.) compared field by
 * field, which lands with the registry migration, not this function.
 */
export function compareExtractedDocument(extracted: ExtractedDocumentFields): DocumentReviewResult {
  if (!extracted.legible) {
    return {
      extracted,
      matchesRequirement: false,
      mismatchReason: extracted.legibilityIssue ?? "Document is not legible.",
      confidence: "high",
    };
  }

  // A legible file that's simply the wrong kind of document (a CV where a
  // certificate was asked for, an unrelated photo, someone else's
  // paperwork) is a real, definite failure -- not "uncertain". Only a
  // legible file that actually looks like what was asked for is
  // provisional.
  if (!extracted.matchesDocumentType) {
    return {
      extracted,
      matchesRequirement: false,
      mismatchReason: extracted.documentTypeMismatchReason ??
        "This doesn't look like the document this requirement asks for.",
      confidence: "high",
    };
  }

  return {
    extracted,
    matchesRequirement: "uncertain",
    mismatchReason: null,
    confidence: "medium",
  };
}
