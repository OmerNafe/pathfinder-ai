-- Shared reference data — the migrated, AI-verifiable version of
-- lib/data/registration_bodies.dart and occupation_registration_ledger.dart.
-- Not user-specific: everyone signed in reads the same rows.
--
-- Deliberately no insert/update/delete policy for the authenticated role.
-- Only the service role (used exclusively inside Edge Functions, never the
-- Flutter client) can write here — and even then, see
-- registry_review_queue in the next migration: the verification agent
-- proposes changes there, it does not write directly to these tables.
-- A human approving a queued proposal is what actually updates these rows.

create table public.registration_requirements (
  id uuid primary key default gen_random_uuid(),
  target_country text not null,
  occupation_category text not null,
  body_name text not null,
  body_full_name text not null default '',
  description text not null,
  applicable boolean not null default true,
  mandatory boolean not null default true,
  confidence text not null default 'directional'
    check (confidence in ('verified', 'directional', 'not_regulated')),
  source_url text,
  source_excerpt text,
  steps jsonb,
  official_url text,
  checked_at timestamptz,
  updated_at timestamptz not null default now(),
  unique (target_country, occupation_category)
);

alter table public.registration_requirements enable row level security;

create policy "Signed-in users can read the registration registry"
  on public.registration_requirements for select
  to authenticated
  using (true);

create trigger set_registration_requirements_updated_at
  before update on public.registration_requirements
  for each row execute function public.set_updated_at();

create table public.occupation_ledger (
  id uuid primary key default gen_random_uuid(),
  occupation text not null,
  target_country text not null,
  body text not null,
  note text,
  confidence text not null default 'directional'
    check (confidence in ('verified', 'directional', 'not_regulated')),
  applicable boolean not null default true,
  mandatory boolean not null default true,
  steps jsonb,
  official_url text,
  source_url text,
  source_excerpt text,
  checked_at timestamptz,
  updated_at timestamptz not null default now(),
  unique (occupation, target_country)
);

alter table public.occupation_ledger enable row level security;

create policy "Signed-in users can read the occupation ledger"
  on public.occupation_ledger for select
  to authenticated
  using (true);

create trigger set_occupation_ledger_updated_at
  before update on public.occupation_ledger
  for each row execute function public.set_updated_at();
