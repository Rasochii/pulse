import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/presentation/widgets/glass_panel.dart';
import '../../../core/presentation/widgets/pulse_snackbar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/app_providers.dart';
import '../../habits/presentation/app_shell_screen.dart';
import '../domain/auth_error_messages.dart';
import '../domain/pulse_auth_failure.dart';

/// Aberta pelo link de redefinição de senha (`AuthChangeEvent.passwordRecovery`).
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  static const path = '/reset-password';

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ref.read(authRepositoryProvider).updatePassword(_password.text);
      if (!mounted) return;
      showPulseSnackBar(
        context,
        'Senha atualizada.',
        kind: PulseSnackKind.success,
      );
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
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Nova senha'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          children: [
            Text(
              'Escolha uma nova senha para a sua conta.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            GlassPanel(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _password,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Nova senha',
                      ),
                      validator: (v) => (v ?? '').length < 8
                          ? 'Mínimo 8 caracteres'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _confirm,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Repita a nova senha',
                      ),
                      validator: (v) => v != _password.text
                          ? 'As senhas não coincidem'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: _saving ? null : _submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: PulseColors.accent,
                        minimumSize: const Size.fromHeight(52),
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Salvar nova senha'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _saving
                          ? null
                          : () {
                              ref
                                  .read(authRepositoryProvider)
                                  .passwordRecoveryPending = false;
                              context.go(AppShellScreen.path);
                            },
                      child: const Text('Agora não'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
