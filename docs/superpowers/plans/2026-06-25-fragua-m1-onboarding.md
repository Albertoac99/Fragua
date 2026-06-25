# Fragua M1 — Onboarding + persistencia: Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Un onboarding que recoge el `UserProfile`, lo persiste con drift, y enruta el arranque: si hay perfil → Home; si no → Onboarding. La BD de la app se abre copiando el catálogo bundleado a una ubicación escribible.

**Architecture:** Una sola `FraguaDatabase` (drift) con `Exercises` (catálogo, precargado del asset) + `UserProfiles` (datos de usuario). En producción se abre copiando `assets/exercise_db.sqlite` a la carpeta de documentos y drift crea las tablas de usuario que falten vía `MigrationStrategy` (el asset solo trae `exercises`, con `user_version=0`). El estado se gestiona con Riverpod; el `databaseProvider` se sobreescribe en `main()` con la BD real y en los tests con `NativeDatabase.memory()`.

**Tech Stack:** Flutter · drift · flutter_riverpod · path_provider · flutter_test.

## Global Constraints

- `lib/core/**` NUNCA importa Flutter (Dart puro). El código que toca assets/Flutter vive en `lib/services/**`, `lib/app/**` y `lib/features/**`.
- Offline-first, sin backend, 0 €. Android, sideload.
- Estado con **Riverpod**; el `databaseProvider` se inyecta (override) en `main()` y en tests → los tests no tocan assets ni path_provider.
- Columnas SQLite en snake_case con `.named(...)`.
- Commits frecuentes, uno por tarea. Mensajes terminan con `Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>`.

---

## File Structure

- `lib/core/db/database.dart` — (modificar) añade tabla `UserProfiles`, `MigrationStrategy`, y métodos `saveProfile`/`loadProfile`.
- `lib/core/db/database.g.dart` — (regenerar con build_runner).
- `lib/services/db/app_database.dart` — (crear) `openAppDatabase()`: copia el asset y abre la BD real. Flutter-side.
- `lib/app/providers.dart` — (crear) `databaseProvider`, `profileProvider`, `exerciseCountProvider`.
- `lib/app/app.dart` — (crear) `FraguaApp` + `_Root` (enruta Onboarding vs Home).
- `lib/features/onboarding/onboarding_screen.dart` — (crear) formulario de onboarding.
- `lib/features/home/home_screen.dart` — (crear) resumen del perfil + nº de ejercicios.
- `lib/main.dart` — (reescribir) abre la BD real y monta `ProviderScope`.
- `test/core/db/profile_persistence_test.dart` — (crear) persistencia en memoria.
- `test/features/onboarding_screen_test.dart` — (crear) guardar perfil desde el formulario.
- `test/features/app_routing_test.dart` — (crear) enrutado según haya perfil o no.
- `test/widget_test.dart` — (borrar) el contador por defecto ya no aplica.

---

### Task 1: Tabla `UserProfiles` + migración + persistencia del perfil

**Files:**
- Modify: `lib/core/db/database.dart`
- Regenerate: `lib/core/db/database.g.dart`
- Test: `test/core/db/profile_persistence_test.dart`

**Interfaces:**
- Consumes: `UserProfile`, enums (`Sex`, `Goal`, `ExperienceLevel`, `Equipment`).
- Produces: tabla drift `UserProfiles` (fila única `id=0`); `Future<void> FraguaDatabase.saveProfile(UserProfile)` (upsert), `Future<UserProfile?> FraguaDatabase.loadProfile()`.

- [ ] **Step 1: Write the failing test**

Crear `test/core/db/profile_persistence_test.dart`:
```dart
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/core/db/database.dart';
import 'package:fragua/core/models/enums.dart';
import 'package:fragua/core/models/user_profile.dart';

void main() {
  test('guarda y recupera el UserProfile (una sola fila)', () async {
    final db = FraguaDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final p = UserProfile(
      sex: Sex.female,
      birthDate: DateTime(2000, 1, 15),
      heightCm: 165,
      weightKg: 60,
      goal: Goal.fatLoss,
      level: ExperienceLevel.beginner,
      daysPerWeek: 3,
      sessionMinutes: 45,
      equipment: {Equipment.dumbbell, Equipment.bands},
      limitations: {'knee'},
    );

    expect(await db.loadProfile(), isNull);
    await db.saveProfile(p);

    final loaded = await db.loadProfile();
    expect(loaded, isNotNull);
    expect(loaded!.sex, Sex.female);
    expect(loaded.goal, Goal.fatLoss);
    expect(loaded.equipment, {Equipment.dumbbell, Equipment.bands});
    expect(loaded.limitations, {'knee'});
    expect(loaded.daysPerWeek, 3);

    // Guardar de nuevo NO duplica (upsert sobre id=0).
    await db.saveProfile(p.copyWith(weightKg: 58));
    final rows = await db.select(db.userProfiles).get();
    expect(rows, hasLength(1));
    expect((await db.loadProfile())!.weightKg, 58);
  });
}
```

- [ ] **Step 2: Modify the drift schema**

Reescribir `lib/core/db/database.dart` (añade imports, tabla `UserProfiles`, migración y métodos; conserva `Exercises`):
```dart
import 'dart:convert';

import 'package:drift/drift.dart';

import '../models/enums.dart';
import '../models/user_profile.dart';

part 'database.g.dart';

class Exercises extends Table {
  TextColumn get id => text().named('id')();
  TextColumn get name => text().named('name')();
  TextColumn get category => text().named('category').nullable()();
  TextColumn get force => text().named('force').nullable()();
  TextColumn get difficulty => text().named('difficulty')();
  TextColumn get mechanic => text().named('mechanic').nullable()();
  TextColumn get equipment => text().named('equipment')();
  TextColumn get primaryMuscles => text().named('primary_muscles')();
  TextColumn get secondaryMuscles => text().named('secondary_muscles')();
  TextColumn get instructions => text().named('instructions')();
  TextColumn get staticImages => text().named('static_images')();
  TextColumn get gifKey => text().named('gif_key').nullable()();
  TextColumn get modality => text().named('modality')();
  TextColumn get variationGroup => text().named('variation_group').nullable()();
  IntColumn get variationRank =>
      integer().named('variation_rank').withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class UserProfiles extends Table {
  IntColumn get id => integer().named('id').withDefault(const Constant(0))();
  TextColumn get sex => text().named('sex')();
  DateTimeColumn get birthDate => dateTime().named('birth_date')();
  RealColumn get heightCm => real().named('height_cm')();
  RealColumn get weightKg => real().named('weight_kg')();
  TextColumn get goal => text().named('goal')();
  TextColumn get level => text().named('level')();
  IntColumn get daysPerWeek => integer().named('days_per_week')();
  IntColumn get sessionMinutes => integer().named('session_minutes')();
  TextColumn get equipment => text().named('equipment')(); // JSON: nombres de enum
  TextColumn get limitations => text().named('limitations')(); // JSON: strings

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Exercises, UserProfiles])
class FraguaDatabase extends _$FraguaDatabase {
  FraguaDatabase(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          // El asset bundleado solo trae `exercises` (user_version=0).
          // Crea las tablas de usuario que faltan.
          await m.createTable(userProfiles);
        },
      );

  Future<void> saveProfile(UserProfile p) async {
    await into(userProfiles).insertOnConflictUpdate(
      UserProfilesCompanion.insert(
        id: const Value(0),
        sex: p.sex.name,
        birthDate: p.birthDate,
        heightCm: p.heightCm,
        weightKg: p.weightKg,
        goal: p.goal.name,
        level: p.level.name,
        daysPerWeek: p.daysPerWeek,
        sessionMinutes: p.sessionMinutes,
        equipment: jsonEncode(p.equipment.map((e) => e.name).toList()),
        limitations: jsonEncode(p.limitations.toList()),
      ),
    );
  }

  Future<UserProfile?> loadProfile() async {
    final row =
        await (select(userProfiles)..where((t) => t.id.equals(0))).getSingleOrNull();
    if (row == null) return null;
    return UserProfile(
      sex: Sex.values.byName(row.sex),
      birthDate: row.birthDate,
      heightCm: row.heightCm,
      weightKg: row.weightKg,
      goal: Goal.values.byName(row.goal),
      level: ExperienceLevel.values.byName(row.level),
      daysPerWeek: row.daysPerWeek,
      sessionMinutes: row.sessionMinutes,
      equipment: (jsonDecode(row.equipment) as List)
          .map((e) => Equipment.values.byName(e as String))
          .toSet(),
      limitations: (jsonDecode(row.limitations) as List).cast<String>().toSet(),
    );
  }
}
```

- [ ] **Step 3: Run codegen**

Run: `dart run build_runner build`
Expected: regenera `database.g.dart` con `UserProfiles`/`UserProfilesCompanion`, sin errores.

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/core/db/profile_persistence_test.dart`
Expected: PASS. (El test antiguo `test/core/db/database_test.dart` sigue verde: `onCreate→createAll` crea ambas tablas.)

- [ ] **Step 5: Commit**

```bash
git add lib/core/db/database.dart lib/core/db/database.g.dart test/core/db/profile_persistence_test.dart
git commit -m "feat(core): persistencia de UserProfile en drift

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 2: Apertura de la BD real (asset) + providers Riverpod

**Files:**
- Modify: `pubspec.yaml` (añade `flutter_riverpod`, `path_provider`)
- Create: `lib/services/db/app_database.dart`
- Create: `lib/app/providers.dart`

**Interfaces:**
- Consumes: `FraguaDatabase`, `UserProfile`.
- Produces: `Future<FraguaDatabase> openAppDatabase()`; `databaseProvider` (Provider<FraguaDatabase>, se sobreescribe), `profileProvider` (FutureProvider<UserProfile?>), `exerciseCountProvider` (FutureProvider<int>).

- [ ] **Step 1: Add dependencies (setup, folded)**

Run: `flutter pub add flutter_riverpod path_provider`
Expected: `flutter pub get` OK.

- [ ] **Step 2: Create the asset-backed connection**

Crear `lib/services/db/app_database.dart`:
```dart
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/db/database.dart';

/// Abre la FraguaDatabase copiando el catálogo bundleado a una ubicación
/// escribible la primera vez (patrón "prepopulated database"). drift crea
/// entonces las tablas de usuario que falten vía MigrationStrategy.
Future<FraguaDatabase> openAppDatabase() async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File(p.join(dir.path, 'fragua.sqlite'));
  if (!await file.exists()) {
    final data = await rootBundle.load('assets/exercise_db.sqlite');
    final bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    await file.writeAsBytes(bytes, flush: true);
  }
  return FraguaDatabase(NativeDatabase(file));
}
```

- [ ] **Step 3: Create the providers**

Crear `lib/app/providers.dart`:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/db/database.dart';
import '../core/models/user_profile.dart';

/// Se sobreescribe en main() con la BD real (asset) y en tests con memoria.
final databaseProvider = Provider<FraguaDatabase>((ref) {
  throw UnimplementedError('databaseProvider debe sobreescribirse');
});

final profileProvider = FutureProvider<UserProfile?>((ref) {
  return ref.watch(databaseProvider).loadProfile();
});

final exerciseCountProvider = FutureProvider<int>((ref) async {
  final db = ref.watch(databaseProvider);
  final rows = await db.select(db.exercises).get();
  return rows.length;
});
```

- [ ] **Step 4: Verify it compiles**

Run: `flutter analyze lib/services/db/app_database.dart lib/app/providers.dart`
Expected: "No issues found!". (La cobertura funcional llega en Task 4 vía override del `databaseProvider` en los widget tests.)

- [ ] **Step 5: Commit**

```bash
git add pubspec.yaml pubspec.lock lib/services/db/app_database.dart lib/app/providers.dart
git commit -m "feat(app): apertura de BD desde asset + providers Riverpod

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 3: Pantalla de Onboarding

**Files:**
- Create: `lib/features/onboarding/onboarding_screen.dart`
- Test: `test/features/onboarding_screen_test.dart`

**Interfaces:**
- Consumes: `databaseProvider`, `profileProvider`, enums, `UserProfile`.
- Produces: `OnboardingScreen` (ConsumerStatefulWidget). Al pulsar "Guardar" valida, llama `db.saveProfile(...)` e invalida `profileProvider`. Tiene valores por defecto válidos para que el guardado funcione sin rellenar todo.

- [ ] **Step 1: Write the failing widget test**

Crear `test/features/onboarding_screen_test.dart`:
```dart
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/app/providers.dart';
import 'package:fragua/core/db/database.dart';
import 'package:fragua/features/onboarding/onboarding_screen.dart';

void main() {
  testWidgets('al guardar persiste un UserProfile', (tester) async {
    final db = FraguaDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: const MaterialApp(home: OnboardingScreen()),
    ));

    expect(await db.loadProfile(), isNull);

    await tester.tap(find.byKey(const Key('onboarding-save')));
    await tester.pumpAndSettle();

    final saved = await db.loadProfile();
    expect(saved, isNotNull);
    expect(saved!.daysPerWeek, inInclusiveRange(1, 7));
    expect(saved.equipment, isNotEmpty);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/onboarding_screen_test.dart`
Expected: FAIL — `OnboardingScreen` no existe.

- [ ] **Step 3: Implement the screen**

Crear `lib/features/onboarding/onboarding_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/models/enums.dart';
import '../../core/models/user_profile.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  Sex _sex = Sex.male;
  Goal _goal = Goal.hypertrophy;
  ExperienceLevel _level = ExperienceLevel.beginner;
  DateTime _birth = DateTime(2000, 1, 1);
  double _height = 175;
  double _weight = 75;
  int _days = 4;
  int _minutes = 60;
  final Set<Equipment> _equipment = {Equipment.bodyweight};

  Future<void> _save() async {
    final profile = UserProfile(
      sex: _sex,
      birthDate: _birth,
      heightCm: _height,
      weightKg: _weight,
      goal: _goal,
      level: _level,
      daysPerWeek: _days,
      sessionMinutes: _minutes,
      equipment: _equipment.isEmpty ? {Equipment.bodyweight} : _equipment,
    );
    await ref.read(databaseProvider).saveProfile(profile);
    ref.invalidate(profileProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cuéntanos sobre ti')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _dropdown<Sex>('Género', _sex, Sex.values, (v) => setState(() => _sex = v)),
          _dropdown<Goal>('Objetivo', _goal, Goal.values, (v) => setState(() => _goal = v)),
          _dropdown<ExperienceLevel>(
              'Nivel', _level, ExperienceLevel.values, (v) => setState(() => _level = v)),
          _slider('Altura (cm)', _height, 120, 220, (v) => setState(() => _height = v)),
          _slider('Peso (kg)', _weight, 35, 200, (v) => setState(() => _weight = v)),
          _slider('Días/semana', _days.toDouble(), 1, 7,
              (v) => setState(() => _days = v.round())),
          _slider('Minutos/sesión', _minutes.toDouble(), 15, 120,
              (v) => setState(() => _minutes = v.round())),
          const SizedBox(height: 8),
          const Text('Equipo disponible'),
          Wrap(
            spacing: 8,
            children: Equipment.values.map((e) {
              final sel = _equipment.contains(e);
              return FilterChip(
                label: Text(e.name),
                selected: sel,
                onSelected: (s) => setState(
                    () => s ? _equipment.add(e) : _equipment.remove(e)),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          FilledButton(
            key: const Key('onboarding-save'),
            onPressed: _save,
            child: const Text('Empezar'),
          ),
        ],
      ),
    );
  }

  Widget _dropdown<T extends Enum>(
      String label, T value, List<T> values, ValueChanged<T> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: DropdownButtonFormField<T>(
        initialValue: value,
        decoration: InputDecoration(labelText: label),
        items: values
            .map((v) => DropdownMenuItem(value: v, child: Text(v.name)))
            .toList(),
        onChanged: (v) => onChanged(v as T),
      ),
    );
  }

  Widget _slider(String label, double value, double min, double max,
      ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ${value.round()}'),
          Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/onboarding_screen_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/onboarding/onboarding_screen.dart test/features/onboarding_screen_test.dart
git commit -m "feat(onboarding): formulario de perfil

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 4: Home + enrutado de arranque + main.dart

**Files:**
- Create: `lib/features/home/home_screen.dart`
- Create: `lib/app/app.dart`
- Modify: `lib/main.dart`
- Delete: `test/widget_test.dart`
- Test: `test/features/app_routing_test.dart`

**Interfaces:**
- Consumes: `profileProvider`, `exerciseCountProvider`, `OnboardingScreen`.
- Produces: `FraguaApp` (root MaterialApp), `HomeScreen` (muestra resumen del perfil + nº de ejercicios del catálogo).

- [ ] **Step 1: Write the failing routing test**

Crear `test/features/app_routing_test.dart`:
```dart
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/app/app.dart';
import 'package:fragua/app/providers.dart';
import 'package:fragua/core/db/database.dart';
import 'package:fragua/core/models/enums.dart';
import 'package:fragua/core/models/user_profile.dart';

UserProfile _profile() => UserProfile(
      sex: Sex.male,
      birthDate: DateTime(1995, 5, 5),
      heightCm: 180,
      weightKg: 80,
      goal: Goal.strength,
      level: ExperienceLevel.intermediate,
      daysPerWeek: 4,
      sessionMinutes: 60,
      equipment: {Equipment.barbell},
    );

Future<void> _pump(WidgetTester tester, FraguaDatabase db) async {
  await tester.pumpWidget(ProviderScope(
    overrides: [databaseProvider.overrideWithValue(db)],
    child: const FraguaApp(),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('sin perfil => Onboarding', (tester) async {
    final db = FraguaDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await _pump(tester, db);
    expect(find.text('Cuéntanos sobre ti'), findsOneWidget);
  });

  testWidgets('con perfil => Home', (tester) async {
    final db = FraguaDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db.saveProfile(_profile());
    await _pump(tester, db);
    expect(find.byKey(const Key('home-title')), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/app_routing_test.dart`
Expected: FAIL — `FraguaApp`/`HomeScreen` no existen.

- [ ] **Step 3: Implement Home**

Crear `lib/features/home/home_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider).valueOrNull;
    final count = ref.watch(exerciseCountProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fragua', key: Key('home-title')),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.fitness_center, size: 64),
            const SizedBox(height: 12),
            Text(profile == null
                ? 'Sin perfil'
                : 'Objetivo: ${profile.goal.name} · ${profile.daysPerWeek} días/sem'),
            const SizedBox(height: 8),
            count.when(
              loading: () => const Text('Cargando catálogo…'),
              error: (e, _) => Text('Error catálogo: $e'),
              data: (n) => Text('$n ejercicios en el catálogo'),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Implement the app root**

Crear `lib/app/app.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/home/home_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import 'providers.dart';

class FraguaApp extends StatelessWidget {
  const FraguaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fragua',
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF58CC02),
        useMaterial3: true,
      ),
      home: const _Root(),
    );
  }
}

class _Root extends ConsumerWidget {
  const _Root();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    return profile.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (p) => p == null ? const OnboardingScreen() : const HomeScreen(),
    );
  }
}
```

- [ ] **Step 5: Rewrite main.dart and delete the default widget test**

Reescribir `lib/main.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/providers.dart';
import 'services/db/app_database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = await openAppDatabase();
  runApp(ProviderScope(
    overrides: [databaseProvider.overrideWithValue(db)],
    child: const FraguaApp(),
  ));
}
```
Run: `git rm test/widget_test.dart`

- [ ] **Step 6: Run test to verify it passes**

Run: `flutter test test/features/app_routing_test.dart`
Expected: PASS (ambos casos).

- [ ] **Step 7: Commit**

```bash
git add lib/features/home/home_screen.dart lib/app/app.dart lib/main.dart test/features/app_routing_test.dart
git commit -m "feat(app): Home + enrutado de arranque (onboarding vs home)

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

## Verificación de M1 (Definition of Done)

- `flutter analyze` limpio.
- `flutter test` verde: persistencia de perfil, onboarding guarda, enrutado (con/sin perfil), drift en memoria.
- La app abre la BD real desde el asset (verificado por construcción; ejecución on-device en M9).
- Todo commiteado y mergeado a `master`; push a `origin` con OK.

## Cobertura de la spec (self-review)

- §7.1 onboarding (datos físicos, objetivo, nivel, días/min, equipo) → Task 3. (Limitaciones/lesiones: el modelo `UserProfile` ya las soporta; la UI las añade en una iteración posterior — el campo se persiste vacío por ahora.)
- §8 modelo de datos (`user_profile`) → Task 1. §12 manejo de errores (estados loading/error en providers) → Task 4. §6 `core/` sin Flutter (la apertura del asset vive en services) → Task 2.
- **Fuera de M1:** coach (M2) — primer consumidor real del catálogo de ejercicios; el resto de milestones según el plan global.
