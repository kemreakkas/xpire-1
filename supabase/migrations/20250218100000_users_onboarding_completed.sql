-- Add onboarding_completed for Smart Onboarding flow.
-- When false, show OnboardingPage on first login; after completion, set true and create starter goals/challenge.
alter table public.users
  add column if not exists onboarding_completed boolean not null default false;

comment on column public.users.onboarding_completed is 'When false, user sees onboarding; after completion we set true and create starter goals.';
