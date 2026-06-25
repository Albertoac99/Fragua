import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/core/models/plan.dart';
import 'package:fragua/core/session/guided_session.dart';

PlanDay circuit({int rounds = 3}) => PlanDay(
      name: 'Circuito',
      type: DayType.guided,
      format: WorkoutFormat.circuit,
      rounds: rounds,
      exercises: const [
        PlanExercise(
          exerciseId: 'a',
          exerciseName: 'Sentadilla',
          sets: 1,
          repLow: 10,
          repHigh: 15,
          restSeconds: 15,
          workSeconds: 40,
        ),
        PlanExercise(
          exerciseId: 'b',
          exerciseName: 'Flexión',
          sets: 1,
          repLow: 10,
          repHigh: 15,
          restSeconds: 15,
          workSeconds: 40,
        ),
      ],
    );

void main() {
  test('2 ejercicios x 3 rondas => trabajo/descanso intercalados, sin descanso final', () {
    final t = buildGuidedTimeline(circuit(rounds: 3));
    // 3 rondas * 2 ejercicios * 2 (work+rest) - 1 (descanso final) = 11
    expect(t, hasLength(11));
    expect(t.first.kind, StepKind.work);
    expect(t.first.label, 'Sentadilla');
    expect(t.last.kind, StepKind.work); // termina en trabajo, no en descanso
    expect(t.last.round, 3);
  });

  test('numera las rondas correctamente (1-based)', () {
    final t = buildGuidedTimeline(circuit(rounds: 2));
    expect(t.first.round, 1);
    expect(t.first.totalRounds, 2);
    // 4 pasos por ronda (2 ejercicios * work+rest); el primer work de la 2ª ronda
    // está en el índice 4.
    expect(t[4].round, 2);
    expect(t[4].kind, StepKind.work);
    expect(t[4].label, 'Sentadilla');
  });

  test('usa workSeconds del ejercicio y restSeconds como descanso', () {
    final t = buildGuidedTimeline(circuit(rounds: 1));
    expect(t[0].seconds, 40); // work
    expect(t[1].seconds, 15); // rest
  });

  test('workSecondsOverride y roundsOverride mandan sobre el día', () {
    final t = buildGuidedTimeline(circuit(rounds: 3),
        workSecondsOverride: 30, roundsOverride: 1);
    expect(t, hasLength(3)); // 1 ronda: w,r,w
    expect(t[0].seconds, 30);
  });

  test('AMRAP no tiene timeline fijo => lista vacía', () {
    const day = PlanDay(
      name: 'AMRAP',
      type: DayType.guided,
      format: WorkoutFormat.amrap,
      rounds: 5,
      totalSeconds: 600,
      exercises: [],
    );
    expect(buildGuidedTimeline(day), isEmpty);
  });
}
