import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/core/db/database.dart';
import 'package:fragua/core/leagues/divisions.dart';
import 'package:fragua/features/leagues/leagues_service.dart';

void main() {
  test('primer entreno: crea estado, suma XP, racha 1 y logro firstWorkout', () async {
    final db = FraguaDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final svc = LeaguesService(db);
    final now = DateTime.utc(2026, 6, 25);

    await svc.awardForSession(
        unitsCompleted: 6, prCount: 1, completed: true, now: now);

    final s = (await db.loadLeagueState())!;
    expect(s.weekId, weekIdFor(now));
    // 50 base + 6*5 + 1*20 + min(1,7)*2 = 102
    expect(s.weeklyXp, 102);
    expect(s.streakCurrent, 1);
    expect(s.totalWorkouts, 1);
    expect(s.totalPrs, 1);
    expect(await db.loadAchievements(), containsAll({'firstWorkout', 'firstPr'}));
  });

  test('dos entrenos la misma semana acumulan XP', () async {
    final db = FraguaDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final svc = LeaguesService(db);
    final d1 = DateTime.utc(2026, 6, 25);
    final d2 = DateTime.utc(2026, 6, 26);

    await svc.awardForSession(
        unitsCompleted: 0, prCount: 0, completed: true, now: d1); // 50
    await svc.awardForSession(
        unitsCompleted: 0, prCount: 0, completed: true, now: d2); // +50 +racha2*2

    final s = (await db.loadLeagueState())!;
    expect(s.streakCurrent, 2);
    expect(s.weeklyXp, greaterThanOrEqualTo(100));
    expect(s.totalWorkouts, 2);
  });

  test('cambio de semana: rollover de división y reset de XP semanal', () async {
    final db = FraguaDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final svc = LeaguesService(db);

    // Semana antigua con XP alta: al entrar en la nueva semana debe hacer rollover.
    await db.saveLeagueState(
      division: 'gold',
      weekId: weekIdFor(DateTime.utc(2026, 6, 1)),
      weeklyXp: 99999, // garantiza top => ascenso
      streakCurrent: 1,
      streakRecord: 1,
      lastActiveDay: null,
      totalWorkouts: 5,
      totalPrs: 0,
    );

    final s = await svc.ensureCurrentWeek(DateTime.utc(2026, 6, 25));
    expect(s.weekId, weekIdFor(DateTime.utc(2026, 6, 25)));
    expect(s.weeklyXp, 0); // reseteada
    expect(s.division, 'platinum'); // ascendió desde gold
  });
}
