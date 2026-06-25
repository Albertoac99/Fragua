import '../models/enums.dart';
import 'bots.dart';
import 'divisions.dart';

class LeagueStanding {
  final int rank;
  final String name;
  final int xp;
  final bool isUser;
  final BotArchetype? archetype;
  const LeagueStanding({
    required this.rank,
    required this.name,
    required this.xp,
    required this.isUser,
    this.archetype,
  });
}

/// Construye el leaderboard (bots + usuario) ordenado por XP desc. En empate el
/// usuario va por delante; el resto se desempata por nombre (determinista).
List<LeagueStanding> buildLeaderboard({
  required List<LeagueBot> bots,
  required int userXp,
  String userName = 'Tú',
}) {
  final entries = <({String name, int xp, bool isUser, BotArchetype? a})>[
    (name: userName, xp: userXp, isUser: true, a: null),
    for (final b in bots)
      (name: b.name, xp: b.weeklyXp, isUser: false, a: b.archetype),
  ];
  entries.sort((x, y) {
    if (x.xp != y.xp) return y.xp.compareTo(x.xp); // desc
    if (x.isUser != y.isUser) return x.isUser ? -1 : 1; // usuario primero
    return x.name.compareTo(y.name);
  });
  return [
    for (var i = 0; i < entries.length; i++)
      LeagueStanding(
        rank: i + 1,
        name: entries[i].name,
        xp: entries[i].xp,
        isUser: entries[i].isUser,
        archetype: entries[i].a,
      ),
  ];
}

enum LeagueZone { promote, hold, relegate }

/// Zona del puesto [rank] (1-based) en una cohorte de [cohortSize]: ascenso si
/// está en el top [promoteTop] (salvo leyenda), descenso si está en la cola
/// [relegateBottom] (salvo bronce), si no se mantiene.
LeagueZone zoneFor({
  required int rank,
  required int cohortSize,
  required Division division,
  int promoteTop = 5,
  int relegateBottom = 5,
}) {
  if (division != Division.legend && rank <= promoteTop) {
    return LeagueZone.promote;
  }
  if (division != Division.bronze && rank > cohortSize - relegateBottom) {
    return LeagueZone.relegate;
  }
  return LeagueZone.hold;
}

/// Nueva división tras cerrar la semana, según la zona del puesto final.
Division applyWeekRollover({
  required Division current,
  required int finalRank,
  required int cohortSize,
  int promoteTop = 5,
  int relegateBottom = 5,
}) {
  switch (zoneFor(
      rank: finalRank,
      cohortSize: cohortSize,
      division: current,
      promoteTop: promoteTop,
      relegateBottom: relegateBottom)) {
    case LeagueZone.promote:
      return promote(current) ?? current;
    case LeagueZone.relegate:
      return relegate(current) ?? current;
    case LeagueZone.hold:
      return current;
  }
}
