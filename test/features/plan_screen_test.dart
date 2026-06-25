import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/app/providers.dart';
import 'package:fragua/core/db/database.dart';
import 'package:fragua/core/models/plan.dart';
import 'package:fragua/features/plan/plan_screen.dart';

void main() {
  testWidgets('muestra los días y ejercicios del plan', (tester) async {
    final db = FraguaDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db.savePlan(const Plan(split: SplitType.fullBody, days: [
      PlanDay(
        name: 'Full Body 1',
        type: DayType.strength,
        format: WorkoutFormat.straightSets,
        rounds: 1,
        exercises: [
          PlanExercise(
            exerciseId: 'squat',
            exerciseName: 'Sentadilla',
            sets: 3,
            repLow: 6,
            repHigh: 12,
            restSeconds: 90,
          ),
        ],
      ),
    ]));

    await tester.pumpWidget(ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: const MaterialApp(home: PlanScreen()),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Full Body 1'), findsOneWidget);
    expect(find.text('Sentadilla'), findsOneWidget);
    expect(find.textContaining('3 x 6-12'), findsOneWidget);
  });
}
