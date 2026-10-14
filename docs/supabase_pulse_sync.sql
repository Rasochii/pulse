-- Pulse — espelhos remotos para Plano 8 (UPSERT por linha / LWW `updated_at_ms`).
-- Projeto novo: execute este arquivo inteiro uma vez no SQL Editor.
-- Projeto já criado com uma versão anterior: execute os arquivos de `docs/migrations/` em ordem.

create table if not exists public.pulse_habits (
  id text primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  description text,
  category text,
  icon_key text not null default 'task_alt',
  -- ARGB sem sinal (até 4294967295): não cabe em `int`.
  color_argb bigint not null default 4286350335,
  weekdays_bitmask int not null default 127,
  reminder_hour int,
  reminder_minute int,
  daily_target double precision not null default 1,
  daily_target_unit text,
  reminder_times_json text,
  created_at_ms bigint not null,
  updated_at_ms bigint not null,
  deleted_at_ms bigint
);

create table if not exists public.pulse_habit_completions (
  habit_id text not null references public.pulse_habits(id) on delete cascade,
  date_key int not null,
  completed_at_ms bigint not null,
  quantity double precision not null default 1,
  -- Carimbo da última alteração (marca d'água do pull) e tombstone de desmarcação.
  updated_at_ms bigint not null default 0,
  deleted_at_ms bigint,
  primary key (habit_id, date_key)
);

create table if not exists public.pulse_wellbeing_logs (
  id text primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  logged_at_ms bigint not null,
  mood smallint not null,
  energy smallint not null,
  note text,
  -- Carimbo da última alteração (marca d'água do pull) e tombstone de exclusão.
  updated_at_ms bigint not null default 0,
  deleted_at_ms bigint
);

-- Uma linha por usuário: XP, nível e conquistas (`{"chave": unlocked_at_ms}`).
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

create index if not exists pulse_habits_user_updated_idx
  on public.pulse_habits (user_id, updated_at_ms);
create index if not exists pulse_habit_completions_updated_idx
  on public.pulse_habit_completions (updated_at_ms);
create index if not exists pulse_wellbeing_logs_user_logged_idx
  on public.pulse_wellbeing_logs (user_id, logged_at_ms);
create index if not exists pulse_wellbeing_logs_user_updated_idx
  on public.pulse_wellbeing_logs (user_id, updated_at_ms);

-- Ligue RLS antes de usar em produção:

alter table public.pulse_habits enable row level security;
alter table public.pulse_habit_completions enable row level security;
alter table public.pulse_wellbeing_logs enable row level security;
alter table public.pulse_gamification enable row level security;
alter table public.profiles enable row level security;

create policy "habits_own" on public.pulse_habits
for all using (auth.uid() = user_id);

create policy "completions_via_habit" on public.pulse_habit_completions
for all using (
  habit_id in (select id from public.pulse_habits where user_id = auth.uid())
);

create policy "wellbeing_own" on public.pulse_wellbeing_logs
for all using (auth.uid() = user_id);

create policy "gamification_own" on public.pulse_gamification
for all using (auth.uid() = user_id);

create policy "profiles_own" on public.profiles
for all using (auth.uid() = id);

-- Versão mínima/recomendada do app (ver docs/migrations/2026-10-05_app_config.sql).
create table if not exists public.app_config (
  platform text primary key check (platform in ('android', 'ios')),
  min_build int not null default 0,
  recommended_build int not null default 0,
  store_url text,
  updated_at timestamptz not null default now()
);
alter table public.app_config enable row level security;
create policy "app_config_read" on public.app_config
for select to anon, authenticated using (true);
insert into public.app_config (platform)
values ('android'), ('ios')
on conflict (platform) do nothing;
