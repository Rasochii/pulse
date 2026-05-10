import '../../../core/database/app_database.dart';
import '../../../core/utils/date_key.dart';

/// Resumo imutável para o cartão de bem-estar e o histórico.
final class WellbeingUiSummary {
  const WellbeingUiSummary({
    required this.hasAnyLog,
    this.lastLog,
    this.moodAvgLast7CalendarDays,
    this.energyAvgLast7CalendarDays,
    required this.moodByDayLast7,
    this.correlationLine,
  });

  factory WellbeingUiSummary.empty() => WellbeingUiSummary(
        hasAnyLog: false,
        moodByDayLast7: List<double?>.filled(7, null),
      );

  final bool hasAnyLog;
  final WellbeingLog? lastLog;
  final double? moodAvgLast7CalendarDays;
  final double? energyAvgLast7CalendarDays;

  /// Índice 0 = há 6 dias; 6 = hoje. `null` = sem check-in nesse dia civil.
  final List<double?> moodByDayLast7;

  /// Frase opcional (hábitos + dados suficientes).
  final String? correlationLine;
}

DateTime _startOfDayLocal(int ms) {
  return DateTime.fromMillisecondsSinceEpoch(ms, isUtc: false);
}

int _dateKeyFromLog(WellbeingLog l) {
  final dt = _startOfDayLocal(l.loggedAtMs);
  return dateKeyFromDateTime(dt);
}

/// Agrega humor/energia por dia civil.
Map<int, ({int moodSum, int energySum, int count})> _aggregatesByDayKey(
  Iterable<WellbeingLog> logs,
) {
  final map = <int, ({int moodSum, int energySum, int count})>{};
  for (final log in logs) {
    final k = _dateKeyFromLog(log);
    final prev = map[k];
    if (prev == null) {
      map[k] = (moodSum: log.mood, energySum: log.energy, count: 1);
    } else {
      map[k] = (
        moodSum: prev.moodSum + log.mood,
        energySum: prev.energySum + log.energy,
        count: prev.count + 1,
      );
    }
  }
  return map;
}

bool _inLastNDaysStart(DateTime dayStart, DateTime todayStart, int n) {
  final diff = todayStart.difference(dayStart).inDays;
  return diff >= 0 && diff < n;
}

/// Taxa 0..1 ou `null` se não havia hábitos esperados nesse dia.
double? _completionRateForDay(
  DateTime day,
  List<Habit> habits,
  Map<int, Set<String>> completionSet,
) {
  final sched = habits
      .where((h) => isWeekdayInBitmask(day.weekday, h.weekdaysBitmask))
      .toList();
  if (sched.isEmpty) return null;
  final key = dateKeyFromDateTime(day);
  final set = completionSet[key] ?? {};
  var done = 0;
  for (final h in sched) {
    if (set.contains(h.id)) done++;
  }
  return done / sched.length;
}

Map<int, Set<String>> _completionSet(List<HabitCompletion> completions) {
  final m = <int, Set<String>>{};
  for (final c in completions) {
    m.putIfAbsent(c.dateKey, () => <String>{}).add(c.habitId);
  }
  return m;
}

/// Média das taxas de dias com `rates` não vazias; `-1` se nenhuma taxa válida.
double _meanRate(List<DateTime> days, List<Habit> habits, Map<int, Set<String>> set) {
  var sum = 0.0;
  var n = 0;
  for (final d in days) {
    final r = _completionRateForDay(d, habits, set);
    if (r != null) {
      sum += r;
      n++;
    }
  }
  if (n == 0) return -1;
  return sum / n;
}

String? _buildCorrelationLine({
  required DateTime now,
  required List<WellbeingLog> logs,
  required List<Habit> habits,
  required List<HabitCompletion> completions,
}) {
  if (habits.isEmpty || logs.isEmpty) return null;

  final todayStart = DateTime(now.year, now.month, now.day);
  final byDay = _aggregatesByDayKey(logs);
  final completionSet = _completionSet(completions);

  final highDays = <DateTime>[];
  final lowDays = <DateTime>[];

  for (var i = 0; i < 14; i++) {
    final day = todayStart.subtract(Duration(days: 13 - i));
    final key = dateKeyFromDateTime(day);
    final agg = byDay[key];
    if (agg == null || agg.count == 0) continue;
    final avgM = agg.moodSum / agg.count;
    if (avgM >= 4) {
      highDays.add(day);
    } else if (avgM <= 2) {
      lowDays.add(day);
    }
  }

  if (highDays.length < 2 || lowDays.length < 2) return null;

  final highR = _meanRate(highDays, habits, completionSet);
  final lowR = _meanRate(lowDays, habits, completionSet);
  if (highR < 0 || lowR < 0) return null;

  final hp = (highR * 100).round();
  final lp = (lowR * 100).round();
  return 'Nos dias de humor alto (média ≥ 4), a taxa dos hábitos ficou perto de $hp%; '
      'nos de humor baixo (≤ 2), perto de $lp%.';
}

WellbeingUiSummary buildWellbeingUiSummary({
  required List<WellbeingLog> logsNewestFirst,
  required List<Habit> habits,
  required List<HabitCompletion> completions,
  required DateTime now,
}) {
  if (logsNewestFirst.isEmpty) {
    return WellbeingUiSummary.empty();
  }

  final todayStart = DateTime(now.year, now.month, now.day);
  final last = logsNewestFirst.first;
  final byDay = _aggregatesByDayKey(logsNewestFirst);

  var moodSum7 = 0;
  var energySum7 = 0;
  var count7 = 0;
  for (final log in logsNewestFirst) {
    final local = _startOfDayLocal(log.loggedAtMs);
    final dayStart = DateTime(local.year, local.month, local.day);
    if (_inLastNDaysStart(dayStart, todayStart, 7)) {
      moodSum7 += log.mood;
      energySum7 += log.energy;
      count7++;
    }
  }

  final moodByDayLast7 = List<double?>.generate(7, (i) {
    final day = todayStart.subtract(Duration(days: 6 - i));
    final key = dateKeyFromDateTime(day);
    final agg = byDay[key];
    if (agg == null || agg.count == 0) return null;
    return agg.moodSum / agg.count;
  });

  final correlationLine = _buildCorrelationLine(
    now: now,
    logs: logsNewestFirst,
    habits: habits,
    completions: completions,
  );

  return WellbeingUiSummary(
    hasAnyLog: true,
    lastLog: last,
    moodAvgLast7CalendarDays: count7 > 0 ? moodSum7 / count7 : null,
    energyAvgLast7CalendarDays: count7 > 0 ? energySum7 / count7 : null,
    moodByDayLast7: moodByDayLast7,
    correlationLine: correlationLine,
  );
}
