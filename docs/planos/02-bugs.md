# Plano 2 — Bugs

Objetivo: números corretos na tela e sincronização confiável entre aparelhos.

## 2.1 Sequência zera todo dia

- **Arquivo:** `lib/features/habits/domain/habit_metrics.dart` (`_currentStreak`).
- **Mudança:** se hoje é dia agendado e ainda não foi marcado, começar a contagem por ontem em vez de quebrar a série.
- **Teste:** novo `test/habit_metrics_test.dart` (hoje pendente mantém a série; ontem perdido zera).

## 2.2 Métricas ignoram a data de criação do hábito

- **Regra nova:** um hábito só é "esperado" em dias a partir do dia em que foi criado.
- **Arquivos:**
  - `habit_metrics.dart`: `computeHabitMetrics` recebe `createdAtMs`; a janela de 30 dias começa na criação.
  - `dashboard_builder.dart`: heatmap, sequência de dias perfeitos e top hábitos (14 d).
  - `gamification_coordinator.dart`: `_isPerfectDay`.
  - `insight_engine.dart` e `wellbeing_summary.dart`: taxa por dia.
- **Implementação:** helper único `isHabitExpectedOn(habit, day)` em `core/utils/date_key.dart`.
- **Teste:** hábito criado hoje com 1 conclusão dá 100%; dias anteriores ficam "muted" no heatmap.

## 2.3 Motor de sync (`lib/core/sync/`)

Itens interligados, feitos juntos.

| # | Problema | Mudança |
|---|---|---|
| a | Marcar hábito ou humor não envia nada | Chamar `flushOutbox` (sem bloquear a UI) após toggle e check-in |
| b | Humor nunca é baixado | `pullRemote` passa a buscar `pulse_wellbeing_logs`; nova marca d'água; upsert local |
| c | Desmarcar não propaga | Exclusão vira "tombstone": upsert remoto com `deleted_at_ms`; o pull apaga a linha local |
| d | Marcas d'água globais | Chaves do `SyncWatermarkStore` passam a incluir o `userId` |
| e | Pull truncado em 1000 linhas | Paginação com `.range()` e ordenação estável |
| f | Fila trava com itens ruins | Processar a fila inteira; erro de rede aborta sem contar tentativa; rejeição do servidor conta, e após 8 o item sai da fila ativa (fica guardado) |
| g | Itens de outro usuário são apagados da fila | Passam a ser ignorados, não apagados |
| h | Flushes concorrentes | Trava simples para não rodar dois ao mesmo tempo |

- **Mudança de esquema remoto (item c):** `pulse_habit_completions` ganha `updated_at_ms bigint` e `deleted_at_ms bigint`.
- **Migração:** `docs/migrations/2026-10-02_completions_tombstone.sql` (com backfill `updated_at_ms = completed_at_ms`); `docs/supabase_pulse_sync.sql` atualizado.
- **Ação sua:** rodar a migração no Supabase.
- **Sem mudança no esquema local** (nada de regenerar código Drift nesta fase).

## 2.4 Tela não atualiza depois do pull

- **Arquivo:** `lib/features/habits/presentation/app_shell_screen.dart`.
- **Mudança:** após `bootstrap`, invalidar checklist, dashboard, insights, humor e gamificação, e reagendar lembretes.
- **Extra:** ao voltar do segundo plano (`AppLifecycleState.resumed`), sincronizar e invalidar de novo. Isso também resolve a virada do dia.

## 2.5 Conquistas desatualizadas e sem aviso

- **Arquivos:** `app_providers.dart`, `today_habit_checklist.dart`.
- **Mudança:** o hook de conclusão guarda as conquistas recém-desbloqueadas; o checklist invalida `unlockedAchievementsProvider` e mostra um snackbar ("Conquista desbloqueada: …").

## 2.6 Chaves estrangeiras desligadas no SQLite

- **Arquivo:** `lib/core/database/app_database.dart`.
- **Mudança:** `beforeOpen` com `PRAGMA foreign_keys = ON`.
- **Reforço:** `wipeAllLocalDataForUser` apaga explicitamente conclusões e registros de XP antes dos hábitos.

## Validação da fase

- `flutter analyze` e `flutter test` (com os testes novos de métricas e dashboard).
- Sync não tem como ser testado sem um projeto Supabase; fica roteiro manual:
  1. Criar hábito e marcar no aparelho A; conferir as linhas no Supabase.
  2. Abrir no aparelho B e ver hábito e conclusão.
  3. Desmarcar em A; conferir que some em B.
