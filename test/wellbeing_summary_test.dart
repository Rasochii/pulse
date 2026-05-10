import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/database/app_database.dart';
import 'package:pulse/core/utils/date_key.dart';
import 'package:pulse/features/wellbeing/domain/wellbeing_summary.dart';

WellbeingLog _log({
  required String id,
  required DateTime at,
  required int mood,
  required int energy,
}) {
  return WellbeingLog(
    id: id,
    userId: 'user',
    loggedAtMs: at.millisecondsSinceEpoch,
    mood: mood,
    energy: energy,
  );
}

Habit _habitEveryDay() {
  return Habit(
    id: 'h1',
    userId: 'user',
    name: 'Água',
    iconKey: 'water',
    colorArgb: 0xff000000,
    weekdaysBitmask: 0x7f,
    dailyTarget: 1,
    createdAtMs: 0,
    updatedAtMs: 0,
  );
}

void main() {
  group('buildWellbeingUiSummary', () {
    test('sem registros retorna resumo vazio', () {
      final s = buildWellbeingUiSummary(
        logsNewestFirst: [],
        habits: [_habitEveryDay()],
        completions: const [],
        now: DateTime(2026, 5, 10, 12),
      );
      expect(s.hasAnyLog, isFalse);
      expect(s.lastLog, isNull);
      expect(s.correlationLine, isNull);
    });

    test('médias no mesmo dia civil combinam check-ins', () {
      final noon = DateTime(2026, 5, 10, 12);
      final logs = [
        _log(id: 'b', at: noon.add(const Duration(hours: 3)), mood: 5, energy: 4),
        _log(id: 'a', at: noon, mood: 3, energy: 3),
      ];

      final s = buildWellbeingUiSummary(
        logsNewestFirst: logs,
        habits: const [],
        completions: const [],
        now: DateTime(2026, 5, 10, 22),
      );

      expect(s.hasAnyLog, isTrue);
      expect(s.lastLog!.id, 'b');
      expect(s.moodAvgLast7CalendarDays, closeTo((5 + 3) / 2, 0.001));
      expect(s.energyAvgLast7CalendarDays, closeTo((4 + 3) / 2, 0.001));
      expect(s.moodByDayLast7.last, closeTo(4.0, 0.001));
    });

    test('correlação omitida sem hábitos suficientes nos grupos', () {
      final logs = [
        _log(id: '1', at: DateTime(2026, 5, 10), mood: 5, energy: 5),
      ];
      final s = buildWellbeingUiSummary(
        logsNewestFirst: logs,
        habits: const [],
        completions: const [],
        now: DateTime(2026, 5, 10),
      );
      expect(s.correlationLine, isNull);
    });

    test('correlação quando há dois dias altos e dois dias baixos na janela',
        () {
      final habit = _habitEveryDay();
      final completions = <HabitCompletion>[];

      void completeDay(DateTime day) {
        completions.add(
          HabitCompletion(
            habitId: habit.id,
            dateKey: dateKeyFromDateTime(day),
            completedAtMs: day.millisecondsSinceEpoch,
            quantity: 1,
          ),
        );
      }

      /// Hoje = 10 mai 2026 (dom); últimos 13 dias incluem 7–9 mai.
      final now = DateTime(2026, 5, 10, 18);

      /// Humor alto em dois dias (taxa 100%).
      completeDay(DateTime(2026, 5, 9));
      completeDay(DateTime(2026, 5, 8));
      final logs = <WellbeingLog>[
        _log(id: 'h1', at: DateTime(2026, 5, 9), mood: 5, energy: 5),
        _log(id: 'h2', at: DateTime(2026, 5, 8), mood: 5, energy: 5),
        _log(id: 'l1', at: DateTime(2026, 5, 7), mood: 2, energy: 2),
        _log(id: 'l2', at: DateTime(2026, 5, 6), mood: 1, energy: 2),
      ];

      final s = buildWellbeingUiSummary(
        logsNewestFirst: logs,
        habits: [habit],
        completions: completions,
        now: now,
      );

      expect(s.correlationLine, isNotNull);
      expect(s.correlationLine, contains('100%'));
      expect(s.correlationLine, contains('0%'));
    });
  });
}
