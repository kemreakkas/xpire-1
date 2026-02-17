-- Add missing users columns (fixes PGRST204 "Could not find the 'is_premium' column").
-- Run in Supabase SQL Editor or: supabase db push

alter table public.users add column if not exists last_active_date timestamptz;
alter table public.users add column if not exists is_premium boolean not null default false;
alter table public.users add column if not exists freeze_credits int not null default 0;
alter table public.users add column if not exists last_freeze_reset timestamptz;
alter table public.users add column if not exists subscription_status text not null default 'free';
alter table public.users add column if not exists created_at timestamptz not null default now();
alter table public.users add column if not exists updated_at timestamptz not null default now();

-- Profile fields (may already exist from another migration)
alter table public.users add column if not exists full_name text;
alter table public.users add column if not exists username text;
alter table public.users add column if not exists age int;
alter table public.users add column if not exists occupation text;
alter table public.users add column if not exists focus_category text;

-- Optional: enforce subscription_status values (run only if column was just added)
do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conname = 'users_subscription_status_check'
  ) then
    alter table public.users
      add constraint users_subscription_status_check
      check (subscription_status in ('free', 'active', 'canceled'));
  end if;
end $$;
