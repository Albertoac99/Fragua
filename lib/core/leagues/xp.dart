/// XP de una sesión: base por completar + por unidad (serie/bloque) + por PR +
/// bonus de racha (con tope). Determinista.
int computeSessionXp({
  required int unitsCompleted,
  required int prCount,
  required bool completed,
  required int streakDays,
  int base = 50,
  int perUnit = 5,
  int perPr = 20,
  int streakCap = 7,
  int perStreakDay = 2,
}) {
  if (!completed && unitsCompleted == 0) return 0;
  var xp = completed ? base : 0;
  xp += unitsCompleted * perUnit;
  xp += prCount * perPr;
  xp += streakDays.clamp(0, streakCap) * perStreakDay;
  return xp;
}
