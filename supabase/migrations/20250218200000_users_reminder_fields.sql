-- Daily reminder support: local notifications (mobile) / in-app banner (web).
alter table public.users
  add column if not exists reminder_enabled boolean not null default true,
  add column if not exists reminder_time time not null default '20:00'::time,
  add column if not exists last_notification_sent date;

comment on column public.users.reminder_enabled is 'When true, user gets daily reminder (local on mobile, in-app on web).';
comment on column public.users.reminder_time is 'Time of day for daily reminder (e.g. 20:00).';
comment on column public.users.last_notification_sent is 'Last date we sent/cancelled reminder (avoid duplicate; clear after first goal of day).';
