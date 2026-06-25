import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/core/leagues/xp.dart';

void main() {
  test('entreno completado: base + unidades + PR + racha (con tope)', () {
    // 50 base + 8*5 + 2*20 + min(10,7)*2 = 50+40+40+14 = 144
    final xp = computeSessionXp(
        unitsCompleted: 8, prCount: 2, completed: true, streakDays: 10);
    expect(xp, 144);
  });

  test('sin completar pero con unidades: sin base', () {
    // 0 + 3*5 + 0 + 0 = 15
    final xp = computeSessionXp(
        unitsCompleted: 3, prCount: 0, completed: false, streakDays: 0);
    expect(xp, 15);
  });

  test('sin completar y sin unidades: 0', () {
    expect(
        computeSessionXp(
            unitsCompleted: 0, prCount: 0, completed: false, streakDays: 5),
        0);
  });
}
