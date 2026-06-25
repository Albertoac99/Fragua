# Fragua M4 — Modo guiado: Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ejecutar un día **guiado** del plan (circuito / intervalos / AMRAP): un motor dirige el entreno por segmentos de trabajo/descanso a lo largo de las rondas con **cadencia por voz**, y al terminar **auto-regula** los parámetros del día guiado (tiempo de trabajo → variante → densidad/rondas) y los persiste.

**Architecture:** El corazón es **Dart puro y determinista** en `lib/core/`: `buildGuidedTimeline` construye la línea de tiempo (`SessionStep`s de trabajo/descanso × rondas) y `decideGuidedProgression` decide la progresión. La sesión en tiempo real la orquesta `GuidedSessionController` (`ChangeNotifier`, igual que el de fuerza): expone un `tick()` público que la UI llama cada segundo con un `Timer.periodic` y los tests llaman a mano (sin reloj real); dispara la voz en cada transición y, al acabar, aplica la progresión y persiste. El estado por día guiado (tiempo de trabajo / rondas / racha) vive en una tabla drift `GuidedStates` (migración v4). La voz reutiliza el seam `VoiceCues` ya existente (inyectable; `SilentVoiceCues` en tests).

**Tech Stack:** Dart puro (timeline + progresión) · drift · flutter_riverpod · flutter_tts (vía `VoiceCues`) · `dart:async` (`Timer`) · flutter_test.

## Global Constraints

- `lib/core/**` NUNCA importa Flutter. La voz vive en `lib/services/**`; el reloj (`Timer`) vive en la pantalla (`lib/features/**`).
- Lógica de timeline y progresión **determinista** (testeable sin tiempo real ni audio). BD y voz **inyectables** vía Riverpod.
- Columnas SQLite snake_case con `.named(...)`. Migración drift **versionada** (`if (from < N)`).
- Cambios de modelo **retrocompatibles** con los planes ya guardados: campos nuevos `nullable`, sin renombrar/borrar enums existentes.
- Commits frecuentes, uno por tarea. Mensajes terminan con `Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>`.

---

## File Structure

- `lib/core/models/plan.dart` — (modificar) `WorkoutFormat` gana `intervals` y `amrap`; `PlanExercise` gana `workSeconds` (nullable); `PlanDay` gana `totalSeconds` (nullable, para AMRAP). JSON retrocompatible.
- `lib/core/session/guided_session.dart` — (crear) `StepKind`, `SessionStep`, `buildGuidedTimeline(...)`.
- `lib/core/progression/guided_progression.dart` — (crear) `GuidedProgressionResult`, `decideGuidedProgression(...)`.
- `lib/core/db/database.dart` — (modificar) tabla `GuidedStates` + `guidedState`/`saveGuidedState`; migración v4.
- `lib/core/db/database.g.dart` — (regenerar) build_runner.
- `lib/features/workout/guided_session_controller.dart` — (crear) `GuidedSessionState`, `GuidedSessionController`.
- `lib/features/workout/guided_session_screen.dart` — (crear) UI guiada (temporizador grande, ronda X/Y, ejercicio actual + siguiente, progreso, +ronda en AMRAP).
- `lib/core/coach/coach.dart` — (modificar) los días guiados pueblan `workSeconds`.
- `lib/features/plan/plan_screen.dart` — (modificar) botón "Empezar" también en días guiados → `GuidedSessionScreen`.
- Tests: `test/core/models/plan_json_test.dart` (ampliar), `test/core/session/guided_session_test.dart`, `test/core/progression/guided_progression_test.dart`, `test/core/db/guided_state_test.dart`, `test/features/guided_session_controller_test.dart`, `test/features/guided_session_screen_test.dart`, `test/features/plan_screen_test.dart` (ampliar), `test/core/coach/coach_test.dart` (ampliar).

---

### Task 1: Modelo — formatos guiados + tiempo de trabajo + tiempo total

**Files:**
- Modify: `lib/core/models/plan.dart`
- Test: `test/core/models/plan_json_test.dart`

**Interfaces:**
- Produces: `enum WorkoutFormat { straightSets, circuit, intervals, amrap }`; `PlanExercise` con campo `final int? workSeconds` (param opcional `this.workSeconds`); `PlanDay` con campo `final int? totalSeconds` (param opcional `this.totalSeconds`). Ambos serializados en `toJson`/`fromJson` de forma retrocompatible (`as int?`).

- [ ] **Step 1: Write the failing test**

Añade al final de `test/core/models/plan_json_test.dart` (dentro de `main()`):
```dart
  test('PlanExercise round-trips workSeconds (y null por defecto)', () {
    const timed = PlanExercise(
      exerciseId: 'burpee',
      exerciseName: 'Burpee',
      sets: 1,
      repLow: 10,
      repHigh: 15,
      restSeconds: 20,
      workSeconds: 40,
    );
    expect(PlanExercise.fromJson(timed.toJson()).workSeconds, 40);

    const repBased = PlanExercise(
      exerciseId: 'squat',
      exerciseName: 'Squat',
      sets: 3,
      repLow: 6,
      repHigh: 12,
      restSeconds: 90,
    );
    expect(repBased.workSeconds, isNull);
    expect(PlanExercise.fromJson(repBased.toJson()).workSeconds, isNull);
  });

  test('PlanDay round-trips totalSeconds y los nuevos formatos', () {
    const day = PlanDay(
      name: 'AMRAP 10',
      type: DayType.guided,
      format: WorkoutFormat.amrap,
      rounds: 5,
      totalSeconds: 600,
      exercises: [],
    );
    final back = PlanDay.fromJson(day.toJson());
    expect(back.format, WorkoutFormat.amrap);
    expect(back.totalSeconds, 600);
  });

  test('PlanDay sin totalSeconds => null (retrocompatible)', () {
    const day = PlanDay(
      name: 'Circuito 1',
      type: DayType.guided,
      format: WorkoutFormat.circuit,
      rounds: 3,
      exercises: [],
    );
    expect(PlanDay.fromJson(day.toJson()).totalSeconds, isNull);
  });
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/models/plan_json_test.dart`
Expected: FAIL — `workSeconds`/`totalSeconds`/`WorkoutFormat.amrap` no existen (error de compilación).

- [ ] **Step 3: Extend the model**

En `lib/core/models/plan.dart`:

- Cambia el enum:
```dart
enum WorkoutFormat { straightSets, circuit, intervals, amrap }
```

- En `PlanExercise`, añade el campo (tras `restSeconds`):
```dart
  final int? workSeconds;
```
añade el parámetro al constructor (tras `required this.restSeconds,`):
```dart
    this.workSeconds,
```
añade a `toJson()` (dentro del map):
```dart
        'workSeconds': workSeconds,
```
y a `fromJson` (dentro del constructor):
```dart
        workSeconds: j['workSeconds'] as int?,
```

- En `PlanDay`, añade el campo (tras `rounds`):
```dart
  final int? totalSeconds;
```
añade el parámetro al constructor (tras `required this.rounds,`):
```dart
    this.totalSeconds,
```
añade a `toJson()`:
```dart
        'totalSeconds': totalSeconds,
```
y a `fromJson`:
```dart
        totalSeconds: j['totalSeconds'] as int?,
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/core/models/`
Expected: PASS (round-trip nuevo + sin regresiones en los tests de modelo).

- [ ] **Step 5: Commit**

```bash
git add lib/core/models/plan.dart test/core/models/plan_json_test.dart
git commit -m "feat(core): formatos guiados (intervals/amrap) + workSeconds/totalSeconds

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 2: Motor de timeline guiado (core, puro)

**Files:**
- Create: `lib/core/session/guided_session.dart`
- Test: `test/core/session/guided_session_test.dart`

**Interfaces:**
- Consumes: `PlanDay`, `PlanExercise`, `WorkoutFormat` (Task 1).
- Produces: `enum StepKind { work, rest }`; `class SessionStep { final StepKind kind; final int seconds; final String label; final int round; final int totalRounds; }` (constructor `const` con esos 5 campos requeridos); `List<SessionStep> buildGuidedTimeline(PlanDay day, {int? workSecondsOverride, int? roundsOverride, int defaultWorkSeconds = 40, String restLabel = 'Descanso'})`. Para `WorkoutFormat.amrap` devuelve `const []` (AMRAP no tiene timeline fijo).

- [ ] **Step 1: Write the failing test**

Crear `test/core/session/guided_session_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/core/models/plan.dart';
import 'package:fragua/core/session/guided_session.dart';

PlanDay circuit({int rounds = 3}) => PlanDay(
      name: 'Circuito',
      type: DayType.guided,
      format: WorkoutFormat.circuit,
      rounds: rounds,
      exercises: const [
        PlanExercise(
          exerciseId: 'a',
          exerciseName: 'Sentadilla',
          sets: 1,
          repLow: 10,
          repHigh: 15,
          restSeconds: 15,
          workSeconds: 40,
        ),
        PlanExercise(
          exerciseId: 'b',
          exerciseName: 'Flexión',
          sets: 1,
          repLow: 10,
          repHigh: 15,
          restSeconds: 15,
          workSeconds: 40,
        ),
      ],
    );

void main() {
  test('2 ejercicios x 3 rondas => trabajo/descanso intercalados, sin descanso final', () {
    final t = buildGuidedTimeline(circuit(rounds: 3));
    // 3 rondas * 2 ejercicios * 2 (work+rest) - 1 (descanso final) = 11
    expect(t, hasLength(11));
    expect(t.first.kind, StepKind.work);
    expect(t.first.label, 'Sentadilla');
    expect(t.last.kind, StepKind.work); // termina en trabajo, no en descanso
    expect(t.last.round, 3);
  });

  test('numera las rondas correctamente (1-based)', () {
    final t = buildGuidedTimeline(circuit(rounds: 2));
    expect(t.first.round, 1);
    expect(t.first.totalRounds, 2);
    // 4 pasos por ronda (2 ejercicios * work+rest); el primer work de la 2ª ronda
    // está en el índice 4.
    expect(t[4].round, 2);
    expect(t[4].kind, StepKind.work);
    expect(t[4].label, 'Sentadilla');
  });

  test('usa workSeconds del ejercicio y restSeconds como descanso', () {
    final t = buildGuidedTimeline(circuit(rounds: 1));
    expect(t[0].seconds, 40); // work
    expect(t[1].seconds, 15); // rest
  });

  test('workSecondsOverride y roundsOverride mandan sobre el día', () {
    final t = buildGuidedTimeline(circuit(rounds: 3),
        workSecondsOverride: 30, roundsOverride: 1);
    expect(t, hasLength(3)); // 1 ronda: w,r,w
    expect(t[0].seconds, 30);
  });

  test('AMRAP no tiene timeline fijo => lista vacía', () {
    const day = PlanDay(
      name: 'AMRAP',
      type: DayType.guided,
      format: WorkoutFormat.amrap,
      rounds: 5,
      totalSeconds: 600,
      exercises: [],
    );
    expect(buildGuidedTimeline(day), isEmpty);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/session/guided_session_test.dart`
Expected: FAIL — `buildGuidedTimeline` / `SessionStep` no existen.

- [ ] **Step 3: Implement the timeline builder**

Crear `lib/core/session/guided_session.dart`:
```dart
import '../models/plan.dart';

/// Tipo de segmento de una sesión guiada.
enum StepKind { work, rest }

/// Un segmento de la línea de tiempo de una sesión guiada.
class SessionStep {
  final StepKind kind;
  final int seconds;
  final String label; // nombre del ejercicio (work) o etiqueta de descanso (rest)
  final int round; // ronda actual, 1-based
  final int totalRounds;

  const SessionStep({
    required this.kind,
    required this.seconds,
    required this.label,
    required this.round,
    required this.totalRounds,
  });
}

/// Construye la línea de tiempo determinista de un día guiado de tipo
/// circuito/intervalos: por cada ronda, cada ejercicio genera un segmento de
/// trabajo ([workSecondsOverride] ?? `exercise.workSeconds` ?? [defaultWorkSeconds])
/// seguido de uno de descanso (`exercise.restSeconds`). Se omite el descanso
/// final (tras el último ejercicio de la última ronda).
///
/// AMRAP no tiene timeline fijo (se cuenta a contrarreloj con rondas manuales),
/// por lo que devuelve una lista vacía.
List<SessionStep> buildGuidedTimeline(
  PlanDay day, {
  int? workSecondsOverride,
  int? roundsOverride,
  int defaultWorkSeconds = 40,
  String restLabel = 'Descanso',
}) {
  if (day.format == WorkoutFormat.amrap) return const [];
  final rounds = roundsOverride ?? day.rounds;
  final steps = <SessionStep>[];
  for (var r = 1; r <= rounds; r++) {
    for (final e in day.exercises) {
      final work = workSecondsOverride ?? e.workSeconds ?? defaultWorkSeconds;
      steps.add(SessionStep(
        kind: StepKind.work,
        seconds: work,
        label: e.exerciseName,
        round: r,
        totalRounds: rounds,
      ));
      steps.add(SessionStep(
        kind: StepKind.rest,
        seconds: e.restSeconds,
        label: restLabel,
        round: r,
        totalRounds: rounds,
      ));
    }
  }
  if (steps.isNotEmpty) steps.removeLast(); // sin descanso tras el último trabajo
  return steps;
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/core/session/guided_session_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/core/session/guided_session.dart test/core/session/guided_session_test.dart
git commit -m "feat(core): motor de timeline guiado (circuito/intervalos)

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 3: Motor de progresión guiada (core, puro)

**Files:**
- Create: `lib/core/progression/guided_progression.dart`
- Test: `test/core/progression/guided_progression_test.dart`

**Interfaces:**
- Produces: `class GuidedProgressionResult { final int nextWorkSeconds; final int nextRounds; final bool bumpVariant; final int nextStreak; }` (constructor `const`); `GuidedProgressionResult decideGuidedProgression({required bool completedAll, required int workSeconds, required int rounds, required int streak, bool harderVariantAvailable = false, int baseWorkSeconds = 30, int workSecondsCap = 60, int workSecondsStep = 5, int maxRounds = 6, int streakToProgress = 2})`.

- [ ] **Step 1: Write the failing test**

Crear `test/core/progression/guided_progression_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/core/progression/guided_progression.dart';

GuidedProgressionResult decide({
  required bool done,
  int work = 30,
  int rounds = 3,
  int streak = 0,
  bool harder = false,
}) =>
    decideGuidedProgression(
      completedAll: done,
      workSeconds: work,
      rounds: rounds,
      streak: streak,
      harderVariantAvailable: harder,
    );

void main() {
  test('no completa => resetea la racha y mantiene parámetros', () {
    final r = decide(done: false, work: 40, rounds: 4, streak: 1);
    expect(r.nextWorkSeconds, 40);
    expect(r.nextRounds, 4);
    expect(r.bumpVariant, isFalse);
    expect(r.nextStreak, 0);
  });

  test('completa pero racha insuficiente => acumula racha sin cambios', () {
    final r = decide(done: true, work: 30, streak: 0); // umbral 2
    expect(r.nextWorkSeconds, 30);
    expect(r.bumpVariant, isFalse);
    expect(r.nextStreak, 1);
  });

  test('completa y alcanza el umbral con trabajo < tope => sube el tiempo', () {
    final r = decide(done: true, work: 30, streak: 1); // 2º => progresa
    expect(r.nextWorkSeconds, 35);
    expect(r.nextStreak, 0);
    expect(r.bumpVariant, isFalse);
  });

  test('trabajo en el tope y hay variante => sube variante y resetea el tiempo', () {
    final r = decide(done: true, work: 60, streak: 1, harder: true);
    expect(r.bumpVariant, isTrue);
    expect(r.nextWorkSeconds, 30); // baseWorkSeconds
    expect(r.nextStreak, 0);
  });

  test('trabajo en el tope, sin variante => añade ronda (densidad) y resetea el tiempo', () {
    final r = decide(done: true, work: 60, rounds: 3, streak: 1, harder: false);
    expect(r.nextRounds, 4);
    expect(r.nextWorkSeconds, 30);
    expect(r.bumpVariant, isFalse);
    expect(r.nextStreak, 0);
  });

  test('todo al techo (tope de tiempo y de rondas, sin variante) => sin cambios', () {
    final r = decide(done: true, work: 60, rounds: 6, streak: 1, harder: false);
    expect(r.nextWorkSeconds, 60);
    expect(r.nextRounds, 6);
    expect(r.bumpVariant, isFalse);
    expect(r.nextStreak, 0);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/progression/guided_progression_test.dart`
Expected: FAIL — `decideGuidedProgression` no existe.

- [ ] **Step 3: Implement the engine**

Crear `lib/core/progression/guided_progression.dart`:
```dart
import 'dart:math' as math;

class GuidedProgressionResult {
  final int nextWorkSeconds;
  final int nextRounds;
  final bool bumpVariant;
  final int nextStreak;
  const GuidedProgressionResult({
    required this.nextWorkSeconds,
    required this.nextRounds,
    required this.bumpVariant,
    required this.nextStreak,
  });
}

/// Auto-regulación del modo guiado (§7.3 de la spec).
///
/// Si el usuario completa todas las rondas/objetivos ([completedAll]) acumula
/// racha; al alcanzar [streakToProgress] aplica **una** mejora y resetea la
/// racha, en este orden:
/// 1. **(a) tiempo/reps**: sube el trabajo [workSecondsStep] s hasta [workSecondsCap];
/// 2. **(c) variante**: si el trabajo ya está al tope y hay variante más difícil
///    ([harderVariantAvailable]), sube de variante y resetea el trabajo a [baseWorkSeconds];
/// 3. **(b) densidad**: si no hay variante, añade una ronda hasta [maxRounds] y
///    resetea el trabajo a [baseWorkSeconds].
/// Si no completa, **resetea la racha** y mantiene los parámetros.
GuidedProgressionResult decideGuidedProgression({
  required bool completedAll,
  required int workSeconds,
  required int rounds,
  required int streak,
  bool harderVariantAvailable = false,
  int baseWorkSeconds = 30,
  int workSecondsCap = 60,
  int workSecondsStep = 5,
  int maxRounds = 6,
  int streakToProgress = 2,
}) {
  GuidedProgressionResult keep({int? streakOverride, int? work, int? rounds_, bool variant = false}) =>
      GuidedProgressionResult(
        nextWorkSeconds: work ?? workSeconds,
        nextRounds: rounds_ ?? rounds,
        bumpVariant: variant,
        nextStreak: streakOverride ?? streak,
      );

  if (!completedAll) return keep(streakOverride: 0);

  final newStreak = streak + 1;
  if (newStreak < streakToProgress) return keep(streakOverride: newStreak);

  // Listo para progresar: aplica una mejora y resetea la racha.
  if (workSeconds < workSecondsCap) {
    return keep(
      work: math.min(workSeconds + workSecondsStep, workSecondsCap),
      streakOverride: 0,
    );
  }
  if (harderVariantAvailable) {
    return keep(work: baseWorkSeconds, variant: true, streakOverride: 0);
  }
  if (rounds < maxRounds) {
    return keep(work: baseWorkSeconds, rounds_: rounds + 1, streakOverride: 0);
  }
  return keep(streakOverride: 0); // techo: nada que mejorar
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/core/progression/guided_progression_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/core/progression/guided_progression.dart test/core/progression/guided_progression_test.dart
git commit -m "feat(core): progresion guiada (tiempo -> variante -> densidad)

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 4: Persistencia del estado por día guiado

**Files:**
- Modify: `lib/core/db/database.dart` (tabla `GuidedStates` + métodos + migración v4)
- Regenerate: `lib/core/db/database.g.dart`
- Test: `test/core/db/guided_state_test.dart`

**Interfaces:**
- Produces: tabla drift `GuidedStates` (`day_key` PK TEXT, `work_seconds` INT, `rounds` INT, `streak` INT con default 0); `Future<({int workSeconds, int rounds, int streak})?> FraguaDatabase.guidedState(String dayKey)`; `Future<void> FraguaDatabase.saveGuidedState(String dayKey, int workSeconds, int rounds, int streak)`.

- [ ] **Step 1: Write the failing test**

Crear `test/core/db/guided_state_test.dart`:
```dart
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/core/db/database.dart';

void main() {
  test('guarda y recupera el estado por día guiado (upsert)', () async {
    final db = FraguaDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    expect(await db.guidedState('Circuito 1'), isNull);

    await db.saveGuidedState('Circuito 1', 40, 3, 0);
    var s = await db.guidedState('Circuito 1');
    expect(s!.workSeconds, 40);
    expect(s.rounds, 3);
    expect(s.streak, 0);

    await db.saveGuidedState('Circuito 1', 45, 3, 1);
    s = await db.guidedState('Circuito 1');
    expect(s!.workSeconds, 45);
    expect(s.streak, 1);

    final rows = await db.select(db.guidedStates).get();
    expect(rows, hasLength(1));
  });
}
```

- [ ] **Step 2: Add the table, methods and migration**

En `lib/core/db/database.dart`:

- Añade la tabla (junto a `ExerciseStates`):
```dart
@DataClassName('GuidedStateRow')
class GuidedStates extends Table {
  TextColumn get dayKey => text().named('day_key')();
  IntColumn get workSeconds => integer().named('work_seconds')();
  IntColumn get rounds => integer().named('rounds')();
  IntColumn get streak =>
      integer().named('streak').withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {dayKey};
}
```

- Regístrala en `@DriftDatabase`:
```dart
@DriftDatabase(tables: [Exercises, UserProfiles, Plans, ExerciseStates, GuidedStates])
```

- Sube `schemaVersion` a `4`:
```dart
  @override
  int get schemaVersion => 4;
```

- Añade en `onUpgrade` (tras la línea de `exerciseStates`):
```dart
          if (from < 4) await m.createTable(guidedStates);
```

- Añade los métodos en `FraguaDatabase` (tras `saveExerciseState`):
```dart
  Future<({int workSeconds, int rounds, int streak})?> guidedState(
      String dayKey) async {
    final row = await (select(guidedStates)
          ..where((t) => t.dayKey.equals(dayKey)))
        .getSingleOrNull();
    if (row == null) return null;
    return (
      workSeconds: row.workSeconds,
      rounds: row.rounds,
      streak: row.streak,
    );
  }

  Future<void> saveGuidedState(
      String dayKey, int workSeconds, int rounds, int streak) async {
    await into(guidedStates).insertOnConflictUpdate(
      GuidedStatesCompanion.insert(
        dayKey: dayKey,
        workSeconds: workSeconds,
        rounds: rounds,
        streak: Value(streak),
      ),
    );
  }
```

- [ ] **Step 3: Run codegen**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: regenera `database.g.dart` con `GuidedStates`/`GuidedStateRow`/`GuidedStatesCompanion`.

- [ ] **Step 4: Run tests**

Run: `flutter test test/core/db/`
Expected: PASS (estado guiado + sin regresiones en el resto de tests de BD).

- [ ] **Step 5: Commit**

```bash
git add lib/core/db/database.dart lib/core/db/database.g.dart test/core/db/guided_state_test.dart
git commit -m "feat(core): persistencia del estado por dia guiado (tiempo/rondas/racha)

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 5: Controlador de la sesión guiada

**Files:**
- Create: `lib/features/workout/guided_session_controller.dart`
- Test: `test/features/guided_session_controller_test.dart`

**Interfaces:**
- Consumes: `FraguaDatabase` (`guidedState`/`saveGuidedState`), `VoiceCues`, `PlanDay`, `WorkoutFormat`, `SessionStep`/`buildGuidedTimeline` (sólo el tipo `SessionStep`), `decideGuidedProgression`.
- Produces:
  - `class GuidedSessionState` con `final PlanDay day; final List<SessionStep> timeline; final int stepIndex; final int remainingSeconds; final int completedRounds; final bool running; final bool finished;` y getters `bool get isAmrap`, `SessionStep? get currentStep`, `SessionStep? get nextStep`, `double get progress`; `copyWith(...)`.
  - `class GuidedSessionController extends ChangeNotifier` con constructor `({required FraguaDatabase db, required VoiceCues voice, required PlanDay day, required List<SessionStep> timeline, required int initialWorkSeconds, required int initialRounds})`, y métodos `void start()`, `void pause()`, `void addRound()`, `void tick()`, `Future<void> finish()`. `tick()` es síncrono y no usa reloj real (la UI lo llama por `Timer`; los tests a mano). Al consumirse el último segmento, `tick()` marca `finished = true` (sin tocar la BD); `finish()` aplica `decideGuidedProgression` y persiste **una sola vez** (idempotente).

- [ ] **Step 1: Write the failing test**

Crear `test/features/guided_session_controller_test.dart`:
```dart
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/core/db/database.dart';
import 'package:fragua/core/models/plan.dart';
import 'package:fragua/core/session/guided_session.dart';
import 'package:fragua/features/workout/guided_session_controller.dart';
import 'package:fragua/services/voice/voice_cues.dart';

class RecordingVoice implements VoiceCues {
  final List<String> said = [];
  @override
  Future<void> say(String text) async => said.add(text);
}

PlanDay circuit() => const PlanDay(
      name: 'Circuito',
      type: DayType.guided,
      format: WorkoutFormat.circuit,
      rounds: 2,
      exercises: [
        PlanExercise(
          exerciseId: 'a',
          exerciseName: 'Sentadilla',
          sets: 1,
          repLow: 10,
          repHigh: 15,
          restSeconds: 1,
          workSeconds: 2,
        ),
      ],
    );

void main() {
  test('recorre el timeline, anuncia rondas y al terminar progresa+persiste', () async {
    final db = FraguaDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    // racha previa 1 => al completar (umbral 2) debe progresar el tiempo.
    await db.saveGuidedState('Circuito', 30, 2, 1);

    final voice = RecordingVoice();
    final day = circuit();
    final timeline = buildGuidedTimeline(day, workSecondsOverride: 2, roundsOverride: 2);
    // timeline: [work2(r1), rest1(r1), work2(r2)] => 5 segundos en total.
    final c = GuidedSessionController(
      db: db,
      voice: voice,
      day: day,
      timeline: timeline,
      initialWorkSeconds: 30,
      initialRounds: 2,
    );

    c.start();
    expect(c.state.currentStep!.label, 'Sentadilla');
    expect(c.state.remainingSeconds, 2);

    // 5 ticks consumen los 3 segmentos (2+1+2).
    for (var i = 0; i < 5; i++) {
      c.tick();
    }
    expect(c.state.finished, isTrue);

    await c.finish();
    final gs = await db.guidedState('Circuito');
    expect(gs!.workSeconds, 35); // progresó el tiempo (+5) por completar
    expect(gs.streak, 0);

    // Anunció la segunda ronda por voz en algún momento.
    expect(voice.said.any((s) => s.contains('Ronda 2 de 2')), isTrue);
  });

  test('finish() es idempotente (no progresa dos veces)', () async {
    final db = FraguaDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db.saveGuidedState('Circuito', 30, 2, 1);

    final day = circuit();
    final c = GuidedSessionController(
      db: db,
      voice: SilentVoiceCues(),
      day: day,
      timeline: buildGuidedTimeline(day, workSecondsOverride: 2, roundsOverride: 2),
      initialWorkSeconds: 30,
      initialRounds: 2,
    );
    c.start();
    for (var i = 0; i < 5; i++) {
      c.tick();
    }
    await c.finish();
    await c.finish(); // segunda llamada: no debe volver a progresar
    final gs = await db.guidedState('Circuito');
    expect(gs!.workSeconds, 35);
  });

  test('AMRAP: cuenta rondas a mano y completa si alcanza el objetivo', () async {
    final db = FraguaDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    const day = PlanDay(
      name: 'AMRAP',
      type: DayType.guided,
      format: WorkoutFormat.amrap,
      rounds: 2, // objetivo de rondas
      totalSeconds: 3,
      exercises: [],
    );
    final c = GuidedSessionController(
      db: db,
      voice: SilentVoiceCues(),
      day: day,
      timeline: const [],
      initialWorkSeconds: 30,
      initialRounds: 2,
    );
    c.start();
    expect(c.state.isAmrap, isTrue);
    expect(c.state.remainingSeconds, 3);

    c.addRound();
    c.addRound();
    expect(c.state.completedRounds, 2);

    for (var i = 0; i < 3; i++) {
      c.tick(); // agota el tiempo
    }
    expect(c.state.finished, isTrue);

    await c.finish();
    // completó el objetivo (2 >= 2): racha sube a 1 (umbral 2, aún sin progresar).
    final gs = await db.guidedState('AMRAP');
    expect(gs!.streak, 1);
    expect(gs.rounds, 2);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/guided_session_controller_test.dart`
Expected: FAIL — `GuidedSessionController` no existe.

- [ ] **Step 3: Implement the controller**

Crear `lib/features/workout/guided_session_controller.dart`:
```dart
import 'package:flutter/foundation.dart';

import '../../core/db/database.dart';
import '../../core/models/plan.dart';
import '../../core/progression/guided_progression.dart';
import '../../core/session/guided_session.dart';
import '../../services/voice/voice_cues.dart';

class GuidedSessionState {
  final PlanDay day;
  final List<SessionStep> timeline;
  final int stepIndex;
  final int remainingSeconds;
  final int completedRounds;
  final bool running;
  final bool finished;

  const GuidedSessionState({
    required this.day,
    required this.timeline,
    required this.stepIndex,
    required this.remainingSeconds,
    required this.completedRounds,
    required this.running,
    required this.finished,
  });

  bool get isAmrap => day.format == WorkoutFormat.amrap;

  SessionStep? get currentStep =>
      (!isAmrap && stepIndex >= 0 && stepIndex < timeline.length)
          ? timeline[stepIndex]
          : null;

  SessionStep? get nextStep {
    final n = stepIndex + 1;
    return (!isAmrap && n < timeline.length) ? timeline[n] : null;
  }

  /// Progreso 0..1 (por tiempo en AMRAP; por segmentos en circuito/intervalos).
  double get progress {
    if (isAmrap) {
      final total = day.totalSeconds ?? 0;
      if (total <= 0) return 0;
      return (1 - remainingSeconds / total).clamp(0, 1);
    }
    if (timeline.isEmpty) return 0;
    return (stepIndex / timeline.length).clamp(0, 1);
  }

  GuidedSessionState copyWith({
    int? stepIndex,
    int? remainingSeconds,
    int? completedRounds,
    bool? running,
    bool? finished,
  }) {
    return GuidedSessionState(
      day: day,
      timeline: timeline,
      stepIndex: stepIndex ?? this.stepIndex,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      completedRounds: completedRounds ?? this.completedRounds,
      running: running ?? this.running,
      finished: finished ?? this.finished,
    );
  }
}

class GuidedSessionController extends ChangeNotifier {
  GuidedSessionController({
    required this.db,
    required this.voice,
    required PlanDay day,
    required List<SessionStep> timeline,
    required int initialWorkSeconds,
    required int initialRounds,
  })  : _initialWorkSeconds = initialWorkSeconds,
        _initialRounds = initialRounds,
        _stepsPerRound = day.exercises.isEmpty ? 1 : day.exercises.length * 2,
        _state = GuidedSessionState(
          day: day,
          timeline: timeline,
          stepIndex: 0,
          remainingSeconds: day.format == WorkoutFormat.amrap
              ? (day.totalSeconds ?? 0)
              : (timeline.isEmpty ? 0 : timeline.first.seconds),
          completedRounds: 0,
          running: false,
          finished: false,
        );

  final FraguaDatabase db;
  final VoiceCues voice;
  final int _initialWorkSeconds;
  final int _initialRounds;
  final int _stepsPerRound;

  GuidedSessionState _state;
  GuidedSessionState get state => _state;

  bool _reachedEnd = false;
  bool _applied = false;

  void start() {
    if (_state.finished) return;
    _state = _state.copyWith(running: true);
    final s = _state.currentStep;
    if (s != null) voice.say(_announce(0));
    notifyListeners();
  }

  void pause() {
    _state = _state.copyWith(running: false);
    notifyListeners();
  }

  /// AMRAP: el usuario marca una ronda completada.
  void addRound() {
    if (!_state.isAmrap || _state.finished) return;
    final n = _state.completedRounds + 1;
    _state = _state.copyWith(completedRounds: n);
    voice.say('Ronda $n');
    notifyListeners();
  }

  /// Avanza un segundo. La UI lo llama desde un `Timer.periodic`; los tests a mano.
  void tick() {
    if (!_state.running || _state.finished) return;
    final remaining = _state.remainingSeconds - 1;
    if (remaining > 0) {
      _state = _state.copyWith(remainingSeconds: remaining);
      if (remaining <= 3) voice.say('$remaining');
      notifyListeners();
      return;
    }
    // Segmento agotado.
    if (_state.isAmrap) {
      _reachedEnd = true;
      _state = _state.copyWith(remainingSeconds: 0, finished: true, running: false);
      notifyListeners();
      return;
    }
    final next = _state.stepIndex + 1;
    if (next >= _state.timeline.length) {
      _reachedEnd = true;
      _state = _state.copyWith(remainingSeconds: 0, finished: true, running: false);
      notifyListeners();
      return;
    }
    final step = _state.timeline[next];
    _state = _state.copyWith(stepIndex: next, remainingSeconds: step.seconds);
    voice.say(_announce(next));
    notifyListeners();
  }

  /// Aplica la progresión y persiste el estado del día. Idempotente.
  Future<void> finish() async {
    if (_applied) return;
    _applied = true;
    final completedAll = _state.isAmrap
        ? _state.completedRounds >= _state.day.rounds
        : _reachedEnd;
    final prev = await db.guidedState(_state.day.name);
    final result = decideGuidedProgression(
      completedAll: completedAll,
      workSeconds: _initialWorkSeconds,
      rounds: _initialRounds,
      streak: prev?.streak ?? 0,
    );
    await db.saveGuidedState(
      _state.day.name,
      result.nextWorkSeconds,
      result.nextRounds,
      result.nextStreak,
    );
    if (!_state.finished) {
      _state = _state.copyWith(finished: true, running: false);
      notifyListeners();
    }
  }

  String _announce(int index) {
    final step = _state.timeline[index];
    if (step.kind == StepKind.rest) return 'Descanso';
    final isRoundStart = index % _stepsPerRound == 0;
    if (!isRoundStart) return 'Siguiente: ${step.label}';
    if (step.round == step.totalRounds) {
      return 'Última ronda. ${step.label}';
    }
    return 'Ronda ${step.round} de ${step.totalRounds}. ${step.label}';
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/guided_session_controller_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/workout/guided_session_controller.dart test/features/guided_session_controller_test.dart
git commit -m "feat(workout): controlador de sesion guiada (timeline + voz + AMRAP)

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 6: El coach puebla el tiempo de trabajo de los días guiados

**Files:**
- Modify: `lib/core/coach/coach.dart`
- Test: `test/core/coach/coach_test.dart`

**Interfaces:**
- Consumes: `PlanExercise.workSeconds` (Task 1).
- Produces: los `PlanExercise` de los días guiados llevan `workSeconds: 40` (intervalo de trabajo por defecto del circuito). Sin cambios en los días de fuerza (`workSeconds` queda `null`).

- [ ] **Step 1: Write the failing test**

Añade al final de `test/core/coach/coach_test.dart` (dentro de `main()`):
```dart
  test('los días guiados llevan workSeconds; los de fuerza no', () {
    final plan = const Coach().generate(
      profile(goal: Goal.strength, days: 3, equip: {Equipment.bodyweight}),
      catalog(),
    );
    final guided = plan.days.firstWhere((d) => d.type == DayType.guided);
    expect(guided.exercises.first.workSeconds, 40);

    final strengthPlan =
        const Coach().generate(profile(goal: Goal.hypertrophy, days: 4), catalog());
    final strength =
        strengthPlan.days.firstWhere((d) => d.type == DayType.strength);
    expect(strength.exercises.first.workSeconds, isNull);
  });
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/coach/coach_test.dart`
Expected: FAIL — el `workSeconds` de los guiados es `null` (esperaba 40).

- [ ] **Step 3: Populate workSeconds in guided days**

En `lib/core/coach/coach.dart`, en el bloque "Días guiados", dentro del `PlanExercise(...)` del circuito añade `workSeconds`:
```dart
          exercises.add(PlanExercise(
            exerciseId: picked.id,
            exerciseName: picked.name,
            sets: 1,
            repLow: 10,
            repHigh: 15,
            restSeconds: 20,
            workSeconds: 40,
          ));
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/core/coach/`
Expected: PASS (nuevo + los 4 tests del coach existentes siguen verdes).

- [ ] **Step 5: Commit**

```bash
git add lib/core/coach/coach.dart test/core/coach/coach_test.dart
git commit -m "feat(coach): tiempo de trabajo (workSeconds) en los dias guiados

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 7: Pantalla de sesión guiada + enlace desde el plan + verificación M4

**Files:**
- Create: `lib/features/workout/guided_session_screen.dart`
- Modify: `lib/features/plan/plan_screen.dart` (botón "Empezar" en días guiados)
- Test: `test/features/guided_session_screen_test.dart`, `test/features/plan_screen_test.dart` (ampliar)

**Interfaces:**
- Consumes: `databaseProvider`, `voiceProvider` (ya existen en `lib/app/providers.dart`), `GuidedSessionController`, `buildGuidedTimeline`, `PlanDay`.
- Produces: `class GuidedSessionScreen extends ConsumerStatefulWidget` con `final PlanDay day;`. Carga `guidedState` (tiempo/rondas persistidos o defaults), construye el timeline y el controlador, arranca un `Timer.periodic(1s)` que llama `tick()`, y al `finished` cancela el timer, llama `finish()` y hace `pop()`. La UI muestra el segmento actual, la ronda, el tiempo restante, el siguiente ejercicio y, en AMRAP, un botón `+1 ronda`.

- [ ] **Step 1: Write the failing widget test**

Crear `test/features/guided_session_screen_test.dart`:
```dart
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/app/providers.dart';
import 'package:fragua/core/db/database.dart';
import 'package:fragua/core/models/plan.dart';
import 'package:fragua/features/workout/guided_session_screen.dart';

PlanDay circuit() => const PlanDay(
      name: 'Circuito',
      type: DayType.guided,
      format: WorkoutFormat.circuit,
      rounds: 2,
      exercises: [
        PlanExercise(
          exerciseId: 'a',
          exerciseName: 'Sentadilla',
          sets: 1,
          repLow: 10,
          repHigh: 15,
          restSeconds: 1,
          workSeconds: 3,
        ),
      ],
    );

void main() {
  testWidgets('arranca y muestra el ejercicio y la ronda actual', (tester) async {
    final db = FraguaDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: MaterialApp(home: GuidedSessionScreen(day: circuit())),
    ));
    await tester.pump(); // deja terminar el _init() async (carga estado + arranca)

    expect(find.text('Sentadilla'), findsOneWidget);
    expect(find.textContaining('Ronda 1'), findsOneWidget);

    // Limpieza: descarta el widget para cancelar el Timer.periodic.
    await tester.pumpWidget(const SizedBox());
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/guided_session_screen_test.dart`
Expected: FAIL — `GuidedSessionScreen` no existe.

- [ ] **Step 3: Implement the guided session screen**

Crear `lib/features/workout/guided_session_screen.dart`:
```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/models/plan.dart';
import '../../core/session/guided_session.dart';
import 'guided_session_controller.dart';

class GuidedSessionScreen extends ConsumerStatefulWidget {
  const GuidedSessionScreen({super.key, required this.day});
  final PlanDay day;

  @override
  ConsumerState<GuidedSessionScreen> createState() =>
      _GuidedSessionScreenState();
}

class _GuidedSessionScreenState extends ConsumerState<GuidedSessionScreen> {
  GuidedSessionController? _c;
  Timer? _timer;
  bool _leaving = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final db = ref.read(databaseProvider);
    final voice = ref.read(voiceProvider);
    final gs = await db.guidedState(widget.day.name);
    final defaultWork = widget.day.exercises.isNotEmpty
        ? (widget.day.exercises.first.workSeconds ?? 40)
        : 40;
    final work = gs?.workSeconds ?? defaultWork;
    final rounds = gs?.rounds ?? widget.day.rounds;
    final timeline = buildGuidedTimeline(
      widget.day,
      workSecondsOverride: work,
      roundsOverride: rounds,
    );
    if (!mounted) return;
    final c = GuidedSessionController(
      db: db,
      voice: voice,
      day: widget.day,
      timeline: timeline,
      initialWorkSeconds: work,
      initialRounds: rounds,
    );
    c.addListener(_onState);
    setState(() => _c = c);
    c.start();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => c.tick());
  }

  void _onState() {
    if (_c != null && _c!.state.finished && !_leaving) {
      _leaving = true;
      _timer?.cancel();
      _finishAndLeave();
    }
  }

  Future<void> _finishAndLeave() async {
    await _c!.finish();
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _finishEarly() async {
    if (_leaving) return;
    _leaving = true;
    _timer?.cancel();
    await _finishAndLeave();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _c?.removeListener(_onState);
    _c?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _c;
    if (controller == null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.day.name)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(widget.day.name)),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final st = controller.state;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: st.isAmrap
                ? _amrapBody(controller, st)
                : _timelineBody(controller, st),
          );
        },
      ),
    );
  }

  Widget _timelineBody(GuidedSessionController c, GuidedSessionState st) {
    final step = st.currentStep;
    final next = st.nextStep;
    final isRest = step?.kind == StepKind.rest;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (step != null)
          Text('Ronda ${step.round} de ${step.totalRounds}',
              style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(isRest ? 'Descanso' : (step?.label ?? ''),
            style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        Text('${st.remainingSeconds}',
            style: Theme.of(context).textTheme.displayLarge),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: st.progress),
        const SizedBox(height: 16),
        if (next != null)
          Text('Siguiente: ${next.kind == StepKind.rest ? 'Descanso' : next.label}'),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            OutlinedButton(
              onPressed: st.running ? c.pause : c.start,
              child: Text(st.running ? 'Pausa' : 'Reanudar'),
            ),
            FilledButton(
              key: const Key('finish-guided'),
              onPressed: _finishEarly,
              child: const Text('Terminar'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _amrapBody(GuidedSessionController c, GuidedSessionState st) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('AMRAP', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text('${st.remainingSeconds}',
            style: Theme.of(context).textTheme.displayLarge),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: st.progress),
        const SizedBox(height: 16),
        Text('Rondas: ${st.completedRounds}',
            style: Theme.of(context).textTheme.headlineSmall),
        const Spacer(),
        FilledButton(
          key: const Key('amrap-round'),
          onPressed: c.addRound,
          child: const Text('+1 ronda'),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          key: const Key('finish-guided'),
          onPressed: _finishEarly,
          child: const Text('Terminar'),
        ),
      ],
    );
  }
}
```

- [ ] **Step 4: Link guided days from the plan**

En `lib/features/plan/plan_screen.dart`:

- Importa la pantalla guiada (junto al import de `session_screen.dart`):
```dart
import '../workout/guided_session_screen.dart';
```

- Sustituye el bloque del botón "Empezar" (el `if (day.type == DayType.strength && ...)`) por uno que cubra ambos tipos:
```dart
            if (day.exercises.isNotEmpty)
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => day.type == DayType.guided
                          ? GuidedSessionScreen(day: day)
                          : SessionScreen(day: day),
                    ),
                  ),
                  child: const Text('Empezar'),
                ),
              ),
```

- [ ] **Step 5: Extend the plan screen test (guided day shows "Empezar")**

Abre `test/features/plan_screen_test.dart`. Localiza el helper que construye el `Plan`/`PlanDay` de prueba y **añade un test** que verifique que un día guiado con ejercicios muestra el botón "Empezar". Si el archivo ya construye un plan con un día guiado, añade sólo el `expect`; si no, añade este test independiente al `main()`:
```dart
  testWidgets('un día guiado con ejercicios muestra "Empezar"', (tester) async {
    final db = FraguaDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db.savePlan(const Plan(
      split: SplitType.fullBody,
      days: [
        PlanDay(
          name: 'Circuito 1',
          type: DayType.guided,
          format: WorkoutFormat.circuit,
          rounds: 3,
          exercises: [
            PlanExercise(
              exerciseId: 'a',
              exerciseName: 'Burpee',
              sets: 1,
              repLow: 10,
              repHigh: 15,
              restSeconds: 20,
              workSeconds: 40,
            ),
          ],
        ),
      ],
    ));

    await tester.pumpWidget(ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: const MaterialApp(home: PlanScreen()),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Burpee'), findsOneWidget);
    expect(find.text('Empezar'), findsOneWidget);
  });
```
Asegúrate de que los imports del test incluyen `package:drift/native.dart`, `package:flutter/material.dart`, `package:flutter_riverpod/flutter_riverpod.dart`, `package:fragua/app/providers.dart`, `package:fragua/core/db/database.dart`, `package:fragua/core/models/plan.dart` y `package:fragua/features/plan/plan_screen.dart` (añade los que falten).

- [ ] **Step 6: Run the new widget tests**

Run: `flutter test test/features/guided_session_screen_test.dart test/features/plan_screen_test.dart`
Expected: PASS.

- [ ] **Step 7: Full verification (Definition of Done de M4)**

Run: `flutter test`
Expected: verde (todos: modelo, timeline, progresión guiada, estado guiado, controlador, coach, pantallas).

Run: `flutter analyze`
Expected: sin issues (`No issues found!`).

Run: `tools/.venv/bin/python -m pytest tools/ -q`
Expected: verde (sin regresiones en el pipeline de build de la BD).

- [ ] **Step 8: Commit**

```bash
git add lib/features/workout/guided_session_screen.dart lib/features/plan/plan_screen.dart test/features/guided_session_screen_test.dart test/features/plan_screen_test.dart
git commit -m "feat(workout): pantalla de sesion guiada + enlace desde el plan

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

## Verificación de M4 (Definition of Done)

- `flutter analyze` limpio · `flutter test` verde (timeline, progresión guiada, estado guiado, controlador con voz/AMRAP, coach, pantallas) · `pytest` verde.
- Desde el plan se puede **Empezar** un día guiado: el motor dirige el circuito por segmentos de trabajo/descanso con cuenta atrás y voz ("Ronda X de Y", "Descanso", "Última ronda"), y al terminar **auto-regula** el tiempo de trabajo / rondas del día y lo **persiste** (se nota en la siguiente sesión).
- El motor soporta los tres formatos nombrados en la spec: **circuito/intervalos** (timeline fijo) y **AMRAP** (contrarreloj con rondas manuales).
- Mergeado a `master`; push a `origin` (con el OK de Alberto).

## Cobertura de la spec (self-review)

- **§7.4 sesión guiada** (intervalos/circuito/AMRAP, temporizador grande, ejercicio actual + siguiente, anillo/barra de progreso, registro por bloque) → Tasks 2, 5, 7. El registro por bloque se materializa como rondas completadas (AMRAP) y recorrido del timeline (circuito); el historial detallado para stats es de M7.
- **§7.3 progresión guiada** (a reps/tiempo · b densidad/rondas · c escalera de variantes) → Task 3 (`decideGuidedProgression`), aplicada y persistida en Task 5. La variante se decide vía `harderVariantAvailable`; **conectar** la escalera real (`variation_group` del catálogo) queda para cuando se curen los grupos (spec §5.4/§16) — el hook está listo.
- **§7.6 voz guiada** (cadencia: "trabajo"/"descanso", "ronda X de Y", "última ronda", cuenta atrás, ánimos) → Task 5 (`_announce` + cuenta atrás ≤3 s) reutilizando el seam `VoiceCues` de M3.
- **§8 modelo** (plan_day.formato/total, plan_exercise.trabajo_s) → Task 1; estado persistido del día guiado → Task 4.
- **Fuera de M4** (explícito): generación por el coach de días de intervalos/AMRAP (M4 genera circuitos; el motor ya soporta los tres formatos) · conexión de la escalera de variantes con datos curados (M5) · GIFs/animaciones (M5) · XP/ligas por completar guiados (M6) · historial de sesiones para gráficas (M7) · banco de voz "Álvaro" edge-tts (mejora futura; se usa flutter_tts).
