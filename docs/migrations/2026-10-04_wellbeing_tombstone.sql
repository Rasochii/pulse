-- Apagar um check-in de humor grava um tombstone (`deleted_at_ms`) em vez de apagar a linha,
-- para a exclusão chegar aos outros aparelhos. `updated_at_ms` passa a ser a marca d'água do pull.
alter table public.pulse_wellbeing_logs
  add column if not exists updated_at_ms bigint not null default 0,
  add column if not exists deleted_at_ms bigint;

update public.pulse_wellbeing_logs
   set updated_at_ms = logged_at_ms
 where updated_at_ms = 0;

create index if not exists pulse_wellbeing_logs_user_updated_idx
  on public.pulse_wellbeing_logs (user_id, updated_at_ms);
