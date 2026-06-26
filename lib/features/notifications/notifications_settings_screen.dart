import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/notifications/notification_settings.dart';

const _dayLabels = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

class NotificationsSettingsScreen extends ConsumerStatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  ConsumerState<NotificationsSettingsScreen> createState() =>
      _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState
    extends ConsumerState<NotificationsSettingsScreen> {
  NotificationSettings? _s;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = await ref.read(databaseProvider).loadNotificationSettings();
    if (mounted) setState(() => _s = s);
  }

  Future<void> _apply(NotificationSettings next,
      {bool requestPerm = false}) async {
    setState(() => _s = next);
    await ref.read(databaseProvider).saveNotificationSettings(next);
    if (requestPerm) await ref.read(notifierProvider).requestPermission();
    await ref.read(notificationsServiceProvider).reschedule(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final s = _s;
    return Scaffold(
      appBar: AppBar(title: const Text('Notificaciones')),
      body: s == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                SwitchListTile(
                  key: const Key('reminders-toggle'),
                  title: const Text('Recordatorio de entreno'),
                  value: s.remindersEnabled,
                  onChanged: (v) =>
                      _apply(s.copyWith(remindersEnabled: v), requestPerm: v),
                ),
                if (s.remindersEnabled) ...[
                  ListTile(
                    title: const Text('Hora'),
                    trailing: Text(
                        '${s.reminderHour.toString().padLeft(2, '0')}:${s.reminderMinute.toString().padLeft(2, '0')}'),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay(
                            hour: s.reminderHour, minute: s.reminderMinute),
                      );
                      if (picked != null) {
                        await _apply(s.copyWith(
                            reminderHour: picked.hour,
                            reminderMinute: picked.minute));
                      }
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Wrap(
                      spacing: 6,
                      children: [
                        for (var d = 1; d <= 7; d++)
                          FilterChip(
                            label: Text(_dayLabels[d - 1]),
                            selected: s.reminderDays.contains(d),
                            onSelected: (sel) {
                              final days = {...s.reminderDays};
                              sel ? days.add(d) : days.remove(d);
                              _apply(s.copyWith(reminderDays: days));
                            },
                          ),
                      ],
                    ),
                  ),
                ],
                const Divider(),
                SwitchListTile(
                  key: const Key('streak-toggle'),
                  title: const Text('Aviso de racha en peligro'),
                  value: s.streakReminderEnabled,
                  onChanged: (v) =>
                      _apply(s.copyWith(streakReminderEnabled: v)),
                ),
              ],
            ),
    );
  }
}
