import { corsHeaders } from "../_shared/cors.ts";
import { supabaseAdmin } from "../_shared/supabase_admin.ts";

/**
 * Serves a previously-published certificate snapshot to anyone with the
 * link — deliberately public, no auth required (this function must be
 * deployed with --no-verify-jwt). It only ever reads the stored
 * `certificate_snapshot` jsonb the owner explicitly published via the app
 * (see AuthService-adjacent publishCertificate in pathway_certificate_screen.dart),
 * never live per-user data, and never anything beyond what that snapshot
 * contains — no email, no raw document filenames, no account identifiers.
 */
Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const url = new URL(req.url);
    const token = url.searchParams.get("token");
    if (!token) {
      return jsonResponse({ error: "token is required" }, 400);
    }

    const admin = supabaseAdmin();
    const { data, error } = await admin
      .from("pathways")
      .select("certificate_snapshot, certificate_published_at")
      .eq("share_token", token)
      .maybeSingle();

    if (error) {
      console.error("get-public-certificate lookup failed", error);
      return jsonResponse({ error: "Internal error" }, 500);
    }

    if (!data || !data.certificate_snapshot) {
      return jsonResponse({ error: "No certificate found for this link" }, 404);
    }

    return jsonResponse({
      snapshot: data.certificate_snapshot,
      publishedAt: data.certificate_published_at,
    });
  } catch (error) {
    console.error("get-public-certificate failed", error);
    return jsonResponse({ error: "Internal error" }, 500);
  }
});

function jsonResponse(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}
