-- Quick fix for: "Could not find the 'is_premium' column of 'users' in the schema cache"
-- Run this in Supabase Dashboard → SQL Editor → New query, then Run.

alter table public.users
  add column if not exists is_premium boolean not null default false;

-- Reload PostgREST schema cache (optional; Supabase may do this automatically after a moment)
-- notify pgrst, 'reload schema';
