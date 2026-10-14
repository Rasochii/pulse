import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/database/app_database.dart';
import 'package:pulse/features/gamification/domain/level_curve.dart';
import 'package:pulse/features/habits/domain/habit_daily_goal_display.dart';
import 'package:pulse/features/habits/domain/habit_reminder_times_codec.dart';
import 'package:pulse/features/habits/domain/habit_schedule.dart';
import 'package:pulse/features/insights/domain/insight_engine.dart';

Habit _habit({required DateTime createdAt, int mask = 0x7f}) => Habit(
      id: 'h1',
      userId: 'user',
      name: 'Água',
      iconKey: 'water_drop',
      colorArgb: 0xff000000,
      weekdaysBitmask: mask,
      dailyTarget: 1,
      createdAtMs: createdAt.millisecondsSinceEpoch,
      updatedAtMs: createdAt.millisecondsSinceEpoch,
      sortOrder: 0,
    );

void main() {
  group('curva de nível', () {
    test('limites acumulados', () {
      expect(xpThresholdForLevel(1), 0);
      expect(xpThresholdForLevel(2), 100);
      expect(xpThresholdForLevel(3), 300);
      expect(xpThresholdForLevel(4), 600);
    });

    test('nível a partir do XP total', () {
      expect(computeLevelFromTotalXp(0), 1);
      expect(computeLevelFromTotalXp(99), 1);
      expect(computeLevelFromTotalXp(100), 2);
      expect(computeLevelFromTotalXp(299), 2);
      expect(computeLevelFromTotalXp(300), 3);
    });

    test('progresso dentro do nível', () {
      expect(xpIntoCurrentLevel(150), 50);
      expect(xpToReachNextLevel(150), 150);
    });
  });

  group('lembretes', () {
    test('encode ordena e decode devolve o mesmo', () {
      final json = encodeHabitReminderTimes(const [
        TimeOfDay(hour: 14, minute: 30),
        TimeOfDay(hour: 9, minute: 0),
      ]);
      expect(json, '[[9,0],[14,30]]');
      expect(decodeHabitReminderTimes(json), const [
        TimeOfDay(hour: 9, minute: 0),
        TimeOfDay(hour: 14, minute: 30),
      ]);
    });

    test('decode tolera lixo e horários inválidos', () {
      expect(decodeHabitReminderTimes(null), isEmpty);
      expect(decodeHabitReminderTimes('  '), isEmpty);
      expect(decodeHabitReminderTimes('não é json'), isEmpty);
      expect(decodeHabitReminderTimes('[[25,0],[8,15]]'), const [
        TimeOfDay(hour: 8, minute: 15),
      ]);
    });

    test('distribui horários no intervalo', () {
      final times = spreadRemindersBetween(
        count: 3,
        start: const TimeOfDay(hour: 8, minute: 0),
        end: const TimeOfDay(hour: 20, minute: 0),
      );
      expect(times, const [
        TimeOfDay(hour: 8, minute: 0),
        TimeOfDay(hour: 14, minute: 0),
        TimeOfDay(hour: 20, minute: 0),
      ]);
      expect(
        spreadRemindersBetween(
          count: 0,
          start: const TimeOfDay(hour: 8, minute: 0),
          end: const TimeOfDay(hour: 20, minute: 0),
        ),
        isEmpty,
      );
    });

    test('fim antes do início atravessa a meia-noite', () {
      expect(
        spreadRemindersBetween(
          count: 3,
          start: const TimeOfDay(hour: 10, minute: 0),
          end: const TimeOfDay(hour: 0, minute: 0),
        ),
        const [
          TimeOfDay(hour: 10, minute: 0),
          TimeOfDay(hour: 17, minute: 0),
          TimeOfDay(hour: 0, minute: 0),
        ],
      );
      expect(
        spreadRemindersBetween(
          count: 3,
          start: const TimeOfDay(hour: 22, minute: 0),
          end: const TimeOfDay(hour: 2, minute: 0),
        ),
        const [
          TimeOfDay(hour: 22, minute: 0),
          TimeOfDay(hour: 0, minute: 0),
          TimeOfDay(hour: 2, minute: 0),
        ],
      );
    });
  });

  group('meta diária', () {
    test('atingida com folga de ponto flutuante', () {
      expect(isDailyTargetReached(8, 8), isTrue);
      expect(isDailyTargetReached(0.1 + 0.2, 0.3), isTrue);
      expect(isDailyTargetReached(7, 8), isFalse);
    });

    test('textos de meta e progresso', () {
      expect(formatDailyGoalLine(8, 'copos'), 'Meta: 8 copos');
      expect(formatDailyGoalLine(2.5, null), 'Meta: 2.5');
      expect(formatDailyProgressLine(3, 8, 'copos'), '3 / 8 copos');
      expect(formatDailyProgressLine(0, 2.5, ' '), '0 / 2.5');
    });
  });

  group('agenda do hábito', () {
    test('só é esperado a partir do dia de criação e nos dias ativos', () {
      // Criado na sexta 8/5/2026; ativo só às sextas (bit 4).
      final h = _habit(createdAt: DateTime(2026, 5, 8, 15), mask: 1 << 4);
      expect(isHabitExpectedOn(h, DateTime(2026, 5, 1)), isFalse);
      expect(isHabitExpectedOn(h, DateTime(2026, 5, 8)), isTrue);
      expect(isHabitExpectedOn(h, DateTime(2026, 5, 9)), isFalse);
      expect(isHabitExpectedOn(h, DateTime(2026, 5, 15)), isTrue);
    });
  });

  group('insights', () {
    final now = DateTime(2026, 5, 10, 12);

    test('sem hábitos sugere começar', () {
      final list = InsightEngine.generate(
        habits: const [],
        completions: const [],
        now: now,
      );
      expect(list.single.title, 'Por onde começo?');
    });

    test('sem dados suficientes cai no insight genérico', () {
      final list = InsightEngine.generate(
        habits: [_habit(createdAt: DateTime(2026, 5, 10, 8))],
        completions: const [],
        now: now,
      );
      expect(list.single.title, 'Continuidade');
    });

    test('humor alto recente gera insight de energia', () {
      final list = InsightEngine.generate(
        habits: [_habit(createdAt: DateTime(2026, 5, 10, 8))],
        completions: const [],
        now: now,
        moodsLast7d: const [5, 4, 4],
      );
      expect(list.map((e) => e.title), contains('Humor em alta'));
    });
  });
}
