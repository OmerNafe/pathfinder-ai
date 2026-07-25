import type { ExtractedDocumentFields } from "./document_review_types.ts";

export class NotConfiguredError extends Error {}

/**
 * The one function every caller uses for extraction — swapping the stub
 * below for a real OpenAI call (once OPENAI_API_KEY exists) means editing
 * this file only. Nothing that calls extractDocumentFields needs to change.
 */
export async function extractDocumentFields(_params: {
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

  // Real implementation goes here once a key exists: send fileBytes to a
  // vision-capable OpenAI model with a prompt requesting exactly the
  // ExtractedDocumentFields shape via structured output (e.g.
  // response_format: { type: "json_schema", schema: ... }), then validate
  // the parsed response actually matches that shape before returning it —
  // never trust unvalidated model output as if it already conforms.
  await Promise.resolve();
  throw new NotConfiguredError("OpenAI integration not yet implemented.");
}
