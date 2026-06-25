import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/core/leagues/streak.dart';

void main() {
  test('primer día: racha 1', () {
    final r = updateStreak(today: 100, lastActiveDay: null, current: 0, record: 0);
    expect(r.current, 1);
    expect(r.record, 1);
  });

  test('día consecutivo: +1 y actualiza récord', () {
    final r = updateStreak(today: 101, lastActiveDay: 100, current: 1, record: 1);
    expect(r.current, 2);
    expect(r.record, 2);
  });

  test('mismo día: no cambia', () {
    final r = updateStreak(today: 100, lastActiveDay: 100, current: 3, record: 5);
    expect(r.current, 3);
    expect(r.record, 5);
  });

  test('hueco: se reinicia a 1 pero conserva el récord', () {
    final r = updateStreak(today: 105, lastActiveDay: 100, current: 4, record: 4);
    expect(r.current, 1);
    expect(r.record, 4);
  });
}
