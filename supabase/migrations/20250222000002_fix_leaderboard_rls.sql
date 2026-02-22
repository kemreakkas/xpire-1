-- FIX: global_leaderboard view RLS bypass.
-- The previous view inherited the users table's RLS policy (users_select_own),
-- which means each user could only see their own row.
-- Dropping and recreating as a SECURITY DEFINER function-backed view
-- so the view runs as the owner (bypassing row-level security).

drop view if exists public.global_leaderboard;

-- Create a security-definer function that returns all leaderboard rows
create or replace function public.get_global_leaderboard()
returns table (
  id uuid,
  username text,
  full_name text,
  level integer,
  total_xp integer,
  streak integer
)
language sql
security definer
stable
as $$
  select id, username, full_name, level, total_xp, streak
  from public.users
  where total_xp > 0
  order by total_xp desc
  limit 50;
$$;

-- Grant execute to authenticated users and anon
grant execute on function public.get_global_leaderboard() to authenticated;
grant execute on function public.get_global_leaderboard() to anon;

-- Recreate the view using the security-definer function
-- so existing Flutter code querying 'global_leaderboard' still works
create or replace view public.global_leaderboard
with (security_invoker = false)
as
  select id, username, full_name, level, total_xp, streak
  from public.get_global_leaderboard();

grant select on public.global_leaderboard to authenticated;
grant select on public.global_leaderboard to anon;
