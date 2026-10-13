# Plano 5 — Fluxos que não fechavam

Levantados numa leitura de ponta a ponta depois do teste em aparelho. Ordem de execução: 5.1 → 5.9.

## 5.1 Marcar um dia esquecido

- **Problema:** o checklist só trabalha com hoje; quem esquece de marcar perde a sequência sem conserto.
- **Mudança:** seletor de dia no checklist (hoje + 6 dias anteriores).
  - `habits_providers.dart`: `checklistDayOffsetProvider` (0 = hoje) e `checklistDayProvider`; `todayHabitsProvider` passa a usar o dia escolhido.
  - `HabitsRepository.todayRows`: só lista o hábito se ele já existia no dia (`isHabitExpectedOn`).
  - `today_habit_checklist.dart`: chips de dia, gravação no dia escolhido, textos do painel de progresso.
  - `dashboard_tab.dart`: título do checklist acompanha o dia.
- **Limite de 7 dias:** corrige esquecimento sem permitir reescrever o histórico inteiro.

## 5.2 Onboarding repetido em aparelho novo

- **Problema:** "onboarding feito" fica só no aparelho; `profiles.onboarding_completed_at` é gravado e nunca lido. Em aparelho novo o onboarding reaparece e pode duplicar o primeiro hábito.
- **Mudança:** `AuthRepository.isOnboardingDone(userId)`: aparelho → `profiles` → (contas antigas) existência de algum hábito remoto. Resultado positivo é gravado no aparelho. Router e splash passam a usar esse método.
- **Sem rede:** vale só o aparelho; a consulta é refeita na próxima navegação.

## 5.3 Lembrete com notificação bloqueada

- **Problema:** dá para ligar lembretes com a permissão negada, sem aviso; o onboarding promete "ativar depois nas configurações" e essa tela não existe; mensagens citam iPhone no Android.
- **Mudança:**
  - `notification_permission.dart`: consulta/pedido de permissão e `NotificationPermissionBuilder` (reavalia ao voltar para o app).
  - Formulário do hábito: aviso com botão quando lembretes estão ligados e a permissão não.
  - Perfil: item "Lembretes" com o estado da permissão e atalho para ativar.
  - Onboarding: textos neutros de plataforma, apontando para o Perfil.

## 5.4 Cadastro com e-mail já usado

- **Contexto:** a confirmação por e-mail foi desativada no Supabase; "reenviar e-mail" deixa de ser necessário.
- **Mudança:** mensagem clara para `user_already_exists` / `email_exists`; `signUpWithEmail` detecta a resposta "disfarçada" (usuário sem identidades) caso a confirmação volte a ser ligada.

## 5.5 Manutenção da conta

- **Problema:** não dá para editar o nome nem trocar a senha logado.
- **Mudança:** `AuthRepository.updateDisplayName` e `hasPasswordLogin`; no Perfil, lápis no cartão da conta e item "Trocar senha" (só para contas com senha).

## 5.6 Apagar check-in de humor

- **Problema:** registro errado fica para sempre no histórico e nas médias.
- **Mudança:** lixeira em cada item do histórico, com confirmação.
- **Sync:** tombstone remoto, como nas conclusões.
  - `docs/migrations/2026-10-04_wellbeing_tombstone.sql`: `updated_at_ms` e `deleted_at_ms` em `pulse_wellbeing_logs`.
  - Pull de humor passa a usar `updated_at_ms` como marca d'água e remove localmente o que veio com `deleted_at_ms`.
  - O tombstone é enviado sem a nota.
- **Ação manual:** rodar a migração no Supabase; sem ela o sync de humor falha.

## 5.7 Aviso ao excluir hábito

- **Mudança:** o diálogo passa a dizer que o histórico sai das estatísticas e que não há como desfazer.
- **Fora do escopo:** pausar/arquivar hábito (exige coluna nova local e remota, filtros em todas as métricas).

## 5.8 XP ao desmarcar

- **Decisão:** mantido. Desmarcar não devolve XP; o registro de XP por hábito/dia impede ganhar duas vezes. Retirar XP exigiria guardar o valor ganho em cada marcação.

## 5.9 Textos

- Português do Brasil no Perfil ("Excluindo conta…", texto da zona de risco).
- Estado vazio do histórico de humor e dos insights.
- Erros de autenticação não mapeados deixam de aparecer em inglês.

## Decisão de produto em aberto

- A versão da loja exige conta na primeira tela; o modo sem login só existe em build sem Supabase.

## Validação

- `flutter analyze` e `flutter test`.
- Manual: marcar hábito de ontem e ver a sequência voltar; entrar numa conta existente em instalação limpa e não ver o onboarding; negar notificações e ver o aviso no formulário; trocar nome e senha; apagar um check-in e conferir no segundo aparelho.

## 5.10 Humor e insights (adendo)

- **Janela de 7 dias:** o insight de humor usava os últimos 7 check-ins, mesmo antigos; passa a usar só os dos últimos 7 dias.
- **Correlação humor × hábitos:** a frase já era calculada e só aparecia no cartão grande, que não é usado; passa a aparecer no cartão do Início.
- **"Energia alta" → "Humor em alta":** o insight usa o humor, não a energia.
- **Aviso:** rodapé na aba Insights (dicas gerais, não substituem orientação médica ou psicológica) e, no insight de humor baixo, sugestão de procurar um profissional se a fase se prolongar.
- **Fora do código:** política de privacidade tratando o humor como dado sensível (LGPD) e declarações da Play (segurança dos dados, apps de saúde) — revisar com advogado.

## 5.11 Usar sem conta (adendo)

- **Decisão revista:** a conta deixa de ser obrigatória. Sem conta, nada vai para o Supabase.
- **O app já era offline-first:** tudo é lido e gravado no SQLite local; a nuvem é uma fila de envio em segundo plano. Só o login precisava de internet.
- **Mudança:**
  - `AuthRepository`: `isGuest` (escolha gravada no aparelho ou build sem Supabase); `currentUserId` devolve o usuário local nesse caso.
  - Login: "Continuar sem conta"; quem já está sem conta chega ao login pelo Perfil e pode voltar.
  - `SyncOutboxWriter`: não enfileira nada enquanto não há sessão.
  - Perfil: "Criar conta ou entrar" no lugar de "Sair" e "Excluir conta".
- **Ao criar conta ou entrar:** os dados do aparelho passam para a conta (`PulseDatabase.reassignUserData`) e são enfileirados para subir (`enqueueAllForUser`). XP: fica o maior entre aparelho e conta.
- **Limites conhecidos:** sem conta não há backup (desinstalar apaga tudo); não há botão para apagar os dados locais sem conta; entrar numa conta de outra pessoa no mesmo aparelho junta os dados locais a ela.

## 5.12 Versão web (PWA) no GitHub Pages (adendo)

- **Banco:** `driftDatabase` com `DriftWebOptions`; `web/sqlite3.wasm` (sqlite3 2.9.4) e `web/drift_worker.js` (drift 2.28.2) vêm das releases dos pacotes e precisam acompanhar as versões do `pubspec.lock`. Sem os cabeçalhos COOP/COEP do Pages, o armazenamento é IndexedDB.
- **Lembretes:** não existem no navegador (`kRemindersSupported`): somem do formulário, do Perfil e do onboarding; horários já salvos são preservados.
- **Login com Google:** na web é por redirecionamento (`signInWithOAuth`); o plugin nativo só é criado no primeiro uso, porque na web ele se inicializa sozinho e falha sem client ID.
- **Dados criados sem conta:** a passagem para a conta também roda no splash e no evento `signedIn`, para cobrir a volta do redirecionamento.
- **Rotas:** estratégia de URL padrão (com `#`), sem 404 ao recarregar.
- **Deploy:** `.github/workflows/deploy-web.yml` (push em `main`), com `SUPABASE_URL`/`GOOGLE_WEB_CLIENT_ID` em Variables e `SUPABASE_ANON_KEY` em Secrets.
- **Configuração externa:** URL do Pages nas Redirect URLs do Supabase; para o Google na web, Client Secret preenchido no provedor Google do Supabase.
