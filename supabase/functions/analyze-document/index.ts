import { corsHeaders } from "../_shared/cors.ts";
import { supabaseAdmin } from "../_shared/supabase_admin.ts";
import { extractDocumentFields, NotConfiguredError } from "../_shared/openai_client.ts";
import { compareExtractedDocument } from "../_shared/compare_document.ts";
import { logAiCall } from "../_shared/audit_log.ts";

/**
 * Phase 1 — turns "documents saved" into real feedback. Takes a
 * documentId (already uploaded to Storage by the client), runs it through
 * AI extraction + deterministic comparison, and writes the result back
 * onto the documents row for the client to read.
 *
 * Every exit path sets ai_review_status to something real
 * (reviewing/reviewed/failed) — there is no code path that leaves a
 * document silently stuck or fakes a "reviewed" result without one.
 */
Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  // Triggers a real (billed, once configured) AI call -- never reachable
  // via GET.
  if (req.method !== "POST") {
    return jsonResponse({ error: "Method not allowed" }, 405);
  }

  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return jsonResponse({ error: "Missing Authorization header" }, 401);
    }

    const admin = supabaseAdmin();
    const jwt = authHeader.replace("Bearer ", "");
    const { data: userData, error: userError } = await admin.auth.getUser(jwt);
    if (userError || !userData.user) {
      return jsonResponse({ error: "Invalid session" }, 401);
    }
    const userId = userData.user.id;

    const { documentId } = await req.json();
    if (!documentId) {
      return jsonResponse({ error: "documentId is required" }, 400);
    }

    // Scoped to the caller's own user_id even though this is the
    // service-role client — never review (or leak) someone else's upload.
    const { data: doc, error: docError } = await admin
      .from("documents")
      .select("*")
      .eq("id", documentId)
      .eq("user_id", userId)
      .single();

    if (docError || !doc) {
      return jsonResponse({ error: "Document not found" }, 404);
    }

    await admin.from("documents").update({ ai_review_status: "reviewing" }).eq("id", documentId);

    const { data: fileBlob, error: downloadError } = await admin.storage
      .from("documents")
      .download(doc.storage_path);

    if (downloadError || !fileBlob) {
      await admin.from("documents").update({ ai_review_status: "failed" }).eq("id", documentId);
      return jsonResponse({ error: "Could not read the uploaded file" }, 500);
    }

    const fileBytes = new Uint8Array(await fileBlob.arrayBuffer());

    let extracted;
    try {
      extracted = await extractDocumentFields({
        fileBytes,
        mimeType: fileBlob.type,
        requirementDescription: doc.requirement_id,
      });
    } catch (e) {
      if (e instanceof NotConfiguredError) {
        await admin.from("documents").update({
          ai_review_status: "failed",
          ai_review_result: { error: e.message },
        }).eq("id", documentId);
        // 503, not 200 — a stubbed feature must never look like a
        // successful review to the client.
        return jsonResponse({ error: e.message, configured: false }, 503);
      }
      // A real extraction failure (OpenAI request/parsing error) must also
      // leave the document in a terminal, honest state — not stuck on
      // "reviewing" forever, which is what happened here before this
      // branch existed.
      console.error("analyze-document: extraction failed", e);
      const message = "AI review failed — please try again.";
      await admin.from("documents").update({
        ai_review_status: "failed",
        ai_review_result: { error: message },
      }).eq("id", documentId);
      return jsonResponse({ error: message }, 502);
    }

    const result = compareExtractedDocument(extracted);

    await logAiCall({
      userId,
      feature: "document_review",
      model: Deno.env.get("OPENAI_MODEL") || "gpt-4o-mini",
      prompt: `Extract fields for requirement ${doc.requirement_id}`,
      retrievedSources: [],
      output: result,
      confidence: result.confidence,
    });

    await admin.from("documents").update({
      ai_review_status: "reviewed",
      ai_review_result: result,
    }).eq("id", documentId);

    return jsonResponse({ result });
  } catch (error) {
    console.error("analyze-document failed", error);
    return jsonResponse({ error: "Internal error" }, 500);
  }
});

function jsonResponse(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}
