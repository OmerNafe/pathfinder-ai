-- A real, append-only audit trail of what an applicant actually agreed to
-- and when -- not just "we showed them a link once." Same insert-and-view
-- pattern as ai_audit_log: no update/delete policy for the authenticated
-- role, because an acceptance record that a user could edit or remove
-- after the fact would be worthless as evidence of consent.
create table public.legal_acceptances (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  document text not null check (document in ('terms', 'privacy', 'ai_processing')),
  version text not null,
  accepted_at timestamptz not null default now()
);

alter table public.legal_acceptances enable row level security;

create policy "Users can view their own legal acceptances"
  on public.legal_acceptances for select
  using (auth.uid() = user_id);

create policy "Users can insert their own legal acceptances"
  on public.legal_acceptances for insert
  with check (auth.uid() = user_id);

create index legal_acceptances_user_document_idx
  on public.legal_acceptances (user_id, document, accepted_at desc);
