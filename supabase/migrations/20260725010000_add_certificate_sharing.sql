-- Publishing a certificate is a deliberate, explicit action (like a real
-- certificate) rather than a live-mutating feed a stranger could scrub
-- through — the applicant's own client computes a real snapshot of their
-- current, genuine progress and writes it here; the public viewer only
-- ever reads this stored snapshot, never live per-user data directly.
alter table public.pathways
  add column share_token text unique,
  add column certificate_snapshot jsonb,
  add column certificate_published_at timestamptz;

-- Public lookups go through the get-public-certificate Edge Function
-- (service role), never direct table access — no public SELECT policy is
-- added here, so an anonymous visitor still can't query pathways directly
-- even if they had a token.
create index pathways_share_token_idx on public.pathways (share_token);
