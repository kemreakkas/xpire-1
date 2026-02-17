-- Eksik users sütunlarını ekle (freeze_credits vb. yoksa PGRST204 hatası alınır).
-- Supabase SQL Editor'da çalıştır veya: supabase db push

alter table public.users
  add column if not exists last_active_date timestamptz,
  add column if not exists is_premium boolean not null default false,
  add column if not exists freeze_credits int not null default 0,
  add column if not exists last_freeze_reset timestamptz,
  add column if not exists subscription_status text not null default 'free' check (subscription_status in ('free', 'active', 'canceled')),
  add column if not exists created_at timestamptz not null default now(),
  add column if not exists updated_at timestamptz not null default now();

-- Profil alanları (önceki migration ile eklenmiş olabilir)
alter table public.users
  add column if not exists full_name text,
  add column if not exists username text,
  add column if not exists age int,
  add column if not exists occupation text,
  add column if not exists focus_category text;
