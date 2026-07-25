/**
 * The domain allowlist a retrieved source must match before anything can
 * be marked "verified" — anti-hallucination rule 3 (domain allowlisting).
 * Loaded from an env var so it's editable without a redeploy, but the
 * existence of the check itself is not optional or bypassable per-call.
 */
export function getAllowlist(): string[] {
  const raw = Deno.env.get("VERIFIED_SOURCE_DOMAIN_ALLOWLIST") ?? "";
  return raw
    .split(",")
    .map((domain) => domain.trim().toLowerCase())
    .filter(Boolean);
}

export function isAllowlistedSource(url: string): boolean {
  let hostname: string;
  try {
    hostname = new URL(url).hostname.toLowerCase();
  } catch {
    return false;
  }
  return getAllowlist().some((domain) => hostname === domain || hostname.endsWith(`.${domain}`));
}
