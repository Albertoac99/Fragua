import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/core/db/database.dart';

void main() {
  test('league_state: upsert de fila única', () async {
    final db = FraguaDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    expect(await db.loadLeagueState(), isNull);

    await db.saveLeagueState(
      division: 'gold',
      weekId: 42,
      weeklyXp: 120,
      streakCurrent: 3,
      streakRecord: 5,
      lastActiveDay: 1000,
      totalWorkouts: 7,
      totalPrs: 2,
    );
    var s = await db.loadLeagueState();
    expect(s!.division, 'gold');
    expect(s.weeklyXp, 120);
    expect(s.streakRecord, 5);
    expect(s.totalWorkouts, 7);

    await db.saveLeagueState(
      division: 'platinum',
      weekId: 43,
      weeklyXp: 0,
      streakCurrent: 4,
      streakRecord: 5,
      lastActiveDay: 1001,
      totalWorkouts: 8,
      totalPrs: 2,
    );
    s = await db.loadLeagueState();
    expect(s!.division, 'platinum');
    expect(s.weeklyXp, 0);
    expect(await db.select(db.leagueStates).get(), hasLength(1));
  });

  test('xp_entries y achievements', () async {
    final db = FraguaDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await db.addXpEntry(
        weekId: 1, source: 'workout', amount: 50, createdAt: DateTime(2026, 6, 25));
    await db.addXpEntry(
        weekId: 1, source: 'pr', amount: 20, createdAt: DateTime(2026, 6, 25));
    expect(await db.select(db.xpEntries).get(), hasLength(2));

    expect(await db.loadAchievements(), isEmpty);
    await db.unlockAchievement('firstWorkout', DateTime(2026, 6, 25));
    await db.unlockAchievement('firstWorkout', DateTime(2026, 6, 26)); // no duplica
    final got = await db.loadAchievements();
    expect(got, {'firstWorkout'});
  });
}
