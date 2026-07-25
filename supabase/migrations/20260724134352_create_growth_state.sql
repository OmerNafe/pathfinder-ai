-- Replaces the SharedPreferences-backed GrowthState in
-- lib/state/growth_state.dart — same fields, now per-user and synced
-- instead of local-only/single-device.
create table public.growth_state (
  user_id uuid primary key references auth.users (id) on delete cascade,
  current_streak int not null default 0,
  longest_streak int not null default 0,
  milestone_count int not null default 0,
  last_action_date date,
  last_celebrated_streak int not null default 0,
  updated_at timestamptz not null default now()
);

alter table public.growth_state enable row level security;

create policy "Users can view their own growth state"
  on public.growth_state for select using (auth.uid() = user_id);
create policy "Users can insert their own growth state"
  on public.growth_state for insert with check (auth.uid() = user_id);
create policy "Users can update their own growth state"
  on public.growth_state for update using (auth.uid() = user_id);

create trigger set_growth_state_updated_at
  before update on public.growth_state
  for each row execute function public.set_updated_at();
