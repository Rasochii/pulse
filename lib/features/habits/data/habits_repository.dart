import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/utils/date_key.dart';
import '../domain/habit_metrics.dart';
import 'habit_today_row.dart';

class HabitsRepository {
  HabitsRepository(this._db);

  final PulseDatabase _db;
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
  }

  Future<void> deleteHabit(Habit habit) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _db.softDeleteHabit(habit.id, now);
  }

  Future<void> toggleCompletion({
    required Habit habit,
    required DateTime day,
  }) async {
    final key = dateKeyFromDateTime(day);
    final exists = await _db.hasCompletion(habit.id, key);
    final now = DateTime.now().millisecondsSinceEpoch;
    if (exists) {
      await _db.deleteCompletion(habit.id, key);
    } else {
      await _db.setCompletion(
        habitId: habit.id,
        dateKey: key,
        completedAtMs: now,
        quantity: 1,
      );
    }
  }
}
