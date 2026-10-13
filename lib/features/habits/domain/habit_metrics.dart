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

DateTime _previousDay(DateTime d) => DateTime(d.year, d.month, d.day - 1);

/// [createdAtMs] limita a janela de 30 dias aos dias em que o hábito já existia.
HabitMetrics computeHabitMetrics({
  required int weekdaysBitmask,
  required List<int> completionDateKeys,
  required DateTime now,
  int? createdAtMs,
}) {
  final today = DateTime(now.year, now.month, now.day);
  final set = completionDateKeys.toSet();
  final createdKey = createdAtMs == null
      ? 0
      : dateKeyFromDateTime(
          DateTime.fromMillisecondsSinceEpoch(createdAtMs, isUtc: false),
        );

  final current = _currentStreak(weekdaysBitmask, set, today);
  final best = _bestStreak(weekdaysBitmask, set);

  var expected = 0;
  var completed = 0;
  for (var i = 0; i < 30; i++) {
    final d = DateTime(today.year, today.month, today.day - i);
    if (!isWeekdayInBitmask(d.weekday, weekdaysBitmask)) continue;
    final k = dateKeyFromDateTime(d);
    if (k < createdKey) continue;
    expected++;
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

/// Hoje ainda pendente não quebra a série: ela só zera quando um dia agendado
/// **anterior** ficou sem conclusão.
int _currentStreak(int bitmask, Set<int> completions, DateTime today) {
  var end = DateTime(today.year, today.month, today.day);
  final todayPending = isWeekdayInBitmask(end.weekday, bitmask) &&
      !completions.contains(dateKeyFromDateTime(end));
  if (todayPending) end = _previousDay(end);
  return _streakEndingOn(end, bitmask, completions);
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
    if (scheduled && !completions.contains(dateKeyFromDateTime(d))) break;
    if (scheduled) streak++;
    d = _previousDay(d);
  }
  return streak;
}
