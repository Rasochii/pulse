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
  SyncOutboxWriter(this._db, {bool Function()? isEnabled})
      : _isEnabled = isEnabled;

  final PulseDatabase _db;
  final _uuid = const Uuid();

  /// `false` enquanto o app é usado sem conta: nada entra na fila.
  final bool Function()? _isEnabled;

  Future<void> _put({
    String? id,
    required String entity,
    required String op,
    required Map<String, dynamic> payload,
  }) async {
    if (_isEnabled?.call() == false) return;
    await _db.enqueueOutbox(
      id: id ?? _uuid.v4(),
      entity: entity,
      op: op,
      payloadJson: jsonEncode(payload),
    );
  }

  /// Enfileira tudo o que [userId] tem no aparelho — usado quando os dados criados
  /// sem conta passam para uma conta. O carimbo novo faz os outros aparelhos baixarem.
  Future<void> enqueueAllForUser(String userId) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    for (final h in await _db.habitsForUser(userId)) {
      await enqueueHabitUpsert(h);
      for (final c in await _db.progressRowsForHabit(h.id)) {
        await enqueueCompletionUpsert(
          habitId: c.habitId,
          dateKey: c.dateKey,
          completedAtMs: c.completedAtMs,
          quantity: c.quantity,
          updatedAtMs: now,
        );
      }
    }
    final logs = await _db.wellbeingLogsForUser(userId, limit: 100000);
    for (final l in logs) {
      await enqueueWellbeingUpsert(l, updatedAtMs: now);
    }
    await enqueueGamificationSnapshot(userId);
  }

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

  Future<void> enqueueHabitUpsert(Habit habit) =>
      _put(entity: 'habit', op: 'upsert', payload: _habitPayload(habit));

  Future<void> enqueueHabitSoftDelete({
    required Habit habit,
    required int deletedAtMs,
  }) {
    return _put(
      entity: 'habit',
      op: 'upsert',
      payload: _habitPayload(habit, deletedAtMs: deletedAtMs),
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
    return _put(entity: 'habit_completion', op: 'upsert', payload: payload);
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
    return _put(entity: 'habit_completion', op: 'delete', payload: payload);
  }

  Future<void> enqueueWellbeingUpsert(WellbeingLog log, {int? updatedAtMs}) {
    final payload = {
      'id': log.id,
      'user_id': log.userId,
      'logged_at_ms': log.loggedAtMs,
      'mood': log.mood,
      'energy': log.energy,
      'note': log.note,
      'updated_at_ms': updatedAtMs ?? log.loggedAtMs,
      'deleted_at_ms': null,
    };
    return _put(entity: 'wellbeing_log', op: 'upsert', payload: payload);
  }

  /// Vira um tombstone remoto (`deleted_at_ms`), enviado sem a nota.
  Future<void> enqueueWellbeingDelete({
    required WellbeingLog log,
    required int deletedAtMs,
  }) {
    final payload = {
      'id': log.id,
      'user_id': log.userId,
      'logged_at_ms': log.loggedAtMs,
      'mood': log.mood,
      'energy': log.energy,
      'note': null,
      'updated_at_ms': deletedAtMs,
      'deleted_at_ms': deletedAtMs,
    };
    return _put(entity: 'wellbeing_log', op: 'delete', payload: payload);
  }

  /// Um único item por usuário na fila: cada novo snapshot substitui o anterior.
  Future<void> enqueueGamificationSnapshot(String userId) async {
    final payload = await buildGamificationPayload(_db, userId);
    if (payload == null) return;
    await _put(
      id: 'gamification:$userId',
      entity: 'gamification',
      op: 'upsert',
      payload: payload,
    );
  }
}
