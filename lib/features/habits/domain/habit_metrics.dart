import '../../../core/utils/date_key.dart';

/// Resumo de métricas derivadas de um conjunto de date keys (calendário local).
class HabitMetrics {
  const HabitMetrics({
    required this.currentStreak,
    required this.bestStreak,
    required this.completionRate30d,
    required this.completionsLast30d,
    required this.expectedDaysLast30d,
  });

  final int currentStreak;
  final int bestStreak;
  /// 0–1
  final double completionRate30d;
  final int completionsLast30d;
  final int expectedDaysLast30d;
}

HabitMetrics computeHabitMetrics({
  required int weekdaysBitmask,
  required List<int> completionDateKeys,
  required DateTime now,
}) {
  final today = DateTime(now.year, now.month, now.day);
  final set = completionDateKeys.toSet();

  final current = _currentStreak(weekdaysBitmask, set, today);
  final best = _bestStreak(weekdaysBitmask, set);

  final windowStart = today.subtract(const Duration(days: 29));
  var expected = 0;
  var completed = 0;
  for (var i = 0; i < 30; i++) {
    final d = DateTime(
      windowStart.year,
      windowStart.month,
      windowStart.day,
    ).add(Duration(days: i));
    if (!isWeekdayInBitmask(d.weekday, weekdaysBitmask)) continue;
    expected++;
    final k = dateKeyFromDateTime(d);
    if (set.contains(k)) completed++;
  }
  final rate = expected == 0 ? 0.0 : completed / expected;

  return HabitMetrics(
    currentStreak: current,
    bestStreak: best,
    completionRate30d: rate,
    completionsLast30d: completed,
    expectedDaysLast30d: expected,
  );
}

int _currentStreak(int bitmask, Set<int> completions, DateTime today) {
  var streak = 0;
  var d = DateTime(today.year, today.month, today.day);
  for (var i = 0; i < 730; i++) {
    final scheduled = isWeekdayInBitmask(d.weekday, bitmask);
    final key = dateKeyFromDateTime(d);
    if (scheduled) {
      if (completions.contains(key)) {
        streak++;
        d = d.subtract(const Duration(days: 1));
      } else {
        break;
      }
    } else {
      d = d.subtract(const Duration(days: 1));
    }
  }
  return streak;
}

int _bestStreak(int bitmask, Set<int> completions) {
  if (completions.isEmpty) return 0;
  final sorted = completions.toList()..sort();

  var best = 0;
  for (final key in sorted) {
    final end = startOfDayFromDateKey(key);
    final s = _streakEndingOn(end, bitmask, completions);
    if (s > best) best = s;
  }
  return best;
}

int _streakEndingOn(
  DateTime endDay,
  int bitmask,
  Set<int> completions,
) {
  var streak = 0;
  var d = DateTime(endDay.year, endDay.month, endDay.day);
  for (var i = 0; i < 730; i++) {
    final scheduled = isWeekdayInBitmask(d.weekday, bitmask);
    final key = dateKeyFromDateTime(d);
    if (scheduled) {
      if (completions.contains(key)) {
        streak++;
        d = d.subtract(const Duration(days: 1));
      } else {
        break;
      }
    } else {
      d = d.subtract(const Duration(days: 1));
    }
  }
  return streak;
}
