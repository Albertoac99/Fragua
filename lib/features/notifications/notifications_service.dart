import '../../core/db/database.dart';
import '../../core/notifications/schedule.dart';
import '../../services/notifications/notifier.dart';

class NotificationsService {
  NotificationsService({required this.notifier, required this.db});
  final AppNotifier notifier;
  final FraguaDatabase db;

  /// Cancela y reprograma todos los avisos según ajustes y estado de racha.
  Future<void> reschedule(DateTime now) async {
    await notifier.cancelAll();
    final s = await db.loadNotificationSettings();

    var id = 0;
    for (final at in nextReminderOccurrences(s, now)) {
      await notifier.scheduleAt(
          id++, at, 'Hora de entrenar', '¡Vamos! Tu sesión te espera 💪');
    }

    if (s.streakReminderEnabled) {
      final league = await db.loadLeagueState();
      final danger =
          streakInDangerTime(lastActiveDay: league?.lastActiveDay, now: now);
      if (danger != null) {
        await notifier.scheduleAt(900, danger, 'Tu racha está en peligro',
            'Entrena hoy para mantenerla 🔥');
      }
    }
  }
}
