import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/database/app_database.dart';
import 'package:pulse/core/notifications/reminder_plan.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

const _allDays = 127;
// Bits 0–6 = seg–dom.
const _monWedFri = 1 | 4 | 16;

Habit _habit(
  String id, {
  required List<List<int>> times,
  int weekdays = _allDays,
}) =>
    Habit(
      id: id,
      userId: 'u',
      name: 'Hábito $id',
      iconKey: 'task_alt',
      colorArgb: 0,
      weekdaysBitmask: weekdays,
      dailyTarget: 1,
      reminderTimesJson: jsonEncode(times),
      createdAtMs: 0,
      updatedAtMs: 0,
    );

void main() {
  late tz.Location saoPaulo;
  // Quarta-feira, 14/10/2026, 10:00.
  late tz.TZDateTime now;

  setUpAll(() {
    tz_data.initializeTimeZones();
    saoPaulo = tz.getLocation('America/Sao_Paulo');
    now = tz.TZDateTime(saoPaulo, 2026, 10, 14, 10);
  });

  List<PlannedReminder> plan(
    List<Habit> habits, {
    Set<String> doneToday = const {},
    tz.TZDateTime? at,
    int max = kMaxScheduledRemindersAndroid,
  }) =>
      planHabitReminders(
        habits: habits,
        doneTodayHabitIds: doneToday,
        now: at ?? now,
        maxCount: max,
      );

  bool firesToday(PlannedReminder r) =>
      r.firstFire.year == now.year &&
      r.firstFire.month == now.month &&
      r.firstFire.day == now.day;

  test('a data de referência é uma quarta-feira', () {
    expect(now.weekday, DateTime.wednesday);
  });

  group('um lembrete', () {
    test('todos os dias, antes do horário: um alarme diário hoje', () {
      final r = plan([_habit('a', times: [[21, 0]])]).single;
      expect(r.repeat, ReminderRepeat.daily);
      expect(r.firstFire, tz.TZDateTime(saoPaulo, 2026, 10, 14, 21));
      expect(r.title, 'Hábito a');
    });

    test('todos os dias, horário já passou: começa amanhã', () {
      final r = plan([_habit('a', times: [[8, 30]])]).single;
      expect(r.repeat, ReminderRepeat.daily);
      expect(r.firstFire, tz.TZDateTime(saoPaulo, 2026, 10, 15, 8, 30));
    });

    test('no minuto exato ainda toca hoje', () {
      final r = plan([_habit('a', times: [[10, 0]])]).single;
      expect(r.firstFire, now);
    });

    test('concluído hoje: não toca mais hoje e segue nos outros dias', () {
      final list = plan([_habit('a', times: [[21, 0]])], doneToday: {'a'});
      expect(list, hasLength(7));
      expect(list.where(firesToday), isEmpty);

      final once = list.where((r) => r.repeat == ReminderRepeat.once).single;
      expect(once.firstFire, tz.TZDateTime(saoPaulo, 2026, 10, 21, 21));

      final weekly = list.where((r) => r.repeat == ReminderRepeat.weekly);
      expect(
        weekly.map((r) => r.firstFire.weekday).toSet(),
        {1, 2, 4, 5, 6, 7},
      );
      for (final r in weekly) {
        expect(r.firstFire.hour, 21);
        expect(r.firstFire.isAfter(now), isTrue);
      }
    });

    test('concluído hoje com o horário já passado: agenda normal', () {
      final r = plan([_habit('a', times: [[8, 0]])], doneToday: {'a'}).single;
      expect(r.repeat, ReminderRepeat.daily);
      expect(r.firstFire, tz.TZDateTime(saoPaulo, 2026, 10, 15, 8));
    });

    test('dias específicos: um alarme semanal por dia, no dia certo', () {
      final list = plan([
        _habit('a', times: [[9, 0]], weekdays: _monWedFri),
      ]);
      expect(list.every((r) => r.repeat == ReminderRepeat.weekly), isTrue);
      expect(
        list.map((r) => r.firstFire).toList(),
        [
          tz.TZDateTime(saoPaulo, 2026, 10, 16, 9), // sexta
          tz.TZDateTime(saoPaulo, 2026, 10, 19, 9), // segunda
          tz.TZDateTime(saoPaulo, 2026, 10, 21, 9), // quarta (hoje já passou)
        ],
      );
    });

    test('dia que não é do hábito: concluído hoje não muda nada', () {
      // Hábito só de segunda; "concluído hoje" (quarta) não afeta.
      final r = plan(
        [_habit('a', times: [[21, 0]], weekdays: 1)],
        doneToday: {'a'},
      ).single;
      expect(r.repeat, ReminderRepeat.weekly);
      expect(r.firstFire, tz.TZDateTime(saoPaulo, 2026, 10, 19, 21));
    });
  });

  group('vários lembretes', () {
    test('oito horários todos os dias: oito alarmes diários', () {
      final times = [
        [8, 0], [10, 0], [12, 0], [14, 0], [16, 0], [18, 0], [20, 0], [21, 30],
      ];
      final list = plan([_habit('agua', times: times)]);
      expect(list, hasLength(8));
      expect(list.every((r) => r.repeat == ReminderRepeat.daily), isTrue);
      expect(list.map((r) => r.id).toSet(), hasLength(8));
      expect(
        list.map((r) => '${r.firstFire.day} ${r.firstFire.hour}:${r.firstFire.minute}'),
        [
          '14 10:0', '14 12:0', '14 14:0', '14 16:0', '14 18:0', '14 20:0',
          '14 21:30', '15 8:0',
        ],
      );
    });

    test('concluído no meio do dia: nenhum toca hoje; os de antes seguem diários', () {
      final list = plan(
        [_habit('agua', times: [[8, 0], [12, 0], [16, 0], [20, 0]])],
        doneToday: {'agua'},
      );
      // 08:00 já passou (diário a partir de amanhã); 12, 16 e 20 viram 6 semanais + 1 único.
      expect(list, hasLength(1 + 3 * 7));
      expect(list.where(firesToday), isEmpty);
      expect(list.where((r) => r.repeat == ReminderRepeat.daily).single.firstFire,
          tz.TZDateTime(saoPaulo, 2026, 10, 15, 8));
      expect(
        list
            .where((r) => r.repeat == ReminderRepeat.once)
            .map((r) => r.firstFire.hour),
        [12, 16, 20],
      );
    });

    test('vários hábitos: ids únicos e ordem por disparo', () {
      final list = plan([
        _habit('a', times: [[21, 0], [11, 0]]),
        _habit('b', times: [[9, 0]], weekdays: _monWedFri),
        _habit('c', times: [[10, 30]]),
      ]);
      expect(list.map((r) => r.id).toSet(), hasLength(list.length));
      for (var i = 1; i < list.length; i++) {
        expect(list[i].firstFire.isBefore(list[i - 1].firstFire), isFalse);
      }
      expect(list.first.habitId, 'c');
      expect(list.where((r) => r.habitId == 'b'), hasLength(3));
    });

    test('acima do limite ficam os que disparam primeiro', () {
      final habits = [
        for (var i = 0; i < 30; i++)
          _habit('h$i', times: [for (var h = 0; h < 24; h++) [h, i]]),
      ];
      final list = plan(habits, max: 400);
      expect(list, hasLength(400));
      final all = plan(habits, max: 100000);
      expect(all, hasLength(30 * 24));
      final cutoff = list.last.firstFire;
      expect(
        all.skip(400).every((r) => !r.firstFire.isBefore(cutoff)),
        isTrue,
      );
    });

    test('sem horários ou sem dias: nada agendado', () {
      expect(plan([_habit('a', times: [])]), isEmpty);
      expect(plan([_habit('a', times: [[9, 0]], weekdays: 0)]), isEmpty);
    });
  });

  group('horário de verão', () {
    late tz.Location lisbon;
    // Sábado, 24/10/2026, 10:00; o horário de verão europeu termina no domingo, 25.
    late tz.TZDateTime saturday;

    setUpAll(() {
      lisbon = tz.getLocation('Europe/Lisbon');
      saturday = tz.TZDateTime(lisbon, 2026, 10, 24, 10);
    });

    test('lembrete semanal depois da troca mantém o horário local', () {
      final r = plan(
        [_habit('a', times: [[9, 0]], weekdays: 1)],
        at: saturday,
      ).single;
      expect(r.firstFire.weekday, DateTime.monday);
      expect(r.firstFire.day, 26);
      expect(r.firstFire.hour, 9);
    });

    test('disparo único da semana seguinte mantém o horário local', () {
      final once = plan(
        [_habit('a', times: [[21, 0]])],
        doneToday: {'a'},
        at: saturday,
      ).where((r) => r.repeat == ReminderRepeat.once).single;
      expect(once.firstFire.day, 31);
      expect(once.firstFire.hour, 21);
    });
  });
}
