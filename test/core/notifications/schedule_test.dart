import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/core/leagues/streak.dart';
import 'package:fragua/core/notifications/notification_settings.dart';
import 'package:fragua/core/notifications/schedule.dart';

void main() {
  test('máscara de días ida y vuelta', () {
    expect(daysMaskOf({1, 2, 3, 4, 5}), 0x1F);
    expect(daysFromMask(0x1F), {1, 2, 3, 4, 5});
    expect(daysFromMask(daysMaskOf({6, 7})), {6, 7});
  });

  test('recordatorios deshabilitados => sin ocurrencias', () {
    const s = NotificationSettings(remindersEnabled: false);
    expect(nextReminderOccurrences(s, DateTime(2026, 6, 24, 12)), isEmpty);
  });

  test('ocurrencias: solo días configurados, a la hora, futuras y ordenadas', () {
    const s = NotificationSettings(
        remindersEnabled: true,
        reminderHour: 19,
        reminderMinute: 30,
        reminderDays: {1, 3, 5}); // L, X, V
    final from = DateTime(2026, 6, 24, 12); // mediodía
    final occ = nextReminderOccurrences(s, from);
    expect(occ, isNotEmpty);
    for (final d in occ) {
      expect(s.reminderDays.contains(d.weekday), isTrue);
      expect(d.hour, 19);
      expect(d.minute, 30);
      expect(d.isAfter(from), isTrue);
    }
    final sorted = [...occ]..sort();
    expect(occ, sorted);
  });

  test('una ocurrencia de hoy ya pasada no se incluye', () {
    const s = NotificationSettings(
        remindersEnabled: true,
        reminderHour: 8,
        reminderDays: {1, 2, 3, 4, 5, 6, 7});
    final from = DateTime(2026, 6, 24, 12); // las 8:00 de hoy ya pasaron
    final occ = nextReminderOccurrences(s, from, horizonDays: 1);
    expect(occ, isEmpty); // horizonte de 1 día y la hora de hoy ya pasó
  });

  test('racha en peligro: entrenó ayer y aún no hoy => avisa hoy a las 20', () {
    final now = DateTime(2026, 6, 25, 12);
    final yesterday = dayNumber(now) - 1;
    final at = streakInDangerTime(lastActiveDay: yesterday, now: now);
    expect(at, DateTime(2026, 6, 25, 20));
  });

  test('racha: ya entrenó hoy => sin aviso', () {
    final now = DateTime(2026, 6, 25, 12);
    expect(streakInDangerTime(lastActiveDay: dayNumber(now), now: now), isNull);
  });

  test('racha: hueco mayor a un día (ya rota) => sin aviso', () {
    final now = DateTime(2026, 6, 25, 12);
    expect(streakInDangerTime(lastActiveDay: dayNumber(now) - 3, now: now),
        isNull);
  });

  test('racha: pasada la hora de aviso => null', () {
    final now = DateTime(2026, 6, 25, 21);
    expect(streakInDangerTime(lastActiveDay: dayNumber(now) - 1, now: now),
        isNull);
  });
}
