import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/database/app_database.dart';
import 'package:pulse/core/sync/sync_outbox_writer.dart';
import 'package:pulse/core/utils/date_key.dart';
import 'package:pulse/features/gamification/data/gamification_coordinator.dart';
import 'package:pulse/features/gamification/domain/achievement_defs.dart';
import 'package:pulse/features/habits/data/habits_repository.dart';

void main() {
  late PulseDatabase db;
  late HabitsRepository repo;
  late GamificationCoordinator gamification;
  final unlockedLog = <String>[];
  final today = DateTime.now();
  final todayKey = dateKeyFromDateTime(today);

  setUp(() {
    db = PulseDatabase(NativeDatabase.memory());
    final outbox = SyncOutboxWriter(db);
    gamification = GamificationCoordinator(db, syncOutbox: outbox);
    unlockedLog.clear();
    repo = HabitsRepository(
      db,
      syncOutbox: outbox,
      completionHooks: HabitCompletionHooks(
        afterMarkedComplete: (habit, day) async {
          unlockedLog.addAll(
            await gamification.onMarkedComplete(
              userId: 'user',
              habit: habit,
              day: day,
            ),
          );
        },
      ),
    );
  });

  tearDown(() => db.close());

  Future<Habit> createHabit({double target = 1, String name = 'Água'}) async {
    await repo.createHabit(userId: 'user', name: name, dailyTarget: target);
    return (await db.habitsForUser('user')).firstWhere((h) => h.name == name);
  }

  test('meta 1: toque alterna entre concluído e sem registro', () async {
    final h = await createHabit();

    expect(await repo.toggleCompletion(habit: h, day: today), isTrue);
    expect(await db.hasCompletion(h.id, todayKey), isTrue);

    expect(await repo.toggleCompletion(habit: h, day: today), isFalse);
    expect(await db.completionRow(h.id, todayKey), isNull);
  });

  test('meta numérica: progresso parcial não conta como concluído', () async {
    final h = await createHabit(target: 8);

    expect(await repo.setProgress(habit: h, day: today, quantity: 3), isFalse);
    expect((await db.completionRow(h.id, todayKey))!.quantity, 3);
    expect(await db.hasCompletion(h.id, todayKey), isFalse);
    expect(await db.completionsForHabit(h.id), isEmpty);
    expect(await db.completionsForUserHabits([h.id]), isEmpty);

    final row = (await repo.todayRows('user', today)).single;
    expect(row.done, isFalse);
    expect(row.quantity, 3);
    expect(row.progress, closeTo(3 / 8, 1e-9));

    expect(await repo.setProgress(habit: h, day: today, quantity: 8), isTrue);
    expect(await db.hasCompletion(h.id, todayKey), isTrue);
    expect(await db.completionsForUserHabits([h.id]), hasLength(1));
    expect((await repo.todayRows('user', today)).single.done, isTrue);
  });

  test('XP e conquista só ao atingir a meta, e uma vez por dia', () async {
    final h = await createHabit(target: 4);

    await repo.setProgress(habit: h, day: today, quantity: 2);
    expect(await db.gamificationForUser('user'), isNull);

    await repo.setProgress(habit: h, day: today, quantity: 4);
    final xp = (await db.gamificationForUser('user'))!.totalXp;
    expect(xp, greaterThan(0));
    expect(unlockedLog, contains(kAchFirstStep));
    expect(unlockedLog, contains(kAchPerfectDay));

    // Desmarcar e marcar de novo não rende XP nem repete conquistas.
    unlockedLog.clear();
    await repo.setProgress(habit: h, day: today, quantity: 0);
    await repo.setProgress(habit: h, day: today, quantity: 4);
    expect((await db.gamificationForUser('user'))!.totalXp, xp);
    expect(unlockedLog, isEmpty);
  });

  test('aumentar a meta preserva dias anteriores já concluídos', () async {
    final h = await createHabit(target: 2);
    await db.setCompletion(
      habitId: h.id,
      dateKey: 20200101,
      completedAtMs: 1000,
      quantity: 2,
    );
    await db.setCompletion(
      habitId: h.id,
      dateKey: 20200102,
      completedAtMs: 2000,
      quantity: 1,
    );

    await repo.updateHabitFull(
      habit: h,
      name: h.name,
      iconKey: h.iconKey,
      colorArgb: h.colorArgb,
      weekdaysBitmask: h.weekdaysBitmask,
      dailyTarget: 5,
    );

    final done = await db.completionsForHabit(h.id);
    expect(done.map((c) => c.dateKey), [20200101]);
    expect(done.single.quantity, 5);
    expect(done.single.completedAtMs, 1000);
    expect((await db.completionRow(h.id, 20200102))!.quantity, 1);
  });

  test('fila: desmarcar gera tombstone e o snapshot de gamificação é único',
      () async {
    final h = await createHabit();
    await repo.toggleCompletion(habit: h, day: today);
    await repo.toggleCompletion(habit: h, day: today);
    await repo.toggleCompletion(habit: h, day: today);

    final pending = await db.pendingOutbox(limit: 100, maxAttempts: 8);
    final ops = pending.map((r) => '${r.entity}:${r.op}').toList();
    expect(ops.where((o) => o == 'habit_completion:delete'), hasLength(1));
    expect(ops.where((o) => o == 'habit_completion:upsert'), hasLength(2));
    expect(ops.where((o) => o == 'gamification:upsert'), hasLength(1));
    final delete =
        pending.firstWhere((r) => r.op == 'delete').payloadJson;
    expect(delete, contains('"deleted_at_ms"'));
  });

  test('itens rejeitados demais saem da fila ativa até o reset', () async {
    await createHabit();
    final item = (await db.pendingOutbox()).single;
    await db.markOutboxFailure(item.id, 'rejeitado', 8);

    expect(await db.pendingOutbox(maxAttempts: 8), isEmpty);
    await db.resetOutboxAttempts();
    expect(await db.pendingOutbox(maxAttempts: 8), hasLength(1));
  });

  test('apagar dados do usuário não deixa conclusões nem XP órfãos', () async {
    final h = await createHabit();
    await repo.toggleCompletion(habit: h, day: today);

    await db.wipeAllLocalDataForUser('user');

    expect(await db.habitById(h.id), isNull);
    expect(await db.completionRow(h.id, todayKey), isNull);
    expect(
      await db.hasHabitXpClaim(
        userId: 'user',
        habitId: h.id,
        dateKey: todayKey,
      ),
      isFalse,
    );
    expect(await db.gamificationForUser('user'), isNull);
    expect(await db.pendingOutbox(), isEmpty);
  });

  test('chaves estrangeiras ativas: conclusão de hábito inexistente falha',
      () async {
    await expectLater(
      db.setCompletion(
        habitId: 'nao-existe',
        dateKey: todayKey,
        completedAtMs: 1,
      ),
      throwsA(isA<Exception>()),
    );
  });

  test('upsert de check-in vindo do servidor substitui pelo id', () async {
    WellbeingLogsCompanion log(int mood) => WellbeingLogsCompanion.insert(
          id: 'w1',
          userId: 'user',
          loggedAtMs: 10,
          mood: mood,
          energy: 3,
          note: const Value(null),
        );
    await db.upsertWellbeingLog(log(2));
    await db.upsertWellbeingLog(log(5));
    expect((await db.wellbeingLogsForUser('user')).single.mood, 5);
  });
}
