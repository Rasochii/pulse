# Plano 1 — Desbloqueio

Objetivo: o app compilar, sincronizar hábitos, disparar lembretes no Android e ter login/release configuráveis.

## 1.1 Compilação no Flutter 3.47 — JÁ APLICADO

- **Problema:** `CupertinoPageTransitionsBuilder` não é mais exportado por `material.dart`.
- **Mudança:** `lib/core/theme/app_theme.dart` importa a classe de `package:flutter/cupertino.dart`.
- **Verificação:** `flutter analyze` sem erros; `test/widget_test.dart` volta a compilar.

## 1.2 Coluna `color_argb` estoura `int` no Postgres

- **Problema:** o app envia cores ARGB sem sinal (ex.: 4.286.350.335); a coluna remota é `int` (máx. 2.147.483.647). Todo upsert de hábito falha.
- **Mudança:** em `docs/supabase_pulse_sync.sql`, trocar `color_argb int` por `bigint` e corrigir o default para `4286350335`.
- **Migração:** novo arquivo `docs/migrations/2026-10-01_color_bigint.sql` com `alter table public.pulse_habits alter column color_argb type bigint;`.
- **Ação sua:** rodar a migração no SQL Editor do Supabase.

## 1.3 Lembretes no Android — JÁ APLICADO

- **Problema:** o manifest não declara os receivers do `flutter_local_notifications`.
- **Mudança:** `AndroidManifest.xml` ganha `RECEIVE_BOOT_COMPLETED`, `ScheduledNotificationReceiver` e `ScheduledNotificationBootReceiver`.
- **Verificação:** só em aparelho — criar hábito com lembrete para daqui a 2 min; repetir após reiniciar o aparelho.

## 1.4 Login com Google

- **Problema:** `GoogleSignIn()` sem `serverClientId`; no Android o `idToken` vem nulo.
- **Mudança:**
  - `AppEnv`: novos `--dart-define` `GOOGLE_WEB_CLIENT_ID` e `GOOGLE_IOS_CLIENT_ID`.
  - `AuthRepository`: passar `serverClientId` / `clientId`; envolver `signIn()` em try/catch com mensagem em português.
  - Tela de login: esconder o botão do Google quando o client ID não estiver definido.
  - README, `.env.example` e `.vscode/*.example.json`: documentar as variáveis e o `REVERSED_CLIENT_ID` do iOS.
- **Ação sua:** criar os clientes OAuth no Google Cloud (Web + Android com SHA-1 + iOS) e habilitar o provedor Google no Supabase.

## 1.5 App preso no login sem Supabase — PRECISA DA SUA DECISÃO

- **Problema:** o README promete uso sem backend, mas o router sempre manda para o login.
- **Opção A (recomendada): modo local.** Sem Supabase, o app usa um usuário fixo `local`, pula o login e funciona 100% offline.
  - `AuthRepository`: novo getter `currentUserId` (id do Supabase ou `local`).
  - Trocar todos os `currentUser?.id` por `currentUserId` (providers, formulário, checklist, humor, shell).
  - `app_router.dart` e `splash_gate.dart`: sem Supabase, ir para onboarding/app em vez de login.
  - `onboarding_screen.dart`: parar de usar `Supabase.instance` direto.
  - Perfil: esconder "Sair" e "Excluir conta" no modo local.
  - Atualizar `test/widget_test.dart` (hoje espera a tela de login).
- **Opção B: só corrigir o README**, assumindo que Supabase é obrigatório.

## 1.6 Assinatura de release — JÁ APLICADO (parcial)

- **Mudança feita:** `android/app/build.gradle.kts` lê `android/key.properties`; sem o arquivo, continua usando a chave de debug.
- **Falta:** documentar no README como gerar o keystore e o `key.properties`.
- **Fora do escopo:** trocar o `applicationId` (`com.pulse.app.pulse`). É decisão sua e muda a identidade do app na loja.
- **Ação sua:** gerar o keystore.

## Também já aplicado (pertence ao plano 3.2)

- Scheme `pulse://auth-callback` no `AndroidManifest.xml` e no `Info.plist`, com o deep linking automático do Flutter desligado. Sozinho não muda comportamento; é pré-requisito da redefinição de senha.

## Validação da fase

- `flutter analyze` e `flutter test` limpos.
- `flutter build apk --debug` para confirmar que manifest e Gradle estão válidos.
