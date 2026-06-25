# Fragua M0 — Esqueleto: Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Tener un proyecto Flutter que compila, con los modelos de dominio en Dart puro y una BD de ejercicios `exercise_db.sqlite` generada por un script Python a partir de free-exercise-db, todo con tests unitarios en verde.

**Architecture:** Separación estricta `core/` (Dart puro, sin Flutter, 100 % testeable) vs resto de la app. La BD de ejercicios se construye **fuera de la app** con un script Python (`tools/build_exercise_db.py`) que normaliza free-exercise-db y escribe un SQLite cuyo esquema de columnas coincide **exactamente** con la tabla drift `exercises` (nombres de columna explícitos en ambos lados). En M0 drift se prueba con `NativeDatabase.memory()`; abrir el SQLite bundleado en runtime es de M1.

**Tech Stack:** Flutter (Dart) · drift (SQLite) · build_runner/drift_dev (codegen) · Python 3 (stdlib + requests) · flutter_test.

## Global Constraints

- `lib/core/**` **NUNCA** importa Flutter (ni `package:flutter/*` ni `package:flutter_test` en el propio código de librería). Solo Dart puro. (Los tests sí pueden usar flutter_test.)
- Offline-first, sin backend, 0 €. Objetivo Android, distribución sideload.
- Persistencia con **drift**; la BD de ejercicios es un **asset pre-construido** (`assets/exercise_db.sqlite`), generado por `tools/build_exercise_db.py`.
- Nombres de columna SQLite en snake_case, **idénticos** entre el script Python y las columnas drift (vía `.named(...)`).
- Datos de ejercicios: **free-exercise-db** (yuhonas), JSON combinado `dist/exercises.json`.
- Commits frecuentes, uno por tarea. Mensajes de commit terminan con la línea `Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>`.

---

## File Structure

- `pubspec.yaml` — dependencias (drift, sqlite3_flutter_libs, path; dev: drift_dev, build_runner).
- `analysis_options.yaml` — lints (flutter_lints) + regla que evita Flutter en core (documental).
- `lib/main.dart` — entrada mínima de la app (pantalla placeholder), solo para que `flutter run` arranque.
- `lib/core/models/enums.dart` — enums de dominio + `equipmentFromRaw()`.
- `lib/core/models/user_profile.dart` — `UserProfile` (datos del onboarding).
- `lib/core/models/exercise.dart` — `Exercise` + `Exercise.fromDbRow()`.
- `lib/core/db/database.dart` — drift: tabla `Exercises` + `FraguaDatabase`.
- `tools/requirements.txt` — `requests`.
- `tools/build_exercise_db.py` — descarga + normaliza free-exercise-db → `assets/exercise_db.sqlite`.
- `tools/fixtures/sample_exercises.json` — 3 registros de muestra (formato free-exercise-db) para tests sin red.
- `tools/test_build_exercise_db.py` — pytest de la normalización y del ensamblado SQLite.
- `test/core/models/enums_test.dart`, `user_profile_test.dart`, `exercise_test.dart` — tests Dart.
- `test/core/db/database_test.dart` — test drift en memoria.
- `.gitignore` — Flutter estándar + `tools/.cache/`; **NO** ignora `assets/exercise_db.sqlite` (es el asset que se publica).

---

### Task 1: Scaffold del proyecto + enums de dominio

**Files:**
- Create (scaffold): proyecto Flutter en la carpeta `fragua/` (ya tiene `.git` y `docs/`).
- Modify: `pubspec.yaml` (deps + assets), `.gitignore`.
- Create: `lib/core/models/enums.dart`
- Test: `test/core/models/enums_test.dart`

**Interfaces:**
- Consumes: nada (primera tarea).
- Produces: `enum Sex {male, female, other}`, `enum Goal {fatLoss, hypertrophy, strength, generalFitness, endurance}`, `enum ExperienceLevel {beginner, intermediate, advanced}`, `enum Modality {strength, guided, both}`, `enum ForceType {push, pull, staticHold}`, `enum Mechanic {compound, isolation}`, `enum ExerciseDifficulty {beginner, intermediate, expert}`, `enum Equipment {bodyweight, dumbbell, barbell, machine, cable, kettlebell, bands, pullupBar, bench, other}`, y `Equipment equipmentFromRaw(String? raw)`.

- [ ] **Step 1: Scaffold Flutter + deps (setup, folded)**

Run (dentro de `fragua/`):
```bash
flutter create --org com.aranda --project-name fragua --platforms=android .
flutter pub add drift sqlite3_flutter_libs path
flutter pub add -d drift_dev build_runner
```
Añadir a `pubspec.yaml` bajo `flutter:` la sección de assets:
```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/exercise_db.sqlite
```
Crear `.gitignore` (añadir al de Flutter) la línea: `tools/.cache/`. Crear carpeta `assets/` con un placeholder vacío para que `flutter pub get` no falle por el asset ausente todavía: `touch assets/.gitkeep`.
Expected: `flutter pub get` termina sin errores.

- [ ] **Step 2: Write the failing test**

Crear `test/core/models/enums_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/core/models/enums.dart';

void main() {
  group('equipmentFromRaw', () {
    test('mapea valores conocidos de free-exercise-db', () {
      expect(equipmentFromRaw('body only'), Equipment.bodyweight);
      expect(equipmentFromRaw('dumbbell'), Equipment.dumbbell);
      expect(equipmentFromRaw('barbell'), Equipment.barbell);
      expect(equipmentFromRaw('e-z curl bar'), Equipment.barbell);
      expect(equipmentFromRaw('machine'), Equipment.machine);
      expect(equipmentFromRaw('cable'), Equipment.cable);
      expect(equipmentFromRaw('kettlebells'), Equipment.kettlebell);
      expect(equipmentFromRaw('bands'), Equipment.bands);
    });

    test('null, vacío o desconocido => bodyweight/other', () {
      expect(equipmentFromRaw(null), Equipment.bodyweight);
      expect(equipmentFromRaw(''), Equipment.bodyweight);
      expect(equipmentFromRaw('medicine ball'), Equipment.other);
    });

    test('es case-insensitive y tolera espacios', () {
      expect(equipmentFromRaw('  Dumbbell '), Equipment.dumbbell);
    });
  });
}
```

- [ ] **Step 3: Run test to verify it fails**

Run: `flutter test test/core/models/enums_test.dart`
Expected: FAIL — `enums.dart` no existe / símbolos no definidos.

- [ ] **Step 4: Write minimal implementation**

Crear `lib/core/models/enums.dart`:
```dart
/// Enums de dominio de Fragua. Dart puro: no debe importar Flutter.

enum Sex { male, female, other }

enum Goal { fatLoss, hypertrophy, strength, generalFitness, endurance }

enum ExperienceLevel { beginner, intermediate, advanced }

enum Modality { strength, guided, both }

enum ForceType { push, pull, staticHold }

enum Mechanic { compound, isolation }

enum ExerciseDifficulty { beginner, intermediate, expert }

/// Equipo que el usuario puede tener / que un ejercicio requiere.
enum Equipment {
  bodyweight,
  dumbbell,
  barbell,
  machine,
  cable,
  kettlebell,
  bands,
  pullupBar,
  bench,
  other,
}

/// Convierte el campo `equipment` crudo de free-exercise-db en [Equipment].
Equipment equipmentFromRaw(String? raw) {
  switch (raw?.toLowerCase().trim()) {
    case null:
    case '':
    case 'body only':
      return Equipment.bodyweight;
    case 'dumbbell':
      return Equipment.dumbbell;
    case 'barbell':
    case 'e-z curl bar':
      return Equipment.barbell;
    case 'machine':
      return Equipment.machine;
    case 'cable':
      return Equipment.cable;
    case 'kettlebells':
      return Equipment.kettlebell;
    case 'bands':
      return Equipment.bands;
    default:
      return Equipment.other;
  }
}
```

- [ ] **Step 5: Run test to verify it passes**

Run: `flutter test test/core/models/enums_test.dart`
Expected: PASS (todos los tests verdes).

- [ ] **Step 6: Commit**

```bash
git add pubspec.yaml pubspec.lock .gitignore analysis_options.yaml android lib test assets
git commit -m "feat(core): scaffold Flutter + enums de dominio

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 2: Modelo `UserProfile`

**Files:**
- Create: `lib/core/models/user_profile.dart`
- Test: `test/core/models/user_profile_test.dart`

**Interfaces:**
- Consumes: `Sex`, `Goal`, `ExperienceLevel`, `Equipment` de `enums.dart`.
- Produces: clase `UserProfile` con campos `Sex sex`, `DateTime birthDate`, `double heightCm`, `double weightKg`, `Goal goal`, `ExperienceLevel level`, `int daysPerWeek`, `int sessionMinutes`, `Set<Equipment> equipment`, `Set<String> limitations`; métodos `int ageOn(DateTime now)`, `bool get isValid`, `UserProfile copyWith({...})`.

- [ ] **Step 1: Write the failing test**

Crear `test/core/models/user_profile_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/core/models/enums.dart';
import 'package:fragua/core/models/user_profile.dart';

UserProfile sample({int daysPerWeek = 4}) => UserProfile(
      sex: Sex.male,
      birthDate: DateTime(1999, 6, 20),
      heightCm: 178,
      weightKg: 75,
      goal: Goal.hypertrophy,
      level: ExperienceLevel.intermediate,
      daysPerWeek: daysPerWeek,
      sessionMinutes: 60,
      equipment: {Equipment.barbell, Equipment.dumbbell},
    );

void main() {
  group('ageOn', () {
    test('aún no ha cumplido años este año', () {
      expect(sample().ageOn(DateTime(2026, 6, 19)), 26);
    });
    test('ya ha cumplido (el mismo día cuenta)', () {
      expect(sample().ageOn(DateTime(2026, 6, 20)), 27);
    });
  });

  group('isValid', () {
    test('un perfil bien formado es válido', () {
      expect(sample().isValid, isTrue);
    });
    test('daysPerWeek fuera de [1,7] es inválido', () {
      expect(sample(daysPerWeek: 0).isValid, isFalse);
      expect(sample(daysPerWeek: 8).isValid, isFalse);
    });
  });

  test('copyWith cambia solo lo indicado', () {
    final p = sample().copyWith(weightKg: 80);
    expect(p.weightKg, 80);
    expect(p.heightCm, 178);
    expect(p.goal, Goal.hypertrophy);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/models/user_profile_test.dart`
Expected: FAIL — `UserProfile` no existe.

- [ ] **Step 3: Write minimal implementation**

Crear `lib/core/models/user_profile.dart`:
```dart
import 'enums.dart';

/// Datos del usuario recogidos en el onboarding; alimentan al coach.
class UserProfile {
  final Sex sex;
  final DateTime birthDate;
  final double heightCm;
  final double weightKg;
  final Goal goal;
  final ExperienceLevel level;
  final int daysPerWeek;
  final int sessionMinutes;
  final Set<Equipment> equipment;
  final Set<String> limitations;

  const UserProfile({
    required this.sex,
    required this.birthDate,
    required this.heightCm,
    required this.weightKg,
    required this.goal,
    required this.level,
    required this.daysPerWeek,
    required this.sessionMinutes,
    this.equipment = const {Equipment.bodyweight},
    this.limitations = const {},
  });

  int ageOn(DateTime now) {
    var age = now.year - birthDate.year;
    final hadBirthday = now.month > birthDate.month ||
        (now.month == birthDate.month && now.day >= birthDate.day);
    if (!hadBirthday) age -= 1;
    return age;
  }

  bool get isValid =>
      heightCm > 0 &&
      weightKg > 0 &&
      daysPerWeek >= 1 &&
      daysPerWeek <= 7 &&
      sessionMinutes >= 10 &&
      equipment.isNotEmpty;

  UserProfile copyWith({
    Sex? sex,
    DateTime? birthDate,
    double? heightCm,
    double? weightKg,
    Goal? goal,
    ExperienceLevel? level,
    int? daysPerWeek,
    int? sessionMinutes,
    Set<Equipment>? equipment,
    Set<String>? limitations,
  }) {
    return UserProfile(
      sex: sex ?? this.sex,
      birthDate: birthDate ?? this.birthDate,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      goal: goal ?? this.goal,
      level: level ?? this.level,
      daysPerWeek: daysPerWeek ?? this.daysPerWeek,
      sessionMinutes: sessionMinutes ?? this.sessionMinutes,
      equipment: equipment ?? this.equipment,
      limitations: limitations ?? this.limitations,
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/core/models/user_profile_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/core/models/user_profile.dart test/core/models/user_profile_test.dart
git commit -m "feat(core): modelo UserProfile

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 3: Modelo `Exercise` + `fromDbRow`

**Files:**
- Create: `lib/core/models/exercise.dart`
- Test: `test/core/models/exercise_test.dart`

**Interfaces:**
- Consumes: `ForceType`, `Mechanic`, `Equipment`, `Modality`, `ExerciseDifficulty` de `enums.dart`.
- Produces: clase `Exercise` (campos: `String id`, `String name`, `String? category`, `ForceType? force`, `ExerciseDifficulty difficulty`, `Mechanic? mechanic`, `Equipment equipment`, `List<String> primaryMuscles`, `List<String> secondaryMuscles`, `List<String> instructions`, `List<String> staticImages`, `String? gifKey`, `Modality modality`, `String? variationGroup`, `int variationRank`) y `factory Exercise.fromDbRow(Map<String, Object?> row)`. La fila usa columnas snake_case y listas como **JSON text**.

- [ ] **Step 1: Write the failing test**

Crear `test/core/models/exercise_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/core/models/enums.dart';
import 'package:fragua/core/models/exercise.dart';

void main() {
  test('fromDbRow parsea una fila SQLite con listas en JSON', () {
    final row = <String, Object?>{
      'id': 'Barbell_Squat',
      'name': 'Barbell Squat',
      'category': 'strength',
      'force': 'push',
      'difficulty': 'intermediate',
      'mechanic': 'compound',
      'equipment': 'barbell',
      'primary_muscles': '["quadriceps"]',
      'secondary_muscles': '["glutes","hamstrings"]',
      'instructions': '["Baja","Sube"]',
      'static_images': '["Barbell_Squat/0.jpg"]',
      'gif_key': null,
      'modality': 'strength',
      'variation_group': null,
      'variation_rank': 0,
    };

    final ex = Exercise.fromDbRow(row);

    expect(ex.id, 'Barbell_Squat');
    expect(ex.force, ForceType.push);
    expect(ex.difficulty, ExerciseDifficulty.intermediate);
    expect(ex.mechanic, Mechanic.compound);
    expect(ex.equipment, Equipment.barbell);
    expect(ex.primaryMuscles, ['quadriceps']);
    expect(ex.secondaryMuscles, ['glutes', 'hamstrings']);
    expect(ex.instructions.length, 2);
    expect(ex.modality, Modality.strength);
    expect(ex.gifKey, isNull);
    expect(ex.variationRank, 0);
  });

  test('fromDbRow tolera force/mechanic nulos', () {
    final row = <String, Object?>{
      'id': 'Plank',
      'name': 'Plank',
      'category': 'strength',
      'force': null,
      'difficulty': 'beginner',
      'mechanic': null,
      'equipment': 'bodyweight',
      'primary_muscles': '["abdominals"]',
      'secondary_muscles': '[]',
      'instructions': '["Aguanta"]',
      'static_images': '[]',
      'gif_key': null,
      'modality': 'both',
      'variation_group': null,
      'variation_rank': 0,
    };
    final ex = Exercise.fromDbRow(row);
    expect(ex.force, isNull);
    expect(ex.mechanic, isNull);
    expect(ex.equipment, Equipment.bodyweight);
    expect(ex.secondaryMuscles, isEmpty);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/models/exercise_test.dart`
Expected: FAIL — `Exercise` no existe.

- [ ] **Step 3: Write minimal implementation**

Crear `lib/core/models/exercise.dart`:
```dart
import 'dart:convert';
import 'enums.dart';

/// Un ejercicio del catálogo (proveniente de la BD pre-construida).
class Exercise {
  final String id;
  final String name;
  final String? category;
  final ForceType? force;
  final ExerciseDifficulty difficulty;
  final Mechanic? mechanic;
  final Equipment equipment;
  final List<String> primaryMuscles;
  final List<String> secondaryMuscles;
  final List<String> instructions;
  final List<String> staticImages;
  final String? gifKey;
  final Modality modality;
  final String? variationGroup;
  final int variationRank;

  const Exercise({
    required this.id,
    required this.name,
    required this.category,
    required this.force,
    required this.difficulty,
    required this.mechanic,
    required this.equipment,
    required this.primaryMuscles,
    required this.secondaryMuscles,
    required this.instructions,
    required this.staticImages,
    required this.gifKey,
    required this.modality,
    required this.variationGroup,
    required this.variationRank,
  });

  factory Exercise.fromDbRow(Map<String, Object?> row) {
    List<String> jsonList(Object? v) =>
        (jsonDecode(v as String? ?? '[]') as List).cast<String>();

    return Exercise(
      id: row['id'] as String,
      name: row['name'] as String,
      category: row['category'] as String?,
      force: _forceFrom(row['force'] as String?),
      difficulty: ExerciseDifficulty.values.byName(row['difficulty'] as String),
      mechanic: _mechanicFrom(row['mechanic'] as String?),
      equipment: Equipment.values.byName(row['equipment'] as String),
      primaryMuscles: jsonList(row['primary_muscles']),
      secondaryMuscles: jsonList(row['secondary_muscles']),
      instructions: jsonList(row['instructions']),
      staticImages: jsonList(row['static_images']),
      gifKey: row['gif_key'] as String?,
      modality: Modality.values.byName(row['modality'] as String),
      variationGroup: row['variation_group'] as String?,
      variationRank: (row['variation_rank'] as int?) ?? 0,
    );
  }

  static ForceType? _forceFrom(String? raw) {
    switch (raw) {
      case 'push':
        return ForceType.push;
      case 'pull':
        return ForceType.pull;
      case 'static':
        return ForceType.staticHold;
      default:
        return null;
    }
  }

  static Mechanic? _mechanicFrom(String? raw) {
    switch (raw) {
      case 'compound':
        return Mechanic.compound;
      case 'isolation':
        return Mechanic.isolation;
      default:
        return null;
    }
  }
}
```

Nota: el script Python (Task 5) normaliza `equipment` y `modality` a **nombres de enum** (`bodyweight`, `barbell`, `strength`, `both`…), por eso los fixtures de los tests usan esos valores ya normalizados y `Equipment.values.byName(...)`/`Modality.values.byName(...)` resuelven sin error.

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/core/models/exercise_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/core/models/exercise.dart test/core/models/exercise_test.dart
git commit -m "feat(core): modelo Exercise con fromDbRow

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 4: Tabla drift `Exercises` + base de datos

**Files:**
- Create: `lib/core/db/database.dart`
- Create (generado): `lib/core/db/database.g.dart` (vía build_runner)
- Test: `test/core/db/database_test.dart`

**Interfaces:**
- Consumes: nada del dominio (drift autónomo).
- Produces: clase drift `FraguaDatabase(QueryExecutor e)` con tabla `Exercises`; columnas nombradas en snake_case idénticas a las de `Exercise.fromDbRow` (`id`, `name`, `category`, `force`, `difficulty`, `mechanic`, `equipment`, `primary_muscles`, `secondary_muscles`, `instructions`, `static_images`, `gif_key`, `modality`, `variation_group`, `variation_rank`). `schemaVersion == 1`.

- [ ] **Step 1: Write the failing test**

Crear `test/core/db/database_test.dart`:
```dart
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/core/db/database.dart';

void main() {
  test('inserta y lee una fila de Exercises en memoria', () async {
    final db = FraguaDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await db.into(db.exercises).insert(ExercisesCompanion.insert(
          id: 'Plank',
          name: 'Plank',
          difficulty: 'beginner',
          equipment: 'bodyweight',
          primaryMuscles: '["abdominals"]',
          secondaryMuscles: '[]',
          instructions: '["Aguanta"]',
          staticImages: '[]',
          modality: 'both',
        ));

    final rows = await db.select(db.exercises).get();
    expect(rows, hasLength(1));
    expect(rows.single.id, 'Plank');
    expect(rows.single.variationRank, 0); // default
  });
}
```

- [ ] **Step 2: Write the drift schema**

Crear `lib/core/db/database.dart`:
```dart
import 'package:drift/drift.dart';

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

@DriftDatabase(tables: [Exercises])
class FraguaDatabase extends _$FraguaDatabase {
  FraguaDatabase(super.e);

  @override
  int get schemaVersion => 1;
}
```

- [ ] **Step 3: Run codegen**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: genera `lib/core/db/database.g.dart` sin errores.

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/core/db/database_test.dart`
Expected: PASS.
Si falla con un error tipo "Failed to load dynamic library 'libsqlite3.so'", instala la lib nativa en el host Kali: `sudo apt-get install -y libsqlite3-0` y reintenta. (En el dispositivo Android la aporta `sqlite3_flutter_libs`.)

- [ ] **Step 5: Commit**

```bash
git add lib/core/db/database.dart lib/core/db/database.g.dart test/core/db/database_test.dart
git commit -m "feat(core): esquema drift Exercises

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 5: Build script Python — normalización (TDD)

**Files:**
- Create: `tools/requirements.txt`
- Create: `tools/build_exercise_db.py`
- Create: `tools/fixtures/sample_exercises.json`
- Test: `tools/test_build_exercise_db.py`

**Interfaces:**
- Consumes: registros con el shape de free-exercise-db (`id, name, force, level, mechanic, equipment, primaryMuscles, secondaryMuscles, instructions, category, images`).
- Produces: `map_equipment(raw: str | None) -> str` (devuelve el **nombre del enum** Dart: `bodyweight`/`dumbbell`/…), `infer_modality(equipment: str) -> str` (`strength`/`guided`/`both`), `normalize_exercise(raw: dict) -> dict` (fila con las 15 columnas snake_case del esquema drift).

- [ ] **Step 1: Crea el fixture**

Crear `tools/fixtures/sample_exercises.json`:
```json
[
  {
    "id": "Barbell_Squat",
    "name": "Barbell Squat",
    "force": "push",
    "level": "intermediate",
    "mechanic": "compound",
    "equipment": "barbell",
    "primaryMuscles": ["quadriceps"],
    "secondaryMuscles": ["glutes", "hamstrings"],
    "instructions": ["Baja controlando", "Sube con fuerza"],
    "category": "strength",
    "images": ["Barbell_Squat/0.jpg", "Barbell_Squat/1.jpg"]
  },
  {
    "id": "Plank",
    "name": "Plank",
    "force": "static",
    "level": "beginner",
    "mechanic": null,
    "equipment": "body only",
    "primaryMuscles": ["abdominals"],
    "secondaryMuscles": [],
    "instructions": ["Aguanta la posición"],
    "category": "strength",
    "images": []
  },
  {
    "id": "Jump_Rope",
    "name": "Jump Rope",
    "force": null,
    "level": "beginner",
    "mechanic": null,
    "equipment": "other",
    "primaryMuscles": ["calves"],
    "secondaryMuscles": [],
    "instructions": ["Salta"],
    "category": "cardio",
    "images": []
  }
]
```

- [ ] **Step 2: Write the failing test**

Crear `tools/test_build_exercise_db.py`:
```python
import json
from pathlib import Path

import build_exercise_db as b

FIXTURE = Path(__file__).parent / "fixtures" / "sample_exercises.json"


def test_map_equipment():
    assert b.map_equipment("body only") == "bodyweight"
    assert b.map_equipment(None) == "bodyweight"
    assert b.map_equipment("barbell") == "barbell"
    assert b.map_equipment("e-z curl bar") == "barbell"
    assert b.map_equipment("kettlebells") == "kettlebell"
    assert b.map_equipment("medicine ball") == "other"


def test_infer_modality():
    assert b.infer_modality("barbell") == "strength"
    assert b.infer_modality("dumbbell") == "strength"
    assert b.infer_modality("bodyweight") == "both"
    assert b.infer_modality("bands") == "both"


def test_normalize_exercise_shape():
    raw = json.loads(FIXTURE.read_text())[0]  # Barbell_Squat
    row = b.normalize_exercise(raw)
    assert row["id"] == "Barbell_Squat"
    assert row["equipment"] == "barbell"
    assert row["modality"] == "strength"
    assert row["difficulty"] == "intermediate"
    assert json.loads(row["primary_muscles"]) == ["quadriceps"]
    assert json.loads(row["static_images"]) == [
        "Barbell_Squat/0.jpg",
        "Barbell_Squat/1.jpg",
    ]
    assert row["gif_key"] is None
    assert row["variation_rank"] == 0
    # 15 columnas exactas del esquema drift
    assert set(row.keys()) == {
        "id", "name", "category", "force", "difficulty", "mechanic",
        "equipment", "primary_muscles", "secondary_muscles", "instructions",
        "static_images", "gif_key", "modality", "variation_group",
        "variation_rank",
    }


def test_normalize_handles_nulls():
    raw = json.loads(FIXTURE.read_text())[1]  # Plank
    row = b.normalize_exercise(raw)
    assert row["mechanic"] is None
    assert row["equipment"] == "bodyweight"
    assert row["modality"] == "both"
    assert json.loads(row["secondary_muscles"]) == []
```

- [ ] **Step 3: Run test to verify it fails**

Run: `cd tools && python -m pytest test_build_exercise_db.py -v`
Expected: FAIL — `build_exercise_db` no existe.

- [ ] **Step 4: Write minimal implementation**

Crear `tools/requirements.txt`:
```
requests
```
Crear `tools/build_exercise_db.py`:
```python
"""Construye assets/exercise_db.sqlite a partir de free-exercise-db.

Uso: python build_exercise_db.py [--out ../assets/exercise_db.sqlite]
"""
import argparse
import json
import sqlite3
from pathlib import Path

DATA_URL = "https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/dist/exercises.json"

_EQUIPMENT_MAP = {
    None: "bodyweight",
    "": "bodyweight",
    "body only": "bodyweight",
    "dumbbell": "dumbbell",
    "barbell": "barbell",
    "e-z curl bar": "barbell",
    "machine": "machine",
    "cable": "cable",
    "kettlebells": "kettlebell",
    "bands": "bands",
}

# Equipo cargado => trabajo de fuerza; peso corporal/bandas => sirve para ambas.
_STRENGTH_EQUIPMENT = {"dumbbell", "barbell", "machine", "cable", "kettlebell"}

COLUMNS = [
    "id", "name", "category", "force", "difficulty", "mechanic", "equipment",
    "primary_muscles", "secondary_muscles", "instructions", "static_images",
    "gif_key", "modality", "variation_group", "variation_rank",
]


def map_equipment(raw):
    if raw is not None:
        raw = raw.lower().strip()
    return _EQUIPMENT_MAP.get(raw, "other")


def infer_modality(equipment):
    return "strength" if equipment in _STRENGTH_EQUIPMENT else "both"


def normalize_exercise(raw):
    equipment = map_equipment(raw.get("equipment"))
    return {
        "id": raw["id"],
        "name": raw["name"],
        "category": raw.get("category"),
        "force": raw.get("force"),
        "difficulty": raw.get("level") or "beginner",
        "mechanic": raw.get("mechanic"),
        "equipment": equipment,
        "primary_muscles": json.dumps(raw.get("primaryMuscles", [])),
        "secondary_muscles": json.dumps(raw.get("secondaryMuscles", [])),
        "instructions": json.dumps(raw.get("instructions", [])),
        "static_images": json.dumps(raw.get("images", [])),
        "gif_key": None,
        "modality": infer_modality(equipment),
        "variation_group": None,
        "variation_rank": 0,
    }


def build_db(rows, out_path):
    out = Path(out_path)
    out.parent.mkdir(parents=True, exist_ok=True)
    if out.exists():
        out.unlink()
    con = sqlite3.connect(out)
    try:
        con.execute(
            """
            CREATE TABLE exercises (
              id TEXT PRIMARY KEY,
              name TEXT NOT NULL,
              category TEXT,
              force TEXT,
              difficulty TEXT NOT NULL,
              mechanic TEXT,
              equipment TEXT NOT NULL,
              primary_muscles TEXT NOT NULL,
              secondary_muscles TEXT NOT NULL,
              instructions TEXT NOT NULL,
              static_images TEXT NOT NULL,
              gif_key TEXT,
              modality TEXT NOT NULL,
              variation_group TEXT,
              variation_rank INTEGER NOT NULL DEFAULT 0
            )
            """
        )
        placeholders = ", ".join(["?"] * len(COLUMNS))
        con.executemany(
            f"INSERT INTO exercises ({', '.join(COLUMNS)}) VALUES ({placeholders})",
            [tuple(r[c] for c in COLUMNS) for r in rows],
        )
        con.commit()
    finally:
        con.close()
    return out


def _load_remote():
    import requests
    resp = requests.get(DATA_URL, timeout=60)
    resp.raise_for_status()
    return resp.json()


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", default=str(Path(__file__).parent.parent / "assets" / "exercise_db.sqlite"))
    args = ap.parse_args()
    raw = _load_remote()
    rows = [normalize_exercise(r) for r in raw]
    out = build_db(rows, args.out)
    print(f"Escritos {len(rows)} ejercicios en {out}")


if __name__ == "__main__":
    main()
```

- [ ] **Step 5: Run test to verify it passes**

Run: `cd tools && python -m pytest test_build_exercise_db.py -v`
Expected: PASS (4 tests verdes).

- [ ] **Step 6: Commit**

```bash
git add tools/requirements.txt tools/build_exercise_db.py tools/fixtures/sample_exercises.json tools/test_build_exercise_db.py
git commit -m "feat(tools): normalizacion de free-exercise-db (TDD)

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 6: Ensamblado del SQLite + generación del asset real

**Files:**
- Modify: `tools/test_build_exercise_db.py` (añade test de `build_db`)
- Create (generado, commit del asset): `assets/exercise_db.sqlite`

**Interfaces:**
- Consumes: `build_db(rows, out_path)` y `normalize_exercise` de Task 5.
- Produces: `assets/exercise_db.sqlite` poblado (~800 filas) listo para bundlear.

- [ ] **Step 1: Write the failing test (build_db en archivo temporal)**

Añadir a `tools/test_build_exercise_db.py`:
```python
import sqlite3


def test_build_db_creates_queryable_file(tmp_path):
    raws = json.loads(FIXTURE.read_text())
    rows = [b.normalize_exercise(r) for r in raws]
    out = b.build_db(rows, tmp_path / "exercise_db.sqlite")

    con = sqlite3.connect(out)
    try:
        count = con.execute("SELECT COUNT(*) FROM exercises").fetchone()[0]
        names = {r[0] for r in con.execute("SELECT name FROM exercises")}
        cols = [c[1] for c in con.execute("PRAGMA table_info(exercises)")]
    finally:
        con.close()

    assert count == 3
    assert "Barbell Squat" in names
    assert cols == b.COLUMNS  # mismo orden y nombres que el esquema drift
```

- [ ] **Step 2: Run test to verify it fails (o pasa si build_db ya está)**

Run: `cd tools && python -m pytest test_build_exercise_db.py::test_build_db_creates_queryable_file -v`
Expected: PASS (build_db ya existe de Task 5; este test bloquea regresiones de esquema). Si falla por orden de columnas, ajustar `COLUMNS`/PRAGMA.

- [ ] **Step 3: Genera el asset real desde free-exercise-db**

Run:
```bash
cd tools && python -m pip install -r requirements.txt && python build_exercise_db.py
```
Expected: imprime `Escritos <N> ejercicios en .../assets/exercise_db.sqlite` con N en torno a 800. Reemplaza el placeholder `assets/.gitkeep` si procede.
Verificación manual:
```bash
sqlite3 ../assets/exercise_db.sqlite "SELECT COUNT(*), COUNT(DISTINCT modality) FROM exercises;"
```
Expected: count ~800 y 2 modalidades distintas (`strength`, `both`).

- [ ] **Step 4: Run full test suites**

Run: `cd tools && python -m pytest -v` → todos verdes.
Run: `flutter test` → todos los tests Dart verdes.
Run: `flutter analyze` → sin errores.

- [ ] **Step 5: Commit (incluye el asset)**

```bash
git add tools/test_build_exercise_db.py assets/exercise_db.sqlite
git rm --cached assets/.gitkeep 2>/dev/null || true
git commit -m "feat(tools): genera assets/exercise_db.sqlite desde free-exercise-db

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

## Verificación de M0 (Definition of Done)

- `flutter analyze` limpio.
- `flutter test` verde (enums, UserProfile, Exercise, drift en memoria).
- `cd tools && python -m pytest` verde.
- `assets/exercise_db.sqlite` existe, ~800 ejercicios, esquema idéntico a la tabla drift `Exercises`.
- App arranca (`flutter run`) mostrando la pantalla placeholder.
- Todo commiteado (push a `Albertoac99/Fragua` solo con OK de Alberto).

## Cobertura de la spec (self-review)

- §4 stack (Flutter, drift) → Tasks 1, 4. §5.1 free-exercise-db → Tasks 5, 6. §6 estructura `core/` sin Flutter → Tasks 1-4 (constraint global). §7.1 `UserProfile` → Task 2. §8 modelo de datos (tabla exercise + campos modalidad/variantes) → Tasks 3, 4, 5. §13 testing core puro → todas.
- **Fuera de M0 (milestones siguientes):** persistencia de `UserProfile`, apertura del SQLite bundleado en runtime, coach, progresión, sesiones, ligas, voz, animaciones, seguimiento, notificaciones, workflow APK. Cada uno con su propio plan.
