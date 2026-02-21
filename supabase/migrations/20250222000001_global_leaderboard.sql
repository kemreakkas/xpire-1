-- Liderlik tablosu için sadece gerekli bilgileri (okunabilir) dışarı veren yeni bir view

create or replace view public.global_leaderboard as
select 
  id,
  email,
  username,
  full_name,
  level,
  total_xp,
  streak
from public.users
where total_xp > 0
order by total_xp desc;

-- Bu view'a herkesin erişebilmesi (sadece kendi hesabını değil herkesi okuyabilmesi) için yetki veriyoruz:
grant select on public.global_leaderboard to authenticated;
grant select on public.global_leaderboard to anon;
