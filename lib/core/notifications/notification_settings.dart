class NotificationSettings {
  final bool remindersEnabled;
  final int reminderHour; // 0-23
  final int reminderMinute; // 0-59
  final Set<int> reminderDays; // 1=lunes .. 7=domingo (DateTime.weekday)
  final bool streakReminderEnabled;

  const NotificationSettings({
    this.remindersEnabled = false,
    this.reminderHour = 19,
    this.reminderMinute = 0,
    this.reminderDays = const {1, 2, 3, 4, 5},
    this.streakReminderEnabled = true,
  });

  NotificationSettings copyWith({
    bool? remindersEnabled,
    int? reminderHour,
    int? reminderMinute,
    Set<int>? reminderDays,
    bool? streakReminderEnabled,
  }) {
    return NotificationSettings(
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
      reminderDays: reminderDays ?? this.reminderDays,
      streakReminderEnabled: streakReminderEnabled ?? this.streakReminderEnabled,
    );
  }
}

/// Máscara de bits de los días (bit `weekday-1`): lunes=bit0 … domingo=bit6.
int daysMaskOf(Set<int> days) {
  var m = 0;
  for (final d in days) {
    m |= 1 << (d - 1);
  }
  return m;
}

Set<int> daysFromMask(int mask) =>
    {for (var d = 1; d <= 7; d++) if (mask & (1 << (d - 1)) != 0) d};
