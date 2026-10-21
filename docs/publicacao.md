# Publicação na Play Store: o que falta fazer

Roteiro na ordem sugerida. Os itens de código já estão no repositório; aqui ficam só os passos manuais.

## 1. Preencher a política de privacidade (antes do merge do PR)

Em `web/privacidade.html` e `web/excluir-conta.html`, troque os marcadores:

- `[PREENCHER: seu nome completo]`: o responsável pelos dados (pessoa física ou empresa);
- `[PREENCHER: e-mail de contato]`: um e-mail que você leia. Ele fica público; um e-mail só para o app
  (ex.: `pulse.app.contato@gmail.com`) evita expor o pessoal.

Depois do merge, as páginas ficam em:

- https://rasochii.github.io/pulse/privacidade.html
- https://rasochii.github.io/pulse/excluir-conta.html

> Recomendado: revisão por um advogado. O app trata humor, que é dado sensível pela LGPD.

## 2. GitHub Pages

Settings › Pages › **Source: GitHub Actions**. Hoje está em "Deploy from a branch" (legacy), e o README
disputa o site com o app. Sem isso, as páginas da política também podem não aparecer.

## 3. Keystore de release (PowerShell)

Gere a chave **fora do repositório**:

```powershell
& "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe" -genkeypair -v `
  -keystore "$env:USERPROFILE\pulse-upload.jks" `
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Ele pede uma senha (guarde) e nome/organização (pode preencher só o nome e confirmar o resto).

Crie `android/key.properties` (já ignorado pelo Git):

```properties
storeFile=C:/Users/Rafael/pulse-upload.jks
storePassword=SUA_SENHA
keyAlias=upload
keyPassword=SUA_SENHA
```

> **Backup obrigatório:** copie `pulse-upload.jks` e as senhas para dois lugares seguros (ex.: gerenciador de
> senhas e um pendrive/nuvem pessoal). Sem eles não dá para enviar atualizações do app.
>
> Com o Play App Signing (padrão), a Google guarda a chave final; a sua é a "chave de upload". Se perdê-la,
> dá para pedir a troca ao suporte da Play, mas o processo demora.

Pegue o SHA-1 da chave:

```powershell
& "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe" -list -v `
  -keystore "$env:USERPROFILE\pulse-upload.jks" -alias upload
```

Gere o pacote para a loja (aumente o `+N` de `version:` no `pubspec.yaml` a cada envio):

```powershell
$cfg = (Get-Content .vscode\launch.json -Raw | ConvertFrom-Json).configurations | Where-Object name -eq 'Pulse + Supabase'
flutter build appbundle --release @($cfg.toolArgs)
```

O arquivo sai em `build\app\outputs\bundle\release\app-release.aab`.

## 4. Google Cloud (login com Google)

Em APIs e serviços › Credenciais, um cliente OAuth **Android** por SHA-1, todos com o pacote
`com.rasochii.pulse`:

| Cliente | SHA-1 | Onde pegar |
|:--|:--|:--|
| Debug | `54:9D:E9:66:7E:95:E5:87:A5:A4:BD:B5:4F:FB:93:B1:E2:F2:21:93` | já conhecido (esta máquina) |
| Upload | o da sua keystore | comando do passo 3 |
| Play App Signing | o da Google | Play Console › Configuração › Integridade do app, depois do primeiro envio |

Sem o terceiro, o login com Google funciona no APK que você instala mas **falha na versão baixada da loja**.

## 5. Supabase

- **SQL Editor:** rodar, se ainda não rodou, `docs/migrations/2026-10-04_wellbeing_tombstone.sql`,
  `2026-10-05_app_config.sql` e `2026-10-06_habit_sort_order.sql`;
- **Exclusão de conta:** `supabase functions deploy delete-account` (precisa da CLI do Supabase e
  `supabase login`), ou cole `supabase/functions/delete-account/index.ts` no editor da função no painel
  (Edge Functions › delete-account › Code) e clique em Deploy. Teste excluindo uma conta de teste pelo app;
- **Authentication › URL Configuration:** adicionar `https://rasochii.github.io/pulse/` às Redirect URLs;
- **Authentication › Providers › Google:** preencher o Client Secret (login com Google na web);
- **Authentication › Emails › SMTP:** configurar um SMTP próprio (ex.: Resend, com domínio verificado). O
  padrão do Supabase só entrega e-mail para os membros da organização e manda cerca de 2 por hora: sem
  SMTP próprio, quem se cadastra com e-mail não recebe a confirmação. Depois, subir o limite em
  Authentication › Rate Limits;
- **app_config:** `store_url` é opcional no Android (sem ele, o app monta o link da Play pelo pacote);
  só é necessário na linha `ios`, com o link da App Store.

## 6. Play Console

1. Criar o app (nome, idioma pt-BR, app gratuito);
2. **Política de privacidade:** URL do passo 1;
3. **Segurança dos dados:**
   - Coleta: sim. Criptografia em trânsito: sim. Exclusão de conta: sim, com a URL de `excluir-conta.html`;
   - Informações pessoais: **e-mail** e **nome** (funcionalidade do app, gestão da conta);
   - Saúde e condicionamento físico: **informações de saúde** (humor e energia; funcionalidade do app; opcional);
   - Atividade no app: **outro conteúdo gerado pelo usuário** (hábitos e anotações; funcionalidade do app);
   - Informações e desempenho do app: **registros de falhas** e **diagnóstico** (Sentry; análise);
   - Nada é compartilhado com terceiros para outros fins (fornecedores que processam em seu nome não contam
     como "compartilhamento");
4. **Classificação de conteúdo:** questionário (sem violência, sem conteúdo adulto → livre);
5. **Público-alvo:** 13 anos ou mais (é o que a política diz);
6. **Anúncios:** não contém anúncios;
7. **Acesso ao app:** como o login é opcional ("Continuar sem conta"), informe que não há restrição; ou
   forneça uma conta de teste;
8. **Ficha da loja:** ícone 512×512, imagem de destaque 1024×500, pelo menos 2 capturas de tela do celular,
   descrição curta (até 80 caracteres) e completa;
9. **Teste fechado** (conta pessoal criada depois de nov/2023): 12 testadores por 14 dias seguidos antes de
   pedir o acesso à produção.

## 7. A cada nova versão

1. Aumentar o `+N` de `version:` no `pubspec.yaml`;
2. `flutter build appbundle --release` com as chaves (passo 3);
3. Enviar o `.aab` no Play Console;
4. Para forçar atualização de versões antigas: `min_build` na tabela `app_config`.
