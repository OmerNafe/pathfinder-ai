create table public.gaps (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  category text not null,
  target_requirement text not null,
  current_status text not null,
  current_stage text not null,
  validity_note text,
  history jsonb not null default '[]'::jsonb,
  next_step_task_numbers int[] not null default '{}',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.gaps enable row level security;

create policy "Users can view their own gaps"
  on public.gaps for select using (auth.uid() = user_id);
create policy "Users can insert their own gaps"
  on public.gaps for insert with check (auth.uid() = user_id);
create policy "Users can update their own gaps"
  on public.gaps for update using (auth.uid() = user_id);
create policy "Users can delete their own gaps"
  on public.gaps for delete using (auth.uid() = user_id);

create trigger set_gaps_updated_at
  before update on public.gaps
  for each row execute function public.set_updated_at();

create table public.tasks (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  step int not null,
  title text not null,
  description text not null,
  status text not null default 'pending' check (status in ('verified', 'pending', 'rejected')),
  status_note text,
  course_guide text,
  material_pack text,
  cta_label text,
  due_note text,
  updated_at timestamptz not null default now(),
  unique (user_id, step)
);

alter table public.tasks enable row level security;

create policy "Users can view their own tasks"
  on public.tasks for select using (auth.uid() = user_id);
create policy "Users can insert their own tasks"
  on public.tasks for insert with check (auth.uid() = user_id);
create policy "Users can update their own tasks"
  on public.tasks for update using (auth.uid() = user_id);

create trigger set_tasks_updated_at
  before update on public.tasks
  for each row execute function public.set_updated_at();
