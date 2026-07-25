-- Shared trigger used by every mutable table below (and later migrations)
-- to keep updated_at honest without relying on the client to set it.
create function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- One row per authenticated user.
create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  full_name text,
  avatar_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

create policy "Users can view their own profile"
  on public.profiles for select
  using (auth.uid() = id);

create policy "Users can update their own profile"
  on public.profiles for update
  using (auth.uid() = id);

create policy "Users can insert their own profile"
  on public.profiles for insert
  with check (auth.uid() = id);

create trigger set_profiles_updated_at
  before update on public.profiles
  for each row execute function public.set_updated_at();

-- Auto-create a profile row whenever someone signs up, so the app never
-- has to handle "no profile yet" as a special case.
create function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, full_name)
  values (new.id, new.raw_user_meta_data ->> 'full_name');
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- One active pathway per user — mirrors PathwayData in lib/state/pathway_state.dart.
create table public.pathways (
  user_id uuid primary key references auth.users (id) on delete cascade,
  occupation text not null,
  target_country text not null,
  progress numeric not null default 0 check (progress >= 0 and progress <= 1),
  has_completed_setup boolean not null default false,
  updated_at timestamptz not null default now()
);

alter table public.pathways enable row level security;

create policy "Users can view their own pathway"
  on public.pathways for select
  using (auth.uid() = user_id);

create policy "Users can insert their own pathway"
  on public.pathways for insert
  with check (auth.uid() = user_id);

create policy "Users can update their own pathway"
  on public.pathways for update
  using (auth.uid() = user_id);

create trigger set_pathways_updated_at
  before update on public.pathways
  for each row execute function public.set_updated_at();
