# Fragua M8 — Notificaciones locales: Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Recordatorios **100 % locales** (sin servidor): aviso de entreno configurable (días + hora) y aviso de **"racha en peligro"**, con gestión del permiso `POST_NOTIFICATIONS` (Android 13+) y degradado elegante si se deniega.

**Architecture:** La **lógica de cuándo notificar** es Dart puro y determinista en `lib/core/notifications/` (próximas ocurrencias del recordatorio según ajustes + hora de aviso de racha), testeable sin plugin. El plugin real vive tras un *seam* inyectable `Notifier` (patrón de `VoiceCues`/`MediaCache`): `NoopNotifier` por defecto (tests/degradado), `LocalNotifier` real con `flutter_local_notifications` + `timezone` + `flutter_timezone`. Los ajustes se persisten en una fila única `app_settings` (drift, migración **v7**). Un `NotificationsService` orquesta: lee ajustes, calcula los disparos con la lógica pura y los programa por el seam. La UI añade una pantalla de **Notificaciones** (separada de la de Ajustes de M5 para no tocar su test).

**Tech Stack:** Dart puro (programación) · drift · flutter_riverpod · flutter_local_notifications + timezone + flutter_timezone (nuevos) · flutter_test.

## Global Constraints

- `lib/core/**` NUNCA importa Flutter ni el plugin. La lógica de programación es **pura y determinista** (testeable con `now` fijo).
- El plugin es un **seam inyectable** (`notifierProvider`): por defecto `NoopNotifier` → tests y degradado sin notificaciones nunca tocan el plugin. `LocalNotifier` solo se construye en `main()`.
- Persistencia drift: fila única `id=0` en `app_settings`; migración **versionada** (`if (from < 7)`).
- **Offline-first / degradado**: si el permiso se deniega o el plugin falla, la app sigue funcionando (los avisos simplemente no se programan).
- Commits frecuentes, uno por tarea. Mensajes terminan con `Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>`.

---

## File Structure

- `lib/core/notifications/notification_settings.dart` — (crear) modelo `NotificationSettings` + conversión días↔máscara.
- `lib/core/notifications/schedule.dart` — (crear) `nextReminderOccurrences`, `streakInDangerTime`.
- `lib/core/db/database.dart` — (modificar) tabla `AppSettings` + métodos; migración v7.
- `lib/core/db/database.g.dart` — (regenerar).
- `lib/services/notifications/notifier.dart` — (crear) `Notifier` (abstracto), `NoopNotifier`, `LocalNotifier`.
- `lib/features/notifications/notifications_service.dart` — (crear) `NotificationsService.reschedule`.
- `lib/app/providers.dart` — (modificar) `notifierProvider`, `notificationsServiceProvider`, `notificationSettingsProvider`.
- `lib/features/notifications/notifications_settings_screen.dart` — (crear) UI de notificaciones.
- `lib/features/settings/settings_screen.dart` — (modificar) acceso a Notificaciones.
- `lib/main.dart` — (modificar) construir `LocalNotifier`, inicializar y reprogramar.
- `android/app/src/main/AndroidManifest.xml` — (modificar) permisos + receivers.
- `pubspec.yaml` — (modificar) deps.
- Tests: `test/core/notifications/schedule_test.dart`, `test/core/db/app_settings_test.dart`, `test/features/notifications_service_test.dart`, `test/features/notifications_settings_screen_test.dart`.

---

### Task 1: Modelo de ajustes + lógica de programación (puro)

**Files:**
- Create: `lib/core/notifications/notification_settings.dart`
- Create: `lib/core/notifications/schedule.dart`
- Test: `test/core/notifications/schedule_test.dart`

**Interfaces:**
- Produces:
  - `class NotificationSettings { final bool remindersEnabled; final int reminderHour; final int reminderMinute; final Set<int> reminderDays; final bool streakReminderEnabled; const NotificationSettings({this.remindersEnabled = false, this.reminderHour = 19, this.reminderMinute = 0, this.reminderDays = const {1,2,3,4,5}, this.streakReminderEnabled = true}); NotificationSettings copyWith({...}); }`.
  - `int daysMaskOf(Set<int> days)` (bit `weekday-1`); `Set<int> daysFromMask(int mask)`.
  - `List<DateTime> nextReminderOccurrences(NotificationSettings s, DateTime from, {int horizonDays = 7})`.
  - `DateTime? streakInDangerTime({required int? lastActiveDay, required DateTime now, int hour = 20})`.

- [ ] **Step 1: Write the failing test**

Crear `test/core/notifications/schedule_test.dart`:
```dart
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
        remindersEnabled: true, reminderHour: 8, reminderDays: {1, 2, 3, 4, 5, 6, 7});
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
    expect(streakInDangerTime(lastActiveDay: dayNumber(now) - 3, now: now), isNull);
  });

  test('racha: pasada la hora de aviso => null', () {
    final now = DateTime(2026, 6, 25, 21);
    expect(streakInDangerTime(lastActiveDay: dayNumber(now) - 1, now: now), isNull);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/notifications/schedule_test.dart`
Expected: FAIL — símbolos no existen.

- [ ] **Step 3: Implement**

Crear `lib/core/notifications/notification_settings.dart`:
```dart
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
```

Crear `lib/core/notifications/schedule.dart`:
```dart
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
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/core/notifications/schedule_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/core/notifications/notification_settings.dart lib/core/notifications/schedule.dart test/core/notifications/schedule_test.dart
git commit -m "feat(core): ajustes de notificaciones + logica de programacion

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 2: Persistencia de ajustes (migración v7)

**Files:**
- Modify: `lib/core/db/database.dart`
- Regenerate: `lib/core/db/database.g.dart`
- Test: `test/core/db/app_settings_test.dart`

**Interfaces:**
- Consumes: `NotificationSettings`, `daysMaskOf`, `daysFromMask`.
- Produces: tabla `AppSettings` (fila única id=0); migración v7; métodos `Future<NotificationSettings> loadNotificationSettings()` (defaults si no hay fila) y `Future<void> saveNotificationSettings(NotificationSettings s)`.

- [ ] **Step 1: Write the failing test**

Crear `test/core/db/app_settings_test.dart`:
```dart
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/core/db/database.dart';
import 'package:fragua/core/notifications/notification_settings.dart';

void main() {
  test('ajustes: defaults cuando no hay fila, y upsert', () async {
    final db = FraguaDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final def = await db.loadNotificationSettings();
    expect(def.remindersEnabled, isFalse);
    expect(def.reminderHour, 19);
    expect(def.reminderDays, {1, 2, 3, 4, 5});

    await db.saveNotificationSettings(const NotificationSettings(
      remindersEnabled: true,
      reminderHour: 7,
      reminderMinute: 15,
      reminderDays: {6, 7},
      streakReminderEnabled: false,
    ));
    final s = await db.loadNotificationSettings();
    expect(s.remindersEnabled, isTrue);
    expect(s.reminderHour, 7);
    expect(s.reminderMinute, 15);
    expect(s.reminderDays, {6, 7});
    expect(s.streakReminderEnabled, isFalse);

    expect(await db.select(db.appSettings).get(), hasLength(1));
  });
}
```

- [ ] **Step 2: Add table, methods and migration**

En `lib/core/db/database.dart`:
- Importa el modelo (junto a los otros imports de core):
```dart
import '../notifications/notification_settings.dart';
```
- Añade la tabla (junto a `BodyMetrics`):
```dart
@DataClassName('AppSettingsRow')
class AppSettings extends Table {
  IntColumn get id => integer().named('id').withDefault(const Constant(0))();
  BoolColumn get remindersEnabled =>
      boolean().named('reminders_enabled').withDefault(const Constant(false))();
  IntColumn get reminderHour =>
      integer().named('reminder_hour').withDefault(const Constant(19))();
  IntColumn get reminderMinute =>
      integer().named('reminder_minute').withDefault(const Constant(0))();
  IntColumn get reminderDaysMask =>
      integer().named('reminder_days_mask').withDefault(const Constant(0x1F))();
  BoolColumn get streakReminderEnabled => boolean()
      .named('streak_reminder_enabled')
      .withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}
```
- Regístrala en `@DriftDatabase` (añade `AppSettings`).
- Sube `schemaVersion` a `7`.
- Añade en `onUpgrade` (tras el bloque `if (from < 6)`):
```dart
          if (from < 7) await m.createTable(appSettings);
```
- Añade los métodos en `FraguaDatabase` (tras `loadBodyMetrics`):
```dart
  Future<NotificationSettings> loadNotificationSettings() async {
    final row = await (select(appSettings)..where((t) => t.id.equals(0)))
        .getSingleOrNull();
    if (row == null) return const NotificationSettings();
    return NotificationSettings(
      remindersEnabled: row.remindersEnabled,
      reminderHour: row.reminderHour,
      reminderMinute: row.reminderMinute,
      reminderDays: daysFromMask(row.reminderDaysMask),
      streakReminderEnabled: row.streakReminderEnabled,
    );
  }

  Future<void> saveNotificationSettings(NotificationSettings s) async {
    await into(appSettings).insertOnConflictUpdate(
      AppSettingsCompanion.insert(
        id: const Value(0),
        remindersEnabled: Value(s.remindersEnabled),
        reminderHour: Value(s.reminderHour),
        reminderMinute: Value(s.reminderMinute),
        reminderDaysMask: Value(daysMaskOf(s.reminderDays)),
        streakReminderEnabled: Value(s.streakReminderEnabled),
      ),
    );
  }
```

- [ ] **Step 3: Run codegen**

Run: `dart run build_runner build`
Expected: regenera `database.g.dart` con `AppSettings`/`AppSettingsCompanion`.

- [ ] **Step 4: Run tests**

Run: `flutter test test/core/db/`
Expected: PASS (ajustes + sin regresiones).

- [ ] **Step 5: Commit**

```bash
git add lib/core/db/database.dart lib/core/db/database.g.dart test/core/db/app_settings_test.dart
git commit -m "feat(core): persistencia de ajustes de notificaciones (migracion v7)

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 3: Seam del notificador + servicio de reprogramación

**Files:**
- Modify: `pubspec.yaml` (deps)
- Create: `lib/services/notifications/notifier.dart`
- Create: `lib/features/notifications/notifications_service.dart`
- Modify: `lib/app/providers.dart` (providers)
- Test: `test/features/notifications_service_test.dart`

**Interfaces:**
- Produces:
  - `abstract class Notifier { Future<void> init(); Future<bool> requestPermission(); Future<void> scheduleAt(int id, DateTime when, String title, String body); Future<void> cancelAll(); }`; `NoopNotifier` (no-op; `requestPermission` → false); `LocalNotifier` (real).
  - `final notifierProvider = Provider<Notifier>((ref) => const NoopNotifier());` (override en main con `LocalNotifier`).
  - `class NotificationsService { NotificationsService({required this.notifier, required this.db}); final Notifier notifier; final FraguaDatabase db; Future<void> reschedule(DateTime now); }`.
  - `final notificationsServiceProvider = Provider<NotificationsService>((ref) => NotificationsService(notifier: ref.read(notifierProvider), db: ref.read(databaseProvider)));`.

- [ ] **Step 1: Add dependencies + the notifier seam**

Run: `flutter pub add flutter_local_notifications timezone flutter_timezone`

Crear `lib/services/notifications/notifier.dart`:
```dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Seam de notificaciones locales. La app degrada sin él (NoopNotifier).
abstract class Notifier {
  Future<void> init();
  Future<bool> requestPermission();
  Future<void> scheduleAt(int id, DateTime when, String title, String body);
  Future<void> cancelAll();
}

/// Sin notificaciones (tests / permiso denegado / fallo del plugin).
class NoopNotifier implements Notifier {
  const NoopNotifier();
  @override
  Future<void> init() async {}
  @override
  Future<bool> requestPermission() async => false;
  @override
  Future<void> scheduleAt(int id, DateTime when, String title, String body) async {}
  @override
  Future<void> cancelAll() async {}
}

/// Implementación real con flutter_local_notifications + timezone.
class LocalNotifier implements Notifier {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'fragua_reminders',
      'Recordatorios',
      channelDescription: 'Recordatorios de entreno y racha',
      importance: Importance.max,
      priority: Priority.high,
    ),
  );

  @override
  Future<void> init() async {
    tzdata.initializeTimeZones();
    final name = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(name));
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(const InitializationSettings(android: android));
  }

  @override
  Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final granted = await android?.requestNotificationsPermission();
    return granted ?? false;
  }

  @override
  Future<void> scheduleAt(int id, DateTime when, String title, String body) async {
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(when, tz.local),
      _details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  @override
  Future<void> cancelAll() => _plugin.cancelAll();
}
```

- [ ] **Step 2: Add the providers + service**

Crear `lib/features/notifications/notifications_service.dart`:
```dart
import '../../core/db/database.dart';
import '../../core/notifications/schedule.dart';
import '../../services/notifications/notifier.dart';

class NotificationsService {
  NotificationsService({required this.notifier, required this.db});
  final Notifier notifier;
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
        await notifier.scheduleAt(
            900, danger, 'Tu racha está en peligro', 'Entrena hoy para mantenerla 🔥');
      }
    }
  }
}
```

En `lib/app/providers.dart` añade (importa los dos archivos):
```dart
import '../features/notifications/notifications_service.dart';
import '../services/notifications/notifier.dart';
```
```dart
/// Override con LocalNotifier() en main(); NoopNotifier por defecto (tests).
final notifierProvider = Provider<Notifier>((ref) => const NoopNotifier());

final notificationsServiceProvider = Provider<NotificationsService>((ref) =>
    NotificationsService(
        notifier: ref.read(notifierProvider), db: ref.read(databaseProvider)));
```

- [ ] **Step 3: Write the failing test**

Crear `test/features/notifications_service_test.dart`:
```dart
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/core/db/database.dart';
import 'package:fragua/core/leagues/streak.dart';
import 'package:fragua/core/notifications/notification_settings.dart';
import 'package:fragua/features/notifications/notifications_service.dart';
import 'package:fragua/services/notifications/notifier.dart';

class FakeNotifier implements Notifier {
  final List<({int id, DateTime when, String title})> scheduled = [];
  bool cancelled = false;
  @override
  Future<void> init() async {}
  @override
  Future<bool> requestPermission() async => true;
  @override
  Future<void> scheduleAt(int id, DateTime when, String title, String body) async =>
      scheduled.add((id: id, when: when, title: title));
  @override
  Future<void> cancelAll() async => cancelled = true;
}

void main() {
  test('reprograma: cancela, agenda recordatorios y aviso de racha', () async {
    final db = FraguaDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final now = DateTime(2026, 6, 24, 12); // miércoles mediodía

    await db.saveNotificationSettings(const NotificationSettings(
      remindersEnabled: true,
      reminderHour: 19,
      reminderDays: {1, 2, 3, 4, 5},
      streakReminderEnabled: true,
    ));
    // Entrenó ayer => racha en peligro hoy.
    await db.saveLeagueState(
      division: 'bronze',
      weekId: 0,
      weeklyXp: 0,
      streakCurrent: 1,
      streakRecord: 1,
      lastActiveDay: dayNumber(now) - 1,
      totalWorkouts: 1,
      totalPrs: 0,
    );

    final fake = FakeNotifier();
    await NotificationsService(notifier: fake, db: db).reschedule(now);

    expect(fake.cancelled, isTrue);
    expect(fake.scheduled.any((e) => e.title == 'Hora de entrenar'), isTrue);
    final streak = fake.scheduled.where((e) => e.id == 900);
    expect(streak, hasLength(1));
    expect(streak.first.when, DateTime(2026, 6, 24, 20));
  });

  test('deshabilitado: solo cancela, no agenda nada', () async {
    final db = FraguaDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db.saveNotificationSettings(
        const NotificationSettings(remindersEnabled: false, streakReminderEnabled: false));

    final fake = FakeNotifier();
    await NotificationsService(notifier: fake, db: db)
        .reschedule(DateTime(2026, 6, 24, 12));

    expect(fake.cancelled, isTrue);
    expect(fake.scheduled, isEmpty);
  });
}
```

- [ ] **Step 4: Run tests**

Run: `flutter test test/features/notifications_service_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add pubspec.yaml pubspec.lock lib/services/notifications/notifier.dart lib/features/notifications/notifications_service.dart lib/app/providers.dart test/features/notifications_service_test.dart
git commit -m "feat(notifications): seam del notificador + servicio de reprogramacion

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 4: UI de notificaciones + manifest + arranque

**Files:**
- Create: `lib/features/notifications/notifications_settings_screen.dart`
- Modify: `lib/features/settings/settings_screen.dart` (acceso)
- Modify: `lib/main.dart` (LocalNotifier + init + reschedule)
- Modify: `android/app/src/main/AndroidManifest.xml` (permisos + receivers)
- Modify: `lib/app/providers.dart` (`notificationSettingsProvider`)
- Test: `test/features/notifications_settings_screen_test.dart`

**Interfaces:**
- Consumes: `databaseProvider`, `notificationsServiceProvider`, `notifierProvider`, `NotificationSettings`.
- Produces: `final notificationSettingsProvider = FutureProvider<NotificationSettings>((ref) => ref.watch(databaseProvider).loadNotificationSettings());`; `class NotificationsSettingsScreen extends ConsumerStatefulWidget` (toggle recordatorios `key: Key('reminders-toggle')`, hora, chips de días, toggle racha; cada cambio guarda + reprograma + pide permiso al habilitar). `SettingsScreen` gana un `ListTile` (`key: Key('open-notifications')`).

- [ ] **Step 1: Write the failing widget test**

Crear `test/features/notifications_settings_screen_test.dart`:
```dart
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/app/providers.dart';
import 'package:fragua/core/db/database.dart';
import 'package:fragua/features/notifications/notifications_settings_screen.dart';

void main() {
  testWidgets('activar recordatorios persiste el ajuste', (tester) async {
    final db = FraguaDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: const MaterialApp(home: NotificationsSettingsScreen()),
    ));
    await tester.pumpAndSettle();

    expect((await db.loadNotificationSettings()).remindersEnabled, isFalse);

    await tester.tap(find.byKey(const Key('reminders-toggle')));
    await tester.pumpAndSettle();

    expect((await db.loadNotificationSettings()).remindersEnabled, isTrue);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/notifications_settings_screen_test.dart`
Expected: FAIL — `NotificationsSettingsScreen` no existe.

- [ ] **Step 3: Add the provider + implement the screen**

En `lib/app/providers.dart` añade (importa el modelo):
```dart
import '../core/notifications/notification_settings.dart';
```
```dart
final notificationSettingsProvider = FutureProvider<NotificationSettings>(
    (ref) => ref.watch(databaseProvider).loadNotificationSettings());
```

Crear `lib/features/notifications/notifications_settings_screen.dart`:
```dart
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

  Future<void> _apply(NotificationSettings next, {bool requestPerm = false}) async {
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
                  onChanged: (v) => _apply(s.copyWith(remindersEnabled: v),
                      requestPerm: v),
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
```

- [ ] **Step 4: Link from Settings**

En `lib/features/settings/settings_screen.dart`:
- Importa la pantalla:
```dart
import '../notifications/notifications_settings_screen.dart';
```
- Al principio del `ListView` (antes del título "Caché de animaciones"), añade el acceso:
```dart
          ListTile(
            key: const Key('open-notifications'),
            leading: const Icon(Icons.notifications),
            title: const Text('Notificaciones'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => const NotificationsSettingsScreen()),
            ),
          ),
          const Divider(),
```

- [ ] **Step 5: Android manifest**

En `android/app/src/main/AndroidManifest.xml`:
- Tras la etiqueta `<manifest ...>` de apertura (antes de `<application>`), añade los permisos:
```xml
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
    <uses-permission android:name="android.permission.VIBRATE"/>
    <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
    <uses-permission android:name="android.permission.USE_EXACT_ALARM"/>
```
- Dentro de `<application>`, antes del cierre `</application>` (tras el `<meta-data android:name="flutterEmbedding" .../>`), añade los receivers de flutter_local_notifications:
```xml
        <receiver android:exported="false"
            android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
        <receiver android:exported="false"
            android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED"/>
                <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
                <action android:name="android.intent.action.QUICKBOOT_POWERON"/>
            </intent-filter>
        </receiver>
```

- [ ] **Step 6: Wire the real notifier in main**

En `lib/main.dart`:
- Importa:
```dart
import 'features/notifications/notifications_service.dart';
import 'services/notifications/notifier.dart';
```
- En `main()`, tras abrir la BD, construye e inicializa el notificador (degradado si falla) y reprograma; añade el override:
```dart
  final notifier = LocalNotifier();
  try {
    await notifier.init();
    await NotificationsService(notifier: notifier, db: db)
        .reschedule(DateTime.now());
  } catch (_) {
    // Degradado: sin notificaciones, la app sigue.
  }
  runApp(ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(db),
      voiceProvider.overrideWithValue(TtsVoiceCues()),
      mediaCacheProvider.overrideWithValue(HttpMediaCache()),
      notifierProvider.overrideWithValue(notifier),
    ],
    child: const FraguaApp(),
  ));
```

- [ ] **Step 7: Run the widget test**

Run: `flutter test test/features/notifications_settings_screen_test.dart`
Expected: PASS (usa `NoopNotifier` por defecto → sin plugin).

- [ ] **Step 8: Commit**

```bash
git add lib/features/notifications/notifications_settings_screen.dart lib/features/settings/settings_screen.dart lib/main.dart lib/app/providers.dart android/app/src/main/AndroidManifest.xml test/features/notifications_settings_screen_test.dart
git commit -m "feat(notifications): pantalla de ajustes + manifest + arranque

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 5: Verificación de M8

**Files:** (sin cambios de código; solo verificación)

- [ ] **Step 1: Full test suite**

Run: `flutter test`
Expected: verde (programación pura, persistencia v7, servicio con FakeNotifier, pantalla de notificaciones, sin regresiones).

- [ ] **Step 2: Analyze**

Run: `flutter analyze`
Expected: `No issues found!`

- [ ] **Step 3: Pytest**

Run: `tools/.venv/bin/python -m pytest tools/ -q`
Expected: verde.

- [ ] **Step 4: (si hay ajustes) Commit**

```bash
git commit -am "chore(notifications): ajustes de verificacion M8

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

## Verificación de M8 (Definition of Done)

- `flutter analyze` limpio · `flutter test` verde (lógica de programación, persistencia v7, servicio, pantalla) · `pytest` verde.
- En Ajustes → Notificaciones se pueden activar recordatorios (días + hora) y el aviso de racha; al activar se pide el permiso y se (re)programan los avisos; todo persiste.
- Sin permiso o si el plugin falla, la app **sigue funcionando** (degradado vía `NoopNotifier` / try-catch en `main`).
- Mergeado a `master`; push a `origin` (con el OK de Alberto). La entrega real de notificaciones se valida en el móvil (M9).

## Cobertura de la spec (self-review)

- **§7.8 notificaciones locales** — recordatorio de entreno configurable (días + hora) → Tasks 1–4; "racha en peligro" → Tasks 1, 3, 4; permiso `POST_NOTIFICATIONS` (Android 13+) + degradado → Tasks 3, 4 (`requestPermission`, `NoopNotifier`, try-catch). **Sin servidor** (`flutter_local_notifications` + `timezone`).
- **§12 manejo de errores** (permiso denegado → degradado) → seam `NoopNotifier` + try-catch en `main`.
- **§4 stack** (flutter_local_notifications + timezone, 100% local) → Task 3.
- **Fuera de M8** (explícito, documentado): **fin de descanso en segundo plano** — el temporizador y la voz en primer plano (M3/M4) ya cubren el caso; la variante en segundo plano acoplaría el plugin a las pantallas de sesión y aporta poco; queda como mejora. La **entrega real** de notificaciones (zonedSchedule, permiso, reboot) se verifica **on-device en M9** (no es testeable en `flutter test`).
