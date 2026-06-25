import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/core/leagues/achievements.dart';
import 'package:fragua/core/models/enums.dart';

void main() {
  test('primer entreno y primer PR', () {
    final a = unlockedAchievements(totalWorkouts: 1, streakRecord: 0, totalPrs: 1);
    expect(a, contains(AchievementType.firstWorkout));
    expect(a, contains(AchievementType.firstPr));
    expect(a, isNot(contains(AchievementType.tenWorkouts)));
  });

  test('hitos de volumen y racha', () {
    final a =
        unlockedAchievements(totalWorkouts: 50, streakRecord: 7, totalPrs: 0);
    expect(
        a,
        containsAll([
          AchievementType.firstWorkout,
          AchievementType.tenWorkouts,
          AchievementType.fiftyWorkouts,
          AchievementType.streak7,
        ]));
    expect(a, isNot(contains(AchievementType.hundredWorkouts)));
    expect(a, isNot(contains(AchievementType.streak30)));
  });

  test('sin actividad: vacío', () {
    expect(unlockedAchievements(totalWorkouts: 0, streakRecord: 0, totalPrs: 0),
        isEmpty);
  });
}
