-- Add current_day, failed_at, goal_ids for simple 7-day engine.
alter table public.challenge_progress
  add column if not exists current_day int not null default 1,
  add column if not exists failed_at timestamptz,
  add column if not exists goal_ids text[];

comment on column public.challenge_progress.progress_days is 'Number of days completed (completedDays)';
