import '../../../core/database/app_database.dart';

/// Hábito agendado no dia-alvo + conclusão e métricas leves para a lista “Hoje”.
class HabitTodayRow {
  const HabitTodayRow({
    required this.habit,
    required this.done,
    required this.quantity,
    required this.currentStreak,
    required this.completionRate30d,
  });

  final Habit habit;

  /// Meta do dia atingida (`quantity >= habit.dailyTarget`).
  final bool done;

  /// Progresso registrado hoje (0 se nada foi marcado).
  final double quantity;
  final int currentStreak;
  final double completionRate30d;

  /// Hábitos com meta > 1 registram progresso parcial em vez de um toque único.
  bool get hasNumericGoal => habit.dailyTarget > 1;

  /// 0–1
  double get progress => habit.dailyTarget <= 0
      ? (done ? 1 : 0)
      : (quantity / habit.dailyTarget).clamp(0, 1).toDouble();
}
