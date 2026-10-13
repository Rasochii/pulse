-- XP/nível/conquistas na nuvem e a tabela `profiles` usada no fim do onboarding.
create table if not exists public.pulse_gamification (
  user_id uuid primary key references auth.users(id) on delete cascade,
  total_xp int not null default 0,
  level int not null default 1,
  achievements jsonb not null default '{}'::jsonb,
  updated_at_ms bigint not null
);

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  updated_at timestamptz,
  onboarding_completed_at timestamptz
);

alter table public.pulse_gamification enable row level security;
alter table public.profiles enable row level security;

drop policy if exists "gamification_own" on public.pulse_gamification;
create policy "gamification_own" on public.pulse_gamification
for all using (auth.uid() = user_id);

drop policy if exists "profiles_own" on public.profiles;
create policy "profiles_own" on public.profiles
for all using (auth.uid() = id);
