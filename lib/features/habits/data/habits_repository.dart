import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/sync/sync_outbox_writer.dart';
import '../../../core/utils/date_key.dart';
import '../../dashboard/data/dashboard_builder.dart';
import '../../dashboard/domain/dashboard_snapshot.dart';
import '../domain/habit_metrics.dart';
import 'habit_today_row.dart';

typedef HabitDayHook =
    Future<void> Function(Habit habit, DateTime day);

final class HabitCompletionHooks {
  const HabitCompletionHooks({
    this.afterMarkedComplete,
    this.afterUnmarked,
  });

  final HabitDayHook? afterMarkedComplete;
  final HabitDayHook? afterUnmarked;
}

class HabitsRepository {
  HabitsRepository(
    this._db, {
    SyncOutboxWriter? syncOutbox,
    HabitCompletionHooks? completionHooks,
  })  : _syncOutbox = syncOutbox,
        _completionHooks = completionHooks;

  final PulseDatabase _db;
  final SyncOutboxWriter? _syncOutbox;
  final HabitCompletionHooks? _completionHooks;
  final _uuid = const Uuid();

  Stream<List<Habit>> watchHabits(String userId) =>
      _db.watchHabitsForUser(userId);

  Future<Habit?> habitById(String id) => _db.habitById(id);

  Future<HabitMetrics> metricsFor(Habit habit) async {
    final rows = await _db.completionsForHabit(habit.id);
    final keys = rows.map((r) => r.dateKey).toList();
    return computeHabitMetrics(
      weekdaysBitmask: habit.weekdaysBitmask,
      completionDateKeys: keys,
      now: DateTime.now(),
    );
  }

  Future<List<HabitTodayRow>> todayRows(String userId, DateTime day) async {
    final scheduled = await _db.habitsScheduledForDay(userId, day);
    final key = dateKeyFromDateTime(day);
    final out = <HabitTodayRow>[];
    for (final h in scheduled) {
      final done = await _db.hasCompletion(h.id, key);
      final m = await metricsFor(h);
      out.add(
        HabitTodayRow(
          habit: h,
          done: done,
          currentStreak: m.currentStreak,
          completionRate30d: m.completionRate30d,
        ),
      );
    }
    out.sort((a, b) => a.habit.name.compareTo(b.habit.name));
    return out;
  }

  Future<void> createHabit({
    required String userId,
    required String name,
    String? description,
    String? category,
    String iconKey = 'task_alt',
    int colorArgb = 0xFF7C83FF,
    int weekdaysBitmask = 127,
    double dailyTarget = 1,
    String? dailyTargetUnit,
    String? reminderTimesJson,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final id = _uuid.v4();
    await _db.insertHabit(
      HabitsCompanion.insert(
        id: id,
        userId: userId,
        name: name,
        description: Value(description),
        category: Value(category),
        iconKey: Value(iconKey),
        colorArgb: Value(colorArgb),
        weekdaysBitmask: Value(weekdaysBitmask),
        reminderHour: const Value(null),
        reminderMinute: const Value(null),
        dailyTarget: Value(dailyTarget),
        dailyTargetUnit: Value(dailyTargetUnit),
        reminderTimesJson: Value(reminderTimesJson),
        createdAtMs: now,
        updatedAtMs: now,
      ),
    );
    final row = await _db.habitById(id);
    if (row != null) {
      await _syncOutbox?.enqueueHabitUpsert(row);
    }
  }

  Future<void> updateHabitFull({
    required Habit habit,
    required String name,
    String? description,
    String? category,
    required String iconKey,
    required int colorArgb,
    required int weekdaysBitmask,
    double dailyTarget = 1,
    String? dailyTargetUnit,
    String? reminderTimesJson,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _db.updateHabit(
      HabitsCompanion(
        id: Value(habit.id),
        userId: Value(habit.userId),
        name: Value(name),
        description: Value(description),
        category: Value(category),
        iconKey: Value(iconKey),
        colorArgb: Value(colorArgb),
        weekdaysBitmask: Value(weekdaysBitmask),
        reminderHour: const Value(null),
        reminderMinute: const Value(null),
        dailyTarget: Value(dailyTarget),
        dailyTargetUnit: Value(dailyTargetUnit),
        reminderTimesJson: Value(reminderTimesJson),
        createdAtMs: Value(habit.createdAtMs),
        updatedAtMs: Value(now),
        deletedAtMs: Value(habit.deletedAtMs),
      ),
    );
    final row = await _db.habitById(habit.id);
    if (row != null) {
      await _syncOutbox?.enqueueHabitUpsert(row);
    }
  }

  Future<void> deleteHabit(Habit habit) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _db.softDeleteHabit(habit.id, now);
    final row = await _db.habitById(habit.id);
    if (row != null) {
      await _syncOutbox?.enqueueHabitSoftDelete(habit: row, deletedAtMs: now);
    }
  }

  /// Retorna `true` se ficou marcado como concluído.
  Future<bool> toggleCompletion({
    required Habit habit,
    required DateTime day,
  }) async {
    final key = dateKeyFromDateTime(day);
    final exists = await _db.hasCompletion(habit.id, key);
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    if (exists) {
      await _db.deleteCompletion(habit.id, key);
      await _syncOutbox?.enqueueCompletionDelete(habitId: habit.id, dateKey: key);
      final cb = _completionHooks?.afterUnmarked;
      if (cb != null) await cb(habit, day);
      return false;
    } else {
      await _db.setCompletion(
        habitId: habit.id,
        dateKey: key,
        completedAtMs: nowMs,
        quantity: 1,
      );
      await _syncOutbox?.enqueueCompletionUpsert(
        habitId: habit.id,
        dateKey: key,
        completedAtMs: nowMs,
        quantity: 1,
      );
      final cb = _completionHooks?.afterMarkedComplete;
      if (cb != null) await cb(habit, day);
      return true;
    }
  }

  Future<DashboardSnapshot> dashboardSnapshot({
    required String userId,
    required DateTime now,
    String? displayName,
  }) async {
    final habits = await _db.habitsForUser(userId);
    final ids = habits.map((e) => e.id).toList();
    final comps = await _db.completionsForUserHabits(ids);
    return DashboardBuilder.compute(
      habits: habits,
      completions: comps,
      now: now,
      displayName: displayName,
    );
  }
}
