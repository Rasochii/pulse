import '../../../core/database/app_database.dart';
import '../../../core/notifications/habit_notification_scheduler.dart';
import '../../../core/sync/sync_watermark_store.dart';
import 'auth_repository.dart';
import 'onboarding_storage.dart';

/// Orquestra exclusão no servidor + limpeza local + sign out.
final class DeleteAccountCoordinator {
  DeleteAccountCoordinator({
    required AuthRepository auth,
    required PulseDatabase database,
    required SyncWatermarkStore watermarks,
    required PulseHabitNotificationScheduler notifications,
  })  : _auth = auth,
        _db = database,
        _watermarks = watermarks,
        _notifications = notifications;

  final AuthRepository _auth;
  final PulseDatabase _db;
  final SyncWatermarkStore _watermarks;
  final PulseHabitNotificationScheduler _notifications;

  Future<void> deleteAccountAndWipeLocal(String userId) async {
    await _auth.deleteAccount();
    await _notifications.cancelAllForPulse();
    await _db.wipeAllLocalDataForUser(userId);
    await _watermarks.clearAll();
    await clearOnboardingForUser(userId);
    await _auth.signOut();
  }
}
