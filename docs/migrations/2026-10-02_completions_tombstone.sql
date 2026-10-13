-- Desmarcar um hábito passa a gravar um tombstone (`deleted_at_ms`) em vez de apagar a linha,
-- para a desmarcação chegar aos outros aparelhos. `updated_at_ms` é a marca d'água do pull.
alter table public.pulse_habit_completions
  add column if not exists updated_at_ms bigint not null default 0,
  add column if not exists deleted_at_ms bigint;

update public.pulse_habit_completions
   set updated_at_ms = completed_at_ms
 where updated_at_ms = 0;

create index if not exists pulse_habit_completions_updated_idx
  on public.pulse_habit_completions (updated_at_ms);
create index if not exists pulse_habits_user_updated_idx
  on public.pulse_habits (user_id, updated_at_ms);
create index if not exists pulse_wellbeing_logs_user_logged_idx
  on public.pulse_wellbeing_logs (user_id, logged_at_ms);
