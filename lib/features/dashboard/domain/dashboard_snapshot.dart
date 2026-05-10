enum HeatTone { muted, missed, partial, perfect }

/// Conclusões no dia (contagem de linhas em habit_completions).
class TopHabitStat {
  const TopHabitStat({
    required this.habitId,
    required this.name,
    required this.rate,
  });

  final String habitId;
  final String name;
  final double rate;
}

class HourBin {
  const HourBin({required this.hour, required this.count});

  final int hour;
  final int count;
}

class DashboardSnapshot {
  const DashboardSnapshot({
    required this.displayNameGuess,
    required this.todayDone,
    required this.todayExpected,
    required this.perfectStreakDays,
    required this.completionsSumLast7,
    required this.barLast7,
    required this.heatmap,
    required this.topHabits14d,
    required this.peakHours30d,
    required this.hasHabits,
  });

  final String displayNameGuess;
  final int todayDone;
  final int todayExpected;

  double get completionRateToday =>
      todayExpected <= 0 ? 0 : (todayDone / todayExpected).clamp(0, 1);

  final int perfectStreakDays;
  final int completionsSumLast7;
  final List<int> barLast7;
  final List<List<HeatTone>> heatmap;
  final List<TopHabitStat> topHabits14d;
  final List<HourBin> peakHours30d;
  final bool hasHabits;

  factory DashboardSnapshot.empty(String nameGuess) => DashboardSnapshot(
        displayNameGuess: nameGuess,
        todayDone: 0,
        todayExpected: 0,
        perfectStreakDays: 0,
        completionsSumLast7: 0,
        barLast7: List.filled(7, 0),
        heatmap: const [],
        topHabits14d: const [],
        peakHours30d: const [],
        hasHabits: false,
      );
}
