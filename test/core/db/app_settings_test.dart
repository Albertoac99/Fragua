import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/core/db/database.dart';
import 'package:fragua/core/notifications/notification_settings.dart';

void main() {
  test('ajustes: defaults cuando no hay fila, y upsert', () async {
    final db = FraguaDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final def = await db.loadNotificationSettings();
    expect(def.remindersEnabled, isFalse);
    expect(def.reminderHour, 19);
    expect(def.reminderDays, {1, 2, 3, 4, 5});

    await db.saveNotificationSettings(const NotificationSettings(
      remindersEnabled: true,
      reminderHour: 7,
      reminderMinute: 15,
      reminderDays: {6, 7},
      streakReminderEnabled: false,
    ));
    final s = await db.loadNotificationSettings();
    expect(s.remindersEnabled, isTrue);
    expect(s.reminderHour, 7);
    expect(s.reminderMinute, 15);
    expect(s.reminderDays, {6, 7});
    expect(s.streakReminderEnabled, isFalse);

    expect(await db.select(db.appSettings).get(), hasLength(1));
  });
}
