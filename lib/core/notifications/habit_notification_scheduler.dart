import 'dart:developer' as developer;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../database/app_database.dart';
import '../utils/date_key.dart';
import '../../features/habits/domain/habit_reminder_times_codec.dart';
import 'pulse_local_notifications.dart';

/// Agenda lembretes semanais por (hábito × dia da semana × horário) — Plano 7.
final class PulseHabitNotificationScheduler {
  PulseHabitNotificationScheduler(this._db);

  final PulseDatabase _db;
  static bool _timezoneReady = false;

  /// Reagendamentos em fila: cada um cancela tudo e recria, não podem se intercalar.
  Future<void> _queue = Future<void>.value();

  Future<void> initTimeZone() async {
    if (_timezoneReady) return;
    tz_data.initializeTimeZones();
    try {
      final name = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(name));
    } catch (e) {
      developer.log('Timezone fallback UTC: $e', name: 'PulseNotif');
      tz.setLocalLocation(tz.UTC);
    }
    _timezoneReady = true;
  }

  /// Solicita permissões de notificação (Android 13+ / iOS).
  Future<void> requestPermissionsIfNeeded() async {
    await Permission.notification.request();
    final ios = PulseLocalNotifications.plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    await ios?.requestPermissions(alert: true, badge: true, sound: true);
    final mac = PulseLocalNotifications.plugin
        .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>();
    await mac?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> cancelAllForPulse() async {
    await PulseLocalNotifications.plugin.cancelAll();
  }

  int stableNotificationId({
    required String habitId,
    required int weekday,
    required int slotIndex,
  }) {
    var h = 0;
    for (final c in habitId.codeUnits) {
      h = (h * 31 + c) & 0x7fffffff;
    }
    return (h ^ (weekday << 8) ^ (slotIndex << 16)) & 0x7fffffff;
  }

  Future<void> rescheduleAll(String userId) {
    final next = _queue.catchError((_) {}).then((_) => _rescheduleAll(userId));
    _queue = next;
    return next;
  }

  Future<void> _rescheduleAll(String userId) async {
    await PulseLocalNotifications.ensureInitialized();
    await initTimeZone();
    await cancelAllForPulse();

    final habits = await _db.habitsForUser(userId);
    const androidChan = AndroidNotificationChannel(
      'pulse_habit_reminders_v1',
      'Lembretes de hábitos',
      description: 'Horários configurados nos seus hábitos.',
      importance: Importance.defaultImportance,
    );
    await PulseLocalNotifications.plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChan);

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'pulse_habit_reminders_v1',
        'Lembretes de hábitos',
        channelDescription:
            'Lembretes semanais alinhados aos dias onde o hábito está ativo.',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
      iOS: DarwinNotificationDetails(threadIdentifier: 'pulse_habit'),
    );

    final todayKey = dateKeyFromDateTime(DateTime.now());

    for (final habit in habits) {
      final times =
          decodeHabitReminderTimes(habit.reminderTimesJson);
      if (times.isEmpty) continue;

      // Hábito já concluído hoje: os lembretes de hoje só voltam na semana que vem.
      final doneToday = await _db.hasCompletion(habit.id, todayKey);

      for (var s = 0; s < times.length; s++) {
        final t = times[s];
        for (var bit = 0; bit < 7; bit++) {
          if ((habit.weekdaysBitmask & (1 << bit)) == 0) continue;
          final weekdayDart = bit + DateTime.monday;
          await _scheduleWeekly(
            id: stableNotificationId(
              habitId: habit.id,
              weekday: weekdayDart,
              slotIndex: s,
            ),
            title: habit.name,
            body: 'Hora de registrar esse hábito.',
            dow: weekdayDart,
            hour: t.hour,
            minute: t.minute,
            details: details,
            skipToday: doneToday,
          );
        }
      }
    }
  }

  tz.TZDateTime _nextInstanceFrom({
    required int dow,
    required int hour,
    required int minute,
    required bool skipToday,
  }) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    while (scheduled.weekday != dow ||
        scheduled.isBefore(now.subtract(const Duration(seconds: 1)))) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    final isToday = scheduled.year == now.year &&
        scheduled.month == now.month &&
        scheduled.day == now.day;
    if (skipToday && isToday) {
      scheduled = scheduled.add(const Duration(days: 7));
    }
    return scheduled;
  }

  Future<void> _scheduleWeekly({
    required int id,
    required String title,
    required String body,
    required int dow,
    required int hour,
    required int minute,
    required NotificationDetails details,
    required bool skipToday,
  }) async {
    final when = _nextInstanceFrom(
      dow: dow,
      hour: hour,
      minute: minute,
      skipToday: skipToday,
    );
    await PulseLocalNotifications.plugin.zonedSchedule(
      id,
      title,
      body,
      when,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }
}
