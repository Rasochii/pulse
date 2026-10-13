import 'package:go_router/go_router.dart';

import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/reset_password_screen.dart';
import '../../features/habits/presentation/app_shell_screen.dart';
import '../../features/auth/presentation/onboarding_screen.dart';
import '../../features/auth/presentation/splash_gate.dart';
import 'auth_refresh.dart';
import 'navigator_keys.dart';

GoRouter createAppRouter({
  required AuthRepository authRepository,
}) {
  final refresh = AuthRefreshListenable(authRepository);

  return GoRouter(
    navigatorKey: pulseRootNavigatorKey,
    initialLocation: SplashGate.path,
    refreshListenable: refresh,
    redirect: (context, state) async {
      final raw = state.matchedLocation;
      final loc = raw.isEmpty || raw == SplashGate.path ? SplashGate.path : raw;

      if (loc == SplashGate.path) return null;

      // Sem conta (por escolha ou sem Supabase) `currentUserId` é o usuário local.
      final userId = authRepository.currentUserId;

      if (userId == null) {
        if (loc == LoginScreen.path) return null;
        return LoginScreen.path;
      }

      if (loc == LoginScreen.path && authRepository.signInInProgress) {
        return null;
      }

      if (loc == ResetPasswordScreen.path) return null;
      // Abertura a frio pelo link: o splash navegaria para o app por cima da tela de nova senha.
      if (authRepository.passwordRecoveryPending) {
        return ResetPasswordScreen.path;
      }

      final onboardingDone = await authRepository.isOnboardingDone(userId);

      if (loc == LoginScreen.path) {
        // Sem conta: o login fica acessível para criar ou entrar numa conta depois.
        if (authRepository.isGuest && authRepository.canUseSupabase) {
          return null;
        }
        return onboardingDone
            ? AppShellScreen.path
            : OnboardingScreen.path;
      }

      if (loc == OnboardingScreen.path && onboardingDone) {
        return AppShellScreen.path;
      }

      if (loc == AppShellScreen.path && !onboardingDone) {
        return OnboardingScreen.path;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: SplashGate.path,
        builder: (context, _) => const SplashGate(),
      ),
      GoRoute(
        path: LoginScreen.path,
        builder: (context, _) => const LoginScreen(),
      ),
      GoRoute(
        path: ResetPasswordScreen.path,
        builder: (context, _) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: OnboardingScreen.path,
        builder: (context, _) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppShellScreen.path,
        builder: (context, _) => const AppShellScreen(),
      ),
    ],
  );
}
