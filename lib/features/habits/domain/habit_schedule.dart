import '../../../core/database/app_database.dart';
import '../../../core/utils/date_key.dart';

/// Chave `yyyymmdd` do dia em que o hábito foi criado.
int habitCreatedDateKey(Habit h) => dateKeyFromDateTime(
      DateTime.fromMillisecondsSinceEpoch(h.createdAtMs, isUtc: false),
    );

/// O hábito conta como "esperado" em [day]: dia da semana ativo **e** já existia nesse dia.
bool isHabitExpectedOn(Habit h, DateTime day) {
  if (!isWeekdayInBitmask(day.weekday, h.weekdaysBitmask)) return false;
  return dateKeyFromDateTime(day) >= habitCreatedDateKey(h);
}
