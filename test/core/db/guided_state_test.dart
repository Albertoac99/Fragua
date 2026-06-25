import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/core/db/database.dart';

void main() {
  test('guarda y recupera el estado por día guiado (upsert)', () async {
    final db = FraguaDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    expect(await db.guidedState('Circuito 1'), isNull);

    await db.saveGuidedState('Circuito 1', 40, 3, 0);
    var s = await db.guidedState('Circuito 1');
    expect(s!.workSeconds, 40);
    expect(s.rounds, 3);
    expect(s.streak, 0);

    await db.saveGuidedState('Circuito 1', 45, 3, 1);
    s = await db.guidedState('Circuito 1');
    expect(s!.workSeconds, 45);
    expect(s.streak, 1);

    final rows = await db.select(db.guidedStates).get();
    expect(rows, hasLength(1));
  });
}
