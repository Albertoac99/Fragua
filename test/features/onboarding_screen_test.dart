import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/app/providers.dart';
import 'package:fragua/core/db/database.dart';
import 'package:fragua/features/onboarding/onboarding_screen.dart';

void main() {
  testWidgets('al guardar persiste un UserProfile', (tester) async {
    final db = FraguaDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: const MaterialApp(home: OnboardingScreen()),
    ));

    expect(await db.loadProfile(), isNull);

    await tester.tap(find.byKey(const Key('onboarding-save')));
    await tester.pumpAndSettle();

    final saved = await db.loadProfile();
    expect(saved, isNotNull);
    expect(saved!.daysPerWeek, inInclusiveRange(1, 7));
    expect(saved.equipment, isNotEmpty);
  });
}
