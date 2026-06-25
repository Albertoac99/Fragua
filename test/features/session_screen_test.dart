import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/app/providers.dart';
import 'package:fragua/core/db/database.dart';
import 'package:fragua/core/models/plan.dart';
import 'package:fragua/features/workout/session_screen.dart';

PlanDay day() => const PlanDay(
      name: 'Push',
      type: DayType.strength,
      format: WorkoutFormat.straightSets,
      rounds: 1,
      exercises: [
        PlanExercise(
          exerciseId: 'bench',
          exerciseName: 'Bench',
          sets: 1,
          repLow: 6,
          repHigh: 12,
          restSeconds: 1,
        ),
      ],
    );

void main() {
  testWidgets('registra una serie y termina => progresión persistida',
      (tester) async {
    final db = FraguaDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db.saveExerciseState('bench', 100, 0);

    await tester.pumpWidget(ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: MaterialApp(home: SessionScreen(day: day())),
    ));
    await tester.pumpAndSettle(); // deja que cargue el peso persistido

    await tester.tap(find.byKey(const Key('log-set')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('finish-session')));
    await tester.pumpAndSettle();

    final s = await db.exerciseState('bench');
    expect(s!.weight, 102.5); // 12 reps por defecto => subió
  });
}
