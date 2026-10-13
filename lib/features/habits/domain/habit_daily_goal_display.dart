import '../../../core/database/app_database.dart';

String habitDailyGoalLabel(Habit h) =>
    formatDailyGoalLine(h.dailyTarget, h.dailyTargetUnit);

/// Texto amigável para UI (lista, formulário) sem instanciar [Habit].
String formatDailyGoalLine(double value, String? unit) {
  final s = formatGoalNumber(value);
  final u = unit?.trim();
  if (u == null || u.isEmpty) {
    return 'Meta: $s';
  }
  return 'Meta: $s $u';
}

/// Progresso do dia, ex.: `3 / 8 copos`.
String formatDailyProgressLine(double done, double target, String? unit) {
  final u = unit?.trim();
  final base = '${formatGoalNumber(done)} / ${formatGoalNumber(target)}';
  return u == null || u.isEmpty ? base : '$base $u';
}

/// Número sem casas decimais desnecessárias (`8`, `2.5`).
String formatGoalNumber(double v) {
  if (v == v.roundToDouble()) return '${v.round()}';
  return v.toString();
}
