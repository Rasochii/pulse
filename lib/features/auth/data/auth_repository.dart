import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/app_env.dart';
import '../domain/auth_error_messages.dart';
import '../domain/pulse_auth_failure.dart';

class AuthRepository {
  AuthRepository({GoogleSignIn? googleSignIn})
      : _googleSignIn = googleSignIn ??
            GoogleSignIn(
              serverClientId:
                  AppEnv.hasGoogleSignIn ? AppEnv.googleWebClientId : null,
              clientId: AppEnv.googleIosClientId.trim().isEmpty ||
                      defaultTargetPlatform != TargetPlatform.iOS
                  ? null
                  : AppEnv.googleIosClientId,
            );

  /// Dono dos dados quando o app roda sem Supabase (modo local, sem conta).
  static const localUserId = 'local';

  /// Deep link de retorno dos e-mails do Supabase Auth (confirmação / redefinição de senha).
  static const authRedirectUrl = 'pulse://auth-callback';

  final GoogleSignIn _googleSignIn;

  /// O app foi aberto por um link de redefinição e a nova senha ainda não foi definida.
  /// O router usa isto para não perder a tela de nova senha numa abertura a frio.
  bool passwordRecoveryPending = false;

  bool get canUseSupabase => AppEnv.hasSupabase;

  /// `false` quando a URL/chave existe mas usa `sb_secret_` no cliente — auth falhará.
  bool get isClientKeyAccepted =>
      AppEnv.hasSupabase && !AppEnv.usesSecretSupabaseKeyInClient;

  bool get canUseGoogle => isClientKeyAccepted && AppEnv.hasGoogleSignIn;

  Stream<AuthState> get authStateChanges {
    if (!canUseSupabase) {
      return const Stream.empty();
    }
    return Supabase.instance.client.auth.onAuthStateChange;
  }

  Session? get currentSession =>
      canUseSupabase ? Supabase.instance.client.auth.currentSession : null;

  User? get currentUser =>
      canUseSupabase ? Supabase.instance.client.auth.currentUser : null;

  /// Id da sessão Supabase ou [localUserId] no modo local; `null` = precisa de login.
  String? get currentUserId => canUseSupabase ? currentUser?.id : localUserId;

  String? get _redirectUrl => kIsWeb ? null : authRedirectUrl;

  void _rejectSecretKeyIfNeeded() {
    if (!AppEnv.hasSupabase) return;
    if (AppEnv.usesSecretSupabaseKeyInClient) {
      throw PulseAuthFailure.secretKeyInClient();
    }
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (!canUseSupabase) throw PulseAuthFailure.supabaseMissing();
    _rejectSecretKeyIfNeeded();
    try {
      final res =
          await Supabase.instance.client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      if (res.session == null) {
        throw const PulseAuthFailure(
          'Não foi possível entrar na conta — verifique se o e-mail foi confirmado no Supabase.',
        );
      }
    } on PulseAuthFailure {
      rethrow;
    } catch (e) {
      throw PulseAuthFailure(AuthErrorMessages.from(e));
    }
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    if (!canUseSupabase) throw PulseAuthFailure.supabaseMissing();
    _rejectSecretKeyIfNeeded();
    try {
      await Supabase.instance.client.auth.signUp(
        email: email.trim(),
        password: password,
        emailRedirectTo: _redirectUrl,
        data: displayName == null ? null : {'full_name': displayName},
      );
    } on PulseAuthFailure {
      rethrow;
    } catch (e) {
      throw PulseAuthFailure(AuthErrorMessages.from(e));
    }
  }

  Future<void> resetPassword({required String email}) async {
    if (!canUseSupabase) throw PulseAuthFailure.supabaseMissing();
    _rejectSecretKeyIfNeeded();
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(
        email.trim(),
        redirectTo: _redirectUrl,
      );
    } on PulseAuthFailure {
      rethrow;
    } catch (e) {
      throw PulseAuthFailure(AuthErrorMessages.from(e));
    }
  }

  /// Define a nova senha da sessão atual (após abrir o link de redefinição).
  Future<void> updatePassword(String newPassword) async {
    if (!canUseSupabase) throw PulseAuthFailure.supabaseMissing();
    _rejectSecretKeyIfNeeded();
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      passwordRecoveryPending = false;
    } on PulseAuthFailure {
      rethrow;
    } catch (e) {
      throw PulseAuthFailure(AuthErrorMessages.from(e));
    }
  }

  /// Login nativo Google + troca por sessão Supabase.
  Future<void> signInWithGoogle() async {
    if (!canUseSupabase) throw PulseAuthFailure.supabaseMissing();
    _rejectSecretKeyIfNeeded();
    if (!AppEnv.hasGoogleSignIn) {
      throw const PulseAuthFailure(
        'Login com Google não configurado: defina GOOGLE_WEB_CLIENT_ID (--dart-define).',
      );
    }

    final GoogleSignInAccount? account;
    try {
      account = await _googleSignIn.signIn();
    } catch (_) {
      throw const PulseAuthFailure(
        'Não foi possível abrir o login do Google. Verifique os clientes OAuth '
        '(SHA-1 no Android, URL scheme no iOS) e tente de novo.',
      );
    }
    if (account == null) throw const PulseAuthCancelled();

    final auth = await account.authentication;
    final idToken = auth.idToken;
    final accessToken = auth.accessToken;

    if (idToken == null) {
      throw const PulseAuthFailure(
        'Não foi possível obter o token do Google. Verifique a configuração OAuth em Android/iOS.',
      );
    }

    try {
      final res = await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
      if (res.session == null) {
        throw const PulseAuthFailure(
          'Google conectou, mas não foi possível entrar na conta — verifique o OAuth no projeto Supabase.',
        );
      }
    } on PulseAuthFailure {
      rethrow;
    } catch (e) {
      throw PulseAuthFailure(AuthErrorMessages.from(e));
    }
  }

  Future<void> signOut() async {
    passwordRecoveryPending = false;
    try {
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
    } catch (_) {
      // Plugin do Google ausente/não configurado não deve impedir o logout.
    }
    if (!canUseSupabase) return;
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (_) {
      // Melhor logout local parcial que travar fluxo por rede.
    }
  }

  /// Chama a Edge Function `delete-account` no Supabase (apaga dados `pulse_*` e o utilizador em `auth`).
  Future<void> deleteAccount() async {
    if (!canUseSupabase) throw PulseAuthFailure.supabaseMissing();
    _rejectSecretKeyIfNeeded();
    try {
      await Supabase.instance.client.functions.invoke('delete-account');
    } on PulseAuthFailure {
      rethrow;
    } catch (e) {
      throw PulseAuthFailure(AuthErrorMessages.from(e));
    }
  }
}
