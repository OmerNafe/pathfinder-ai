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

  return {
    extracted,
    matchesRequirement: "uncertain",
    mismatchReason: null,
    confidence: "medium",
  };
}
