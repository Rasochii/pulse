import '../../../core/database/app_database.dart';

String habitDailyGoalLabel(Habit h) =>
    formatDailyGoalLine(h.dailyTarget, h.dailyTargetUnit);

/// Texto amigável para UI (lista, formulário) sem instanciar [Habit].
String formatDailyGoalLine(double value, String? unit) {
  final s = _formatGoalNumber(value);
  final u = unit?.trim();
  if (u == null || u.isEmpty) {
    return 'Meta: $s';
  }
  return 'Meta: $s $u';
}

String _formatGoalNumber(double v) {
  if (v == v.roundToDouble()) return '${v.round()}';
  return v.toString();
}
