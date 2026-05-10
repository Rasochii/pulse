import '../../../core/database/app_database.dart';
import '../../../core/utils/date_key.dart';

import '../domain/dashboard_snapshot.dart';

abstract final class DashboardBuilder {
  static DashboardSnapshot compute({
    required List<Habit> habits,
    required List<HabitCompletion> completions,
    required DateTime now,
    String? displayName,
  }) {
    final name = displayName?.trim().isNotEmpty == true
        ? displayName!.trim()
        : 'aí';
    if (habits.isEmpty) {
      return DashboardSnapshot.empty(name);
    }

    final today = DateTime(now.year, now.month, now.day);
    final todayKey = dateKeyFromDateTime(today);

    final completionSet = <int, Set<String>>{};
    for (final c in completions) {
      completionSet.putIfAbsent(c.dateKey, () => <String>{}).add(c.habitId);
    }

    int countCompletionsOnDay(DateTime d) {
      final k = dateKeyFromDateTime(d);
      final set = completionSet[k];
      return set?.length ?? 0;
    }

    var barSum = 0;
    final bars = List<int>.generate(7, (i) {
      final day = today.subtract(Duration(days: 6 - i));
      final n = countCompletionsOnDay(day);
      barSum += n;
      return n;
    });

    final scheduledToday =
        habits.where((h) => isWeekdayInBitmask(today.weekday, h.weekdaysBitmask)).toList();
    final todayExpected = scheduledToday.length;
    var todayDone = 0;
    for (final h in scheduledToday) {
      final set = completionSet[todayKey];
      if (set != null && set.contains(h.id)) todayDone++;
    }

    final heatRows = List.generate(14, (row) => List<HeatTone>.filled(7, HeatTone.muted));
    final anchorMonday = today.subtract(Duration(days: today.weekday - DateTime.monday));
    final gridEndMonday = anchorMonday;
    final gridStartMonday = gridEndMonday.subtract(const Duration(days: 7 * 13));

    for (var wi = 0; wi < 14; wi++) {
      final mondayWeek = gridStartMonday.add(Duration(days: wi * 7));
      for (var dow = 0; dow < 7; dow++) {
        final day =
            DateTime(mondayWeek.year, mondayWeek.month, mondayWeek.day + dow);
        if (day.isAfter(today)) {
          heatRows[wi][dow] = HeatTone.muted;
          continue;
        }
        final sched = habits
            .where((h) => isWeekdayInBitmask(day.weekday, h.weekdaysBitmask))
            .toList();
        if (sched.isEmpty) {
          heatRows[wi][dow] = HeatTone.muted;
          continue;
        }
        final key = dateKeyFromDateTime(day);
        final set = completionSet[key] ?? {};
        var done = 0;
        for (final h in sched) {
          if (set.contains(h.id)) done++;
        }
        final ratio = done / sched.length;
        if (day == today) {
          heatRows[wi][dow] = ratio >= 1
              ? HeatTone.perfect
              : ratio > 0
                  ? HeatTone.partial
                  : HeatTone.partial;
        } else {
          if (ratio >= 1) {
            heatRows[wi][dow] = HeatTone.perfect;
          } else if (ratio <= 0) {
            heatRows[wi][dow] = HeatTone.missed;
          } else {
            heatRows[wi][dow] = HeatTone.partial;
          }
        }
      }
    }

    var perfectStreak = 0;
    if (scheduledToday.isNotEmpty && todayDone == todayExpected) {
      perfectStreak++;
    }
    var probe = today.subtract(const Duration(days: 1));
    for (var i = 0; i < 400; i++) {
      final sched = habits
          .where((h) => isWeekdayInBitmask(probe.weekday, h.weekdaysBitmask))
          .toList();
      if (sched.isEmpty) {
        probe = probe.subtract(const Duration(days: 1));
        continue;
      }
      final key = dateKeyFromDateTime(probe);
      final set = completionSet[key] ?? {};
      var ok = true;
      for (final h in sched) {
        if (!set.contains(h.id)) {
          ok = false;
          break;
        }
      }
      if (!ok) break;
      perfectStreak++;
      probe = probe.subtract(const Duration(days: 1));
    }

    final start14 = today.subtract(const Duration(days: 13));
    final topList = <TopHabitStat>[];
    for (final h in habits) {
      var expected = 0;
      var hit = 0;
      for (var d = 0; d < 14; d++) {
        final day = DateTime(
          start14.year,
          start14.month,
          start14.day,
        ).add(Duration(days: d));
        if (!isWeekdayInBitmask(day.weekday, h.weekdaysBitmask)) continue;
        expected++;
        final k = dateKeyFromDateTime(day);
        if ((completionSet[k] ?? {}).contains(h.id)) hit++;
      }
      if (expected > 0) {
        topList.add(
          TopHabitStat(
            habitId: h.id,
            name: h.name,
            rate: hit / expected,
          ),
        );
      }
    }
    topList.sort((a, b) => b.rate.compareTo(a.rate));

    final start30 = today.subtract(const Duration(days: 29));
    final hist = List<int>.filled(24, 0);
    for (final c in completions) {
      if (c.dateKey < dateKeyFromDateTime(start30)) continue;
      final dt = DateTime.fromMillisecondsSinceEpoch(
        c.completedAtMs,
        isUtc: false,
      );
      if (dt.hour >= 0 && dt.hour < 24) {
        hist[dt.hour]++;
      }
    }
    final peak = <HourBin>[];
    for (var h = 0; h < 24; h++) {
      peak.add(HourBin(hour: h, count: hist[h]));
    }
    peak.sort((a, b) => b.count.compareTo(a.count));

    return DashboardSnapshot(
      displayNameGuess: name,
      todayDone: todayDone,
      todayExpected: todayExpected,
      perfectStreakDays: perfectStreak,
      completionsSumLast7: barSum,
      barLast7: bars,
      heatmap: heatRows,
      topHabits14d: topList.take(5).toList(),
      peakHours30d: peak.take(3).where((e) => e.count > 0).toList(),
      hasHabits: true,
    );
  }
}
