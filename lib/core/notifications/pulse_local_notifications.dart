import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final class PulseLocalNotifications {
  PulseLocalNotifications._();

  static final FlutterLocalNotificationsPlugin plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  static Future<void> ensureInitialized() async {
    if (_initialized) return;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(android: android, iOS: ios);
    await plugin.initialize(initSettings);
    _initialized = true;
  }
}
