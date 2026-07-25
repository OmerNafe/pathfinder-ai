-- Backs both the Registration Tracker and Licensing Registry checklists —
-- previously in-memory-only Set<String>/Map<String,DateTime?> state that
-- reset on every refresh despite looking like committed progress to the
-- user. One shared shape (namespace distinguishes the two screens) rather
-- than two near-identical tables.
create table public.checklist_progress (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  namespace text not null check (namespace in ('registration', 'licensing')),
  step_key text not null,
  created_at timestamptz not null default now(),
  unique (user_id, namespace, step_key)
);

alter table public.checklist_progress enable row level security;

create policy "Users can view their own checklist progress"
  on public.checklist_progress for select using (auth.uid() = user_id);
create policy "Users can insert their own checklist progress"
  on public.checklist_progress for insert with check (auth.uid() = user_id);
create policy "Users can delete their own checklist progress"
  on public.checklist_progress for delete using (auth.uid() = user_id);

-- Only the Licensing Registry has a distinct "submitted" moment per cell
-- (Registration Tracker has no submit step, just step-by-step ticking).
create table public.checklist_submissions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  cell_key text not null,
  submitted_at timestamptz not null default now(),
  unique (user_id, cell_key)
);

alter table public.checklist_submissions enable row level security;

create policy "Users can view their own checklist submissions"
  on public.checklist_submissions for select using (auth.uid() = user_id);
create policy "Users can insert their own checklist submissions"
  on public.checklist_submissions for insert with check (auth.uid() = user_id);
create policy "Users can delete their own checklist submissions"
  on public.checklist_submissions for delete using (auth.uid() = user_id);
