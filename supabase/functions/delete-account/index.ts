import { createClient } from "jsr:@supabase/supabase-js@2";
import { corsHeaders } from "../_shared/cors.ts";
import { supabaseAdmin } from "../_shared/supabase_admin.ts";

/**
 * Deployed WITH JWT verification on (no --no-verify-jwt) -- unlike the
 * public functions in this project, this one must never run for an
 * unauthenticated caller. The user to delete is always derived from the
 * caller's own token, never from a client-supplied id, so there's no way
 * to delete an account other than your own.
 *
 * All public.* tables reference auth.users(id) with "on delete cascade",
 * so deleting the auth user removes every row this applicant ever
 * created. Storage objects aren't covered by that cascade, so they're
 * removed explicitly first.
 */
Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  // A destructive action must never be reachable via GET -- a GET can be
  // triggered by an <img> tag, link prefetching, or a browser extension
  // without real user intent, no attacker-controlled Authorization header
  // required.
  if (req.method !== "POST") {
    return jsonResponse({ error: "Method not allowed" }, 405);
  }

  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return jsonResponse({ error: "Missing authorization" }, 401);
    }

    const callerClient = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_ANON_KEY")!,
      { global: { headers: { Authorization: authHeader } } },
    );
    const { data: { user }, error: userError } = await callerClient.auth.getUser();
    if (userError || !user) {
      return jsonResponse({ error: "Not authenticated" }, 401);
    }

    const admin = supabaseAdmin();

    for (const bucket of ["avatars", "documents"]) {
      const { data: files } = await admin.storage.from(bucket).list(user.id);
      if (files && files.length > 0) {
        const paths = files.map((f) => `${user.id}/${f.name}`);
        await admin.storage.from(bucket).remove(paths);
      }
    }

    const { error: deleteError } = await admin.auth.admin.deleteUser(user.id);
    if (deleteError) {
      console.error("delete-account: deleteUser failed", deleteError);
      return jsonResponse({ error: "Could not delete your account right now." }, 500);
    }

    return jsonResponse({ success: true });
  } catch (error) {
    console.error("delete-account failed", error);
    return jsonResponse({ error: "Internal error" }, 500);
  }
});

function jsonResponse(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}
