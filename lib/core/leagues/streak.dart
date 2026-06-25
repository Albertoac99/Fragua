/// Día absoluto desde epoch (UTC), para comparar fechas sin la hora.
int dayNumber(DateTime dt) => dt.toUtc().difference(DateTime.utc(1970)).inDays;

class StreakResult {
  final int current;
  final int record;
  const StreakResult(this.current, this.record);
}

/// Actualiza la racha al registrar actividad en [today] (día absoluto):
/// primer día o hueco => 1; día consecutivo => +1; mismo día => sin cambio.
StreakResult updateStreak({
  required int today,
  int? lastActiveDay,
  required int current,
  required int record,
}) {
  int next;
  if (lastActiveDay == null) {
    next = 1;
  } else {
    final diff = today - lastActiveDay;
    if (diff == 0) {
      next = current;
    } else if (diff == 1) {
      next = current + 1;
    } else {
      next = 1;
    }
  }
  return StreakResult(next, next > record ? next : record);
}
