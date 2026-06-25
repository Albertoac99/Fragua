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
  test('al terminar aplica la progresión y guarda el estado', () async {
    final db = FraguaDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db.saveExerciseState('bench', 100, 0);

    final c = WorkoutSessionController(
        db: db, day: day(), initialWeights: {'bench': 100});
    c.setWeight(100);
    c.logSet(12);
    c.logSet(12);
    c.logSet(12);
    await c.finish();

    expect(c.state.finished, isTrue);
    final s = await db.exerciseState('bench');
    expect(s!.weight, 102.5); // subió por completar el tope
  });
}
