import '../models/enums.dart';

/// Logros desbloqueados a partir de los contadores acumulados. Determinista.
Set<AchievementType> unlockedAchievements({
  required int totalWorkouts,
  required int streakRecord,
  required int totalPrs,
}) {
  final out = <AchievementType>{};
  if (totalWorkouts >= 1) out.add(AchievementType.firstWorkout);
  if (totalWorkouts >= 10) out.add(AchievementType.tenWorkouts);
  if (totalWorkouts >= 50) out.add(AchievementType.fiftyWorkouts);
  if (totalWorkouts >= 100) out.add(AchievementType.hundredWorkouts);
  if (totalPrs >= 1) out.add(AchievementType.firstPr);
  if (streakRecord >= 7) out.add(AchievementType.streak7);
  if (streakRecord >= 30) out.add(AchievementType.streak30);
  return out;
}
