import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/core/models/plan.dart';

void main() {
  test('Plan round-trips a JSON y vuelve', () {
    const plan = Plan(
      split: SplitType.pushPullLegs,
      days: [
        PlanDay(
          name: 'Push',
          type: DayType.strength,
          format: WorkoutFormat.straightSets,
          rounds: 1,
          exercises: [
            PlanExercise(
              exerciseId: 'Barbell_Bench_Press',
              exerciseName: 'Barbell Bench Press',
              sets: 4,
              repLow: 6,
              repHigh: 12,
              restSeconds: 90,
            ),
          ],
        ),
      ],
    );

    final restored = Plan.fromJson(plan.toJson());
    expect(restored.split, SplitType.pushPullLegs);
    expect(restored.days, hasLength(1));
    expect(restored.days.first.name, 'Push');
    expect(restored.days.first.type, DayType.strength);
    expect(restored.days.first.exercises.first.exerciseId, 'Barbell_Bench_Press');
    expect(restored.days.first.exercises.first.repHigh, 12);
  });

  test('PlanExercise round-trips workSeconds (y null por defecto)', () {
    const timed = PlanExercise(
      exerciseId: 'burpee',
      exerciseName: 'Burpee',
      sets: 1,
      repLow: 10,
      repHigh: 15,
      restSeconds: 20,
      workSeconds: 40,
    );
    expect(PlanExercise.fromJson(timed.toJson()).workSeconds, 40);

    const repBased = PlanExercise(
      exerciseId: 'squat',
      exerciseName: 'Squat',
      sets: 3,
      repLow: 6,
      repHigh: 12,
      restSeconds: 90,
    );
    expect(repBased.workSeconds, isNull);
    expect(PlanExercise.fromJson(repBased.toJson()).workSeconds, isNull);
  });

  test('PlanDay round-trips totalSeconds y los nuevos formatos', () {
    const day = PlanDay(
      name: 'AMRAP 10',
      type: DayType.guided,
      format: WorkoutFormat.amrap,
      rounds: 5,
      totalSeconds: 600,
      exercises: [],
    );
    final back = PlanDay.fromJson(day.toJson());
    expect(back.format, WorkoutFormat.amrap);
    expect(back.totalSeconds, 600);
  });

  test('PlanDay sin totalSeconds => null (retrocompatible)', () {
    const day = PlanDay(
      name: 'Circuito 1',
      type: DayType.guided,
      format: WorkoutFormat.circuit,
      rounds: 3,
      exercises: [],
    );
    expect(PlanDay.fromJson(day.toJson()).totalSeconds, isNull);
  });
}
