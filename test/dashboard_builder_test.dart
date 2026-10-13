import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/database/app_database.dart';
import 'package:pulse/core/utils/date_key.dart';
import 'package:pulse/features/dashboard/data/dashboard_builder.dart';
import 'package:pulse/features/dashboard/domain/dashboard_snapshot.dart';

Habit _habit(String id, {required DateTime createdAt}) => Habit(
      id: id,
      userId: 'user',
      name: id,
      iconKey: 'task_alt',
      colorArgb: 0xff000000,
      weekdaysBitmask: 0x7f,
      dailyTarget: 1,
      createdAtMs: createdAt.millisecondsSinceEpoch,
      updatedAtMs: createdAt.millisecondsSinceEpoch,
    );

HabitCompletion _done(String habitId, DateTime day) => HabitCompletion(
      habitId: habitId,
      dateKey: dateKeyFromDateTime(day),
      completedAtMs: DateTime(day.year, day.month, day.day, 9)
          .millisecondsSinceEpoch,
      quantity: 1,
    );

void main() {
  // Domingo, 10 de maio de 2026 → última linha do heatmap é a semana de 4 a 10/5.
  final now = DateTime(2026, 5, 10, 12);

  test('sem hábitos devolve snapshot vazio', () {
    final s = DashboardBuilder.compute(
      habits: const [],
      completions: const [],
      now: now,
    );
    expect(s.hasHabits, isFalse);
    expect(s.displayNameGuess, 'aí');
  });

  test('dias anteriores à criação do hábito não contam como falhados', () {
    final s = DashboardBuilder.compute(
      habits: [_habit('h1', createdAt: DateTime(2026, 5, 8, 10))],
      completions: [
        _done('h1', DateTime(2026, 5, 8)),
        _done('h1', DateTime(2026, 5, 10)),
      ],
      now: now,
    );
    final week = s.heatmap.last; // seg 4/5 … dom 10/5
    expect(week[0], HeatTone.muted); // seg 4/5: hábito não existia
    expect(week[3], HeatTone.muted); // qui 7/5: hábito não existia
    expect(week[4], HeatTone.perfect); // sex 8/5
    expect(week[5], HeatTone.missed); // sáb 9/5
    expect(week[6], HeatTone.perfect); // dom 10/5 (hoje)
    expect(s.heatmap.first.every((t) => t == HeatTone.muted), isTrue);
  });

  test('hoje e últimos 7 dias', () {
    final s = DashboardBuilder.compute(
      habits: [
        _habit('h1', createdAt: DateTime(2026, 4, 1)),
        _habit('h2', createdAt: DateTime(2026, 4, 1)),
      ],
      completions: [
        _done('h1', DateTime(2026, 5, 10)),
        _done('h1', DateTime(2026, 5, 9)),
        _done('h2', DateTime(2026, 5, 9)),
      ],
      now: now,
    );
    expect(s.todayExpected, 2);
    expect(s.todayDone, 1);
    expect(s.barLast7.last, 1);
    expect(s.barLast7[5], 2);
    expect(s.completionsSumLast7, 3);
  });

  test('sequência de dias perfeitos ignora hoje ainda incompleto', () {
    final habits = [_habit('h1', createdAt: DateTime(2026, 4, 1))];
    final s = DashboardBuilder.compute(
      habits: habits,
      completions: [
        _done('h1', DateTime(2026, 5, 9)),
        _done('h1', DateTime(2026, 5, 8)),
      ],
      now: now,
    );
    expect(s.perfectStreakDays, 2);
  });

  test('um hábito novo não desfaz os dias perfeitos anteriores', () {
    final s = DashboardBuilder.compute(
      habits: [
        _habit('h1', createdAt: DateTime(2026, 4, 1)),
        _habit('novo', createdAt: DateTime(2026, 5, 10, 8)),
      ],
      completions: [
        _done('h1', DateTime(2026, 5, 9)),
        _done('h1', DateTime(2026, 5, 8)),
      ],
      now: now,
    );
    expect(s.perfectStreakDays, 2);
    expect(s.heatmap.last[5], HeatTone.perfect); // sáb 9/5
  });
}
