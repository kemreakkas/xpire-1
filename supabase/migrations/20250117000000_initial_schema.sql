-- Xpire SaaS schema. Run in Supabase SQL Editor.
-- Users table (extends auth.users; id = auth.uid())
create table if not exists public.users (
  id uuid primary key references auth.users(id) on delete cascade,
  email text,
  level int not null default 1,
  xp int not null default 0,
  total_xp int not null default 0,
  streak int not null default 0,
  last_active_date timestamptz,
  is_premium boolean not null default false,
  freeze_credits int not null default 0,
  last_freeze_reset timestamptz,
  subscription_status text not null default 'free' check (subscription_status in ('free', 'active', 'canceled')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Goals
create table if not exists public.goals (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  title text not null,
  category text not null,
  difficulty text not null,
  base_xp int not null,
  frequency text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create index if not exists goals_user_id_idx on public.goals(user_id);
create index if not exists goals_category_idx on public.goals(category);

-- Completions
create table if not exists public.completions (
  id uuid primary key default gen_random_uuid(),
  goal_id uuid not null references public.goals(id) on delete cascade,
  user_id uuid not null references public.users(id) on delete cascade,
  earned_xp int not null,
  completed_at timestamptz not null,
  created_at timestamptz not null default now()
);

create index if not exists completions_user_id_idx on public.completions(user_id);
create index if not exists completions_goal_id_idx on public.completions(goal_id);

-- Challenge progress
create table if not exists public.challenge_progress (
  id uuid primary key default gen_random_uuid(),
  challenge_id text not null,
  user_id uuid not null references public.users(id) on delete cascade,
  started_at timestamptz not null default now(),
  completed_at timestamptz,
  progress_days int not null default 0,
  is_completed boolean not null default false
);

create index if not exists challenge_progress_user_id_idx on public.challenge_progress(user_id);

-- Updated_at trigger helper
create or replace function public.set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

-- Trigger for users
drop trigger if exists users_updated_at on public.users;
create trigger users_updated_at
  before update on public.users
  for each row execute function public.set_updated_at();

-- Trigger for goals
drop trigger if exists goals_updated_at on public.goals;
create trigger goals_updated_at
  before update on public.goals
  for each row execute function public.set_updated_at();
