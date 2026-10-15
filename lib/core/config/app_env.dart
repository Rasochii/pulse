/// Configure via: `flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`
abstract final class AppEnv {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  /// Client ID OAuth do tipo **Web** (Google Cloud) — o mesmo configurado no provedor
  /// Google do Supabase. Sem ele o Android não devolve `idToken`.
  static const String googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue: '',
  );

  /// Client ID OAuth do tipo **iOS** (opcional se usar `GoogleService-Info.plist`).
  static const String googleIosClientId = String.fromEnvironment(
    'GOOGLE_IOS_CLIENT_ID',
    defaultValue: '',
  );

  /// DSN do projeto no Sentry (relatório de falhas). Não é segredo; vazio
  /// desliga o envio.
  static const String sentryDsn = String.fromEnvironment(
    'SENTRY_DSN',
    defaultValue: '',
  );

  static bool get hasSentry => sentryDsn.trim().isNotEmpty;

  static bool get hasSupabase =>
      supabaseUrl.trim().isNotEmpty && supabaseAnonKey.trim().isNotEmpty;

  static bool get hasGoogleSignIn => googleWebClientId.trim().isNotEmpty;

  /// Chaves `sb_secret_...` são só para servidor — no app deve-se usar publishable ou anon JWT.
  static bool get usesSecretSupabaseKeyInClient =>
      supabaseAnonKey.trim().toLowerCase().startsWith('sb_secret_');

  static String get warningSecretKeyInFlutter =>
      'SUPABASE_ANON_KEY está como sb_secret_… — isso é chave secreta (só servidor) e vai falhar no app. '
      'No projeto Supabase use a chave Publishable (sb_publishable_…) ou a anon JWT (que começa com eyJ) '
      'em --dart-define=SUPABASE_ANON_KEY= quando rodar flutter run.';
}
