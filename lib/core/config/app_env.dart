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

  static bool get hasSupabase =>
      supabaseUrl.trim().isNotEmpty && supabaseAnonKey.trim().isNotEmpty;

  /// Chaves `sb_secret_...` são só para servidor — no app deve-se usar publishable ou anon JWT.
  static bool get usesSecretSupabaseKeyInClient =>
      supabaseAnonKey.trim().toLowerCase().startsWith('sb_secret_');

  static String get warningSecretKeyInFlutter =>
      'SUPABASE_ANON_KEY está como sb_secret_… — isso é chave secreta (só servidor) e vai falhar no app. '
      'No projeto Supabase use a chave Publishable (sb_publishable_…) ou a anon JWT (que começa com eyJ) '
      'em --dart-define=SUPABASE_ANON_KEY= quando rodar flutter run.';
}
