<p align="center">
  <img src="docs/readme-banner.svg" alt="Pulse — aplicativo de hábitos com linha pulsante em gradiente" width="920"/>
</p>

<p align="center">
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter"/></a>
  <a href="https://dart.dev"><img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart"/></a>
  <a href="https://riverpod.dev"><img src="https://img.shields.io/badge/Riverpod-146C2E?style=for-the-badge&logo=flutter&logoColor=white" alt="Riverpod"/></a>
  <a href="https://supabase.com"><img src="https://img.shields.io/badge/Supabase-3FCF8E?style=for-the-badge&logo=supabase&logoColor=1a1a1a" alt="Supabase"/></a>
  <a href="https://drift.simonbinder.eu"><img src="https://img.shields.io/badge/SQLite%20%28Drift%29-7C83FF?style=for-the-badge&logo=sqlite&logoColor=white" alt="Drift SQLite"/></a>
</p>

<br/>

<h2 align="center">📱 Um app pensado pra rotina de verdade</h2>

<p align="center"><strong>Pulse</strong> transforma hábitos em algo <strong>direto</strong>: menos fricção, mais clareza no que você prometeu fazer — e feedback leve quando você fecha o dia.<br/><br/>
<sub>Ótimo para quem só quer um app que abre rápido, mostra <strong>hoje</strong>, e registra conquistas sem esforço.</sub></p>

<p align="center">
  <img src="https://img.shields.io/badge/Offline--first-SQLite-1e1b4b?style=for-the-badge&logo=database&labelColor=312e81&color=4338ca" alt="Offline-first SQLite"/>
  &nbsp;&nbsp;
  <img src="https://img.shields.io/badge/Navega%C3%A7%C3%A3o-go_router-1e293b?style=for-the-badge&labelColor=0f172a&color=334155" alt="go_router"/>
</p>

<br/>

<h2 align="center">⭐ O que existe hoje no produto</h2>

<br/>

<table>
  <tr>
    <td width="33%" valign="top" align="center">
      <img src="https://img.shields.io/badge/HOJE-vis%C3%A3o%20do%20dia-6366f1?style=for-the-badge&labelColor=1e1b4b"/><br/><br/>
      <b>Lista “hoje só o que conta”</b><br/><br/>
      <small>Hábitos filtrados pelos dias da semana.<br/><b>Toque</b> para marcar ou desmarcar.<br/><i>Gestos simples · feedback imediato</i></small>
    </td>
    <td width="34%" valign="top" align="center">
      <img src="https://img.shields.io/badge/H%C3%81BITOS-criar%20e%20editar-38bdf8?style=for-the-badge&labelColor=164e63"/><br/><br/>
      <b>Do zero ao hábito em segundos</b><br/><br/>
      <small>Nome, categoria, ícone e cor.<br/><b>Meta numérica</b> + <b>unidade</b> livre:<br/><i>km, copos, min, páginas… você escolhe o contexto</i></small>
    </td>
    <td width="33%" valign="top" align="center">
      <img src="https://img.shields.io/badge/M%C3%89TRICAS-sequ%C3%AAncia-a855f7?style=for-the-badge&labelColor=581c87"/><br/><br/>
      <b>Consistência em números</b><br/><br/>
      <small>Sequência atual.<br/><b>Histórico</b> de melhor série.<br/>Taxa de conclusão em janela de ~30 dias</small>
    </td>
  </tr>
  <tr><td colspan="3"><br/></td></tr>
  <tr>
    <td valign="top" align="center">
      <img src="https://img.shields.io/badge/LEMBRETES-v%C3%A1rios%20hor%C3%A1rios-f472b6?style=for-the-badge&labelColor=831843"/><br/><br/>
      <b>Vários pings no mesmo dia</b><br/><br/>
      <small><b>Vários horários por hábito</b> no banco<br/>+ opção de <b>gerar distribuição</b> ao longo do dia<br/><i>(pipeline de OS notification = próximo passo natural)</i></small>
    </td>
    <td valign="top" align="center">
      <img src="https://img.shields.io/badge/CONTA-login%20%26%20onboarding-white?style=for-the-badge&labelColor=374151"/><br/><br/>
      <b>Experiência de primeiro uso completa</b><br/><br/>
      <small>Splash · login · onboarding<br/><b>Google & e-mail</b> quando Supabase está configurado.<br/><i>Roda também sem backend para demos de UI.</i></small>
    </td>
    <td valign="top" align="center">
      <img src="https://img.shields.io/badge/UI-glass%20%26%20tema-oscur-22c55e?style=for-the-badge&labelColor=14532d"/><br/><br/>
      <b>Visual atual, sem poluição</b><br/><br/>
      <small>Painéis “glass”.<br/>Tema coeso · animações onde ajudam<br/><i>Fluxo navegável e estados bem definidos.</i></small>
    </td>
  </tr>
</table>

<br/>

<h2 align="center">🗺️ Fluxo do app — visão rápida</h2>

```mermaid
flowchart LR
    A([Splash]) --> B{{Logado?}}
    B -->|Não| C[Login]
    B -->|Sim| D{{Onboarding ok?}}
    D -->|Não| E[Onboarding]
    D -->|Sim| F[App — abas]
    C --> D
    E --> F
    F --> G[Hoje]
    F --> H[Hábitos]
    F --> I[Perfil]
    G & H --> J[(Drift / SQLite)]
    C --> K[(Supabase auth)]
```

<br/>

<h2 align="center">🧱 Stack — o que entra no PR</h2>

| Camada | Ferramentas |
|:--|:--|
| **App** | Flutter · Material 3 |
| **Estado** | Riverpod |
| **Rotas** | go_router |
| **Persistência** | Drift + SQLite |
| **Auth (opcional)** | Supabase · Google Sign-In |

<p align="center"><sub>Detalhes de versão no <code>pubspec.yaml</code>.</sub></p>

<br/>

<h2 align="center">📂 Onde está cada coisa</h2>

```
lib/
├── core/           tema · router · database (Drift) · utilitários
├── features/       auth · habits (domínio, dados, telas)
├── providers/
└── main.dart
```

<br/>

<h2 align="center">🚀 Clonar e rodar</h2>

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

<p align="center"><small>Supabase via <code>--dart-define=SUPABASE_URL=...</code> e <code>SUPABASE_ANON_KEY=...</code> · modelos em <code>.vscode/*.example.json</code> · <b>não commite chaves</b>.</small></p>

---

<p align="center">
  <br/>
  <img src="https://img.shields.io/badge/showcase-Flutter-02569B?style=flat-square&logo=flutter&logoColor=white" alt="showcase Flutter"/>
  &emsp;
  <strong>PULSE</strong> — pequenos passos repetidos mudam dias inteiros.
  <br/><br/>
</p>
