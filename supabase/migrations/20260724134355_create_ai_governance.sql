-- The two tables that make the anti-hallucination rules real rather than
-- just prompt text: every AI call is logged, and every proposed registry
-- change waits for review before it touches live data.

-- Written only by Edge Functions (service role) — there is deliberately no
-- insert/update policy for the authenticated role, so the client can never
-- write an audit entry, only read its own.
create table public.ai_audit_log (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users (id) on delete set null,
  feature text not null, -- e.g. 'document_review', 'registry_verification'
  model text not null,
  prompt text not null,
  retrieved_sources jsonb not null default '[]'::jsonb,
  output jsonb not null,
  confidence text,
  created_at timestamptz not null default now()
);

alter table public.ai_audit_log enable row level security;

create policy "Users can view their own audit entries"
  on public.ai_audit_log for select
  using (auth.uid() = user_id);

-- Proposed changes from the verification agent, awaiting human approval.
-- The agent inserts rows here; nothing in registration_requirements or
-- occupation_ledger changes until someone approves one (application code,
-- not this migration, does that update — kept out of SQL so the approval
-- action is auditable at the application layer too).
create table public.registry_review_queue (
  id uuid primary key default gen_random_uuid(),
  entry_table text not null check (entry_table in ('registration_requirements', 'occupation_ledger')),
  entry_id uuid,
  target_country text not null,
  occupation_or_category text not null,
  proposed_change jsonb not null,
  source_url text not null,
  source_excerpt text not null,
  status text not null default 'pending' check (status in ('pending', 'approved', 'rejected')),
  created_at timestamptz not null default now(),
  reviewed_at timestamptz,
  reviewed_by uuid references auth.users (id)
);

alter table public.registry_review_queue enable row level security;

-- No policies at all yet, intentionally — RLS with zero policies denies
-- every non-service-role request by default. A real "reviewer" role and
-- its policy get added once that role exists in the app; until then this
-- queue is service-role/admin-only, which is the correct default for an
-- internal moderation surface with no UI yet.
