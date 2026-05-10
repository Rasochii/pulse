import 'dart:convert';

import 'package:uuid/uuid.dart';

import '../database/app_database.dart';

/// Enfileira mutações locais para o [PulseSyncEngine] enviar ao Supabase.
final class SyncOutboxWriter {
  SyncOutboxWriter(this._db);

  final PulseDatabase _db;
  final _uuid = const Uuid();

  Future<void> enqueueHabitUpsert(Habit habit) {
    final payload = {
      'id': habit.id,
      'user_id': habit.userId,
      'name': habit.name,
      'description': habit.description,
      'category': habit.category,
      'icon_key': habit.iconKey,
      'color_argb': habit.colorArgb,
      'weekdays_bitmask': habit.weekdaysBitmask,
      'reminder_hour': habit.reminderHour,
      'reminder_minute': habit.reminderMinute,
      'daily_target': habit.dailyTarget,
      'daily_target_unit': habit.dailyTargetUnit,
      'reminder_times_json': habit.reminderTimesJson,
      'created_at_ms': habit.createdAtMs,
      'updated_at_ms': habit.updatedAtMs,
      'deleted_at_ms': habit.deletedAtMs,
    };
    return _db.enqueueOutbox(
      id: _uuid.v4(),
      entity: 'habit',
      op: 'upsert',
      payloadJson: jsonEncode(payload),
    );
  }

  Future<void> enqueueHabitSoftDelete({
    required Habit habit,
    required int deletedAtMs,
  }) {
    final payload = {
      'id': habit.id,
      'user_id': habit.userId,
      'name': habit.name,
      'description': habit.description,
      'category': habit.category,
      'icon_key': habit.iconKey,
      'color_argb': habit.colorArgb,
      'weekdays_bitmask': habit.weekdaysBitmask,
      'reminder_hour': habit.reminderHour,
      'reminder_minute': habit.reminderMinute,
      'daily_target': habit.dailyTarget,
      'daily_target_unit': habit.dailyTargetUnit,
      'reminder_times_json': habit.reminderTimesJson,
      'created_at_ms': habit.createdAtMs,
      'updated_at_ms': habit.updatedAtMs,
      'deleted_at_ms': deletedAtMs,
    };
    return _db.enqueueOutbox(
      id: _uuid.v4(),
      entity: 'habit',
      op: 'upsert',
      payloadJson: jsonEncode(payload),
    );
  }

  Future<void> enqueueCompletionUpsert({
    required String habitId,
    required int dateKey,
    required int completedAtMs,
    required double quantity,
  }) {
    final payload = {
      'habit_id': habitId,
      'date_key': dateKey,
      'completed_at_ms': completedAtMs,
      'quantity': quantity,
    };
    return _db.enqueueOutbox(
      id: _uuid.v4(),
      entity: 'habit_completion',
      op: 'upsert',
      payloadJson: jsonEncode(payload),
    );
  }

  Future<void> enqueueCompletionDelete({
    required String habitId,
    required int dateKey,
  }) {
    final payload = {'habit_id': habitId, 'date_key': dateKey};
    return _db.enqueueOutbox(
      id: _uuid.v4(),
      entity: 'habit_completion',
      op: 'delete',
      payloadJson: jsonEncode(payload),
    );
  }

  Future<void> enqueueWellbeingUpsert(WellbeingLog log) {
    final payload = {
      'id': log.id,
      'user_id': log.userId,
      'logged_at_ms': log.loggedAtMs,
      'mood': log.mood,
      'energy': log.energy,
      'note': log.note,
    };
    return _db.enqueueOutbox(
      id: _uuid.v4(),
      entity: 'wellbeing_log',
      op: 'upsert',
      payloadJson: jsonEncode(payload),
    );
  }
}
