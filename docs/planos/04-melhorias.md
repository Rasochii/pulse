# Plano 4 — Melhorias

## 4.1 Localização pt-BR

- **Problema:** seletor de horário e diálogos do sistema aparecem em inglês.
- **Mudança:** adicionar `flutter_localizations` ao `pubspec.yaml`; em `pulse_app.dart`, definir `locale: pt_BR`, `supportedLocales` e `localizationsDelegates`.

## 4.2 Não lembrar de hábito já concluído

- **Arquivo:** `lib/core/notifications/habit_notification_scheduler.dart`.
- **Mudança:** ao reagendar, se o hábito já foi concluído hoje, os lembretes de hoje começam só na próxima semana.
- **Gatilho:** reagendar (sem bloquear a UI) após marcar/desmarcar.

## 4.3 Conquistas calculadas em memória

- **Arquivo:** `lib/features/gamification/data/gamification_coordinator.dart`.
- **Problema:** `_unlockByRules` faz uma consulta por dia × hábito a cada toque.
- **Mudança:** carregar hábitos e conclusões uma vez e calcular dias perfeitos e melhor sequência em memória.

## 4.4 Mensagens de erro

- **Problema:** 12 pontos mostram `$e` cru ao usuário.
- **Mudança:** helper `friendlyError(e)` em `core/presentation/` com texto genérico em português (e detalhe só em debug); aplicar em dashboard, listas, formulário, perfil e humor.

## 4.5 Virada do dia

- Coberto pelo plano 2.4 (invalidar ao voltar do segundo plano).
- **Extra:** timer no shell para invalidar o checklist à meia-noite com o app aberto.

## 4.6 Validação de e-mail no login

- Trocar o `contains('@')` por uma expressão regular simples.

## Fora do escopo

- **Relógio dos aparelhos no LWW:** resolver de verdade exige carimbo de tempo do servidor (trigger no Postgres) e mudar o protocolo de sync. Fica como evolução futura, registrada no README.

## Validação da fase

- `flutter analyze` e `flutter test`.
- Manual: seletor de horário em português; marcar hábito antes do horário do lembrete e confirmar que ele não toca.
