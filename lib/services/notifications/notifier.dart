import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Seam de notificaciones locales. La app degrada sin él (NoopNotifier).
/// (Se llama `AppNotifier` para no colisionar con `Notifier` de Riverpod.)
abstract class AppNotifier {
  Future<void> init();
  Future<bool> requestPermission();
  Future<void> scheduleAt(int id, DateTime when, String title, String body);
  Future<void> cancelAll();
}

/// Sin notificaciones (tests / permiso denegado / fallo del plugin).
class NoopNotifier implements AppNotifier {
  const NoopNotifier();
  @override
  Future<void> init() async {}
  @override
  Future<bool> requestPermission() async => false;
  @override
  Future<void> scheduleAt(
      int id, DateTime when, String title, String body) async {}
  @override
  Future<void> cancelAll() async {}
}

/// Implementación real con flutter_local_notifications + timezone.
class LocalNotifier implements AppNotifier {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'fragua_reminders',
      'Recordatorios',
      channelDescription: 'Recordatorios de entreno y racha',
      importance: Importance.max,
      priority: Priority.high,
    ),
  );

  @override
  Future<void> init() async {
    tzdata.initializeTimeZones();
    final info = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(info.identifier));
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(
      settings: const InitializationSettings(android: android),
    );
  }

  @override
  Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final granted = await android?.requestNotificationsPermission();
    return granted ?? false;
  }

  @override
  Future<void> scheduleAt(
      int id, DateTime when, String title, String body) async {
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(when, tz.local),
      notificationDetails: _details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  @override
  Future<void> cancelAll() => _plugin.cancelAll();
}
