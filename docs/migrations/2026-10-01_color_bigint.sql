-- Cores ARGB sem sinal (ex.: 0xFF7C83FF = 4286350335) não cabem em `int`:
-- sem isto, todo upsert de hábito falha com "integer out of range".
alter table public.pulse_habits alter column color_argb type bigint;
alter table public.pulse_habits alter column color_argb set default 4286350335;
