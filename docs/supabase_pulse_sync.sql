-- Pulse — espelhos remotos para Plano 8 (UPSERT por linha / LWW `updated_at_ms` ou `completed_at_ms`).
-- Ajuste nomes conforme seu projeto Supabase e execute uma vez como SQL migration.

create table if not exists public.pulse_habits (
  id text primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  description text,
  category text,
  icon_key text not null default 'task_alt',
  color_argb int not null default 4286635519,
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
  primary key (habit_id, date_key)
);

create table if not exists public.pulse_wellbeing_logs (
  id text primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  logged_at_ms bigint not null,
  mood smallint not null,
  energy smallint not null,
  note text
);

-- Ligue RLS antes de usar em produção:

alter table public.pulse_habits enable row level security;
alter table public.pulse_habit_completions enable row level security;
alter table public.pulse_wellbeing_logs enable row level security;

create policy "habits_own" on public.pulse_habits
for all using (auth.uid() = user_id);

create policy "completions_via_habit" on public.pulse_habit_completions
for all using (
  habit_id in (select id from public.pulse_habits where user_id = auth.uid())
);

create policy "wellbeing_own" on public.pulse_wellbeing_logs
for all using (auth.uid() = user_id);
