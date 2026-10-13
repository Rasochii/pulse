import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/app_env.dart';
import '../domain/auth_error_messages.dart';
import '../domain/pulse_auth_failure.dart';
import 'onboarding_storage.dart';

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

  /// A tela de login está concluindo a entrada (inclui passar os dados locais para a
  /// conta). O router espera em vez de sair do login assim que a sessão aparece.
  bool signInInProgress = false;

  static const _guestKey = 'pulse_guest_mode';
  static bool _guestChosen = false;

  /// Lê a escolha "continuar sem conta" gravada no aparelho (chamar antes do `runApp`).
  static Future<void> loadGuestMode() async {
    final prefs = await SharedPreferences.getInstance();
    _guestChosen = prefs.getBool(_guestKey) ?? false;
  }

  Future<void> setGuestMode(bool enabled) async {
    _guestChosen = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_guestKey, enabled);
  }

  /// Usando o app sem conta: tudo fica só neste aparelho, nada vai para a nuvem.
  /// Vale por escolha do usuário ou quando o app roda sem Supabase.
  bool get isGuest => currentUser == null && (!canUseSupabase || _guestChosen);

  /// Id da sessão Supabase ou [localUserId] sem conta; `null` = precisa escolher (login).
  String? get currentUserId =>
      currentUser?.id ?? (isGuest ? localUserId : null);

  String? get _redirectUrl => kIsWeb ? null : authRedirectUrl;

  /// A conta tem login por senha (contas só-Google não têm senha para trocar).
  bool get hasPasswordLogin {
    final meta = currentUser?.appMetadata;
    if (meta == null) return false;
    final providers = meta['providers'];
    if (providers is List) return providers.contains('email');
    return meta['provider'] == 'email';
  }

  /// Consultas ao servidor em andamento/concluídas, por usuário.
  final _remoteOnboarding = <String, Future<bool>>{};

  /// Onboarding feito neste aparelho ou, em instalação nova, já registrado na conta.
  Future<bool> isOnboardingDone(String userId) async {
    if (await isOnboardingDoneForUser(userId)) return true;
    if (!canUseSupabase || userId != currentUser?.id) return false;
    final done = await _remoteOnboarding.putIfAbsent(
      userId,
      () => _fetchRemoteOnboarding(userId),
    );
    if (done) await setOnboardingDoneForUser(userId);
    return done;
  }

  Future<bool> _fetchRemoteOnboarding(String userId) async {
    const timeout = Duration(seconds: 5);
    try {
      final client = Supabase.instance.client;
      final profile = await client
          .from('profiles')
          .select('onboarding_completed_at')
          .eq('id', userId)
          .maybeSingle()
          .timeout(timeout);
      if (profile?['onboarding_completed_at'] != null) return true;
      // Contas anteriores à tabela `profiles`: quem já tem hábito já passou pelo onboarding.
      final habits = await client
          .from('pulse_habits')
          .select('id')
          .eq('user_id', userId)
          .limit(1)
          .timeout(timeout);
      return habits.isNotEmpty;
    } catch (_) {
      // Sem rede ou tabela ausente: vale só o aparelho; tenta de novo na próxima navegação.
      _remoteOnboarding.remove(userId);
      return false;
    }
  }

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
      final res = await Supabase.instance.client.auth.signUp(
        email: email.trim(),
        password: password,
        emailRedirectTo: _redirectUrl,
        data: displayName == null ? null : {'full_name': displayName},
      );
      // Com confirmação de e-mail ligada, e-mail já cadastrado volta como "sucesso"
      // sem sessão e sem identidades — nenhum e-mail é enviado.
      if (res.session == null && (res.user?.identities?.isEmpty ?? false)) {
        throw PulseAuthFailure(AuthErrorMessages.emailAlreadyRegistered);
      }
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

  /// Nome mostrado no perfil e na saudação (`full_name` nos metadados da conta).
  Future<void> updateDisplayName(String name) async {
    if (!canUseSupabase) throw PulseAuthFailure.supabaseMissing();
    _rejectSecretKeyIfNeeded();
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(data: {'full_name': name.trim()}),
      );
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
    // Sair leva ao login; "continuar sem conta" volta a ser uma escolha explícita.
    await setGuestMode(false);
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
