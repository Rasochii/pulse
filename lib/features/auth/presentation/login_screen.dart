import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_env.dart';
import '../../../core/presentation/widgets/glass_panel.dart';
import '../../../core/presentation/widgets/pulse_snackbar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/app_providers.dart';
import '../domain/auth_error_messages.dart';
import '../domain/pulse_auth_failure.dart';
import '../../habits/presentation/app_shell_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  static const path = '/login';

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _registerMode = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = ref.read(authRepositoryProvider);
    setState(() => _loading = true);
    HapticFeedback.lightImpact();
    try {
      if (_registerMode) {
        await auth.signUpWithEmail(
          email: _email.text,
          password: _password.text,
          displayName: _name.text.trim().isEmpty ? null : _name.text.trim(),
        );
        if (auth.currentSession == null) {
          if (!mounted) return;
          showPulseSnackBar(
            context,
            'Cadastro iniciado — verifique seu e-mail para confirmar a conta.',
            kind: PulseSnackKind.neutral,
          );
          setState(() => _registerMode = false);
          return;
        }
      } else {
        await auth.signInWithEmail(
          email: _email.text,
          password: _password.text,
        );
      }
      if (!mounted) return;
      context.go(AppShellScreen.path);
    } on PulseAuthFailure catch (e) {
      if (!mounted) return;
      showPulseSnackBar(context, e.message, kind: PulseSnackKind.error);
    } catch (e) {
      if (!mounted) return;
      showPulseSnackBar(
        context,
        AuthErrorMessages.from(e),
        kind: PulseSnackKind.error,
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _google() async {
    final auth = ref.read(authRepositoryProvider);
    setState(() => _loading = true);
    HapticFeedback.lightImpact();
    try {
      await auth.signInWithGoogle();
      if (!mounted) return;
      context.go(AppShellScreen.path);
    } on PulseAuthFailure catch (e) {
      if (!mounted) return;
      showPulseSnackBar(context, e.message, kind: PulseSnackKind.error);
    } catch (e) {
      if (!mounted) return;
      showPulseSnackBar(
        context,
        AuthErrorMessages.from(e),
        kind: PulseSnackKind.error,
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resetPassword() async {
    final auth = ref.read(authRepositoryProvider);
    if (_email.text.trim().isEmpty) {
      showPulseSnackBar(
        context,
        'Preencha o e-mail para recuperação.',
        kind: PulseSnackKind.neutral,
      );
      return;
    }
    try {
      await auth.resetPassword(email: _email.text);
      if (!mounted) return;
      showPulseSnackBar(
        context,
        'Se o e-mail existir, você receberá instruções em instantes.',
        kind: PulseSnackKind.success,
      );
    } on PulseAuthFailure catch (e) {
      if (!mounted) return;
      showPulseSnackBar(context, e.message, kind: PulseSnackKind.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authRepositoryProvider);
    final configured = auth.canUseSupabase;
    final canAuthenticateWithProject = configured && auth.isClientKeyAccepted;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          const _GlowBackdrop(),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 12),
                          Text(
                                _registerMode ? 'Criar conta' : 'Bem-vindo',
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineMedium,
                              )
                              .animate()
                              .fadeIn(duration: 220.ms)
                              .slideY(begin: 0.05, end: 0),
                          const SizedBox(height: 8),
                          Text(
                            'Entre para acompanhar consistência,\nníveis e hábitos com clareza.',
                            style: Theme.of(context).textTheme.bodyMedium!
                                .copyWith(color: PulseColors.textSecondary),
                          ).animate(delay: 40.ms).fadeIn(duration: 220.ms),
                          if (!configured) ...[
                            const SizedBox(height: 14),
                            const _MissingConfigBanner(),
                          ],
                          if (configured &&
                              AppEnv.usesSecretSupabaseKeyInClient) ...[
                            const SizedBox(height: 14),
                            const _SecretKeyBanner(),
                          ],
                          const SizedBox(height: 28),
                          GlassPanel(
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (_registerMode) ...[
                                    TextFormField(
                                      controller: _name,
                                      decoration: const InputDecoration(
                                        labelText: 'Nome',
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                  ],
                                  TextFormField(
                                    controller: _email,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: const InputDecoration(
                                      labelText: 'E-mail',
                                    ),
                                    validator: (v) {
                                      final s = v?.trim() ?? '';
                                      if (!s.contains('@')) {
                                        return 'E-mail inválido';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 14),
                                  TextFormField(
                                    controller: _password,
                                    obscureText: true,
                                    decoration: const InputDecoration(
                                      labelText: 'Senha',
                                    ),
                                    validator: (v) {
                                      final s = v ?? '';
                                      if (!_registerMode && s.length < 6) {
                                        return 'Mínimo 6 caracteres';
                                      }
                                      if (_registerMode && s.length < 8) {
                                        return 'Mínimo 8 caracteres para cadastro';
                                      }
                                      return null;
                                    },
                                  ),
                                  if (!_registerMode)
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: canAuthenticateWithProject
                                            ? _resetPassword
                                            : null,
                                        child: const Text('Esqueci a senha'),
                                      ),
                                    )
                                  else
                                    const SizedBox(height: 6),
                                  const SizedBox(height: 6),
                                  FilledButton(
                                    onPressed:
                                        canAuthenticateWithProject && !_loading
                                        ? _submit
                                        : null,
                                    style: FilledButton.styleFrom(
                                      backgroundColor: PulseColors.accent,
                                      minimumSize: const Size.fromHeight(52),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: _loading
                                        ? SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onPrimary,
                                            ),
                                          )
                                        : Text(
                                            _registerMode
                                                ? 'Criar e continuar'
                                                : 'Continuar',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onPrimary,
                                            ),
                                          ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      const Expanded(child: Divider()),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                        ),
                                        child: Text(
                                          'ou',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall,
                                        ),
                                      ),
                                      const Expanded(child: Divider()),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  OutlinedButton.icon(
                                    onPressed:
                                        canAuthenticateWithProject && !_loading
                                        ? _google
                                        : null,
                                    icon: Icon(
                                      Icons.g_mobiledata_rounded,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                                    label: const Text('Continuar com Google'),
                                    style: OutlinedButton.styleFrom(
                                      minimumSize: const Size.fromHeight(52),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextButton(
                                    onPressed: !_loading
                                        ? () => setState(
                                            () =>
                                                _registerMode = !_registerMode,
                                          )
                                        : null,
                                    child: Text(
                                      _registerMode
                                          ? 'Já tenho conta'
                                          : 'Criar uma conta nova',
                                      style: const TextStyle(
                                        color: PulseColors.accent,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowBackdrop extends StatelessWidget {
  const _GlowBackdrop();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Align(
        alignment: Alignment.topRight,
        child: SizedBox(
          height: 240,
          width: 260,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: PulseColors.accent.withValues(alpha: .22),
                  blurRadius: 120,
                  spreadRadius: 48,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MissingConfigBanner extends StatelessWidget {
  const _MissingConfigBanner();

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.all(14),
      borderRadius: 14,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: PulseColors.accent.withValues(alpha: .9),
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Defina SUPABASE_URL e SUPABASE_ANON_KEY com --dart-define para habilitar autenticação.',
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                height: 1.35,
                color: PulseColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SecretKeyBanner extends StatelessWidget {
  const _SecretKeyBanner();

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.all(14),
      borderRadius: 14,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: PulseColors.snackErrorBg,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              AppEnv.warningSecretKeyInFlutter,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                height: 1.35,
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
