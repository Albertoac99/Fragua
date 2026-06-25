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
}
