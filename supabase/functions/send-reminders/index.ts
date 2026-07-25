import { corsHeaders } from "../_shared/cors.ts";
import { supabaseAdmin } from "../_shared/supabase_admin.ts";
import { NotConfiguredError, sendEmail } from "../_shared/email_client.ts";

const INACTIVITY_THRESHOLD_DAYS = 7;

/**
 * Meant to run on a schedule (see the Supabase Dashboard's Cron UI, or a
 * pg_cron job calling this via net.http_post) — not invoked by the
 * Flutter app directly. Finds real candidates (opted in, pathway set up,
 * genuinely inactive) and attempts a real send for each. Until an email
 * provider is configured, every send honestly no-ops via
 * NotConfiguredError rather than pretending to have delivered anything —
 * the candidate-selection logic itself is real and ready to go live the
 * moment a provider key exists.
 */
Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const admin = supabaseAdmin();

    const { data: candidates, error } = await admin
      .from("pathways")
      .select(
        "user_id, occupation, target_country, profiles!inner(email_notifications), growth_state(last_action_date)",
      )
      .eq("has_completed_setup", true)
      .eq("profiles.email_notifications", true);

    if (error) {
      console.error("send-reminders candidate query failed", error);
      return jsonResponse({ error: "Internal error" }, 500);
    }

    const threshold = new Date();
    threshold.setDate(threshold.getDate() - INACTIVITY_THRESHOLD_DAYS);

    const inactive = (candidates ?? []).filter((row) => {
      const growth = Array.isArray(row.growth_state) ? row.growth_state[0] : row.growth_state;
      const lastActionDate: string | null = growth?.last_action_date ?? null;
      if (!lastActionDate) return true;
      return new Date(lastActionDate) < threshold;
    });

    let sent = 0;
    let notConfigured = 0;
    let failed = 0;

    for (const candidate of inactive) {
      const { data: userData, error: userError } = await admin.auth.admin.getUserById(
        candidate.user_id,
      );
      const email = userData?.user?.email;
      if (userError || !email) continue;

      try {
        await sendEmail({
          to: email,
          subject: "Your PathFinder pathway is waiting",
          body:
            `You haven't checked in on your ${candidate.occupation} → ${candidate.target_country} ` +
            "pathway in a while. Pick up where you left off — your document checklist and gaps " +
            "are exactly as you left them.",
        });
        sent++;
      } catch (sendError) {
        if (sendError instanceof NotConfiguredError) {
          notConfigured++;
        } else {
          console.error("send-reminders: send failed for a candidate", sendError);
          failed++;
        }
      }
    }

    return jsonResponse({
      candidateCount: inactive.length,
      sent,
      notConfigured,
      failed,
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
