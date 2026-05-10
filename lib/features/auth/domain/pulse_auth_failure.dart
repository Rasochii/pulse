import '../../../core/config/app_env.dart';

/// Falha controlada na camada de autenticação (mensagem pronta para o usuário).
class PulseAuthFailure implements Exception {
  const PulseAuthFailure(this.message);

  factory PulseAuthFailure.supabaseMissing() => const PulseAuthFailure(
        'Defina SUPABASE_URL e SUPABASE_ANON_KEY ao rodar o app (--dart-define).',
      );

  factory PulseAuthFailure.secretKeyInClient() =>
      PulseAuthFailure(AppEnv.warningSecretKeyInFlutter);

  final String message;

  @override
  String toString() => message;
}
