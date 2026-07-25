-- One row per device/browser a user has enabled push on. A user can have
-- several (phone + laptop), so this is its own table rather than a single
-- column on profiles -- send-reminders sends to every active token for a
-- user, and a token can be removed independently if that device revokes
-- permission.
create table public.push_tokens (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  token text not null,
  created_at timestamptz not null default now(),
  unique (user_id, token)
);

alter table public.push_tokens enable row level security;

create policy "Users can view their own push tokens"
  on public.push_tokens for select using (auth.uid() = user_id);
create policy "Users can insert their own push tokens"
  on public.push_tokens for insert with check (auth.uid() = user_id);
create policy "Users can delete their own push tokens"
  on public.push_tokens for delete using (auth.uid() = user_id);
