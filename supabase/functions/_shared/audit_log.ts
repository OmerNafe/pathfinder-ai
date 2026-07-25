import { supabaseAdmin } from "./supabase_admin.ts";

export interface AuditLogEntry {
  userId: string | null;
  feature: string;
  model: string;
  prompt: string;
  retrievedSources: unknown[];
  output: unknown;
  confidence?: string | null;
}

/**
 * Every AI call, logged — anti-hallucination rule 6. Every Edge Function
 * that makes a model call goes through this, not an ad-hoc console.log.
 * Failing to log is a warning, not a thrown error — a broken audit write
 * must never take down the actual feature the user is waiting on.
 */
export async function logAiCall(entry: AuditLogEntry): Promise<void> {
  const admin = supabaseAdmin();
  const { error } = await admin.from("ai_audit_log").insert({
    user_id: entry.userId,
    feature: entry.feature,
    model: entry.model,
    prompt: entry.prompt,
    retrieved_sources: entry.retrievedSources,
    output: entry.output,
    confidence: entry.confidence ?? null,
  });
  if (error) {
    console.error("Failed to write AI audit log entry", error);
  }
}
