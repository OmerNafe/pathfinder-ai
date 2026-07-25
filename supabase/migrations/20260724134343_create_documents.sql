create table public.documents (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  requirement_id text not null,
  file_name text not null,
  storage_path text not null,
  size_bytes bigint not null,
  uploaded_at timestamptz not null default now(),
  -- 'pending' the instant a file lands; 'reviewing' while the Edge Function
  -- is mid-call; 'reviewed'/'failed' are terminal. The client polls/subscribes
  -- to this instead of ever computing a verdict itself.
  ai_review_status text not null default 'pending'
    check (ai_review_status in ('pending', 'reviewing', 'reviewed', 'failed')),
  ai_review_result jsonb,
  unique (user_id, requirement_id)
);

alter table public.documents enable row level security;

create policy "Users can view their own documents"
  on public.documents for select
  using (auth.uid() = user_id);

create policy "Users can upload their own documents"
  on public.documents for insert
  with check (auth.uid() = user_id);

create policy "Users can update their own documents"
  on public.documents for update
  using (auth.uid() = user_id);

create policy "Users can delete their own documents"
  on public.documents for delete
  using (auth.uid() = user_id);

-- Private bucket — files are namespaced by user id folder, enforced below.
insert into storage.buckets (id, name, public)
values ('documents', 'documents', false)
on conflict (id) do nothing;

create policy "Users can upload to their own storage folder"
  on storage.objects for insert
  with check (bucket_id = 'documents' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "Users can view their own storage folder"
  on storage.objects for select
  using (bucket_id = 'documents' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "Users can delete their own storage folder"
  on storage.objects for delete
  using (bucket_id = 'documents' and (storage.foldername(name))[1] = auth.uid()::text);
