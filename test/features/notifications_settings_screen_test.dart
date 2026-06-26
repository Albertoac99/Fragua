import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/app/providers.dart';
import 'package:fragua/core/db/database.dart';
import 'package:fragua/features/notifications/notifications_settings_screen.dart';

void main() {
  testWidgets('activar recordatorios persiste el ajuste', (tester) async {
    final db = FraguaDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: const MaterialApp(home: NotificationsSettingsScreen()),
    ));
    await tester.pumpAndSettle();

    expect((await db.loadNotificationSettings()).remindersEnabled, isFalse);

    await tester.tap(find.byKey(const Key('reminders-toggle')));
    await tester.pumpAndSettle();

    expect((await db.loadNotificationSettings()).remindersEnabled, isTrue);
  });
}
