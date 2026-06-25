import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/core/db/database.dart';

void main() {
  test('exercise_logs: inserta y lee filtrado por ejercicio y ordenado', () async {
    final db = FraguaDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await db.addExerciseLog(
        exerciseId: 'bench',
        exerciseName: 'Bench',
        performedAt: DateTime(2026, 6, 8),
        weight: 100,
        totalReps: 24,
        sets: 3,
        maxReps: 8);
    await db.addExerciseLog(
        exerciseId: 'bench',
        exerciseName: 'Bench',
        performedAt: DateTime(2026, 6, 1),
        weight: 95,
        totalReps: 30,
        sets: 3,
        maxReps: 10);
    await db.addExerciseLog(
        exerciseId: 'squat',
        exerciseName: 'Squat',
        performedAt: DateTime(2026, 6, 2),
        weight: 120,
        totalReps: 15,
        sets: 3,
        maxReps: 5);

    final bench = await db.loadExerciseLogs('bench');
    expect(bench, hasLength(2));
    expect(bench.first.performedAt, DateTime(2026, 6, 1)); // ascendente
    expect(bench.first.weight, 95);

    final logged = await db.loggedExercises();
    expect(logged.map((e) => e.id).toSet(), {'bench', 'squat'});
  });

  test('body_metrics: inserta y lee por tipo ordenado', () async {
    final db = FraguaDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await db.addBodyMetric(
        kind: 'bodyweight', value: 80.5, measuredAt: DateTime(2026, 6, 8));
    await db.addBodyMetric(
        kind: 'bodyweight', value: 81.0, measuredAt: DateTime(2026, 6, 1));
    await db.addBodyMetric(
        kind: 'waist', value: 85, measuredAt: DateTime(2026, 6, 1));

    final bw = await db.loadBodyMetrics('bodyweight');
    expect(bw.map((e) => e.value).toList(), [81.0, 80.5]); // ascendente por fecha
    expect(await db.loadBodyMetrics('waist'), hasLength(1));
  });
}
