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

/// Fila offline-first de operações a enviar ao Supabase (Plano 8).
class SyncOutbox extends Table {
  TextColumn get id => text()();
  TextColumn get entity => text()();
  TextColumn get op => text()();
  TextColumn get payloadJson => text()();
  IntColumn get createdAtMs => integer()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  TextColumn get lastError =>
      text().nullable().withLength(min: 0, max: 2000)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Progressão local de gamificação (Plano 4).
class GamificationProfiles extends Table {
  TextColumn get userId => text()();
  IntColumn get totalXp => integer().withDefault(const Constant(0))();
  IntColumn get level => integer().withDefault(const Constant(1))();
  IntColumn get updatedAtMs => integer()();

  @override
  Set<Column> get primaryKey => {userId};
}

class UserAchievementUnlocks extends Table {
  TextColumn get userId => text()();
  TextColumn get achievementKey => text()();
  IntColumn get unlockedAtMs => integer()();

  @override
  Set<Column> get primaryKey => {userId, achievementKey};
}

/// Check-in rápido de humor/energia (Plano 6).
class WellbeingLogs extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  IntColumn get loggedAtMs => integer()();
  IntColumn get mood => integer()();
  IntColumn get energy => integer()();
  TextColumn get note => text().nullable().withLength(min: 0, max: 500)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Um registro por (usuário, hábito, dia) quando o XP já foi atribuído — evita farm em toggles.
class HabitXpClaims extends Table {
  TextColumn get userId => text()();
  TextColumn get habitId =>
      text().references(Habits, #id, onDelete: KeyAction.cascade)();
  IntColumn get dateKey => integer()();
  IntColumn get claimedAtMs => integer()();

  @override
  Set<Column> get primaryKey => {userId, habitId, dateKey};
}

@DriftDatabase(
  tables: [
    Habits,
    HabitCompletions,
    SyncOutbox,
    GamificationProfiles,
    UserAchievementUnlocks,
    WellbeingLogs,
    HabitXpClaims,
  ],
)
class PulseDatabase extends _$PulseDatabase {
  PulseDatabase([QueryExecutor? e])
      : super(e ?? driftDatabase(name: 'pulse_db'));

  @override
  int get schemaVersion => 4;

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
          if (from < 3) {
            await m.createTable(syncOutbox);
            await m.createTable(gamificationProfiles);
            await m.createTable(userAchievementUnlocks);
            await m.createTable(wellbeingLogs);
          }
          if (from < 4) {
            await m.createTable(habitXpClaims);
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

  Future<HabitCompletion?> completionRow(String habitId, int dateKey) =>
      (select(habitCompletions)
            ..where((c) =>
                c.habitId.equals(habitId) & c.dateKey.equals(dateKey)))
          .getSingleOrNull();

  Future<bool> hasCompletion(String habitId, int dateKey) async {
    final q = await completionRow(habitId, dateKey);
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

  // --- Sync outbox

  Future<void> enqueueOutbox({
    required String id,
    required String entity,
    required String op,
    required String payloadJson,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await into(syncOutbox).insert(
      SyncOutboxCompanion.insert(
        id: id,
        entity: entity,
        op: op,
        payloadJson: payloadJson,
        createdAtMs: now,
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<List<SyncOutboxData>> pendingOutbox({int limit = 50}) {
    return (select(syncOutbox)
          ..orderBy([(t) => OrderingTerm.asc(t.createdAtMs)])
          ..limit(limit))
        .get();
  }

  Future<void> deleteOutbox(String id) {
    return (delete(syncOutbox)..where((t) => t.id.equals(id))).go();
  }

  Future<void> markOutboxFailure(String id, String err, int attempts) {
    return (update(syncOutbox)..where((t) => t.id.equals(id))).write(
      SyncOutboxCompanion(
        attempts: Value(attempts),
        lastError: Value(err),
      ),
    );
  }

  // --- Gamification

  Future<GamificationProfile?> gamificationForUser(String userId) =>
      (select(gamificationProfiles)..where((t) => t.userId.equals(userId)))
          .getSingleOrNull();

  Future<void> upsertGamificationProfile({
    required String userId,
    required int totalXp,
    required int level,
    required int updatedAtMs,
  }) async {
    await into(gamificationProfiles).insertOnConflictUpdate(
      GamificationProfilesCompanion.insert(
        userId: userId,
        totalXp: Value(totalXp),
        level: Value(level),
        updatedAtMs: updatedAtMs,
      ),
    );
  }

  Future<void> unlockAchievement({
    required String userId,
    required String achievementKey,
    required int unlockedAtMs,
  }) async {
    await into(userAchievementUnlocks).insertOnConflictUpdate(
      UserAchievementUnlocksCompanion.insert(
        userId: userId,
        achievementKey: achievementKey,
        unlockedAtMs: unlockedAtMs,
      ),
    );
  }

  Future<List<UserAchievementUnlock>> achievementsFor(String userId) {
    return (select(userAchievementUnlocks)
          ..where((t) => t.userId.equals(userId))
          ..orderBy([(t) => OrderingTerm.desc(t.unlockedAtMs)]))
        .get();
  }

  Future<bool> hasAchievement(String userId, String key) async {
    final row = await (select(userAchievementUnlocks)
          ..where((t) =>
              t.userId.equals(userId) & t.achievementKey.equals(key)))
        .getSingleOrNull();
    return row != null;
  }

  Future<bool> hasHabitXpClaim({
    required String userId,
    required String habitId,
    required int dateKey,
  }) async {
    final row = await (select(habitXpClaims)
          ..where((t) =>
              t.userId.equals(userId) &
              t.habitId.equals(habitId) &
              t.dateKey.equals(dateKey)))
        .getSingleOrNull();
    return row != null;
  }

  Future<void> insertHabitXpClaim({
    required String userId,
    required String habitId,
    required int dateKey,
    required int claimedAtMs,
  }) async {
    await into(habitXpClaims).insert(
      HabitXpClaimsCompanion.insert(
        userId: userId,
        habitId: habitId,
        dateKey: dateKey,
        claimedAtMs: claimedAtMs,
      ),
      mode: InsertMode.insertOrIgnore,
    );
  }

  // --- Wellbeing

  Future<void> insertWellbeingLog({
    required String id,
    required String userId,
    required int loggedAtMs,
    required int mood,
    required int energy,
    String? note,
  }) async {
    await into(wellbeingLogs).insert(
      WellbeingLogsCompanion.insert(
        id: id,
        userId: userId,
        loggedAtMs: loggedAtMs,
        mood: mood,
        energy: energy,
        note: Value(note),
      ),
    );
  }

  Future<List<WellbeingLog>> wellbeingLogsForUser(
    String userId, {
    int limit = 60,
  }) {
    return (select(wellbeingLogs)
          ..where((t) => t.userId.equals(userId))
          ..orderBy([(t) => OrderingTerm.desc(t.loggedAtMs)])
          ..limit(limit))
        .get();
  }

  /// Apaga dados locais do utilizador e a fila de sync — ex.: exclusão de conta.
  ///
  /// Hábitos primeiro (FK em completions e xp_claims com `onDelete: cascade`).
  Future<void> wipeAllLocalDataForUser(String userId) async {
    await transaction(() async {
      await (delete(habits)..where((h) => h.userId.equals(userId))).go();
      await (delete(gamificationProfiles)
            ..where((t) => t.userId.equals(userId)))
          .go();
      await (delete(userAchievementUnlocks)
            ..where((t) => t.userId.equals(userId)))
          .go();
      await (delete(wellbeingLogs)..where((t) => t.userId.equals(userId))).go();
      await delete(syncOutbox).go();
    });
  }
}
