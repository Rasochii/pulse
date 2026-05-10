import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../utils/date_key.dart';

part 'app_database.g.dart';

class Habits extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get description => text().nullable()();
  TextColumn get category => text().nullable()();
  TextColumn get iconKey => text().withDefault(const Constant('task_alt'))();
  IntColumn get colorArgb =>
      integer().withDefault(const Constant(0xFF7C83FF))();
  /// Bits 0–6 = seg–dom (como [DateTime.weekday] − 1).
  IntColumn get weekdaysBitmask =>
      integer().withDefault(const Constant(127))();
  IntColumn get reminderHour => integer().nullable()();
  IntColumn get reminderMinute => integer().nullable()();
  RealColumn get dailyTarget => real().withDefault(const Constant(1.0))();
  TextColumn get dailyTargetUnit =>
      text().nullable().withLength(min: 0, max: 48)();
  /// JSON `[[hora,minuto],...]` — vários lembretes por dia (ver também [reminderHour] legado).
  TextColumn get reminderTimesJson =>
      text().nullable().withLength(min: 0, max: 2000)();
  IntColumn get createdAtMs => integer()();
  IntColumn get updatedAtMs => integer()();
  IntColumn get deletedAtMs => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class HabitCompletions extends Table {
  TextColumn get habitId =>
      text().references(Habits, #id, onDelete: KeyAction.cascade)();
  IntColumn get dateKey => integer()();
  IntColumn get completedAtMs => integer()();
  RealColumn get quantity => real().withDefault(const Constant(1.0))();

  @override
  Set<Column> get primaryKey => {habitId, dateKey};
}

@DriftDatabase(tables: [Habits, HabitCompletions])
class PulseDatabase extends _$PulseDatabase {
  PulseDatabase([QueryExecutor? e])
      : super(e ?? driftDatabase(name: 'pulse_db'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(habits, habits.dailyTargetUnit);
            await m.addColumn(habits, habits.reminderTimesJson);
            await _migrateReminderTimesJsonV2();
          }
        },
      );

  Future<void> _migrateReminderTimesJsonV2() async {
    final rows = await select(habits).get();
    for (final r in rows) {
      final h = r.reminderHour;
      final mi = r.reminderMinute;
      final already = r.reminderTimesJson;
      if (already != null && already.trim().isNotEmpty) continue;
      if (h != null &&
          mi != null &&
          h >= 0 &&
          h < 24 &&
          mi >= 0 &&
          mi < 60) {
        final json = jsonEncode([
          [h, mi],
        ]);
        await (update(habits)..where((t) => t.id.equals(r.id))).write(
          HabitsCompanion(reminderTimesJson: Value(json)),
        );
      }
    }
  }

  Stream<List<Habit>> watchHabitsForUser(String userId) {
    return (select(habits)
          ..where((h) =>
              h.userId.equals(userId) & h.deletedAtMs.isNull())
          ..orderBy([(h) => OrderingTerm.asc(h.name)]))
        .watch();
  }

  Future<List<Habit>> habitsForUser(String userId) {
    return (select(habits)
          ..where((h) =>
              h.userId.equals(userId) & h.deletedAtMs.isNull())
          ..orderBy([(h) => OrderingTerm.asc(h.name)]))
        .get();
  }

  Future<Habit?> habitById(String id) =>
      (select(habits)..where((h) => h.id.equals(id))).getSingleOrNull();

  Future<int> insertHabit(HabitsCompanion row) => into(habits).insert(row);

  Future<void> updateHabit(HabitsCompanion row) => update(habits).replace(row);

  Future<int> softDeleteHabit(String id, int nowMs) {
    return (update(habits)..where((h) => h.id.equals(id))).write(
      HabitsCompanion(
        deletedAtMs: Value(nowMs),
        updatedAtMs: Value(nowMs),
      ),
    );
  }

  Stream<List<HabitCompletion>> watchCompletionsForHabit(String habitId) {
    return (select(habitCompletions)
          ..where((c) => c.habitId.equals(habitId))
          ..orderBy([(c) => OrderingTerm.desc(c.dateKey)]))
        .watch();
  }

  Future<List<HabitCompletion>> completionsForHabit(String habitId) {
    return (select(habitCompletions)
          ..where((c) => c.habitId.equals(habitId))
          ..orderBy([(c) => OrderingTerm.desc(c.dateKey)]))
        .get();
  }

  Future<List<HabitCompletion>> completionsForUserHabits(
    Iterable<String> habitIds,
  ) {
    if (habitIds.isEmpty) return Future.value([]);
    return (select(habitCompletions)
          ..where((c) => c.habitId.isIn(habitIds.toList())))
        .get();
  }

  Future<bool> hasCompletion(String habitId, int dateKey) async {
    final q = await (select(habitCompletions)
          ..where((c) =>
              c.habitId.equals(habitId) & c.dateKey.equals(dateKey)))
        .getSingleOrNull();
    return q != null;
  }

  Future<void> setCompletion({
    required String habitId,
    required int dateKey,
    required int completedAtMs,
    double quantity = 1,
  }) async {
    await into(habitCompletions).insertOnConflictUpdate(
      HabitCompletionsCompanion.insert(
        habitId: habitId,
        dateKey: dateKey,
        completedAtMs: completedAtMs,
        quantity: Value(quantity),
      ),
    );
  }

  Future<void> deleteCompletion(String habitId, int dateKey) async {
    await (delete(habitCompletions)
          ..where((c) =>
              c.habitId.equals(habitId) & c.dateKey.equals(dateKey)))
        .go();
  }

  /// Retorna hábitos ativos esperados neste dia (máscara de dias da semana).
  Future<List<Habit>> habitsScheduledForDay(String userId, DateTime day) async {
    final list = await habitsForUser(userId);
    final w = day.weekday;
    return list
        .where((h) => isWeekdayInBitmask(w, h.weekdaysBitmask))
        .toList();
  }
}
