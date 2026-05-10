/// Chave de calendário local no formato `yyyymmdd` (ex.: 20260510).
int dateKeyFromDateTime(DateTime d) {
  final l = DateTime(d.year, d.month, d.day);
  return l.year * 10000 + l.month * 100 + l.day;
}

DateTime startOfDayFromDateKey(int key) {
  final y = key ~/ 10000;
  final m = (key % 10000) ~/ 100;
  final day = key % 100;
  return DateTime(y, m, day);
}

/// `weekday` no estilo [DateTime.weekday] (1 = seg … 7 = dom).
bool isWeekdayInBitmask(int weekday, int bitmask) {
  if (weekday < 1 || weekday > 7) return false;
  final bit = weekday - 1;
  return (bitmask & (1 << bit)) != 0;
}

/// Letras tradicionais em PT (calendário escolar / planilhas): S,T,Q,Q,S,S,D.
/// [DateTime.weekday]: 1 = segunda … 7 = domingo.
const kWeekdayLettersPt = ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];

/// Uma letra por dia da semana (mesmo esquema do heatmap: S,T,Q,Q,S,S,D).
String shortWeekdayPt(DateTime date) {
  return kWeekdayLettersPt[date.weekday - 1];
}
