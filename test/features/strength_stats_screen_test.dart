import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/app/providers.dart';
import 'package:fragua/core/db/database.dart';
import 'package:fragua/features/stats/strength_stats_screen.dart';

void main() {
  testWidgets('muestra el PR del ejercicio con log', (tester) async {
    final db = FraguaDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db.addExerciseLog(
        exerciseId: 'bench',
        exerciseName: 'Bench',
        performedAt: DateTime(2026, 6, 1),
        weight: 100,
        totalReps: 24,
        sets: 3,
        maxReps: 8); // 1RM = 100*(1+8/30)=126.7

    await tester.pumpWidget(ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: const MaterialApp(home: StrengthStatsScreen()),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Bench'), findsWidgets);
    expect(find.textContaining('PR'), findsOneWidget);
    expect(find.textContaining('126'), findsOneWidget); // 1RM estimado redondeado
  });
}
