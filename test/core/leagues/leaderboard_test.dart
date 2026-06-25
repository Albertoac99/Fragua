import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/core/leagues/bots.dart';
import 'package:fragua/core/leagues/leaderboard.dart';
import 'package:fragua/core/models/enums.dart';

List<LeagueBot> bots(List<int> xps) => [
      for (var i = 0; i < xps.length; i++)
        LeagueBot(
            name: 'B$i', archetype: BotArchetype.steady, weeklyXp: xps[i]),
    ];

void main() {
  test('ordena desc, marca al usuario y asigna ranks', () {
    final lb = buildLeaderboard(bots: bots([100, 300, 200]), userXp: 250);
    expect(lb.map((e) => e.xp).toList(), [300, 250, 200, 100]);
    expect(lb[1].isUser, isTrue);
    expect(lb.first.rank, 1);
    expect(lb.last.rank, 4);
  });

  test('empate: el usuario queda por delante del bot', () {
    final lb = buildLeaderboard(bots: bots([200]), userXp: 200);
    expect(lb.first.isUser, isTrue);
  });

  test('zonas: top asciende, cola desciende, medio se mantiene', () {
    expect(zoneFor(rank: 3, cohortSize: 20, division: Division.gold),
        LeagueZone.promote);
    expect(zoneFor(rank: 18, cohortSize: 20, division: Division.gold),
        LeagueZone.relegate);
    expect(zoneFor(rank: 10, cohortSize: 20, division: Division.gold),
        LeagueZone.hold);
  });

  test('bronce no desciende y leyenda no asciende', () {
    expect(zoneFor(rank: 20, cohortSize: 20, division: Division.bronze),
        LeagueZone.hold);
    expect(zoneFor(rank: 1, cohortSize: 20, division: Division.legend),
        LeagueZone.hold);
  });

  test('applyWeekRollover mueve la división según la zona', () {
    expect(
        applyWeekRollover(current: Division.gold, finalRank: 2, cohortSize: 20),
        Division.platinum);
    expect(
        applyWeekRollover(current: Division.gold, finalRank: 19, cohortSize: 20),
        Division.silver);
    expect(
        applyWeekRollover(current: Division.gold, finalRank: 10, cohortSize: 20),
        Division.gold);
  });
}
