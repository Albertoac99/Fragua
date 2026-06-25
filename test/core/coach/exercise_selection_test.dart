import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/core/coach/exercise_selection.dart';
import 'package:fragua/core/models/enums.dart';
import 'package:fragua/core/models/exercise.dart';

Exercise ex(String id, Equipment eq, List<String> primary, Mechanic? mech) =>
    Exercise(
      id: id,
      name: id,
      category: 'strength',
      force: null,
      difficulty: ExerciseDifficulty.beginner,
      mechanic: mech,
      equipment: eq,
      primaryMuscles: primary,
      secondaryMuscles: const [],
      instructions: const [],
      staticImages: const [],
      gifKey: null,
      modality: Modality.both,
      variationGroup: null,
      variationRank: 0,
    );

void main() {
  final catalog = [
    ex('press_banca', Equipment.barbell, ['chest'], Mechanic.compound),
    ex('aperturas', Equipment.dumbbell, ['chest'], Mechanic.isolation),
    ex('flexiones', Equipment.bodyweight, ['chest'], Mechanic.compound),
  ];

  test('prioriza compuesto y respeta el equipo disponible', () {
    final pick = selectExercise(
      catalog: catalog,
      targetMuscles: ['chest'],
      available: {Equipment.dumbbell}, // no hay barra
      avoidMuscles: {},
      excludeIds: {},
    );
    // bodyweight siempre disponible; press_banca (barra) excluido =>
    // gana flexiones (compuesto) sobre aperturas (aislamiento).
    expect(pick!.id, 'flexiones');
  });

  test('excluye ya usados y músculos a evitar', () {
    expect(
      selectExercise(
        catalog: catalog,
        targetMuscles: ['chest'],
        available: {Equipment.barbell, Equipment.dumbbell},
        avoidMuscles: {},
        excludeIds: {'press_banca', 'flexiones'},
      )!.id,
      'aperturas',
    );
    expect(
      selectExercise(
        catalog: catalog,
        targetMuscles: ['chest'],
        available: {Equipment.barbell},
        avoidMuscles: {'chest'},
        excludeIds: {},
      ),
      isNull,
    );
  });
}
