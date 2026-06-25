import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/app/app.dart';
import 'package:fragua/app/providers.dart';
import 'package:fragua/core/db/database.dart';
import 'package:fragua/core/models/enums.dart';
import 'package:fragua/core/models/user_profile.dart';

UserProfile _profile() => UserProfile(
      sex: Sex.male,
      birthDate: DateTime(1995, 5, 5),
      heightCm: 180,
      weightKg: 80,
      goal: Goal.strength,
      level: ExperienceLevel.intermediate,
      daysPerWeek: 4,
      sessionMinutes: 60,
      equipment: {Equipment.barbell},
    );

Future<void> _pump(WidgetTester tester, FraguaDatabase db) async {
  await tester.pumpWidget(ProviderScope(
    overrides: [databaseProvider.overrideWithValue(db)],
    child: const FraguaApp(),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('sin perfil => Onboarding', (tester) async {
    final db = FraguaDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await _pump(tester, db);
    expect(find.text('Cuéntanos sobre ti'), findsOneWidget);
  });

  testWidgets('con perfil => Home', (tester) async {
    final db = FraguaDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db.saveProfile(_profile());
    await _pump(tester, db);
    expect(find.byKey(const Key('home-title')), findsOneWidget);
  });
}
