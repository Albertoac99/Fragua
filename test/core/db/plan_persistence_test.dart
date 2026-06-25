import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/core/db/database.dart';
import 'package:fragua/core/models/plan.dart';

void main() {
  test('guarda y recupera el Plan (fila única)', () async {
    final db = FraguaDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    expect(await db.loadPlan(), isNull);

    const plan = Plan(split: SplitType.fullBody, days: [
      PlanDay(
        name: 'Full Body 1',
        type: DayType.strength,
        format: WorkoutFormat.straightSets,
        rounds: 1,
        exercises: [
          PlanExercise(
            exerciseId: 'squat',
            exerciseName: 'Squat',
            sets: 3,
            repLow: 6,
            repHigh: 12,
            restSeconds: 90,
          ),
        ],
      ),
    ]);

    await db.savePlan(plan);
    final loaded = await db.loadPlan();
    expect(loaded, isNotNull);
    expect(loaded!.split, SplitType.fullBody);
    expect(loaded.days.first.exercises.first.exerciseId, 'squat');

    await db.savePlan(plan); // no duplica
    final rows = await db.select(db.plans).get();
    expect(rows, hasLength(1));
  });
}
