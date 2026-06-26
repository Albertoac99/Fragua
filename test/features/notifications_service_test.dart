import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/core/db/database.dart';
import 'package:fragua/core/leagues/streak.dart';
import 'package:fragua/core/notifications/notification_settings.dart';
import 'package:fragua/features/notifications/notifications_service.dart';
import 'package:fragua/services/notifications/notifier.dart';

class FakeNotifier implements Notifier {
  final List<({int id, DateTime when, String title})> scheduled = [];
  bool cancelled = false;
  @override
  Future<void> init() async {}
  @override
  Future<bool> requestPermission() async => true;
  @override
  Future<void> scheduleAt(int id, DateTime when, String title, String body) async =>
      scheduled.add((id: id, when: when, title: title));
  @override
  Future<void> cancelAll() async => cancelled = true;
}

void main() {
  test('reprograma: cancela, agenda recordatorios y aviso de racha', () async {
    final db = FraguaDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final now = DateTime(2026, 6, 24, 12); // miércoles mediodía

    await db.saveNotificationSettings(const NotificationSettings(
      remindersEnabled: true,
      reminderHour: 19,
      reminderDays: {1, 2, 3, 4, 5},
      streakReminderEnabled: true,
    ));
    // Entrenó ayer => racha en peligro hoy.
    await db.saveLeagueState(
      division: 'bronze',
      weekId: 0,
      weeklyXp: 0,
      streakCurrent: 1,
      streakRecord: 1,
      lastActiveDay: dayNumber(now) - 1,
      totalWorkouts: 1,
      totalPrs: 0,
    );

    final fake = FakeNotifier();
    await NotificationsService(notifier: fake, db: db).reschedule(now);

    expect(fake.cancelled, isTrue);
    expect(fake.scheduled.any((e) => e.title == 'Hora de entrenar'), isTrue);
    final streak = fake.scheduled.where((e) => e.id == 900);
    expect(streak, hasLength(1));
    expect(streak.first.when, DateTime(2026, 6, 24, 20));
  });

  test('deshabilitado: solo cancela, no agenda nada', () async {
    final db = FraguaDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db.saveNotificationSettings(const NotificationSettings(
        remindersEnabled: false, streakReminderEnabled: false));

    final fake = FakeNotifier();
    await NotificationsService(notifier: fake, db: db)
        .reschedule(DateTime(2026, 6, 24, 12));

    expect(fake.cancelled, isTrue);
    expect(fake.scheduled, isEmpty);
  });
}
