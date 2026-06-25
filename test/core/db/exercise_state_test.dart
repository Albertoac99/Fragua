import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/core/db/database.dart';

void main() {
  test('guarda y recupera el estado por ejercicio (upsert)', () async {
    final db = FraguaDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    expect(await db.exerciseState('squat'), isNull);

    await db.saveExerciseState('squat', 100, 0);
    var s = await db.exerciseState('squat');
    expect(s!.weight, 100);
    expect(s.stall, 0);

    await db.saveExerciseState('squat', 102.5, 1);
    s = await db.exerciseState('squat');
    expect(s!.weight, 102.5);
    expect(s.stall, 1);

    final rows = await db.select(db.exerciseStates).get();
    expect(rows, hasLength(1));
  });
}
