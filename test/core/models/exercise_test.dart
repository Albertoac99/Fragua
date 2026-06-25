import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/core/models/enums.dart';
import 'package:fragua/core/models/exercise.dart';

void main() {
  test('fromDbRow parsea una fila SQLite con listas en JSON', () {
    final row = <String, Object?>{
      'id': 'Barbell_Squat',
      'name': 'Barbell Squat',
      'category': 'strength',
      'force': 'push',
      'difficulty': 'intermediate',
      'mechanic': 'compound',
      'equipment': 'barbell',
      'primary_muscles': '["quadriceps"]',
      'secondary_muscles': '["glutes","hamstrings"]',
      'instructions': '["Baja","Sube"]',
      'static_images': '["Barbell_Squat/0.jpg"]',
      'gif_key': null,
      'modality': 'strength',
      'variation_group': null,
      'variation_rank': 0,
    };

    final ex = Exercise.fromDbRow(row);

    expect(ex.id, 'Barbell_Squat');
    expect(ex.force, ForceType.push);
    expect(ex.difficulty, ExerciseDifficulty.intermediate);
    expect(ex.mechanic, Mechanic.compound);
    expect(ex.equipment, Equipment.barbell);
    expect(ex.primaryMuscles, ['quadriceps']);
    expect(ex.secondaryMuscles, ['glutes', 'hamstrings']);
    expect(ex.instructions.length, 2);
    expect(ex.modality, Modality.strength);
    expect(ex.gifKey, isNull);
    expect(ex.variationRank, 0);
  });

  test('fromDbRow tolera force/mechanic nulos', () {
    final row = <String, Object?>{
      'id': 'Plank',
      'name': 'Plank',
      'category': 'strength',
      'force': null,
      'difficulty': 'beginner',
      'mechanic': null,
      'equipment': 'bodyweight',
      'primary_muscles': '["abdominals"]',
      'secondary_muscles': '[]',
      'instructions': '["Aguanta"]',
      'static_images': '[]',
      'gif_key': null,
      'modality': 'both',
      'variation_group': null,
      'variation_rank': 0,
    };
    final ex = Exercise.fromDbRow(row);
    expect(ex.force, isNull);
    expect(ex.mechanic, isNull);
    expect(ex.equipment, Equipment.bodyweight);
    expect(ex.secondaryMuscles, isEmpty);
  });
}
