import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/light_theme.dart';
import 'core/update/update_gate.dart';
import 'features/auth/presentation/reset_password_screen.dart';
import 'features/habits/presentation/app_shell_screen.dart';
import 'features/settings/presentation/theme_provider.dart';
import 'providers/app_providers.dart';

class PulseApp extends ConsumerStatefulWidget {
  const PulseApp({super.key});

  @override
  ConsumerState<PulseApp> createState() => _PulseAppState();
}

class _PulseAppState extends ConsumerState<PulseApp> {
  StreamSubscription<Uri>? _deepLinkSubscription;
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final router = ref.read(goRouterProvider);
      await ref.read(themeDarkNotifierProvider.notifier).loadPersisted();

      // O link de "esqueci a senha" abre o app já autenticado; falta só a nova senha.
      final auth = ref.read(authRepositoryProvider);
      _authSubscription ??= auth.authStateChanges.listen((state) async {
        if (state.event == AuthChangeEvent.passwordRecovery) {
          auth.passwordRecoveryPending = true;
          router.go(ResetPasswordScreen.path);
        }
        // Sessão que chegou fora da tela de login (web: volta do Google depois de o app
        // já ter aberto): os dados criados sem conta passam para ela.
        if (state.event == AuthChangeEvent.signedIn && !auth.signInInProgress) {
          await ref.read(adoptLocalDataProvider)();
          if (mounted) ref.invalidate(authUidStreamProvider);
        }
      });

      Future<void> handle(Uri uri) async {
        if (!mounted) return;
        // Retorno do Supabase Auth: o próprio supabase_flutter troca o código pela sessão.
        if (uri.host == 'auth-callback') return;
        final path = '${uri.scheme}://${uri.host}${uri.path}';
        if (uri.scheme == 'pulse' ||
            uri.host.startsWith('pulse') ||
            path.contains('/app')) {
          router.go(AppShellScreen.path);
        }
      }

      // Deep links são do app instalado; na web a URL já é a navegação.
      if (kIsWeb) return;

      try {
        final initial = await AppLinks().getInitialLink();
        if (initial != null) await handle(initial);
        _deepLinkSubscription ??=
            AppLinks().uriLinkStream.listen(handle, onError: (_) {});
      } catch (_) {
        // Plataforma sem app_links configurado ou link inválido.
      }
    });
  }

  @override
  void dispose() {
    _deepLinkSubscription?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(goRouterProvider);
    final dark = ref.watch(themeDarkNotifierProvider);

    final overlayStyle =
        dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark;

    return MaterialApp.router(
      title: 'Pulse',
      debugShowCheckedModeBanner: false,
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      theme: buildPulseLightTheme(),
      darkTheme: buildPulseDarkTheme(),
      routerConfig: router,
      builder: (context, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: overlayStyle,
          child: UpdateGate(child: child ?? const SizedBox.shrink()),
        );
      },
    );
  }
}
