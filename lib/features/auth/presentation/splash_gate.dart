import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../providers/app_providers.dart';
import '../../habits/presentation/app_shell_screen.dart';
import 'login_screen.dart';
import 'onboarding_screen.dart';
import '../data/onboarding_storage.dart';

class SplashGate extends ConsumerStatefulWidget {
  const SplashGate({super.key});

  static const path = '/';

  @override
  ConsumerState<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends ConsumerState<SplashGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _route());
  }

  Future<void> _route() async {
    if (!mounted) return;
    final router = ref.read(goRouterProvider);
    final auth = ref.read(authRepositoryProvider);

    if (auth.canUseSupabase) {
      await Future<void>.delayed(const Duration(milliseconds: 450));
      if (!mounted) return;
    }

    // Modo local (sem Supabase): sempre há um usuário, o login é pulado.
    final userId = auth.currentUserId;
    if (userId == null) {
      router.go(LoginScreen.path);
      return;
    }

    final done = await isOnboardingDoneForUser(userId);
    if (!mounted) return;
    router.go(done ? AppShellScreen.path : OnboardingScreen.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bolt_rounded, size: 56, color: PulseColors.accent),
            SizedBox(height: 16),
            Text(
              'Pulse',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 12),
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: PulseColors.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
