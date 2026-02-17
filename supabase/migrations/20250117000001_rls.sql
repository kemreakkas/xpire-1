-- Row Level Security. Run after initial_schema.

alter table public.users enable row level security;
alter table public.goals enable row level security;
alter table public.completions enable row level security;
alter table public.challenge_progress enable row level security;

-- Users: select and update own row only
create policy "users_select_own" on public.users
  for select using (auth.uid() = id);

create policy "users_update_own" on public.users
  for update using (auth.uid() = id);

create policy "users_insert_own" on public.users
  for insert with check (auth.uid() = id);

-- Goals: full CRUD where user_id = auth.uid()
create policy "goals_select_own" on public.goals
  for select using (auth.uid() = user_id);

create policy "goals_insert_own" on public.goals
  for insert with check (auth.uid() = user_id);

create policy "goals_update_own" on public.goals
  for update using (auth.uid() = user_id);

create policy "goals_delete_own" on public.goals
  for delete using (auth.uid() = user_id);

-- Completions: full CRUD where user_id = auth.uid()
create policy "completions_select_own" on public.completions
  for select using (auth.uid() = user_id);

create policy "completions_insert_own" on public.completions
  for insert with check (auth.uid() = user_id);

create policy "completions_update_own" on public.completions
  for update using (auth.uid() = user_id);

create policy "completions_delete_own" on public.completions
  for delete using (auth.uid() = user_id);

-- Challenge progress: full CRUD where user_id = auth.uid()
create policy "challenge_progress_select_own" on public.challenge_progress
  for select using (auth.uid() = user_id);

create policy "challenge_progress_insert_own" on public.challenge_progress
  for insert with check (auth.uid() = user_id);

create policy "challenge_progress_update_own" on public.challenge_progress
  for update using (auth.uid() = user_id);

create policy "challenge_progress_delete_own" on public.challenge_progress
  for delete using (auth.uid() = user_id);
