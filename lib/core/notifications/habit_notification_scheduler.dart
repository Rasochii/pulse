import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../database/app_database.dart';
import '../utils/date_key.dart';
import '../../features/habits/domain/habit_reminder_times_codec.dart';
import 'notification_permission.dart';
import 'pulse_local_notifications.dart';
import 'reminder_plan.dart';

/// Agenda os lembretes dos hábitos (ver [planHabitReminders]).
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
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (e) {
      developer.log('Timezone fallback UTC: $e', name: 'PulseNotif');
      tz.setLocalLocation(tz.UTC);
    }
    _timezoneReady = true;
  }

  /// Solicita permissões de notificação (Android 13+ / iOS).
  Future<void> requestPermissionsIfNeeded() async {
    if (!kRemindersSupported) return;
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
    if (!kRemindersSupported) return;
    await PulseLocalNotifications.plugin.cancelAll();
  }

  Future<void> rescheduleAll(String userId) {
    if (!kRemindersSupported) return Future<void>.value();
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


    final withTimes = habits
        .where((h) => decodeHabitReminderTimes(h.reminderTimesJson).isNotEmpty)
        .toList();
    final todayKey = dateKeyFromDateTime(DateTime.now());
    final doneToday = <String>{
      for (final h in withTimes)
        if (await _db.hasCompletion(h.id, todayKey)) h.id,
    };

    final plan = planHabitReminders(
      habits: withTimes,
      doneTodayHabitIds: doneToday,
      now: tz.TZDateTime.now(tz.local),
      maxCount: defaultTargetPlatform == TargetPlatform.iOS
          ? kMaxScheduledRemindersIos
          : kMaxScheduledRemindersAndroid,
    );

    for (final r in plan) {
      try {
        await PulseLocalNotifications.plugin.zonedSchedule(
          r.id,
          r.title,
          'Hora de registrar esse hábito.',
          r.firstFire,
          details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: switch (r.repeat) {
            ReminderRepeat.daily => DateTimeComponents.time,
            ReminderRepeat.weekly => DateTimeComponents.dayOfWeekAndTime,
            ReminderRepeat.once => null,
          },
        );
      } catch (e) {
        // Um lembrete recusado não pode derrubar os demais.
        developer.log('Lembrete ${r.id} não agendado: $e', name: 'PulseNotif');
      }
    }
  }
}
