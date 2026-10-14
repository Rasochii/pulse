-- Versão mínima e recomendada do app por plataforma (atualização obrigatória).
-- `min_build`/`recommended_build` comparam com o número depois do "+" em
-- `version:` do pubspec.yaml (ex.: 1.0.3+12 → 12). 0 desliga a regra.
-- `store_url` é opcional no Android (o app monta o link da Play pelo pacote)
-- e necessário no iOS (link da App Store).
create table if not exists public.app_config (
  platform text primary key check (platform in ('android', 'ios')),
  min_build int not null default 0,
  recommended_build int not null default 0,
  store_url text,
  updated_at timestamptz not null default now()
);

alter table public.app_config enable row level security;

-- Leitura para todos (inclusive quem usa sem conta); escrita só pelo painel.
drop policy if exists "app_config_read" on public.app_config;
create policy "app_config_read" on public.app_config
for select to anon, authenticated using (true);

insert into public.app_config (platform)
values ('android'), ('ios')
on conflict (platform) do nothing;
