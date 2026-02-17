-- Optional user profile fields. All nullable; no mandatory onboarding.
alter table public.users
  add column if not exists full_name text,
  add column if not exists username text,
  add column if not exists age int,
  add column if not exists occupation text,
  add column if not exists focus_category text;

comment on column public.users.full_name is 'Optional display name';
comment on column public.users.username is 'Optional username';
comment on column public.users.age is 'Optional age';
comment on column public.users.occupation is 'Optional occupation';
comment on column public.users.focus_category is 'Optional primary focus category (e.g. fitness, study)';
