import 'package:go_router/go_router.dart';

import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/data/onboarding_storage.dart';
import '../../features/auth/presentation/login_screen.dart';
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

      if (!authRepository.canUseSupabase) {
        if (loc != LoginScreen.path) return LoginScreen.path;
        return null;
      }

      final user = authRepository.currentUser;
      final loggedIn = user != null;

      if (!loggedIn) {
        if (loc == LoginScreen.path) return null;
        return LoginScreen.path;
      }

      final onboardingDone = await isOnboardingDoneForUser(user.id);

      if (loc == LoginScreen.path) {
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
