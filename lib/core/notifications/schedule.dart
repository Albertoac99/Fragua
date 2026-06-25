import '../leagues/streak.dart';
import 'notification_settings.dart';

/// Próximas ocurrencias del recordatorio dentro de [horizonDays] días: por cada
/// día configurado, su `hora:minuto`, siempre posterior a [from]. Ordenadas.
List<DateTime> nextReminderOccurrences(
  NotificationSettings s,
  DateTime from, {
  int horizonDays = 7,
}) {
  if (!s.remindersEnabled || s.reminderDays.isEmpty) return [];
  final out = <DateTime>[];
  final base = DateTime(from.year, from.month, from.day);
  for (var i = 0; i < horizonDays; i++) {
    final day = base.add(Duration(days: i));
    if (!s.reminderDays.contains(day.weekday)) continue;
    final at =
        DateTime(day.year, day.month, day.day, s.reminderHour, s.reminderMinute);
    if (at.isAfter(from)) out.add(at);
  }
  out.sort();
  return out;
}

/// Hora del aviso de "racha en peligro": si entrenó **ayer** (racha viva) pero
/// aún no **hoy**, avisa hoy a las [hour]; `null` si ya entrenó hoy, si la racha
/// ya está rota (hueco > 1 día) o si ya pasó la hora.
DateTime? streakInDangerTime({
  required int? lastActiveDay,
  required DateTime now,
  int hour = 20,
}) {
  if (lastActiveDay == null) return null;
  final today = dayNumber(now);
  if (lastActiveDay >= today) return null; // ya entrenó hoy
  if (today - lastActiveDay > 1) return null; // racha ya rota
  final at = DateTime(now.year, now.month, now.day, hour);
  return at.isAfter(now) ? at : null;
}
