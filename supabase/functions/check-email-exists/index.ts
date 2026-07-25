import { corsHeaders } from "../_shared/cors.ts";
import { supabaseAdmin } from "../_shared/supabase_admin.ts";

/**
 * Used by the forgot-password flow to tell someone clearly when there's no
 * account for the email they typed, instead of the generic "check your
 * email" every provider shows regardless.
 *
 * Worth being explicit about the tradeoff this makes: most auth systems
 * deliberately don't reveal whether an email is registered, specifically
 * to prevent attackers from harvesting valid accounts (user enumeration).
 * This app is choosing clarity over that protection for now — revisit
 * before this ever handles real production users.
 */
Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  if (req.method !== "POST") {
    return jsonResponse({ error: "Method not allowed" }, 405);
  }

  try {
    const { email } = await req.json();
    if (!email || typeof email !== "string") {
      return jsonResponse({ error: "email is required" }, 400);
    }

    const admin = supabaseAdmin();
    // generateLink errors when there's no user for this email — that's
    // the check. The generated link itself is discarded; a real reset
    // email is only ever sent by the client's own resetPasswordForEmail
    // call, after this confirms the account exists.
    const { error } = await admin.auth.admin.generateLink({
      type: "recovery",
      email,
    });

    return jsonResponse({ exists: !error });
  } catch (error) {
    console.error("check-email-exists failed", error);
    return jsonResponse({ error: "Internal error" }, 500);
  }
});

function jsonResponse(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}
