import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/analytics/analytics_gateway.dart';
import '../core/database/app_database.dart';
import '../core/notifications/habit_notification_scheduler.dart';
import '../core/router/app_router.dart';
import '../core/sync/pulse_sync_engine.dart';
import '../core/sync/sync_outbox_writer.dart';
import '../core/sync/sync_watermark_store.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/data/delete_account_coordinator.dart';
import '../features/auth/data/onboarding_storage.dart';
import '../features/gamification/data/gamification_coordinator.dart';
import '../features/habits/data/habits_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// Emite o `userId` da sessão (útil quando o stream Supabase atualiza antes do router).
final authUidStreamProvider = StreamProvider.autoDispose<String?>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  Stream<String?> gen() async* {
    yield repo.currentUserId;
    if (!repo.canUseSupabase) return;
    await for (final _ in repo.authStateChanges) {
      yield repo.currentUserId;
    }
  }

  return gen();
});

final analyticsGatewayProvider = Provider<AnalyticsGateway>((ref) {
  return kDebugMode
      ? const DebugAnalyticsGateway()
      : const NoOpAnalyticsGateway();
});

final pulseDatabaseProvider = Provider<PulseDatabase>((ref) {
  final db = PulseDatabase();
  ref.onDispose(db.close);
  return db;
});

final syncWatermarkStoreProvider = Provider<SyncWatermarkStore>((ref) {
  return SyncWatermarkStore();
});

/// `null` sem Supabase. Com Supabase mas sem conta, o writer existe e não enfileira nada:
/// o que é criado sem conta fica só no aparelho.
final syncOutboxWriterProvider = Provider<SyncOutboxWriter?>((ref) {
  final auth = ref.watch(authRepositoryProvider);
  if (!auth.canUseSupabase) return null;
  return SyncOutboxWriter(
    ref.watch(pulseDatabaseProvider),
    isEnabled: () => auth.currentUser != null,
  );
});

final pulseSyncEngineProvider = Provider<PulseSyncEngine>((ref) {
  return PulseSyncEngine(
    ref.watch(pulseDatabaseProvider),
    ref.watch(syncWatermarkStoreProvider),
  );
});

final pulseHabitNotificationSchedulerProvider =
    Provider<PulseHabitNotificationScheduler>((ref) {
  return PulseHabitNotificationScheduler(ref.watch(pulseDatabaseProvider));
});

final deleteAccountCoordinatorProvider =
    Provider<DeleteAccountCoordinator>((ref) {
  return DeleteAccountCoordinator(
    auth: ref.watch(authRepositoryProvider),
    database: ref.watch(pulseDatabaseProvider),
    watermarks: ref.watch(syncWatermarkStoreProvider),
    notifications: ref.watch(pulseHabitNotificationSchedulerProvider),
  );
});

final gamificationCoordinatorProvider =
    Provider<GamificationCoordinator>((ref) {
  return GamificationCoordinator(
    ref.watch(pulseDatabaseProvider),
    analytics: ref.watch(analyticsGatewayProvider),
    syncOutbox: ref.watch(syncOutboxWriterProvider),
  );
});

/// Conquistas desbloqueadas pela última conclusão, à espera de aviso na UI.
final pendingAchievementUnlocksProvider =
    StateProvider<List<String>>((ref) => const []);

final habitCompletionHooksProvider =
    Provider<HabitCompletionHooks>((ref) {
  final gam = ref.watch(gamificationCoordinatorProvider);
  return HabitCompletionHooks(
    afterMarkedComplete: (habit, day) async {
      final uid = ref.read(authRepositoryProvider).currentUserId;
      if (uid == null || uid.isEmpty) return;
      final unlocked =
          await gam.onMarkedComplete(userId: uid, habit: habit, day: day);
      if (unlocked.isNotEmpty) {
        ref.read(pendingAchievementUnlocksProvider.notifier).state = unlocked;
      }
    },
  );
});

/// Dispara o envio da fila sem bloquear a UI; falhas ficam para a próxima tentativa.
final backgroundSyncProvider = Provider<void Function()>((ref) {
  return () {
    final uid = ref.read(authRepositoryProvider).currentUserId;
    if (uid == null || uid.isEmpty) return;
    unawaited(
      ref.read(pulseSyncEngineProvider).flushOutbox(uid).catchError((_) {}),
    );
  };
});

/// Reagenda os lembretes sem bloquear a UI (ex.: hábito concluído não lembra mais hoje).
final backgroundRescheduleProvider = Provider<void Function()>((ref) {
  return () {
    final uid = ref.read(authRepositoryProvider).currentUserId;
    if (uid == null || uid.isEmpty) return;
    unawaited(
      ref
          .read(pulseHabitNotificationSchedulerProvider)
          .rescheduleAll(uid)
          .catchError((_) {}),
    );
  };
});

/// Com sessão ativa, passa para a conta o que foi criado sem conta neste aparelho
/// e enfileira para subir no próximo sync. Sem dados locais, não faz nada.
final adoptLocalDataProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    final auth = ref.read(authRepositoryProvider);
    final uid = auth.currentUser?.id;
    if (uid == null) return;
    const local = AuthRepository.localUserId;
    try {
      final moved = await ref
          .read(pulseDatabaseProvider)
          .reassignUserData(from: local, to: uid);
      if (moved) {
        await ref.read(syncOutboxWriterProvider)?.enqueueAllForUser(uid);
      }
      if (await isOnboardingDoneForUser(local)) {
        await setOnboardingDoneForUser(uid);
        await clearOnboardingForUser(local);
      }
    } catch (_) {
      // Entrar na conta não deve falhar por causa disso; os dados continuam no aparelho.
    }
    await auth.setGuestMode(false);
  };
});

final habitsRepositoryProvider =Provider<HabitsRepository>((ref) {
  return HabitsRepository(
    ref.watch(pulseDatabaseProvider),
    syncOutbox: ref.watch(syncOutboxWriterProvider),
    completionHooks: ref.watch(habitCompletionHooksProvider),
  );
});

final goRouterProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authRepositoryProvider);
  final router = createAppRouter(authRepository: auth);
  ref.onDispose(router.dispose);
  return router;
});
