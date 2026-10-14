-- Ordem manual dos hábitos (arrastar na aba Hábitos). 0 = sem ordem definida;
-- no empate o app ordena pelo nome.
alter table public.pulse_habits
  add column if not exists sort_order int not null default 0;
