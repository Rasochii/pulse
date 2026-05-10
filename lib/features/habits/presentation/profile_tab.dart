import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/presentation/widgets/glass_panel.dart';
import '../../../core/presentation/widgets/pulse_snackbar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/app_providers.dart';
import '../../auth/domain/pulse_auth_failure.dart';
import '../../auth/presentation/login_screen.dart';
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

  Future<void> _signOut() async {
    final router = ref.read(goRouterProvider);
    try {
      await ref.read(authRepositoryProvider).signOut();
      _goToLoginAfterAuthChange(router);
    } catch (e) {
      if (mounted) {
        showPulseSnackBar(
          context,
          'Não foi possível sair: $e',
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

    final uid = auth.currentUser?.id;
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
          'Não foi possível excluir a conta: $e',
          kind: PulseSnackKind.error,
        );
      }
    } finally {
      if (mounted && !navigatedAway) {
        setState(() => _deleting = false);
      }
    }
  }

  /// Navega para o login no frame seguinte, sem usar [context] do ecrã que pode
  /// já estar a ser desmontado após `signOut` / redirect.
  void _goToLoginAfterAuthChange(GoRouter router) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      router.go(LoginScreen.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authRepositoryProvider);
    final user = auth.currentUser;
    final email = user?.email ?? '—';
    final name = user?.userMetadata?['full_name'] as String?;
    final dark = ref.watch(themeDarkNotifierProvider);
    final gam = ref.watch(gamificationProfileProvider);
    final ach = ref.watch(unlockedAchievementsProvider);
    final cs = Theme.of(context).colorScheme;
    final canDeleteRemote =
        auth.canUseSupabase && auth.isClientKeyAccepted;

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name?.trim().isNotEmpty == true ? name!.trim() : 'Conta',
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
                        'Excluir conta envia um pedido seguro ao servidor, remove os seus dados '
                        'sincronizados e termina a sessão neste aparelho.',
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
              const SizedBox(height: 20),
              FilledButton.tonalIcon(
                onPressed: auth.canUseSupabase ? _signOut : null,
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Sair'),
              ),
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
                          'A excluir conta…',
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
