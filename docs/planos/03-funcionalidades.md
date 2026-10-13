# Plano 3 — Funcionalidades incompletas

## 3.1 Meta numérica com progresso — PRECISA DA SUA DECISÃO

Hoje a meta ("8 copos") é só um rótulo; o toque grava sempre quantidade 1.

- **Regra proposta:** a linha de conclusão guarda a quantidade feita; o hábito conta como **concluído** quando `quantidade >= meta`.
- **Interação:**
  - Meta = 1: toque marca/desmarca, como hoje.
  - Meta > 1: toque abre um painel com progresso (`3 / 8 copos`), botões −1 / +1, campo numérico, "Concluir" e "Zerar".
  - O item do checklist mostra uma barra de progresso parcial.
- **Arquivos:**
  - `app_database.dart`: leituras de "concluído" passam a filtrar `quantity >= daily_target`; leitura crua para o progresso.
  - `habits_repository.dart`: novo `setProgress`; `toggleCompletion` grava a meta inteira.
  - `habit_today_row.dart`, `today_habit_checklist.dart`: quantidade e UI.
  - XP e conquistas só disparam ao cruzar a meta.
- **Dados existentes:** migração local (schema v5, sem regenerar código) eleva as conclusões antigas para o valor da meta, para o histórico não virar "incompleto".
- **Efeito colateral:** aumentar a meta depois reescreve as conclusões já completas para a nova meta, preservando o histórico.
- **Alternativa mais simples:** manter o toque único e tirar a meta numérica do formulário.

## 3.2 Redefinição de senha e confirmação de e-mail

- **Problema:** o e-mail é enviado, mas o link não volta para o app e não existe tela de nova senha.
- **Mudança:**
  - `AuthRepository`: `resetPasswordForEmail` e `signUp` com `redirectTo: pulse://auth-callback`; novo `updatePassword`.
  - Nova tela `lib/features/auth/presentation/reset_password_screen.dart` (nova senha + confirmação).
  - `pulse_app.dart`: ao receber `AuthChangeEvent.passwordRecovery`, abrir essa tela.
  - `app_router.dart`: rota `/reset-password`.
- **Já feito:** scheme `pulse://auth-callback` registrado no Android e no iOS.
- **Ação sua:** adicionar `pulse://auth-callback` em Authentication → URL Configuration → Redirect URLs no Supabase.

## 3.3 Onboarding, passo 3

- **Problema:** pede para "nomear uma rotina" e não tem campo.
- **Mudança:** campo de texto opcional; se preenchido, cria o primeiro hábito (todos os dias, sem lembrete) ao continuar.
- **Tabela `profiles`:** o upsert hoje falha em silêncio porque a tabela não existe no script. Adicionar a tabela e a política RLS em `docs/supabase_pulse_sync.sql` e numa migração.

## 3.4 Gamificação na nuvem — PRECISA DA SUA DECISÃO

- **Problema:** reinstalar zera XP e conquistas.
- **Proposta:** tabela `pulse_gamification` (uma linha por usuário: XP total, nível, lista de conquistas).
  - Envio pela fila após cada ganho de XP.
  - No pull: fica o maior XP; conquistas são unidas.
  - A Edge Function `delete-account` passa a apagar essa tabela também.
- **Limitação conhecida:** os registros "XP já concedido hoje" não sincronizam; num aparelho novo dá para ganhar de novo o XP de hoje, uma vez.
- **Alternativa:** deixar só local, como o README já documenta.

## 3.5 Dependências sem uso

- **Remover do `pubspec.yaml`:** `home_widget`, `freezed_annotation`, `json_annotation`, `riverpod_annotation`, `flutter_secure_storage`, `path_provider`, `path`; dev: `freezed`, `json_serializable`, `riverpod_generator`.
- **Verificação:** `grep` confirmando zero imports antes de remover; `flutter pub get` e `flutter analyze` depois.

## 3.6 Testes

Novos testes unitários (sem banco nem rede):

- `habit_metrics_test.dart`: sequência, melhor sequência, taxa de 30 dias, data de criação.
- `dashboard_builder_test.dart`: heatmap, dias perfeitos, barras.
- `level_curve_test.dart`: limites de nível.
- `habit_reminder_times_codec_test.dart`: encode/decode e distribuição.
- `insight_engine_test.dart`: casos sem hábitos e com humor.

## Fora do escopo

- **Analytics:** continua no-op. Depende de você escolher um provedor (Firebase, PostHog…).

## Validação da fase

- `flutter analyze` e `flutter test`.
- Manual: fluxo "esqueci a senha" de ponta a ponta em aparelho; hábito com meta 8 do zero até concluir.
