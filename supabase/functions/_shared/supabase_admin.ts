import { createClient } from "jsr:@supabase/supabase-js@2";

/**
 * Service-role client — bypasses Row-Level Security. Only ever imported
 * inside Edge Functions; nothing the Flutter client can reach ever sees
 * this key (see supabase/functions/.env.example).
 *
 * SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY are auto-injected by the
 * Edge Functions runtime for every deployed/served function — they don't
 * need to be set manually in supabase/functions/.env.
 */
export function supabaseAdmin() {
  const url = Deno.env.get("SUPABASE_URL")!;
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  return createClient(url, serviceRoleKey, {
    auth: { autoRefreshToken: false, persistSession: false },
  });
}
