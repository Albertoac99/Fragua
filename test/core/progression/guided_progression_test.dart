import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/core/progression/guided_progression.dart';

GuidedProgressionResult decide({
  required bool done,
  int work = 30,
  int rounds = 3,
  int streak = 0,
  bool harder = false,
}) =>
    decideGuidedProgression(
      completedAll: done,
      workSeconds: work,
      rounds: rounds,
      streak: streak,
      harderVariantAvailable: harder,
    );

void main() {
  test('no completa => resetea la racha y mantiene parámetros', () {
    final r = decide(done: false, work: 40, rounds: 4, streak: 1);
    expect(r.nextWorkSeconds, 40);
    expect(r.nextRounds, 4);
    expect(r.bumpVariant, isFalse);
    expect(r.nextStreak, 0);
  });

  test('completa pero racha insuficiente => acumula racha sin cambios', () {
    final r = decide(done: true, work: 30, streak: 0); // umbral 2
    expect(r.nextWorkSeconds, 30);
    expect(r.bumpVariant, isFalse);
    expect(r.nextStreak, 1);
  });

  test('completa y alcanza el umbral con trabajo < tope => sube el tiempo', () {
    final r = decide(done: true, work: 30, streak: 1); // 2º => progresa
    expect(r.nextWorkSeconds, 35);
    expect(r.nextStreak, 0);
    expect(r.bumpVariant, isFalse);
  });

  test('trabajo en el tope y hay variante => sube variante y resetea el tiempo', () {
    final r = decide(done: true, work: 60, streak: 1, harder: true);
    expect(r.bumpVariant, isTrue);
    expect(r.nextWorkSeconds, 30); // baseWorkSeconds
    expect(r.nextStreak, 0);
  });

  test('trabajo en el tope, sin variante => añade ronda (densidad) y resetea el tiempo', () {
    final r = decide(done: true, work: 60, rounds: 3, streak: 1, harder: false);
    expect(r.nextRounds, 4);
    expect(r.nextWorkSeconds, 30);
    expect(r.bumpVariant, isFalse);
    expect(r.nextStreak, 0);
  });

  test('todo al techo (tope de tiempo y de rondas, sin variante) => sin cambios', () {
    final r = decide(done: true, work: 60, rounds: 6, streak: 1, harder: false);
    expect(r.nextWorkSeconds, 60);
    expect(r.nextRounds, 6);
    expect(r.bumpVariant, isFalse);
    expect(r.nextStreak, 0);
  });
}
