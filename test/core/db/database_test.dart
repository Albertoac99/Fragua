import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/core/db/database.dart';

void main() {
  test('inserta y lee una fila de Exercises en memoria', () async {
    final db = FraguaDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await db.into(db.exercises).insert(ExercisesCompanion.insert(
          id: 'Plank',
          name: 'Plank',
          difficulty: 'beginner',
          equipment: 'bodyweight',
          primaryMuscles: '["abdominals"]',
          secondaryMuscles: '[]',
          instructions: '["Aguanta"]',
          staticImages: '[]',
          modality: 'both',
        ));

    final rows = await db.select(db.exercises).get();
    expect(rows, hasLength(1));
    expect(rows.single.id, 'Plank');
    expect(rows.single.variationRank, 0); // default
  });
}
