# Fragua M2 — Coach (generación de plan): Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Un coach por reglas que, a partir del `UserProfile` y el catálogo de ejercicios, genera un `Plan` semanal (días de fuerza + guiados), lo persiste y lo muestra en una pantalla de plan.

**Architecture:** Toda la lógica del coach es **Dart puro** en `lib/core/coach/` (determinista, testeable sin Flutter). El catálogo se carga del drift DB como modelos de dominio `Exercise`. El `Plan` generado se persiste **como JSON** en una tabla `plans` de fila única (`id=0`) — desviación justificada del modelo relacional del §8: el `Plan` es un objeto-valor generado; M3 lo lee entero para ejecutar sesiones; no necesitamos consultas por ejercicio-de-plan. La UI lee el plan vía Riverpod.

**Tech Stack:** Dart puro (coach) · drift · flutter_riverpod · flutter_test.

## Global Constraints

- `lib/core/**` NUNCA importa Flutter (Dart puro; drift sí está permitido — no es Flutter).
- El coach es **determinista**: misma entrada ⇒ mismo plan (orden estable por id). Imprescindible para tests.
- Columnas SQLite snake_case con `.named(...)`.
- Commits frecuentes, uno por tarea. Mensajes terminan con `Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>`.

---

## File Structure

- `lib/core/models/plan.dart` — (crear) `Plan`, `PlanDay`, `PlanExercise` + enums `SplitType`/`DayType`/`WorkoutFormat` + `toJson`/`fromJson`.
- `lib/core/coach/rules.dart` — (crear) `guidedDaysFor`, `splitFor`, `repSchemeFor`, `RepScheme`, plantillas de día (`muscleGroups`, `strengthDayTemplates`).
- `lib/core/coach/exercise_selection.dart` — (crear) `selectExercise(...)`.
- `lib/core/coach/coach.dart` — (crear) `Coach.generate(profile, catalog) -> Plan`.
- `lib/core/db/database.dart` — (modificar) `loadExercises()` + tabla `Plans` + `savePlan`/`loadPlan`.
- `lib/app/providers.dart` — (modificar) `catalogProvider`, `planProvider`/lógica de generación.
- `lib/features/plan/plan_screen.dart` — (crear) muestra el plan.
- Tests: `test/core/coach/rules_test.dart`, `exercise_selection_test.dart`, `coach_test.dart`, `test/core/models/plan_json_test.dart`, `test/core/db/plan_persistence_test.dart`, `test/features/plan_screen_test.dart`.

---

### Task 1: Modelos del plan + JSON

**Files:**
- Create: `lib/core/models/plan.dart`
- Test: `test/core/models/plan_json_test.dart`

**Interfaces:**
- Produces: enums `SplitType {fullBody, upperLower, pushPullLegs}`, `DayType {strength, guided}`, `WorkoutFormat {straightSets, circuit}`; clases `PlanExercise`, `PlanDay`, `Plan`; cada una con `Map<String,Object?> toJson()` y `factory .fromJson(Map)`.

- [ ] **Step 1: Write the failing test**

Crear `test/core/models/plan_json_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/core/models/plan.dart';

void main() {
  test('Plan round-trips a JSON y vuelve', () {
    const plan = Plan(
      split: SplitType.pushPullLegs,
      days: [
        PlanDay(
          name: 'Push',
          type: DayType.strength,
          format: WorkoutFormat.straightSets,
          rounds: 1,
          exercises: [
            PlanExercise(
              exerciseId: 'Barbell_Bench_Press',
              exerciseName: 'Barbell Bench Press',
              sets: 4,
              repLow: 6,
              repHigh: 12,
              restSeconds: 90,
            ),
          ],
        ),
      ],
    );

    final restored = Plan.fromJson(plan.toJson());
    expect(restored.split, SplitType.pushPullLegs);
    expect(restored.days, hasLength(1));
    expect(restored.days.first.name, 'Push');
    expect(restored.days.first.type, DayType.strength);
    expect(restored.days.first.exercises.first.exerciseId, 'Barbell_Bench_Press');
    expect(restored.days.first.exercises.first.repHigh, 12);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/models/plan_json_test.dart`
Expected: FAIL — `Plan` no existe.

- [ ] **Step 3: Implement the models**

Crear `lib/core/models/plan.dart`:
```dart
enum SplitType { fullBody, upperLower, pushPullLegs }

enum DayType { strength, guided }

enum WorkoutFormat { straightSets, circuit }

class PlanExercise {
  final String exerciseId;
  final String exerciseName;
  final int sets;
  final int repLow;
  final int repHigh;
  final int restSeconds;

  const PlanExercise({
    required this.exerciseId,
    required this.exerciseName,
    required this.sets,
    required this.repLow,
    required this.repHigh,
    required this.restSeconds,
  });

  Map<String, Object?> toJson() => {
        'exerciseId': exerciseId,
        'exerciseName': exerciseName,
        'sets': sets,
        'repLow': repLow,
        'repHigh': repHigh,
        'restSeconds': restSeconds,
      };

  factory PlanExercise.fromJson(Map<String, Object?> j) => PlanExercise(
        exerciseId: j['exerciseId'] as String,
        exerciseName: j['exerciseName'] as String,
        sets: j['sets'] as int,
        repLow: j['repLow'] as int,
        repHigh: j['repHigh'] as int,
        restSeconds: j['restSeconds'] as int,
      );
}

class PlanDay {
  final String name;
  final DayType type;
  final WorkoutFormat format;
  final int rounds;
  final List<PlanExercise> exercises;

  const PlanDay({
    required this.name,
    required this.type,
    required this.format,
    required this.rounds,
    required this.exercises,
  });

  Map<String, Object?> toJson() => {
        'name': name,
        'type': type.name,
        'format': format.name,
        'rounds': rounds,
        'exercises': exercises.map((e) => e.toJson()).toList(),
      };

  factory PlanDay.fromJson(Map<String, Object?> j) => PlanDay(
        name: j['name'] as String,
        type: DayType.values.byName(j['type'] as String),
        format: WorkoutFormat.values.byName(j['format'] as String),
        rounds: j['rounds'] as int,
        exercises: (j['exercises'] as List)
            .map((e) => PlanExercise.fromJson((e as Map).cast<String, Object?>()))
            .toList(),
      );
}

class Plan {
  final SplitType split;
  final List<PlanDay> days;

  const Plan({required this.split, required this.days});

  Map<String, Object?> toJson() => {
        'split': split.name,
        'days': days.map((d) => d.toJson()).toList(),
      };

  factory Plan.fromJson(Map<String, Object?> j) => Plan(
        split: SplitType.values.byName(j['split'] as String),
        days: (j['days'] as List)
            .map((d) => PlanDay.fromJson((d as Map).cast<String, Object?>()))
            .toList(),
      );
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/core/models/plan_json_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/core/models/plan.dart test/core/models/plan_json_test.dart
git commit -m "feat(core): modelos del plan (Plan/PlanDay/PlanExercise) + JSON

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 2: Reglas del coach (modalidad, split, esquema de reps)

**Files:**
- Create: `lib/core/coach/rules.dart`
- Test: `test/core/coach/rules_test.dart`

**Interfaces:**
- Consumes: `Goal`, `ExperienceLevel`, `SplitType`.
- Produces: `int guidedDaysFor(Goal, int daysPerWeek, bool onlyBodyweight)`; `SplitType splitFor(int strengthDays)`; `class RepScheme {int sets, repLow, repHigh, restSeconds}`; `RepScheme repSchemeFor(Goal, ExperienceLevel)`; `const Map<String, List<String>> muscleGroups`; `List<({String name, List<String> groups})> strengthDayTemplates(SplitType, int strengthDays)`.

- [ ] **Step 1: Write the failing test**

Crear `test/core/coach/rules_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/core/coach/rules.dart';
import 'package:fragua/core/models/enums.dart';
import 'package:fragua/core/models/plan.dart';

void main() {
  group('guidedDaysFor', () {
    test('fuerza/hipertrofia con cargas => 0 guiados', () {
      expect(guidedDaysFor(Goal.strength, 4, false), 0);
      expect(guidedDaysFor(Goal.hypertrophy, 5, false), 0);
    });
    test('solo peso corporal => todo guiado', () {
      expect(guidedDaysFor(Goal.strength, 4, true), 4);
    });
    test('pérdida de grasa => 1-2 guiados', () {
      expect(guidedDaysFor(Goal.fatLoss, 3, false), 1);
      expect(guidedDaysFor(Goal.fatLoss, 5, false), 2);
    });
  });

  group('splitFor', () {
    test('mapea días de fuerza a split', () {
      expect(splitFor(2), SplitType.fullBody);
      expect(splitFor(3), SplitType.fullBody);
      expect(splitFor(4), SplitType.upperLower);
      expect(splitFor(6), SplitType.pushPullLegs);
    });
  });

  group('repSchemeFor', () {
    test('fuerza => pocas reps, descanso largo', () {
      final s = repSchemeFor(Goal.strength, ExperienceLevel.intermediate);
      expect(s.repLow, 3);
      expect(s.repHigh, 6);
      expect(s.restSeconds, greaterThanOrEqualTo(150));
    });
    test('hipertrofia => rango medio', () {
      final s = repSchemeFor(Goal.hypertrophy, ExperienceLevel.beginner);
      expect(s.repLow, 6);
      expect(s.repHigh, 12);
      expect(s.sets, 3); // principiante
    });
  });

  test('strengthDayTemplates: PPL da 3 días con grupos coherentes', () {
    final t = strengthDayTemplates(SplitType.pushPullLegs, 6);
    expect(t.map((d) => d.name), containsAll(['Push', 'Pull', 'Piernas']));
    expect(t.firstWhere((d) => d.name == 'Push').groups, contains('chest'));
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/coach/rules_test.dart`
Expected: FAIL — `rules.dart` no existe.

- [ ] **Step 3: Implement the rules**

Crear `lib/core/coach/rules.dart`:
```dart
import '../models/enums.dart';
import '../models/plan.dart';

/// Nº de días guiados (circuitos/HIIT) según objetivo y equipo.
int guidedDaysFor(Goal goal, int daysPerWeek, bool onlyBodyweight) {
  if (onlyBodyweight) return daysPerWeek; // sin cargas => calistenia/circuitos
  switch (goal) {
    case Goal.fatLoss:
      return daysPerWeek >= 4 ? 2 : 1;
    case Goal.endurance:
      return (daysPerWeek / 2).ceil();
    case Goal.generalFitness:
      return daysPerWeek >= 3 ? 1 : 0;
    case Goal.strength:
    case Goal.hypertrophy:
      return 0;
  }
}

SplitType splitFor(int strengthDays) {
  if (strengthDays <= 3) return SplitType.fullBody;
  if (strengthDays == 4) return SplitType.upperLower;
  return SplitType.pushPullLegs;
}

class RepScheme {
  final int sets;
  final int repLow;
  final int repHigh;
  final int restSeconds;
  const RepScheme({
    required this.sets,
    required this.repLow,
    required this.repHigh,
    required this.restSeconds,
  });
}

RepScheme repSchemeFor(Goal goal, ExperienceLevel level) {
  final sets = level == ExperienceLevel.beginner ? 3 : 4;
  switch (goal) {
    case Goal.strength:
      return RepScheme(sets: sets, repLow: 3, repHigh: 6, restSeconds: 180);
    case Goal.hypertrophy:
      return RepScheme(sets: sets, repLow: 6, repHigh: 12, restSeconds: 90);
    case Goal.endurance:
      return RepScheme(sets: sets, repLow: 12, repHigh: 20, restSeconds: 45);
    case Goal.fatLoss:
      return RepScheme(sets: sets, repLow: 8, repHigh: 15, restSeconds: 60);
    case Goal.generalFitness:
      return RepScheme(sets: sets, repLow: 8, repHigh: 12, restSeconds: 75);
  }
}

/// Etiqueta de grupo -> músculos de free-exercise-db que la componen.
const Map<String, List<String>> muscleGroups = {
  'chest': ['chest'],
  'back': ['lats', 'middle back', 'lower back', 'traps'],
  'shoulders': ['shoulders'],
  'biceps': ['biceps'],
  'triceps': ['triceps'],
  'quadriceps': ['quadriceps'],
  'hamstrings': ['hamstrings'],
  'glutes': ['glutes'],
  'calves': ['calves'],
  'abdominals': ['abdominals'],
};

typedef DayTemplate = ({String name, List<String> groups});

/// Plantillas de días de FUERZA según el split.
List<DayTemplate> strengthDayTemplates(SplitType split, int strengthDays) {
  switch (split) {
    case SplitType.fullBody:
      const groups = [
        'quadriceps',
        'chest',
        'back',
        'shoulders',
        'hamstrings'
      ];
      return List.generate(
        strengthDays,
        (i) => (name: 'Full Body ${i + 1}', groups: groups),
      );
    case SplitType.upperLower:
      return [
        (name: 'Tren superior', groups: ['chest', 'back', 'shoulders', 'biceps', 'triceps']),
        (name: 'Tren inferior', groups: ['quadriceps', 'hamstrings', 'glutes', 'calves']),
        (name: 'Tren superior 2', groups: ['back', 'chest', 'shoulders', 'triceps', 'biceps']),
        (name: 'Tren inferior 2', groups: ['quadriceps', 'glutes', 'hamstrings', 'calves']),
      ].take(strengthDays).toList();
    case SplitType.pushPullLegs:
      final base = <DayTemplate>[
        (name: 'Push', groups: ['chest', 'shoulders', 'triceps']),
        (name: 'Pull', groups: ['back', 'biceps']),
        (name: 'Piernas', groups: ['quadriceps', 'hamstrings', 'glutes', 'calves']),
      ];
      return List.generate(strengthDays, (i) => base[i % base.length]);
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/core/coach/rules_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/core/coach/rules.dart test/core/coach/rules_test.dart
git commit -m "feat(coach): reglas de modalidad, split y esquema de reps

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 3: Selección de ejercicios + carga del catálogo

**Files:**
- Create: `lib/core/coach/exercise_selection.dart`
- Modify: `lib/core/db/database.dart` (añade `loadExercises()`)
- Test: `test/core/coach/exercise_selection_test.dart`

**Interfaces:**
- Consumes: `Exercise`, `Equipment`, `Mechanic`.
- Produces: `Exercise? selectExercise({required List<Exercise> catalog, required List<String> targetMuscles, required Set<Equipment> available, required Set<String> avoidMuscles, required Set<String> excludeIds})` (prioriza compuestos, determinista por id); `Future<List<Exercise>> FraguaDatabase.loadExercises()`.

- [ ] **Step 1: Write the failing test**

Crear `test/core/coach/exercise_selection_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/core/coach/exercise_selection.dart';
import 'package:fragua/core/models/enums.dart';
import 'package:fragua/core/models/exercise.dart';

Exercise ex(String id, Equipment eq, List<String> primary, Mechanic? mech) =>
    Exercise(
      id: id,
      name: id,
      category: 'strength',
      force: null,
      difficulty: ExerciseDifficulty.beginner,
      mechanic: mech,
      equipment: eq,
      primaryMuscles: primary,
      secondaryMuscles: const [],
      instructions: const [],
      staticImages: const [],
      gifKey: null,
      modality: Modality.both,
      variationGroup: null,
      variationRank: 0,
    );

void main() {
  final catalog = [
    ex('press_banca', Equipment.barbell, ['chest'], Mechanic.compound),
    ex('aperturas', Equipment.dumbbell, ['chest'], Mechanic.isolation),
    ex('flexiones', Equipment.bodyweight, ['chest'], Mechanic.compound),
  ];

  test('prioriza compuesto y respeta el equipo disponible', () {
    final pick = selectExercise(
      catalog: catalog,
      targetMuscles: ['chest'],
      available: {Equipment.dumbbell}, // no hay barra
      avoidMuscles: {},
      excludeIds: {},
    );
    // bodyweight siempre disponible; press_banca (barra) excluido =>
    // gana flexiones (compuesto) sobre aperturas (aislamiento).
    expect(pick!.id, 'flexiones');
  });

  test('excluye ya usados y músculos a evitar', () {
    expect(
      selectExercise(
        catalog: catalog,
        targetMuscles: ['chest'],
        available: {Equipment.barbell, Equipment.dumbbell},
        avoidMuscles: {},
        excludeIds: {'press_banca', 'flexiones'},
      )!.id,
      'aperturas',
    );
    expect(
      selectExercise(
        catalog: catalog,
        targetMuscles: ['chest'],
        available: {Equipment.barbell},
        avoidMuscles: {'chest'},
        excludeIds: {},
      ),
      isNull,
    );
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/coach/exercise_selection_test.dart`
Expected: FAIL — `selectExercise` no existe.

- [ ] **Step 3: Implement selection**

Crear `lib/core/coach/exercise_selection.dart`:
```dart
import '../models/enums.dart';
import '../models/exercise.dart';

/// Elige el mejor ejercicio para los músculos objetivo, respetando equipo,
/// lesiones y exclusiones. Prioriza compuestos; determinista por id.
Exercise? selectExercise({
  required List<Exercise> catalog,
  required List<String> targetMuscles,
  required Set<Equipment> available,
  required Set<String> avoidMuscles,
  required Set<String> excludeIds,
}) {
  bool doable(Exercise e) =>
      e.equipment == Equipment.bodyweight || available.contains(e.equipment);

  final candidates = catalog.where((e) {
    if (excludeIds.contains(e.id)) return false;
    if (!e.primaryMuscles.any(targetMuscles.contains)) return false;
    if (e.primaryMuscles.any(avoidMuscles.contains)) return false;
    return doable(e);
  }).toList()
    ..sort((a, b) {
      final ac = a.mechanic == Mechanic.compound ? 0 : 1;
      final bc = b.mechanic == Mechanic.compound ? 0 : 1;
      if (ac != bc) return ac - bc;
      return a.id.compareTo(b.id);
    });

  return candidates.isEmpty ? null : candidates.first;
}
```

- [ ] **Step 4: Add `loadExercises()` to the database**

En `lib/core/db/database.dart`, añade el import del modelo y el método dentro de `FraguaDatabase` (debajo de `loadProfile`):
```dart
// (añadir arriba, junto a los otros imports)
import '../models/exercise.dart';
```
```dart
  Future<List<Exercise>> loadExercises() async {
    final rows = await select(exercises).get();
    return rows
        .map((r) => Exercise.fromDbRow({
              'id': r.id,
              'name': r.name,
              'category': r.category,
              'force': r.force,
              'difficulty': r.difficulty,
              'mechanic': r.mechanic,
              'equipment': r.equipment,
              'primary_muscles': r.primaryMuscles,
              'secondary_muscles': r.secondaryMuscles,
              'instructions': r.instructions,
              'static_images': r.staticImages,
              'gif_key': r.gifKey,
              'modality': r.modality,
              'variation_group': r.variationGroup,
              'variation_rank': r.variationRank,
            }))
        .toList();
  }
```

- [ ] **Step 5: Run tests to verify they pass**

Run: `flutter test test/core/coach/exercise_selection_test.dart test/core/db/`
Expected: PASS (selección + BD sin regresiones).

- [ ] **Step 6: Commit**

```bash
git add lib/core/coach/exercise_selection.dart lib/core/db/database.dart test/core/coach/exercise_selection_test.dart
git commit -m "feat(coach): seleccion de ejercicios + loadExercises del catalogo

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 4: `Coach.generate`

**Files:**
- Create: `lib/core/coach/coach.dart`
- Test: `test/core/coach/coach_test.dart`

**Interfaces:**
- Consumes: `UserProfile`, `Exercise`, `rules.dart`, `exercise_selection.dart`, modelos del plan.
- Produces: `class Coach { Plan generate(UserProfile profile, List<Exercise> catalog) }`.

- [ ] **Step 1: Write the failing test**

Crear `test/core/coach/coach_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/core/coach/coach.dart';
import 'package:fragua/core/models/enums.dart';
import 'package:fragua/core/models/exercise.dart';
import 'package:fragua/core/models/plan.dart';
import 'package:fragua/core/models/user_profile.dart';

Exercise ex(String id, Equipment eq, List<String> primary) => Exercise(
      id: id,
      name: id,
      category: 'strength',
      force: null,
      difficulty: ExerciseDifficulty.beginner,
      mechanic: Mechanic.compound,
      equipment: eq,
      primaryMuscles: primary,
      secondaryMuscles: const [],
      instructions: const [],
      staticImages: const [],
      gifKey: null,
      modality: Modality.both,
      variationGroup: null,
      variationRank: 0,
    );

// Catálogo mínimo que cubre todos los grupos usados por las plantillas.
List<Exercise> catalog() => [
      ex('squat', Equipment.barbell, ['quadriceps']),
      ex('bench', Equipment.barbell, ['chest']),
      ex('row', Equipment.barbell, ['lats']),
      ex('ohp', Equipment.barbell, ['shoulders']),
      ex('rdl', Equipment.barbell, ['hamstrings']),
      ex('hipthrust', Equipment.barbell, ['glutes']),
      ex('calfraise', Equipment.bodyweight, ['calves']),
      ex('curl', Equipment.dumbbell, ['biceps']),
      ex('pushdown', Equipment.dumbbell, ['triceps']),
      ex('pushup', Equipment.bodyweight, ['chest']),
      ex('plank', Equipment.bodyweight, ['abdominals']),
      ex('squat_bw', Equipment.bodyweight, ['quadriceps']),
    ];

UserProfile profile({
  required Goal goal,
  required int days,
  Set<Equipment> equip = const {Equipment.barbell, Equipment.dumbbell},
}) =>
    UserProfile(
      sex: Sex.male,
      birthDate: DateTime(1995, 1, 1),
      heightCm: 180,
      weightKg: 80,
      goal: goal,
      level: ExperienceLevel.intermediate,
      daysPerWeek: days,
      sessionMinutes: 60,
      equipment: equip,
    );

void main() {
  test('hipertrofia 4 días con barra => 4 días de fuerza Upper/Lower', () {
    final plan = Coach().generate(
        profile(goal: Goal.hypertrophy, days: 4), catalog());
    expect(plan.split, SplitType.upperLower);
    expect(plan.days, hasLength(4));
    expect(plan.days.every((d) => d.type == DayType.strength), isTrue);
    // esquema de hipertrofia aplicado
    final firstEx = plan.days.first.exercises.first;
    expect(firstEx.repLow, 6);
    expect(firstEx.repHigh, 12);
    // sin ejercicios que requieran equipo no disponible
    expect(plan.days.first.exercises, isNotEmpty);
  });

  test('solo peso corporal => todos los días guiados (circuito)', () {
    final plan = Coach().generate(
      profile(goal: Goal.strength, days: 3, equip: {Equipment.bodyweight}),
      catalog(),
    );
    expect(plan.days, hasLength(3));
    expect(plan.days.every((d) => d.type == DayType.guided), isTrue);
    expect(plan.days.first.format, WorkoutFormat.circuit);
    expect(plan.days.first.exercises, isNotEmpty);
  });

  test('pérdida de grasa 4 días => 2 fuerza + 2 guiados', () {
    final plan =
        Coach().generate(profile(goal: Goal.fatLoss, days: 4), catalog());
    final strength = plan.days.where((d) => d.type == DayType.strength).length;
    final guided = plan.days.where((d) => d.type == DayType.guided).length;
    expect(strength, 2);
    expect(guided, 2);
  });

  test('es determinista', () {
    final p = profile(goal: Goal.hypertrophy, days: 4);
    final a = Coach().generate(p, catalog()).toJson();
    final b = Coach().generate(p, catalog()).toJson();
    expect(a.toString(), b.toString());
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/coach/coach_test.dart`
Expected: FAIL — `Coach` no existe.

- [ ] **Step 3: Implement the coach**

Crear `lib/core/coach/coach.dart`:
```dart
import '../models/enums.dart';
import '../models/exercise.dart';
import '../models/plan.dart';
import '../models/user_profile.dart';
import 'exercise_selection.dart';
import 'rules.dart';

class Coach {
  const Coach();

  Plan generate(UserProfile profile, List<Exercise> catalog) {
    final onlyBodyweight = profile.equipment.length == 1 &&
        profile.equipment.contains(Equipment.bodyweight);
    final guided =
        guidedDaysFor(profile.goal, profile.daysPerWeek, onlyBodyweight);
    final strengthDays = profile.daysPerWeek - guided;
    final split =
        strengthDays > 0 ? splitFor(strengthDays) : SplitType.fullBody;
    final scheme = repSchemeFor(profile.goal, profile.level);

    final days = <PlanDay>[];

    // --- Días de fuerza ---
    final used = <String>{};
    for (final tpl in strengthDayTemplates(split, strengthDays)) {
      final exercises = <PlanExercise>[];
      for (final group in tpl.groups) {
        final picked = selectExercise(
          catalog: catalog,
          targetMuscles: muscleGroups[group]!,
          available: profile.equipment,
          avoidMuscles: profile.limitations,
          excludeIds: used,
        );
        if (picked != null) {
          used.add(picked.id);
          exercises.add(PlanExercise(
            exerciseId: picked.id,
            exerciseName: picked.name,
            sets: scheme.sets,
            repLow: scheme.repLow,
            repHigh: scheme.repHigh,
            restSeconds: scheme.restSeconds,
          ));
        }
      }
      days.add(PlanDay(
        name: tpl.name,
        type: DayType.strength,
        format: WorkoutFormat.straightSets,
        rounds: 1,
        exercises: exercises,
      ));
    }

    // --- Días guiados (circuito de cuerpo completo) ---
    const circuitGroups = [
      'quadriceps',
      'chest',
      'back',
      'glutes',
      'abdominals'
    ];
    final rounds = profile.level == ExperienceLevel.beginner ? 3 : 4;
    for (var i = 0; i < guided; i++) {
      final exercises = <PlanExercise>[];
      for (final group in circuitGroups) {
        final picked = selectExercise(
          catalog: catalog,
          targetMuscles: muscleGroups[group]!,
          available: profile.equipment,
          avoidMuscles: profile.limitations,
          excludeIds: {},
        );
        if (picked != null) {
          exercises.add(PlanExercise(
            exerciseId: picked.id,
            exerciseName: picked.name,
            sets: 1,
            repLow: 10,
            repHigh: 15,
            restSeconds: 20,
          ));
        }
      }
      days.add(PlanDay(
        name: 'Circuito ${i + 1}',
        type: DayType.guided,
        format: WorkoutFormat.circuit,
        rounds: rounds,
        exercises: exercises,
      ));
    }

    return Plan(split: split, days: days);
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/core/coach/coach_test.dart`
Expected: PASS (4 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/core/coach/coach.dart test/core/coach/coach_test.dart
git commit -m "feat(coach): Coach.generate (plan fuerza+guiado determinista)

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 5: Persistencia del plan (JSON)

**Files:**
- Modify: `lib/core/db/database.dart` (tabla `Plans` + `savePlan`/`loadPlan`)
- Regenerate: `lib/core/db/database.g.dart`
- Test: `test/core/db/plan_persistence_test.dart`

**Interfaces:**
- Consumes: `Plan` (toJson/fromJson).
- Produces: tabla drift `Plans` (fila única `id=0`, columna `data` TEXT JSON); `Future<void> FraguaDatabase.savePlan(Plan)`, `Future<Plan?> FraguaDatabase.loadPlan()`. La migración crea también esta tabla.

- [ ] **Step 1: Write the failing test**

Crear `test/core/db/plan_persistence_test.dart`:
```dart
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/core/db/database.dart';
import 'package:fragua/core/models/plan.dart';

void main() {
  test('guarda y recupera el Plan (fila única)', () async {
    final db = FraguaDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    expect(await db.loadPlan(), isNull);

    const plan = Plan(split: SplitType.fullBody, days: [
      PlanDay(
        name: 'Full Body 1',
        type: DayType.strength,
        format: WorkoutFormat.straightSets,
        rounds: 1,
        exercises: [
          PlanExercise(
            exerciseId: 'squat',
            exerciseName: 'Squat',
            sets: 3,
            repLow: 6,
            repHigh: 12,
            restSeconds: 90,
          ),
        ],
      ),
    ]);

    await db.savePlan(plan);
    final loaded = await db.loadPlan();
    expect(loaded, isNotNull);
    expect(loaded!.split, SplitType.fullBody);
    expect(loaded.days.first.exercises.first.exerciseId, 'squat');

    await db.savePlan(plan); // no duplica
    final rows = await db.select(db.plans).get();
    expect(rows, hasLength(1));
  });
}
```

- [ ] **Step 2: Add the table and methods**

En `lib/core/db/database.dart`:
- Añade la tabla (junto a las otras):
```dart
@DataClassName('PlanRow')
class Plans extends Table {
  IntColumn get id => integer().named('id').withDefault(const Constant(0))();
  TextColumn get data => text().named('data')(); // JSON del Plan

  @override
  Set<Column> get primaryKey => {id};
}
```
- Regístrala en `@DriftDatabase(tables: [Exercises, UserProfiles, Plans])`.
- En `onUpgrade`, añade `await m.createTable(plans);` (después de `createTable(userProfiles)`).
- Añade el import `import 'dart:convert';` (ya está) y los métodos en `FraguaDatabase`:
```dart
  Future<void> savePlan(Plan plan) async {
    await into(plans).insertOnConflictUpdate(
      PlansCompanion.insert(id: const Value(0), data: jsonEncode(plan.toJson())),
    );
  }

  Future<Plan?> loadPlan() async {
    final row =
        await (select(plans)..where((t) => t.id.equals(0))).getSingleOrNull();
    if (row == null) return null;
    return Plan.fromJson(
        (jsonDecode(row.data) as Map).cast<String, Object?>());
  }
```
- Añade el import del modelo: `import '../models/plan.dart';`

- [ ] **Step 3: Run codegen**

Run: `dart run build_runner build`
Expected: regenera `database.g.dart` con `Plans`/`PlansCompanion`.

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/core/db/`
Expected: PASS (plan + perfil + exercises, sin regresiones).

- [ ] **Step 5: Commit**

```bash
git add lib/core/db/database.dart lib/core/db/database.g.dart test/core/db/plan_persistence_test.dart
git commit -m "feat(core): persistencia del Plan como JSON en drift

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 6: Pantalla del plan + generación tras onboarding

**Files:**
- Modify: `lib/app/providers.dart` (catálogo + plan + generación)
- Create: `lib/features/plan/plan_screen.dart`
- Modify: `lib/features/home/home_screen.dart` (botón "Ver mi plan")
- Modify: `lib/features/onboarding/onboarding_screen.dart` (genera y guarda el plan al guardar el perfil)
- Test: `test/features/plan_screen_test.dart`

**Interfaces:**
- Consumes: `databaseProvider`, `Coach`, `Plan`.
- Produces: `planProvider` (FutureProvider<Plan?>), `PlanScreen` (lista los días y ejercicios del plan).

- [ ] **Step 1: Write the failing widget test**

Crear `test/features/plan_screen_test.dart`:
```dart
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/app/providers.dart';
import 'package:fragua/core/db/database.dart';
import 'package:fragua/core/models/plan.dart';
import 'package:fragua/features/plan/plan_screen.dart';

void main() {
  testWidgets('muestra los días y ejercicios del plan', (tester) async {
    final db = FraguaDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db.savePlan(const Plan(split: SplitType.fullBody, days: [
      PlanDay(
        name: 'Full Body 1',
        type: DayType.strength,
        format: WorkoutFormat.straightSets,
        rounds: 1,
        exercises: [
          PlanExercise(
            exerciseId: 'squat',
            exerciseName: 'Sentadilla',
            sets: 3,
            repLow: 6,
            repHigh: 12,
            restSeconds: 90,
          ),
        ],
      ),
    ]));

    await tester.pumpWidget(ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: const MaterialApp(home: PlanScreen()),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Full Body 1'), findsOneWidget);
    expect(find.text('Sentadilla'), findsOneWidget);
    expect(find.textContaining('3 x 6-12'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/plan_screen_test.dart`
Expected: FAIL — `PlanScreen`/`planProvider` no existen.

- [ ] **Step 3: Add providers**

En `lib/app/providers.dart`, añade (importa `coach.dart`, `plan.dart`, `exercise.dart`):
```dart
final catalogProvider = FutureProvider((ref) {
  return ref.watch(databaseProvider).loadExercises();
});

final planProvider = FutureProvider<Plan?>((ref) {
  return ref.watch(databaseProvider).loadPlan();
});
```

- [ ] **Step 4: Implement PlanScreen**

Crear `lib/features/plan/plan_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/models/plan.dart';

class PlanScreen extends ConsumerWidget {
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(planProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Mi plan')),
      body: plan.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (p) => p == null
            ? const Center(child: Text('Aún no hay plan'))
            : ListView(
                children: [
                  for (final day in p.days) _DayCard(day: day),
                ],
              ),
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  const _DayCard({required this.day});
  final PlanDay day;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(day.name, style: Theme.of(context).textTheme.titleMedium),
            Text(day.type == DayType.guided
                ? 'Circuito · ${day.rounds} rondas'
                : 'Fuerza'),
            const Divider(),
            for (final e in day.exercises)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                    '${e.exerciseName} — ${e.sets} x ${e.repLow}-${e.repHigh}'),
              ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 5: Generate the plan on onboarding save + add a Home button**

En `lib/features/onboarding/onboarding_screen.dart`, dentro de `_save()`, tras `await ref.read(databaseProvider).saveProfile(profile);` y antes de `ref.invalidate(profileProvider);`, genera y guarda el plan:
```dart
    final db = ref.read(databaseProvider);
    await db.saveProfile(profile);
    final catalog = await db.loadExercises();
    await db.savePlan(const Coach().generate(profile, catalog));
    ref.invalidate(profileProvider);
    ref.invalidate(planProvider);
```
(añade `import '../../core/coach/coach.dart';`). Sustituye las dos primeras líneas previas del guardado para no duplicar el `saveProfile`.

En `lib/features/home/home_screen.dart`, añade bajo el contador un botón:
```dart
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PlanScreen()),
              ),
              child: const Text('Ver mi plan'),
            ),
```
(añade `import '../plan/plan_screen.dart';`).

- [ ] **Step 6: Run tests to verify they pass**

Run: `flutter test test/features/plan_screen_test.dart`
Expected: PASS.

- [ ] **Step 7: Full suite + analyze**

Run: `flutter test` → verde. `flutter analyze` → limpio. `tools/.venv/bin/python -m pytest tools/ -q` → verde.

- [ ] **Step 8: Commit**

```bash
git add lib/app/providers.dart lib/features/plan/plan_screen.dart lib/features/home/home_screen.dart lib/features/onboarding/onboarding_screen.dart test/features/plan_screen_test.dart
git commit -m "feat(plan): pantalla de plan + generacion tras onboarding

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

## Verificación de M2 (Definition of Done)

- `flutter analyze` limpio · `flutter test` verde (reglas, selección, coach, JSON, persistencia de plan, pantalla) · `pytest` verde.
- El coach genera un plan determinista coherente con objetivo/equipo; se persiste y se ve en la app.
- Mergeado a `master`; push a `origin`.

## Cobertura de la spec (self-review)

- §7.2 coach (modalidad, split, reps, selección por equipo/lesiones, días guiados) → Tasks 2-4. §5.1 catálogo → Task 3 (`loadExercises`). §8 plan (como JSON, desviación justificada) → Tasks 1, 5. §10 estética → Task 6 (básica; pulido Duolingo posterior).
- **Fuera de M2:** edición manual del plan (posterior); sustitución interactiva; ejecución de sesiones (M3 fuerza, M4 guiado); auto-regulación (M3).
