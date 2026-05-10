import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/presentation/widgets/glass_panel.dart';
import '../../../core/presentation/widgets/pulse_snackbar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/app_providers.dart';
import '../../auth/presentation/login_screen.dart';

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authRepositoryProvider);
    final user = auth.currentUser;
    final email = user?.email ?? '—';
    final name = user?.userMetadata?['full_name'] as String?;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        children: [
          Text(
            'Perfil',
            style: Theme.of(context)
                .textTheme
                .headlineMedium!
                .copyWith(color: PulseColors.textPrimary),
          ),
          const SizedBox(height: 16),
          GlassPanel(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name?.trim().isNotEmpty == true ? name!.trim() : 'Conta',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: PulseColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  email,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.tonalIcon(
            onPressed: auth.canUseSupabase ? () => _signOut(context, ref) : null,
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Sair'),
          ),
        ],
      ),
    );
  }

  static Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(authRepositoryProvider).signOut();
      if (context.mounted) context.go(LoginScreen.path);
    } catch (e) {
      if (context.mounted) {
        showPulseSnackBar(
          context,
          'Não foi possível sair: $e',
          kind: PulseSnackKind.error,
        );
      }
    }
  }
}
