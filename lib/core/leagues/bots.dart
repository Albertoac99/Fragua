import 'dart:math';

import '../models/enums.dart';

class LeagueBot {
  final String name;
  final BotArchetype archetype;
  final int weeklyXp;
  const LeagueBot({
    required this.name,
    required this.archetype,
    required this.weeklyXp,
  });
}

const _names = <String>[
  'Lucas', 'Marta', 'Diego', 'Sara', 'Pablo', 'Lucía', 'Hugo', 'Elena',
  'Mario', 'Carla', 'Iván', 'Nora', 'Bruno', 'Alba', 'Gael', 'Vega',
  'Leo', 'Daniela', 'Adrián', 'Noa', 'Marco', 'Irene', 'Nico', 'Julia',
  'Raúl', 'Olga', 'Saúl', 'Lola',
];

/// Rango [min, max] de XP semanal por arquetipo.
({int min, int max}) _xpRange(BotArchetype a) {
  switch (a) {
    case BotArchetype.beginner:
      return (min: 60, max: 260);
    case BotArchetype.sporadic:
      return (min: 100, max: 700);
    case BotArchetype.steady:
      return (min: 300, max: 520);
    case BotArchetype.grinder:
      return (min: 560, max: 900);
  }
}

/// Genera la cohorte semanal de rivales simulados de forma **determinista**:
/// la semilla deriva de [weekId] y [division], así el leaderboard es estable
/// durante la semana y reproducible en tests.
List<LeagueBot> generateCohort({
  required int weekId,
  required Division division,
  int count = 19,
}) {
  final rng = Random(weekId * 1000003 + division.index * 97 + 17);
  final archetypes = BotArchetype.values;
  final bots = <LeagueBot>[];
  for (var i = 0; i < count; i++) {
    final name = _names[(rng.nextInt(_names.length) + i) % _names.length];
    final archetype = archetypes[rng.nextInt(archetypes.length)];
    final r = _xpRange(archetype);
    final xp = r.min + rng.nextInt(r.max - r.min + 1);
    bots.add(LeagueBot(name: name, archetype: archetype, weeklyXp: xp));
  }
  // Garantiza nombres únicos sufijándolos si se repiten (determinista por orden).
  final seen = <String, int>{};
  return [
    for (final b in bots)
      if ((seen[b.name] = (seen[b.name] ?? 0) + 1) == 1)
        b
      else
        LeagueBot(
            name: '${b.name} ${seen[b.name]}',
            archetype: b.archetype,
            weeklyXp: b.weeklyXp),
  ];
}
