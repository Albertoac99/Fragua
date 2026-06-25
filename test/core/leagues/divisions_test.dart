import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/core/leagues/divisions.dart';
import 'package:fragua/core/models/enums.dart';

void main() {
  test('promote sube una división y topa en leyenda', () {
    expect(promote(Division.bronze), Division.silver);
    expect(promote(Division.diamond), Division.legend);
    expect(promote(Division.legend), isNull);
  });

  test('relegate baja una división y topa en bronce', () {
    expect(relegate(Division.silver), Division.bronze);
    expect(relegate(Division.bronze), isNull);
  });

  test('weekIdFor: estable el mismo día y avanza en bloques de 7 días', () {
    final d = DateTime.utc(2026, 6, 25, 8);
    // Mismo día, distinta hora => misma semana.
    expect(weekIdFor(d), weekIdFor(DateTime.utc(2026, 6, 25, 20)));
    // +7 días => exactamente la semana siguiente.
    expect(weekIdFor(d.add(const Duration(days: 7))), weekIdFor(d) + 1);
    // +14 días => dos semanas más adelante.
    expect(weekIdFor(d.add(const Duration(days: 14))), greaterThan(weekIdFor(d)));
  });
}
