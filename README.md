<p align="center">
  <img src="./docs/readme-banner.svg" alt="Pulse" width="92%"/>
</p>

<p align="center">
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter"/></a>
  <a href="https://dart.dev"><img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart"/></a>
  <a href="https://riverpod.dev"><img src="https://img.shields.io/badge/Riverpod-146C2E?style=for-the-badge&logo=flutter&logoColor=white" alt="Riverpod"/></a>
  <a href="https://supabase.com"><img src="https://img.shields.io/badge/Supabase-3FCF8E?style=for-the-badge&logo=supabase&logoColor=1a1a1a" alt="Supabase"/></a>
  <a href="https://drift.simonbinder.eu"><img src="https://img.shields.io/badge/Drift-SQLite-7C83FF?style=for-the-badge&logo=sqlite&logoColor=white" alt="Drift SQLite"/></a>
</p>

<p align="center"><strong>Pulse</strong> é um app de hábitos com foco em <strong>hoje</strong>: pouca fricção, clareza no que importa e registo rápido do progresso.</p>

<p align="center">
  <sub>Offline-first com SQLite local; login e nuvem opcionais via Supabase — ideal para uso real no dia a dia e para explorar a UI sem backend.</sub>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Armazenamento-offline_first-4338ca?style=for-the-badge&logo=database&labelColor=1e1b4b&color=4338ca" alt="Offline-first"/>
  &nbsp;
  <img src="https://img.shields.io/badge/Navega%C3%A7%C3%A3o-go_router-475569?style=for-the-badge&labelColor=1e293b" alt="go_router"/>
</p>

<br/>

## Índice

- [Funcionalidades](#funcionalidades)
- [Fluxo no app](#fluxo-no-app)
- [Stack](#stack)
- [Estrutura do projeto](#estrutura-do-projeto)
- [Começar](#começar)
- [Supabase e variáveis de ambiente](#supabase-e-variáveis-de-ambiente)
- [Sincronização e dados na nuvem](#sincronização-e-dados-na-nuvem)
- [Excluir conta (Edge Function)](#excluir-conta-edge-function)
- [Build de release (Android)](#build-de-release-android)
- [Testes e análise estática](#testes-e-análise-estática)

<br/>

## Funcionalidades

<table>
  <tr>
    <td width="33%" valign="top" align="center">
      <img src="https://img.shields.io/badge/In%C3%ADcio-dashboard-6366f1?style=for-the-badge&labelColor=1e1b4b"/><br/><br/>
      <b>Visão do dia e hábitos</b><br/><br/>
      <small>Resumo no <strong>Início</strong>, lista “só o que conta” por dia da semana, toque para marcar, métricas de consistência e sequência.</small>
    </td>
    <td width="34%" valign="top" align="center">
      <img src="https://img.shields.io/badge/H%C3%81BITOS-criar_editar-38bdf8?style=for-the-badge&labelColor=164e63"/><br/><br/>
      <b>Criar e afinar hábitos</b><br/><br/>
      <small>Nome, categoria, ícone, cor, dias ativos, <strong>meta numérica</strong> com unidade livre e <strong>vários lembretes</strong> por dia (notificações locais).</small>
    </td>
    <td width="33%" valign="top" align="center">
      <img src="https://img.shields.io/badge/Insights-texto_inteligente-a855f7?style=for-the-badge&labelColor=581c87"/><br/><br/>
      <b>Insights leves</b><br/><br/>
      <small>Sugestões baseadas em hábitos e (quando existir) histórico recente de humor — sem sobrecarregar o ecrã.</small>
    </td>
  </tr>
  <tr><td colspan="3"><br/></td></tr>
  <tr>
    <td valign="top" align="center">
      <img src="https://img.shields.io/badge/Humor-check_ins-f472b6?style=for-the-badge&labelColor=831843"/><br/><br/>
      <b>Bem-estar rápido</b><br/><br/>
      <small>Check-in de humor e energia, cartão no dashboard, histórico e tendências com gráfico discreto.</small>
    </td>
    <td valign="top" align="center">
      <img src="https://img.shields.io/badge/XP-n%C3%ADveis_conquistas-22c55e?style=for-the-badge&labelColor=14532d"/><br/><br/>
      <b>Gamificação opcional</b><br/><br/>
      <small>XP por conclusões, níveis, catálogo de conquistas — persistido no Drift e sincronizado com a conta.</small>
    </td>
    <td valign="top" align="center">
      <img src="https://img.shields.io/badge/Conta-auth_privacidade-white?style=for-the-badge&labelColor=374151"/><br/><br/>
      <b>Conta e privacidade</b><br/><br/>
      <small>Login com <strong>e-mail</strong> ou <strong>Google</strong> (Supabase), onboarding, tema escuro, <strong>excluir conta</strong> com confirmação e limpeza local + remota.</small>
    </td>
  </tr>
</table>

<br/>

## Fluxo no app

```mermaid
flowchart LR
    A([Splash]) --> B{{Logado?}}
    B -->|Não| C[Login]
    B -->|Sim| D{{Onboarding ok?}}
    D -->|Não| E[Onboarding]
    D -->|Sim| F[App com abas]
    C --> D
    E --> F
    F --> G[Início]
    F --> H[Hábitos]
    F --> I[Insights]
    F --> J[Perfil]
    G & H & I --> K[(Drift SQLite)]
    C --> L[(Supabase Auth)]
    F --> M[(Sync opcional pulse_*)]
```

<br/>

## Stack

| Camada | Tecnologias |
|:--|:--|
| **UI** | Flutter · Material 3 · painéis estilo glass |
| **Estado** | Riverpod |
| **Rotas** | go_router |
| **Persistência local** | Drift · SQLite |
| **Rede / auth (opcional)** | supabase_flutter · Google Sign-In |
| **Notificações** | flutter_local_notifications · timezone |
| **Gráficos** | fl_chart |

Versões concretas de pacotes: ver [`pubspec.yaml`](pubspec.yaml). SDK Dart: `^3.11.3`.

<br/>

## Estrutura do projeto

```
lib/
├── core/
│   ├── config/          # Ambiente (Supabase, flags)
│   ├── database/        # Drift — hábitos, completions, outbox, gamificação, bem-estar
│   ├── notifications/   # Lembretes de hábitos
│   ├── router/          # go_router, shell
│   ├── sync/            # Motor de sync + outbox + watermarks
│   └── theme/           # Tema claro/escuro Pulse
├── features/
│   ├── auth/            # Login, onboarding, exclusão de conta
│   ├── dashboard/       # Início (cartões, hábitos de hoje, humor)
│   ├── gamification/    # XP, níveis, conquistas
│   ├── habits/          # Lista, formulário, checklist de hoje, perfil
│   ├── insights/        # Motor e ecrã de insights
│   ├── settings/        # Preferências (ex.: tema)
│   └── wellbeing/       # Humor, histórico, providers
├── providers/           # Riverpod global (DB, sync, auth, …)
├── pulse_app.dart
└── main.dart
```

Outros:

- [`test/`](test/) — testes unitários e de widget
- [`supabase/functions/delete-account/`](supabase/functions/delete-account/) — Edge Function para apagar dados e utilizador
- [`.vscode/flutter-dart-define.example.json`](.vscode/flutter-dart-define.example.json) — modelo de `dart-define` para Supabase

<br/>

## Começar

**Pré-requisitos:** [Flutter](https://docs.flutter.dev/get-started/install) (canal stable, compatível com Dart 3.11+), ferramentas da plataforma alvo (Xcode / Android SDK).

```bash
git clone <url-do-repositório> pulse
cd pulse
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

O `build_runner` gera código Drift (`*.g.dart`). Volte a executá-lo após alterar o esquema das tabelas em `app_database.dart`.

<br/>

## Supabase e variáveis de ambiente

O app funciona **sem** Supabase em **modo local**: não há login, os dados ficam só no aparelho (SQLite) e nada é enviado para a nuvem. Para auth e sync, defina no arranque:

| Variável | Uso |
|:--|:--|
| `SUPABASE_URL` | URL do projeto (ex.: `https://xxx.supabase.co`) |
| `SUPABASE_ANON_KEY` | Chave **anon** ou **publishable** do projeto — a que o cliente pode expor |
| `GOOGLE_WEB_CLIENT_ID` | Opcional. Client ID OAuth do tipo **Web** — habilita o botão "Continuar com Google" |
| `GOOGLE_IOS_CLIENT_ID` | Opcional. Client ID OAuth do tipo **iOS** |

> Os dados do modo local pertencem a um usuário fixo (`local`) e **não** migram para a conta ao configurar o Supabase depois.

**Nunca** coloque a chave `service_role` / `sb_secret_` no app Flutter: o runtime rejeita essa configuração por segurança.

**Exemplo de defines** (ajuste e use no VS Code / Android Studio ou na linha de comando):

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://SEU_PROJETO.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=sua_chave_anon_ou_publishable
```

Modelo JSON para copiar chaves: [`.vscode/flutter-dart-define.example.json`](.vscode/flutter-dart-define.example.json). Para depuração no VS Code, alinhe com [`.vscode/launch.example.json`](.vscode/launch.example.json).

**Google Sign-In** (o botão só aparece com `GOOGLE_WEB_CLIENT_ID` definido):

1. No Google Cloud, crie três clientes OAuth: **Web**, **Android** (pacote `com.pulse.app.pulse` + SHA-1 do keystore) e **iOS**.
2. No Supabase, em *Authentication → Providers → Google*, informe o client ID/secret do cliente **Web** (e adicione os IDs Android/iOS em *Authorized Client IDs*).
3. Passe o client ID **Web** em `GOOGLE_WEB_CLIENT_ID` e o **iOS** em `GOOGLE_IOS_CLIENT_ID`.
4. iOS: adicione o `REVERSED_CLIENT_ID` do cliente iOS em `CFBundleURLSchemes` no `ios/Runner/Info.plist`.

**Links de e-mail (confirmação de conta e redefinição de senha):** o app registra o deep link `pulse://auth-callback`. Adicione esse endereço em *Authentication → URL Configuration → Redirect URLs* no Supabase; sem isso o link do e-mail não volta para o app.

<br/>

## Sincronização e dados na nuvem

Com Supabase ativo, o motor em [`lib/core/sync/pulse_sync_engine.dart`](lib/core/sync/pulse_sync_engine.dart):

- envia alterações pendentes a partir de uma **fila local** (`SyncOutbox`) — ao abrir o app, ao voltar do segundo plano e logo após marcar um hábito, registrar humor ou salvar um hábito;
- faz **pull incremental** paginado, usando marcas de tempo **por usuário** guardadas em `SharedPreferences` (`SyncWatermarkStore`);
- propaga desmarcações com **tombstone** (`deleted_at_ms`) em vez de apagar a linha remota.

Tabelas remotas (esquema completo em [`docs/supabase_pulse_sync.sql`](docs/supabase_pulse_sync.sql)):

- `pulse_habits`
- `pulse_habit_completions`
- `pulse_wellbeing_logs`
- `pulse_gamification` (XP, nível e conquistas)
- `profiles` (marca o fim do onboarding)

**Projeto Supabase novo:** execute `docs/supabase_pulse_sync.sql` uma vez no SQL Editor.
**Projeto criado com uma versão anterior do script:** execute, em ordem, os arquivos de [`docs/migrations/`](docs/migrations/). Sem eles o sync falha (cor do hábito fora do limite de `int`, colunas de tombstone ausentes).

Limitações conhecidas:

- A resolução de conflitos é *last-write-wins* pelo relógio de cada aparelho; um relógio muito atrasado pode fazer uma alteração ser ignorada.
- O registro "XP já concedido hoje" é local: num aparelho novo é possível ganhar de novo, uma vez, o XP do dia.
- Itens que o servidor rejeita 8 vezes saem da fila ativa e voltam a ser tentados na próxima abertura do app.

A lógica de insights permanece **só no dispositivo**.

<br/>

## Excluir conta (Edge Function)

No **Perfil**, a ação **Excluir conta** (com confirmação escrita `EXCLUIR`):

1. Chama a Edge Function **`delete-account`** no Supabase com o JWT da sessão.
2. Após sucesso, limpa dados locais (Drift, outbox, watermarks, onboarding), cancela notificações agendadas e faz **sign out**.

A função no repositório: [`supabase/functions/delete-account/index.ts`](supabase/functions/delete-account/index.ts). Ela valida o token, remove linhas do utilizador em `pulse_wellbeing_logs`, `pulse_habit_completions` e `pulse_habits`, e chama a API de administração para remover o utilizador em **auth**. Isso requer a **service role** disponível no ambiente da função (segredo `SUPABASE_SERVICE_ROLE_KEY` no dashboard do Supabase / CLI).

**Deploy** ([Supabase CLI](https://supabase.com/docs/guides/cli)):

```bash
supabase functions deploy delete-account
```

Garanta que os segredos da função incluem a URL do projeto e a service role conforme a documentação atual do Supabase para Edge Functions.

<br/>

## Build de release (Android)

Sem configuração, o release é assinado com a chave de **debug** (serve para testar, não para publicar). Para assinar de verdade:

```bash
keytool -genkey -v -keystore ~/pulse-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Crie `android/key.properties` (já ignorado pelo Git):

```properties
storeFile=/caminho/para/pulse-upload.jks
storePassword=...
keyAlias=upload
keyPassword=...
```

```bash
flutter build apk --release \
  --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
```

<br/>

## Testes e análise estática

```bash
flutter analyze
flutter test
```

Os testes cobrem métricas de hábito (sequência, taxa de 30 dias), dashboard, curva de nível, lembretes, insights, resumo de bem-estar e o repositório de hábitos sobre um SQLite em memória (progresso da meta, XP, fila de sync). O motor de sync contra o Supabase não tem teste automatizado.

<br/>

---

<p align="center">
  <br/>
  <img src="https://img.shields.io/badge/showcase-Flutter-02569B?style=flat-square&logo=flutter&logoColor=white" alt="Flutter"/>
  &emsp;
  <strong>PULSE</strong> — pequenos passos repetidos mudam dias inteiros.
  <br/><br/>
</p>
