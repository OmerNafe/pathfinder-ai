-- Foundation for pulling a real, structured applicant profile out of a
-- reviewed CV -- not the job-matching/soft-landing feature itself (that
-- needs a job-listings data source and matching logic that don't exist
-- yet), just the real data extraction and storage part. One row per user,
-- upserted whenever a CV is successfully reviewed.
create table public.applicant_profiles (
  user_id uuid primary key references auth.users (id) on delete cascade,
  summary text,
  work_experience jsonb not null default '[]'::jsonb,
  education jsonb not null default '[]'::jsonb,
  skills text[] not null default '{}',
  certifications jsonb not null default '[]'::jsonb,
  source_document_id uuid references public.documents (id) on delete set null,
  updated_at timestamptz not null default now()
);

alter table public.applicant_profiles enable row level security;

create policy "Users can view their own applicant profile"
  on public.applicant_profiles for select
  using (auth.uid() = user_id);

create policy "Users can insert their own applicant profile"
  on public.applicant_profiles for insert
  with check (auth.uid() = user_id);

create policy "Users can update their own applicant profile"
  on public.applicant_profiles for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create trigger set_applicant_profiles_updated_at
  before update on public.applicant_profiles
  for each row execute function public.set_updated_at();
