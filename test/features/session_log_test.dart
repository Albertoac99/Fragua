import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/core/db/database.dart';
import 'package:fragua/core/models/plan.dart';
import 'package:fragua/features/workout/session_controller.dart';

PlanDay day() => const PlanDay(
      name: 'Push',
      type: DayType.strength,
      format: WorkoutFormat.straightSets,
      rounds: 1,
      exercises: [
        PlanExercise(
          exerciseId: 'bench',
          exerciseName: 'Bench',
          sets: 3,
          repLow: 6,
          repHigh: 12,
          restSeconds: 90,
        ),
      ],
    );

void main() {
  test('finish() registra un exercise_log con reps totales y máximas', () async {
    final db = FraguaDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final c = WorkoutSessionController(
        db: db, day: day(), initialWeights: {'bench': 100});
    c.setWeight(100);
    c.logSet(10);
    c.logSet(8);
    c.logSet(6);
    await c.finish();

    final logs = await db.loadExerciseLogs('bench');
    expect(logs, hasLength(1));
    expect(logs.first.weight, 100);
    expect(logs.first.totalReps, 24);
    expect(logs.first.maxReps, 10);
    expect(logs.first.sets, 3);
  });
}
