import { corsHeaders } from "../_shared/cors.ts";
import { supabaseAdmin } from "../_shared/supabase_admin.ts";
import { NotConfiguredError as EmailNotConfiguredError, sendEmail } from "../_shared/email_client.ts";
import { NotConfiguredError as PushNotConfiguredError, sendPush } from "../_shared/fcm_client.ts";

const INACTIVITY_THRESHOLD_DAYS = 7;

// The supabase-js query-string type parser doesn't resolve a proper shape
// for 3 embedded relations in one select (falls back to a useless
// error-ish type) -- the runtime response is exactly this shape, so an
// explicit interface + cast sidesteps that rather than fighting it.
interface CandidateRow {
  user_id: string;
  occupation: string;
  target_country: string;
  profiles:
    | { email_notifications: boolean; push_notifications: boolean }
    | { email_notifications: boolean; push_notifications: boolean }[];
  growth_state: { last_action_date: string | null } | { last_action_date: string | null }[] | null;
  push_tokens: { token: string }[];
}

/**
 * Meant to run on a schedule (see the Supabase Dashboard's Cron UI, or a
 * pg_cron job calling this via net.http_post) — not invoked by the
 * Flutter app directly. Finds real candidates (opted in, pathway set up,
 * genuinely inactive) and attempts a real send for each, on whichever
 * channel(s) they've opted into independently. Until a provider is
 * configured, every send honestly no-ops via its own NotConfiguredError
 * rather than pretending to have delivered anything — the
 * candidate-selection logic itself is real and ready to go live the
 * moment provider credentials exist.
 *
 * Security audit finding: this function was deployed with --no-verify-jwt
 * (it has no end user to authenticate — it's triggered by a scheduler, not
 * the app) but had *no* auth check of its own, so anyone with the URL
 * could invoke it directly, repeatedly, for free: reading how many users
 * are inactive, and — once an email/push provider is configured — mass-
 * messaging every one of them on demand. It now requires a shared secret
 * the scheduler sends and the client never sees, matching the same
 * fail-closed "not configured" pattern used everywhere else in this file
 * rather than defaulting open when unset.
 */
Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  if (req.method !== "POST") {
    return jsonResponse({ error: "Method not allowed" }, 405);
  }

  const cronSecret = Deno.env.get("CRON_SECRET");
  if (!cronSecret) {
    console.error("send-reminders: CRON_SECRET is not set — refusing to run.");
    return jsonResponse({ error: "This endpoint is not configured to run yet." }, 503);
  }
  if (req.headers.get("x-cron-secret") !== cronSecret) {
    return jsonResponse({ error: "Unauthorized" }, 401);
  }

  try {
    const admin = supabaseAdmin();

    const { data: rawCandidates, error } = await admin
      .from("pathways")
      .select(
        "user_id, occupation, target_country, " +
          "profiles!inner(email_notifications, push_notifications), " +
          "growth_state(last_action_date), push_tokens(token)",
      )
      .eq("has_completed_setup", true);

    if (error) {
      console.error("send-reminders candidate query failed", error);
      return jsonResponse({ error: "Internal error" }, 500);
    }

    const candidates = (rawCandidates ?? []) as unknown as CandidateRow[];

    const threshold = new Date();
    threshold.setDate(threshold.getDate() - INACTIVITY_THRESHOLD_DAYS);

    const inactive = candidates.filter((row) => {
      const growth = Array.isArray(row.growth_state) ? row.growth_state[0] : row.growth_state;
      const lastActionDate: string | null = growth?.last_action_date ?? null;
      if (!lastActionDate) return true;
      return new Date(lastActionDate) < threshold;
    });

    let emailSent = 0;
    let emailNotConfigured = 0;
    let emailFailed = 0;
    let pushSent = 0;
    let pushNotConfigured = 0;
    let pushFailed = 0;

    for (const candidate of inactive) {
      const profile = Array.isArray(candidate.profiles) ? candidate.profiles[0] : candidate.profiles;
      const message =
        `You haven't checked in on your ${candidate.occupation} → ${candidate.target_country} ` +
        "pathway in a while. Pick up where you left off — your document checklist and gaps are " +
        "exactly as you left them.";

      if (profile?.email_notifications) {
        const { data: userData, error: userError } = await admin.auth.admin.getUserById(
          candidate.user_id,
        );
        const email = userData?.user?.email;
        if (!userError && email) {
          try {
            await sendEmail({ to: email, subject: "Your PathFinder pathway is waiting", body: message });
            emailSent++;
          } catch (sendError) {
            if (sendError instanceof EmailNotConfiguredError) {
              emailNotConfigured++;
            } else {
              console.error("send-reminders: email failed for a candidate", sendError);
              emailFailed++;
            }
          }
        }
      }

      if (profile?.push_notifications) {
        const tokens = (candidate.push_tokens ?? []) as { token: string }[];
        for (const { token } of tokens) {
          try {
            await sendPush({ deviceToken: token, title: "PathFinder AI", body: message });
            pushSent++;
          } catch (sendError) {
            if (sendError instanceof PushNotConfiguredError) {
              pushNotConfigured++;
            } else {
              console.error("send-reminders: push failed for a candidate", sendError);
              pushFailed++;
            }
          }
        }
      }
    }

    return jsonResponse({
      candidateCount: inactive.length,
      email: { sent: emailSent, notConfigured: emailNotConfigured, failed: emailFailed },
      push: { sent: pushSent, notConfigured: pushNotConfigured, failed: pushFailed },
    });
  } catch (error) {
    console.error("send-reminders failed", error);
    return jsonResponse({ error: "Internal error" }, 500);
  }
});

function jsonResponse(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}
