import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/app/providers.dart';
import 'package:fragua/core/db/database.dart';
import 'package:fragua/core/models/plan.dart';
import 'package:fragua/features/workout/guided_session_screen.dart';

PlanDay circuit() => const PlanDay(
      name: 'Circuito',
      type: DayType.guided,
      format: WorkoutFormat.circuit,
      rounds: 2,
      exercises: [
        PlanExercise(
          exerciseId: 'a',
          exerciseName: 'Sentadilla',
          sets: 1,
          repLow: 10,
          repHigh: 15,
          restSeconds: 1,
          workSeconds: 3,
        ),
      ],
    );

void main() {
  testWidgets('arranca y muestra el ejercicio y la ronda actual', (tester) async {
    final db = FraguaDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: MaterialApp(home: GuidedSessionScreen(day: circuit())),
    ));
    await tester.pump(); // deja terminar el _init() async (carga estado + arranca)

    expect(find.text('Sentadilla'), findsOneWidget);
    expect(find.textContaining('Ronda 1'), findsOneWidget);

    // Limpieza: descarta el widget para cancelar el Timer.periodic.
    await tester.pumpWidget(const SizedBox());
  });
}
