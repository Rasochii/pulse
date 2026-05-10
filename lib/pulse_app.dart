import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/light_theme.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final router = ref.read(goRouterProvider);
      await ref.read(themeDarkNotifierProvider.notifier).loadPersisted();

      Future<void> handle(Uri uri) async {
        if (!mounted) return;
        final path = '${uri.scheme}://${uri.host}${uri.path}';
        if (uri.scheme == 'pulse' ||
            uri.host.startsWith('pulse') ||
            path.contains('/app')) {
          router.go(AppShellScreen.path);
        }
      }

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
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      theme: buildPulseLightTheme(),
      darkTheme: buildPulseDarkTheme(),
      routerConfig: router,
      builder: (context, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: overlayStyle,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
