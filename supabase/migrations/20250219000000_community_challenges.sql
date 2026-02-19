-- Community challenges: public challenges table and participants (join) table.

create table if not exists public.challenges (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text not null default '',
  duration_days int not null default 7,
  reward_xp int not null default 0,
  created_by uuid references auth.users(id) on delete set null,
  is_public boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.challenge_participants (
  id uuid primary key default gen_random_uuid(),
  challenge_id uuid not null references public.challenges(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  current_day int not null default 1,
  completed_days int not null default 0,
  joined_at timestamptz not null default now(),
  is_completed boolean not null default false,
  unique(challenge_id, user_id)
);

create index if not exists idx_challenge_participants_user_id
  on public.challenge_participants(user_id);
create index if not exists idx_challenge_participants_challenge_id
  on public.challenge_participants(challenge_id);
create index if not exists idx_challenges_is_public
  on public.challenges(is_public) where is_public = true;

alter table public.challenges enable row level security;
alter table public.challenge_participants enable row level security;

-- Challenges: anyone can read public; authenticated can read own created; service role can manage.
create policy "challenges_select_public" on public.challenges
  for select using (is_public = true);

create policy "challenges_select_own_created" on public.challenges
  for select using (auth.uid() = created_by);

create policy "challenges_insert_authenticated" on public.challenges
  for insert with check (auth.uid() = created_by or created_by is null);

create policy "challenges_update_own" on public.challenges
  for update using (auth.uid() = created_by);

-- Participants: users can read own rows; insert own (join); update own.
create policy "challenge_participants_select_own" on public.challenge_participants
  for select using (auth.uid() = user_id);

create policy "challenge_participants_insert_own" on public.challenge_participants
  for insert with check (auth.uid() = user_id);

create policy "challenge_participants_update_own" on public.challenge_participants
  for update using (auth.uid() = user_id);

-- Allow select on participants for public challenges (for participant count on community cards).
create policy "challenge_participants_select_public_challenge" on public.challenge_participants
  for select using (
    exists (select 1 from public.challenges c where c.id = challenge_id and c.is_public = true)
  );

comment on table public.challenges is 'Community challenges (public and private)';
comment on table public.challenge_participants is 'User participation in community challenges';
