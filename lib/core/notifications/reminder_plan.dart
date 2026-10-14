import 'package:timezone/timezone.dart' as tz;

import '../database/app_database.dart';
import '../utils/date_key.dart';
import '../../features/habits/domain/habit_reminder_times_codec.dart';

/// Como o lembrete se repete depois do primeiro disparo.
enum ReminderRepeat {
  /// Todo dia no mesmo horário.
  daily,

  /// Toda semana, no mesmo dia da semana e horário.
  weekly,

  /// Uma vez só (volta a ser repetido no próximo reagendamento do app).
  once,
}

final class PlannedReminder {
  const PlannedReminder({
    required this.id,
    required this.habitId,
    required this.title,
    required this.firstFire,
    required this.repeat,
  });

  final int id;
  final String habitId;
  final String title;
  final tz.TZDateTime firstFire;
  final ReminderRepeat repeat;
}

/// Limite de lembretes agendados ao mesmo tempo. O Android recusa mais de 500
/// alarmes por app e o iOS guarda só 64 notificações pendentes.
const kMaxScheduledRemindersAndroid = 400;
const kMaxScheduledRemindersIos = 60;

/// Monta a agenda de lembretes a partir dos hábitos.
///
/// - Hábito de todos os dias: um alarme diário por horário.
/// - Hábito de alguns dias: um alarme semanal por (dia × horário).
/// - Hábito já concluído hoje: o horário que ainda tocaria hoje não toca. O dia de
///   hoje vira um disparo único na semana que vem e os outros dias seguem semanais —
///   o Android recalcula o primeiro disparo de alarmes repetidos a partir de agora,
///   então "começar amanhã" não pode ser expresso com repetição.
///
/// Acima de [maxCount], ficam os que disparam primeiro; o resto entra num
/// reagendamento seguinte (o app reagenda ao abrir, ao marcar e à meia-noite).
List<PlannedReminder> planHabitReminders({
  required List<Habit> habits,
  required Set<String> doneTodayHabitIds,
  required tz.TZDateTime now,
  int maxCount = kMaxScheduledRemindersAndroid,
}) {
  final out = <({String habitId, String title, tz.TZDateTime at, ReminderRepeat repeat})>[];

  for (final habit in habits) {
    final times = decodeHabitReminderTimes(habit.reminderTimesJson);
    if (times.isEmpty) continue;
    final activeDays = [
      for (var w = DateTime.monday; w <= DateTime.sunday; w++)
        if (isWeekdayInBitmask(w, habit.weekdaysBitmask)) w,
    ];
    if (activeDays.isEmpty) continue;
    final everyDay = activeDays.length == 7;
    final doneToday = doneTodayHabitIds.contains(habit.id);

    for (final t in times) {
      final todayAt = _at(now, 0, t.hour, t.minute);
      final firesLaterToday =
          activeDays.contains(now.weekday) && !todayAt.isBefore(now);
      final skipToday = doneToday && firesLaterToday;

      void add(tz.TZDateTime at, ReminderRepeat repeat) => out.add(
            (habitId: habit.id, title: habit.name, at: at, repeat: repeat),
          );

      if (!skipToday && everyDay) {
        add(_nextDaily(now, t.hour, t.minute), ReminderRepeat.daily);
        continue;
      }
      for (final w in activeDays) {
        if (skipToday && w == now.weekday) {
          add(_at(now, 7, t.hour, t.minute), ReminderRepeat.once);
        } else {
          add(_nextWeekly(now, w, t.hour, t.minute), ReminderRepeat.weekly);
        }
      }
    }
  }

  out.sort((a, b) => a.at.compareTo(b.at));
  final kept = out.length > maxCount ? out.sublist(0, maxCount) : out;
  return [
    for (var i = 0; i < kept.length; i++)
      PlannedReminder(
        // Tudo é cancelado antes de reagendar: ids sequenciais nunca colidem.
        id: i,
        habitId: kept[i].habitId,
        title: kept[i].title,
        firstFire: kept[i].at,
        repeat: kept[i].repeat,
      ),
  ];
}

/// [days] dias depois de hoje, no horário dado. Conta em dias do calendário
/// (não em 24 h), para o horário não escorregar na mudança de horário de verão.
tz.TZDateTime _at(tz.TZDateTime now, int days, int hour, int minute) =>
    tz.TZDateTime(now.location, now.year, now.month, now.day + days, hour, minute);

tz.TZDateTime _nextDaily(tz.TZDateTime now, int hour, int minute) {
  final today = _at(now, 0, hour, minute);
  return today.isBefore(now) ? _at(now, 1, hour, minute) : today;
}

tz.TZDateTime _nextWeekly(tz.TZDateTime now, int weekday, int hour, int minute) {
  for (var d = 0; d < 7; d++) {
    final at = _at(now, d, hour, minute);
    if (at.weekday == weekday && !at.isBefore(now)) return at;
  }
  return _at(now, 7, hour, minute);
}
