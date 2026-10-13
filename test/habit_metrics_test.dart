import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/utils/date_key.dart';
import 'package:pulse/features/habits/domain/habit_metrics.dart';

const _everyDay = 0x7f;

/// Chaves dos [count] dias terminando em [end] (inclusive).
List<int> _keysEndingOn(DateTime end, int count) => [
      for (var i = 0; i < count; i++)
        dateKeyFromDateTime(DateTime(end.year, end.month, end.day - i)),
    ];

void main() {
  // Domingo, 10 de maio de 2026.
  final now = DateTime(2026, 5, 10, 12);
  final yesterday = DateTime(2026, 5, 9);

  group('sequência atual', () {
    test('hoje pendente não zera a série dos dias anteriores', () {
      final m = computeHabitMetrics(
        weekdaysBitmask: _everyDay,
        completionDateKeys: _keysEndingOn(yesterday, 3),
        now: now,
      );
      expect(m.currentStreak, 3);
    });

    test('hoje concluído soma à série', () {
      final m = computeHabitMetrics(
        weekdaysBitmask: _everyDay,
        completionDateKeys: _keysEndingOn(now, 4),
        now: now,
      );
      expect(m.currentStreak, 4);
    });

    test('ontem perdido zera a série', () {
      final m = computeHabitMetrics(
        weekdaysBitmask: _everyDay,
        completionDateKeys: _keysEndingOn(DateTime(2026, 5, 8), 5),
        now: now,
      );
      expect(m.currentStreak, 0);
      expect(m.bestStreak, 5);
    });

    test('dias não agendados não quebram a série', () {
      // Só segunda (bit 0) e sexta (bit 4): sex 1/5, seg 4/5, sex 8/5.
      final m = computeHabitMetrics(
        weekdaysBitmask: (1 << 0) | (1 << 4),
        completionDateKeys: [20260501, 20260504, 20260508],
        now: now,
      );
      expect(m.currentStreak, 3);
    });

    test('sem conclusões', () {
      final m = computeHabitMetrics(
        weekdaysBitmask: _everyDay,
        completionDateKeys: const [],
        now: now,
      );
      expect(m.currentStreak, 0);
      expect(m.bestStreak, 0);
      expect(m.completionRate30d, 0);
    });
  });

  group('taxa de 30 dias', () {
    test('sem data de criação conta os 30 dias', () {
      final m = computeHabitMetrics(
        weekdaysBitmask: _everyDay,
        completionDateKeys: _keysEndingOn(now, 3),
        now: now,
      );
      expect(m.expectedDaysLast30d, 30);
      expect(m.completionsLast30d, 3);
      expect(m.completionRate30d, closeTo(0.1, 1e-9));
    });

    test('hábito criado hoje e concluído hoje dá 100%', () {
      final m = computeHabitMetrics(
        weekdaysBitmask: _everyDay,
        completionDateKeys: [dateKeyFromDateTime(now)],
        now: now,
        createdAtMs: DateTime(2026, 5, 10, 8).millisecondsSinceEpoch,
      );
      expect(m.expectedDaysLast30d, 1);
      expect(m.completionRate30d, 1);
    });

    test('só conta dias a partir da criação', () {
      final m = computeHabitMetrics(
        weekdaysBitmask: _everyDay,
        completionDateKeys: _keysEndingOn(now, 2),
        now: now,
        createdAtMs: DateTime(2026, 5, 7, 20).millisecondsSinceEpoch,
      );
      expect(m.expectedDaysLast30d, 4);
      expect(m.completionRate30d, closeTo(0.5, 1e-9));
    });
  });
}
