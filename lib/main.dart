import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/app_env.dart';
import 'core/monitoring/crash_reporting.dart';
import 'core/notifications/pulse_local_notifications.dart';
import 'features/auth/data/auth_repository.dart';
import 'pulse_app.dart';

Future<void> main() => runWithCrashReporting(_start);

Future<void> _start() async {
  WidgetsFlutterBinding.ensureInitialized();

  await PulseLocalNotifications.ensureInitialized();

  if (AppEnv.hasSupabase) {
    await Supabase.initialize(
      url: AppEnv.supabaseUrl,
      anonKey: AppEnv.supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
  }

  await AuthRepository.loadGuestMode();

  runApp(const ProviderScope(child: PulseApp()));
}
