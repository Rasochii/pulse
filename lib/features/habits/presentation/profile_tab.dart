import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_links.dart';
import '../../../core/notifications/notification_permission.dart';
import '../../../core/presentation/friendly_error.dart';
import '../../../core/presentation/widgets/glass_panel.dart';
import '../../../core/presentation/widgets/pulse_snackbar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/app_providers.dart';
import '../../auth/domain/pulse_auth_failure.dart';
import '../../auth/presentation/login_screen.dart';
import '../../dashboard/presentation/dashboard_providers.dart';
import '../../gamification/domain/achievement_defs.dart';
import '../../gamification/domain/level_curve.dart';
import '../../gamification/presentation/achievements_catalog_screen.dart';
import '../../gamification/presentation/gamification_providers.dart';
import '../../settings/presentation/theme_provider.dart';
import '../../wellbeing/presentation/wellbeing_history_screen.dart';

class ProfileTab extends ConsumerStatefulWidget {
  const ProfileTab({super.key});

  @override
  ConsumerState<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends ConsumerState<ProfileTab> {
  bool _deleting = false;
  bool _signingOut = false;

  /// Tenta enviar a fila antes de sair; se sobrar algo, pede confirmação.
  /// Retorna `false` se o usuário desistiu.
  Future<bool> _confirmPendingBeforeSignOut() async {
    final uid = ref.read(authRepositoryProvider).currentUser?.id;
    if (uid == null) return true;
    final sync = ref.read(pulseSyncEngineProvider);
    setState(() => _signingOut = true);
    int pending;
    try {
      await sync.retryFailed();
      await sync.flushOutbox(uid).timeout(const Duration(seconds: 10));
    } catch (_) {
      // Sem rede ou demorou demais: o que sobrou entra na contagem abaixo.
    }
    try {
      pending = await sync.pendingCount(uid);
    } catch (_) {
      pending = 0;
    }
    if (!mounted) return false;
    setState(() => _signingOut = false);
    if (pending == 0) return true;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Alterações não enviadas'),
        content: Text(
          '${pending == 1 ? 'Há 1 alteração que ainda não foi' : 'Há $pending alterações que ainda não foram'} '
          'para a nuvem (provavelmente por falta de internet).\n\n'
          'Se sair agora, ${pending == 1 ? 'ela continua guardada' : 'elas continuam guardadas'} '
          'neste aparelho e só ${pending == 1 ? 'é enviada' : 'são enviadas'} quando você '
          'entrar de novo nesta conta aqui. Desinstalar o app antes disso faz perder '
          'o que não foi enviado.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sair mesmo assim'),
          ),
        ],
      ),
    );
    return ok == true;
  }

  Future<void> _signOut() async {
    if (_signingOut) return;
    if (!await _confirmPendingBeforeSignOut()) return;
    if (!mounted) return;
    final router = ref.read(goRouterProvider);
    try {
      // Os lembretes são do usuário que está saindo.
      try {
        await ref
            .read(pulseHabitNotificationSchedulerProvider)
            .cancelAllForPulse();
      } catch (_) {}
      await ref.read(authRepositoryProvider).signOut();
      _goToLoginAfterAuthChange(router);
    } catch (e) {
      if (mounted) {
        showPulseSnackBar(
          context,
          friendlyError(e, 'Não foi possível sair.'),
          kind: PulseSnackKind.error,
        );
      }
    }
  }

  Future<void> _confirmAndDeleteAccount() async {
    final auth = ref.read(authRepositoryProvider);
    if (!auth.canUseSupabase || !auth.isClientKeyAccepted) return;

    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => const _DeleteAccountConfirmDialog(),
    );

    if (ok != true || !mounted) return;

    final uid = auth.currentUserId;
    if (uid == null || uid.isEmpty) {
      showPulseSnackBar(
        context,
        'Sessão inválida. Entre de novo e tente outra vez.',
        kind: PulseSnackKind.error,
      );
      return;
    }

    final router = ref.read(goRouterProvider);

    setState(() => _deleting = true);
    var navigatedAway = false;
    try {
      await ref
          .read(deleteAccountCoordinatorProvider)
          .deleteAccountAndWipeLocal(uid);
      if (!mounted) return;
      navigatedAway = true;
      // Evita `ref.invalidate` + `context.go` no mesmo sítio que o redirect do
      // auth: rebuilds de Provider em árvores a desativar causam asserts de
      // InheritedWidget (`_dependents.isEmpty`).
      _goToLoginAfterAuthChange(router);
    } on PulseAuthFailure catch (e) {
      if (mounted) {
        showPulseSnackBar(
          context,
          e.message,
          kind: PulseSnackKind.error,
        );
      }
    } catch (e) {
      if (mounted) {
        showPulseSnackBar(
          context,
          friendlyError(e, 'Não foi possível excluir a conta.'),
          kind: PulseSnackKind.error,
        );
      }
    } finally {
      if (mounted && !navigatedAway) {
        setState(() => _deleting = false);
      }
    }
  }

  Future<void> _editName(String? current) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _EditNameDialog(initial: current?.trim() ?? ''),
    );
    if (name == null || !mounted) return;
    try {
      await ref.read(authRepositoryProvider).updateDisplayName(name);
      if (!mounted) return;
      ref.invalidate(dashboardSnapshotProvider);
      setState(() {});
    } on PulseAuthFailure catch (e) {
      if (mounted) {
        showPulseSnackBar(context, e.message, kind: PulseSnackKind.error);
      }
    }
  }

  Future<void> _changePassword() async {
    final password = await showDialog<String>(
      context: context,
      builder: (_) => const _ChangePasswordDialog(),
    );
    if (password == null || !mounted) return;
    try {
      await ref.read(authRepositoryProvider).updatePassword(password);
      if (!mounted) return;
      showPulseSnackBar(
        context,
        'Senha atualizada.',
        kind: PulseSnackKind.success,
      );
    } on PulseAuthFailure catch (e) {
      if (mounted) {
        showPulseSnackBar(context, e.message, kind: PulseSnackKind.error);
      }
    }
  }

  /// Navega para o login no frame seguinte, sem usar [context] da tela que pode
  /// já estar sendo desmontada após `signOut` / redirect.
  void _goToLoginAfterAuthChange(GoRouter router) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      router.go(LoginScreen.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authRepositoryProvider);
    final user = auth.currentUser;
    final email = user != null
        ? (user.email ?? '—')
        : 'Sem conta — dados só neste aparelho.';
    final name = user?.userMetadata?['full_name'] as String?;
    final dark = ref.watch(themeDarkNotifierProvider);
    final gam = ref.watch(gamificationProfileProvider);
    final ach = ref.watch(unlockedAchievementsProvider);
    final cs = Theme.of(context).colorScheme;
    final canDeleteRemote = user != null && auth.isClientKeyAccepted;

    return Stack(
      children: [
        SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            children: [
              Text(
                'Perfil',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              GlassPanel(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name?.trim().isNotEmpty == true
                                ? name!.trim()
                                : 'Conta',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            email,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    if (user != null)
                      IconButton(
                        tooltip: 'Editar nome',
                        onPressed: () => _editName(name),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                  ],
                ),
              ),
              if (user == null && auth.canUseSupabase) ...[
                const SizedBox(height: 16),
                GlassPanel(
                  padding: const EdgeInsets.all(4),
                  child: ListTile(
                    leading: Icon(
                      Icons.cloud_upload_outlined,
                      color: PulseColors.accent,
                    ),
                    title: const Text('Criar conta ou entrar'),
                    subtitle: const Text(
                      'Para ter backup e usar em mais de um aparelho. '
                      'O que você já registrou vai junto.',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () =>
                        ref.read(goRouterProvider).go(LoginScreen.path),
                  ),
                ),
              ],
              if (auth.hasPasswordLogin) ...[
                const SizedBox(height: 16),
                GlassPanel(
                  padding: const EdgeInsets.all(4),
                  child: ListTile(
                    leading:
                        Icon(Icons.lock_outline_rounded, color: PulseColors.accent),
                    title: const Text('Trocar senha'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: _changePassword,
                  ),
                ),
              ],
              if (kRemindersSupported) ...[
              const SizedBox(height: 16),
              GlassPanel(
                padding: const EdgeInsets.all(4),
                child: NotificationPermissionBuilder(
                  builder: (context, allowed, enable) => ListTile(
                    leading: Icon(
                      allowed
                          ? Icons.notifications_active_outlined
                          : Icons.notifications_off_outlined,
                      color: allowed ? PulseColors.accent : cs.error,
                    ),
                    title: Text(
                      allowed
                          ? 'Notificações ativadas'
                          : 'Notificações desativadas',
                    ),
                    subtitle: Text(
                      allowed
                          ? 'Toque para mudar som, vibração ou desativar nos '
                              'ajustes do aparelho. Os horários ficam em cada hábito.'
                          : 'Os lembretes não tocam. Toque para ativar.',
                    ),
                    trailing: const Icon(Icons.open_in_new_rounded, size: 20),
                    // Ativas: leva aos ajustes de notificação do Pulse no sistema.
                    onTap: allowed ? openPulseNotificationSettings : enable,
                  ),
                ),
              ),
              ],
              const SizedBox(height: 16),
              GlassPanel(
                padding: const EdgeInsets.all(4),
                child: ListTile(
                  leading:
                      Icon(Icons.mood_rounded, color: PulseColors.accent),
                  title: const Text('Humor e histórico'),
                  subtitle: const Text(
                    'Ver check-ins recentes e tendências.',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.of(context).push<void>(
                      MaterialPageRoute<void>(
                        builder: (_) => const WellbeingHistoryScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              GlassPanel(
                padding: const EdgeInsets.all(16),
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Tema escuro Pulse'),
                  value: dark,
                  activeThumbColor: PulseColors.accent,
                  onChanged: (v) {
                    ref.read(themeDarkNotifierProvider.notifier).setDark(v);
                  },
                ),
              ),
              const SizedBox(height: 16),
              gam.when(
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
                data: (gp) {
                  if (gp == null) return const SizedBox.shrink();
                  final into = xpIntoCurrentLevel(gp.totalXp);
                  final need = xpToReachNextLevel(gp.totalXp);
                  final span = into + need;
                  final frac = span <= 0
                      ? 0.0
                      : (into.toDouble() / span.toDouble()).clamp(0.0, 1.0);
                  return GlassPanel(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gamificação',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Nível ${gp.level} · ${gp.totalXp} XP',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: frac.toDouble(),
                            minHeight: 10,
                            backgroundColor: cs.surfaceContainerHighest,
                            color: PulseColors.accent,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$need XP até o próximo nível.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'O XP reflete hábitos concluídos; o nível é só um marco de progresso. '
                          'Nesta versão não há benefício extra no app além da sua jornada.',
                          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).push<void>(
                                MaterialPageRoute<void>(
                                  builder: (_) =>
                                      const AchievementsCatalogScreen(),
                                ),
                              );
                            },
                            child: const Text('Ver todas as conquistas'),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              ach.when(
                loading: () => const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: PulseColors.accent,
                ),
                error: (_, _) =>
                    Text('Erro ao carregar conquistas', style: Theme.of(context).textTheme.bodySmall),
                data: (unlocks) => GlassPanel(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Conquistas (${unlocks.length})',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push<void>(
                                MaterialPageRoute<void>(
                                  builder: (_) =>
                                      const AchievementsCatalogScreen(),
                                ),
                              );
                            },
                            child: const Text('Ver todas'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (unlocks.isEmpty)
                        Text(
                          'Conclua hábitos para desbloquear badges.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        )
                      else
                        ...unlocks.take(12).map(
                          (u) {
                            final def = achievementByKey(u.achievementKey);
                            return ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              leading:
                                  Icon(Icons.workspace_premium, color: PulseColors.success),
                              title: Text(def?.title ?? u.achievementKey),
                              subtitle: def != null
                                  ? Text(
                                      def.description,
                                      style: Theme.of(context).textTheme.bodySmall,
                                    )
                                  : null,
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GlassPanel(
                padding: const EdgeInsets.all(4),
                child: ListTile(
                  leading: Icon(
                    Icons.privacy_tip_outlined,
                    color: PulseColors.accent,
                  ),
                  title: const Text('Política de privacidade'),
                  subtitle: const Text('Quais dados o Pulse guarda e como.'),
                  trailing: const Icon(Icons.open_in_new_rounded, size: 20),
                  onTap: () => openExternalLink(AppLinks.privacyPolicy),
                ),
              ),
              if (canDeleteRemote) ...[
                const SizedBox(height: 24),
                Text(
                  'Zona de risco',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: cs.error,
                      ),
                ),
                const SizedBox(height: 8),
                GlassPanel(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Excluir a conta apaga seus dados na nuvem e neste aparelho '
                        'e encerra a sessão. Não dá para desfazer.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _deleting ? null : _confirmAndDeleteAccount,
                          icon: const Icon(Icons.delete_forever_outlined),
                          label: const Text('Excluir conta'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: cs.error,
                            side: BorderSide(color: cs.error.withValues(alpha: 0.6)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (user != null) ...[
                const SizedBox(height: 20),
                FilledButton.tonalIcon(
                  onPressed: _signingOut ? null : _signOut,
                  icon: _signingOut
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.logout_rounded),
                  label: Text(_signingOut ? 'Enviando alterações…' : 'Sair'),
                ),
              ],
            ],
          ),
        ),
        if (_deleting)
          Positioned.fill(
            child: ColoredBox(
              color: Colors.black38,
              child: Center(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(color: PulseColors.accent),
                        const SizedBox(height: 16),
                        Text(
                          'Excluindo conta…',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _EditNameDialog extends StatefulWidget {
  const _EditNameDialog({required this.initial});

  final String initial;

  @override
  State<_EditNameDialog> createState() => _EditNameDialogState();
}

class _EditNameDialogState extends State<_EditNameDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final valid = _controller.text.trim().isNotEmpty;
    return AlertDialog(
      title: const Text('Seu nome'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: 60,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(labelText: 'Nome', counterText: ''),
        onChanged: (_) => setState(() {}),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: valid
              ? () => Navigator.of(context).pop(_controller.text.trim())
              : null,
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}

class _ChangePasswordDialog extends StatefulWidget {
  const _ChangePasswordDialog();

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Trocar senha'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _password,
                obscureText: true,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Nova senha'),
                validator: (v) =>
                    (v ?? '').length < 8 ? 'Mínimo 8 caracteres' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _confirm,
                obscureText: true,
                decoration:
                    const InputDecoration(labelText: 'Repita a nova senha'),
                validator: (v) =>
                    v != _password.text ? 'As senhas não coincidem' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.of(context).pop(_password.text);
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}

class _DeleteAccountConfirmDialog extends StatefulWidget {
  const _DeleteAccountConfirmDialog();

  @override
  State<_DeleteAccountConfirmDialog> createState() =>
      _DeleteAccountConfirmDialogState();
}

class _DeleteAccountConfirmDialogState
    extends State<_DeleteAccountConfirmDialog> {
  late final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final match = _controller.text.trim() == 'EXCLUIR';
    final cs = Theme.of(context).colorScheme;

    return AlertDialog(
      title: const Text('Excluir conta'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Todos os seus dados no Pulse serão apagados neste '
              'dispositivo e na nuvem (hábitos, conclusões, humor e '
              'conta de login). Esta ação não pode ser desfeita.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              autofocus: true,
              autocorrect: false,
              enableSuggestions: false,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Digite EXCLUIR para confirmar',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: cs.error,
            foregroundColor: cs.onError,
          ),
          onPressed: match ? () => Navigator.of(context).pop(true) : null,
          child: const Text('Excluir para sempre'),
        ),
      ],
    );
  }
}
