import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/core/progression/progression.dart';

ProgressionResult decide(List<int> reps, {double w = 100, int stall = 0}) =>
    decideProgression(
      repLow: 6,
      repHigh: 12,
      currentWeight: w,
      repsPerSet: reps,
      targetSets: 3,
      increment: 2.5,
      stallCount: stall,
    );

void main() {
  test('todas las series al tope => sube peso y resetea estancamiento', () {
    final r = decide([12, 12, 12], stall: 1);
    expect(r.nextWeight, 102.5);
    expect(r.nextStallCount, 0);
    expect(r.deload, isFalse);
  });

  test('dentro del rango sin tope => mantiene peso (doble progresión)', () {
    final r = decide([10, 9, 8]);
    expect(r.nextWeight, 100);
    expect(r.deload, isFalse);
  });

  test('falla por debajo del mínimo => no sube y suma estancamiento', () {
    final r = decide([6, 5, 4], stall: 0);
    expect(r.nextWeight, 100);
    expect(r.nextStallCount, 1);
    expect(r.deload, isFalse);
  });

  test('estancamiento alcanza el umbral => deload -10% y resetea', () {
    final r = decide([5, 4, 3], stall: 2); // 3er fallo => deload
    expect(r.nextWeight, closeTo(90, 0.001));
    expect(r.nextStallCount, 0);
    expect(r.deload, isTrue);
  });
}
