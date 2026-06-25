import '../../core/db/database.dart';
import '../../core/leagues/achievements.dart';
import '../../core/leagues/bots.dart';
import '../../core/leagues/divisions.dart';
import '../../core/leagues/leaderboard.dart';
import '../../core/leagues/streak.dart';
import '../../core/leagues/xp.dart';
import '../../core/models/enums.dart';

class LeaguesService {
  LeaguesService(this.db);
  final FraguaDatabase db;

  Division _divisionFrom(String name) => Division.values
      .firstWhere((d) => d.name == name, orElse: () => Division.bronze);

  /// Asegura que el estado corresponde a la semana de [now]. Si cambió de semana,
  /// cierra la anterior: calcula el puesto final del usuario en su cohorte y
  /// aplica ascenso/descenso, resetea la XP semanal y fija la nueva semana.
  Future<LeagueStateRow> ensureCurrentWeek(DateTime now) async {
    final week = weekIdFor(now);
    final existing = await db.loadLeagueState();
    if (existing == null) {
      await db.saveLeagueState(
        division: Division.bronze.name,
        weekId: week,
        weeklyXp: 0,
        streakCurrent: 0,
        streakRecord: 0,
        lastActiveDay: null,
        totalWorkouts: 0,
        totalPrs: 0,
      );
      return (await db.loadLeagueState())!;
    }
    if (existing.weekId == week) return existing;

    // Rollover: puesto final en la cohorte de la semana que se cierra.
    final division = _divisionFrom(existing.division);
    final cohort = generateCohort(weekId: existing.weekId, division: division);
    final board = buildLeaderboard(bots: cohort, userXp: existing.weeklyXp);
    final rank = board.firstWhere((s) => s.isUser).rank;
    final newDivision = applyWeekRollover(
        current: division, finalRank: rank, cohortSize: board.length);

    await db.saveLeagueState(
      division: newDivision.name,
      weekId: week,
      weeklyXp: 0,
      streakCurrent: existing.streakCurrent,
      streakRecord: existing.streakRecord,
      lastActiveDay: existing.lastActiveDay,
      totalWorkouts: existing.totalWorkouts,
      totalPrs: existing.totalPrs,
    );
    return (await db.loadLeagueState())!;
  }

  /// Premia una sesión terminada: actualiza racha, suma XP (con bonus de racha),
  /// incrementa contadores, registra la entrada de XP y desbloquea logros.
  Future<void> awardForSession({
    required int unitsCompleted,
    required int prCount,
    required bool completed,
    required DateTime now,
  }) async {
    final state = await ensureCurrentWeek(now);

    final streak = updateStreak(
      today: dayNumber(now),
      lastActiveDay: state.lastActiveDay,
      current: state.streakCurrent,
      record: state.streakRecord,
    );

    final xp = computeSessionXp(
      unitsCompleted: unitsCompleted,
      prCount: prCount,
      completed: completed,
      streakDays: streak.current,
    );

    final totalWorkouts = state.totalWorkouts + (completed ? 1 : 0);
    final totalPrs = state.totalPrs + prCount;

    await db.saveLeagueState(
      division: state.division,
      weekId: state.weekId,
      weeklyXp: state.weeklyXp + xp,
      streakCurrent: streak.current,
      streakRecord: streak.record,
      lastActiveDay: dayNumber(now),
      totalWorkouts: totalWorkouts,
      totalPrs: totalPrs,
    );
    if (xp > 0) {
      await db.addXpEntry(
          weekId: state.weekId,
          source: XpSource.workout.name,
          amount: xp,
          createdAt: now);
    }
    for (final a in unlockedAchievements(
        totalWorkouts: totalWorkouts,
        streakRecord: streak.record,
        totalPrs: totalPrs)) {
      await db.unlockAchievement(a.name, now);
    }
  }
}
