import '../../../core/database/app_database.dart';

/// Hábito agendado no dia-alvo + conclusão e métricas leves para a lista “Hoje”.
class HabitTodayRow {
  const HabitTodayRow({
    required this.habit,
    required this.done,
    required this.currentStreak,
    required this.completionRate30d,
  });

  final Habit habit;
  final bool done;
  final int currentStreak;
  final double completionRate30d;
}
