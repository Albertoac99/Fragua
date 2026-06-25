import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/app/providers.dart';
import 'package:fragua/core/db/database.dart';
import 'package:fragua/core/leagues/divisions.dart';
import 'package:fragua/features/leagues/leagues_screen.dart';

void main() {
  testWidgets('muestra la división y al usuario en el leaderboard', (tester) async {
    final db = FraguaDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db.saveLeagueState(
      division: 'silver',
      weekId: weekIdFor(DateTime.now()),
      weeklyXp: 99999, // rank 1 => visible en lo alto de la lista
      streakCurrent: 3,
      streakRecord: 4,
      lastActiveDay: null,
      totalWorkouts: 5,
      totalPrs: 1,
    );

    await tester.pumpWidget(ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: const MaterialApp(home: LeaguesScreen()),
    ));
    await tester.pumpAndSettle();

    expect(find.textContaining('Plata'), findsOneWidget); // etiqueta de 'silver'
    expect(find.text('Tú'), findsOneWidget);
    expect(find.textContaining('Racha'), findsOneWidget);
  });
}
