import { assertEquals } from "jsr:@std/assert@1";
import { compareExtractedDocument } from "./compare_document.ts";
import type { ExtractedDocumentFields, DocumentReviewResult } from "./document_review_types.ts";

/**
 * Anti-hallucination rule 8 — a golden set that gates every change to
 * compare_document.ts. If a change to that file breaks any case below,
 * that's a regression to fix, not a test to delete.
 */
const cases: { name: string; input: ExtractedDocumentFields; expected: DocumentReviewResult }[] = [
  {
    name: "illegible scan is flagged as a non-match, not silently passed",
    input: {
      documentType: "transcript",
      detectedName: null,
      detectedDates: [],
      keyValues: {},
      legible: false,
      legibilityIssue: "Image too blurry to read",
      matchesDocumentType: true,
      documentTypeMismatchReason: null,
    },
    expected: {
      extracted: {
        documentType: "transcript",
        detectedName: null,
        detectedDates: [],
        keyValues: {},
        legible: false,
        legibilityIssue: "Image too blurry to read",
        matchesDocumentType: true,
        documentTypeMismatchReason: null,
      },
      matchesRequirement: false,
      mismatchReason: "Image too blurry to read",
      confidence: "high",
    },
  },
  {
    name: "illegible with no reason still gets a real fallback message",
    input: {
      documentType: null,
      detectedName: null,
      detectedDates: [],
      keyValues: {},
      legible: false,
      legibilityIssue: null,
      matchesDocumentType: true,
      documentTypeMismatchReason: null,
    },
    expected: {
      extracted: {
        documentType: null,
        detectedName: null,
        detectedDates: [],
        keyValues: {},
        legible: false,
        legibilityIssue: null,
        matchesDocumentType: true,
        documentTypeMismatchReason: null,
      },
      matchesRequirement: false,
      mismatchReason: "Document is not legible.",
      confidence: "high",
    },
  },
  {
    name: "legible but wrong kind of document is a real failure, not uncertain",
    input: {
      documentType: "CV / resume",
      detectedName: "Jordan Alvarez",
      detectedDates: [],
      keyValues: {},
      legible: true,
      legibilityIssue: null,
      matchesDocumentType: false,
      documentTypeMismatchReason: "This is a CV, not a degree certificate.",
    },
    expected: {
      extracted: {
        documentType: "CV / resume",
        detectedName: "Jordan Alvarez",
        detectedDates: [],
        keyValues: {},
        legible: true,
        legibilityIssue: null,
        matchesDocumentType: false,
        documentTypeMismatchReason: "This is a CV, not a degree certificate.",
      },
      matchesRequirement: false,
      mismatchReason: "This is a CV, not a degree certificate.",
      confidence: "high",
    },
  },
  {
    name: "type mismatch with no reason still gets a real fallback message",
    input: {
      documentType: "unrelated photo",
      detectedName: null,
      detectedDates: [],
      keyValues: {},
      legible: true,
      legibilityIssue: null,
      matchesDocumentType: false,
      documentTypeMismatchReason: null,
    },
    expected: {
      extracted: {
        documentType: "unrelated photo",
        detectedName: null,
        detectedDates: [],
        keyValues: {},
        legible: true,
        legibilityIssue: null,
        matchesDocumentType: false,
        documentTypeMismatchReason: null,
      },
      matchesRequirement: false,
      mismatchReason: "This doesn't look like the document this requirement asks for.",
      confidence: "high",
    },
  },
  {
    name: "legible and the right kind of document is provisionally uncertain, never auto-approved",
    input: {
      documentType: "transcript",
      detectedName: "Jordan Alvarez",
      detectedDates: ["2019-06-01"],
      keyValues: { institution: "University of Example" },
      legible: true,
      legibilityIssue: null,
      matchesDocumentType: true,
      documentTypeMismatchReason: null,
    },
    expected: {
      extracted: {
        documentType: "transcript",
        detectedName: "Jordan Alvarez",
        detectedDates: ["2019-06-01"],
        keyValues: { institution: "University of Example" },
        legible: true,
        legibilityIssue: null,
        matchesDocumentType: true,
        documentTypeMismatchReason: null,
      },
      matchesRequirement: "uncertain",
      mismatchReason: null,
      confidence: "medium",
    },
  },
];

for (const testCase of cases) {
  Deno.test(testCase.name, () => {
    const actual = compareExtractedDocument(testCase.input);
    assertEquals(actual, testCase.expected);
  });
}
