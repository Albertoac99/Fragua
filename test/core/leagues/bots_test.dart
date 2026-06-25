import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/core/leagues/bots.dart';
import 'package:fragua/core/models/enums.dart';

void main() {
  test('es reproducible: misma semana+división => misma cohorte', () {
    final a = generateCohort(weekId: 100, division: Division.gold);
    final b = generateCohort(weekId: 100, division: Division.gold);
    expect(a.map((e) => '${e.name}:${e.weeklyXp}:${e.archetype}').toList(),
        b.map((e) => '${e.name}:${e.weeklyXp}:${e.archetype}').toList());
  });

  test('cambia entre semanas o divisiones', () {
    final a = generateCohort(weekId: 100, division: Division.gold);
    final c = generateCohort(weekId: 101, division: Division.gold);
    final d = generateCohort(weekId: 100, division: Division.silver);
    expect(a.map((e) => e.weeklyXp).toList() == c.map((e) => e.weeklyXp).toList(),
        isFalse);
    expect(a.map((e) => e.weeklyXp).toList() == d.map((e) => e.weeklyXp).toList(),
        isFalse);
  });

  test('genera el número pedido, nombres únicos y XP no negativa', () {
    final cohort = generateCohort(weekId: 7, division: Division.bronze, count: 19);
    expect(cohort, hasLength(19));
    expect(cohort.map((e) => e.name).toSet(), hasLength(19));
    expect(cohort.every((e) => e.weeklyXp >= 0), isTrue);
  });
}
