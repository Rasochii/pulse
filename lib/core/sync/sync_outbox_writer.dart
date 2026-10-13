import 'dart:convert';

import 'package:uuid/uuid.dart';

import '../database/app_database.dart';

/// Linha de `pulse_gamification` com o estado local atual; `null` se não há perfil.
Future<Map<String, dynamic>?> buildGamificationPayload(
  PulseDatabase db,
  String userId,
) async {
  final profile = await db.gamificationForUser(userId);
  if (profile == null) return null;
  final unlocks = await db.achievementsFor(userId);
  return {
    'user_id': userId,
    'total_xp': profile.totalXp,
    'level': profile.level,
    'achievements': {
      for (final u in unlocks) u.achievementKey: u.unlockedAtMs,
    },
    'updated_at_ms': profile.updatedAtMs,
  };
}

/// Enfileira mutações locais para o [PulseSyncEngine] enviar ao Supabase.
final class SyncOutboxWriter {
  SyncOutboxWriter(this._db);

  final PulseDatabase _db;
  final _uuid = const Uuid();

  Map<String, dynamic> _habitPayload(Habit habit, {int? deletedAtMs}) => {
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
        'deleted_at_ms': deletedAtMs ?? habit.deletedAtMs,
      };

  Future<void> enqueueHabitUpsert(Habit habit) {
    return _db.enqueueOutbox(
      id: _uuid.v4(),
      entity: 'habit',
      op: 'upsert',
      payloadJson: jsonEncode(_habitPayload(habit)),
    );
  }

  Future<void> enqueueHabitSoftDelete({
    required Habit habit,
    required int deletedAtMs,
  }) {
    return _db.enqueueOutbox(
      id: _uuid.v4(),
      entity: 'habit',
      op: 'upsert',
      payloadJson: jsonEncode(_habitPayload(habit, deletedAtMs: deletedAtMs)),
    );
  }

  /// [updatedAtMs] é a marca d'água remota; difere de [completedAtMs] quando só a
  /// quantidade muda (ex.: meta do hábito aumentada).
  Future<void> enqueueCompletionUpsert({
    required String habitId,
    required int dateKey,
    required int completedAtMs,
    required double quantity,
    int? updatedAtMs,
  }) {
    final payload = {
      'habit_id': habitId,
      'date_key': dateKey,
      'completed_at_ms': completedAtMs,
      'quantity': quantity,
      'updated_at_ms': updatedAtMs ?? completedAtMs,
      'deleted_at_ms': null,
    };
    return _db.enqueueOutbox(
      id: _uuid.v4(),
      entity: 'habit_completion',
      op: 'upsert',
      payloadJson: jsonEncode(payload),
    );
  }

  /// Vira um tombstone remoto (`deleted_at_ms`) para a desmarcação chegar a outros aparelhos.
  Future<void> enqueueCompletionDelete({
    required String habitId,
    required int dateKey,
    required int deletedAtMs,
  }) {
    final payload = {
      'habit_id': habitId,
      'date_key': dateKey,
      'deleted_at_ms': deletedAtMs,
    };
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

  /// Um único item por usuário na fila: cada novo snapshot substitui o anterior.
  Future<void> enqueueGamificationSnapshot(String userId) async {
    final payload = await buildGamificationPayload(_db, userId);
    if (payload == null) return;
    await _db.enqueueOutbox(
      id: 'gamification:$userId',
      entity: 'gamification',
      op: 'upsert',
      payloadJson: jsonEncode(payload),
    );
  }
}
