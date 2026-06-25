# Fragua M3 — Sesión de fuerza + auto-regulación + voz: Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ejecutar un día de fuerza del plan: registrar series/reps por ejercicio, temporizador de descanso con cuenta atrás y voz, y al terminar **auto-regular** el peso de trabajo de cada ejercicio (doble progresión + deload), persistiéndolo.

**Architecture:** La auto-regulación es **Dart puro** en `lib/core/progression/` (determinista, testeable). El peso de trabajo y el contador de estancamiento por ejercicio se persisten en una tabla `exercise_states` (drift, migración v3). La sesión se orquesta con un `WorkoutSessionController` (Riverpod `StateNotifier`); al finalizar aplica la progresión y guarda el estado. La voz es un seam `VoiceCues` inyectable: implementación real con **flutter_tts** (voz del dispositivo, offline); en tests se inyecta una `SilentVoiceCues`.

**Tech Stack:** Dart puro (progresión) · drift · flutter_riverpod · flutter_tts · flutter_test.

## Global Constraints

- `lib/core/**` NUNCA importa Flutter. La voz (flutter_tts) vive en `lib/services/**`.
- Progresión **determinista** (testeable). Voz y BD **inyectables** vía Riverpod (tests sin audio ni assets).
- Columnas SQLite snake_case con `.named(...)`. Migración drift **versionada** (`if (from < N)`).
- Commits frecuentes, uno por tarea. Mensajes terminan con `Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>`.

---

## File Structure

- `lib/core/progression/progression.dart` — (crear) `ProgressionResult` + `decideProgression(...)`.
- `lib/core/db/database.dart` — (modificar) tabla `ExerciseStates` + `exerciseState`/`saveExerciseState`; migración v3.
- `lib/services/voice/voice_cues.dart` — (crear) `VoiceCues` (abstracta), `SilentVoiceCues`, `TtsVoiceCues` (flutter_tts).
- `lib/app/providers.dart` — (modificar) `voiceProvider`.
- `lib/features/workout/session_controller.dart` — (crear) `WorkoutSessionState`, `WorkoutSessionController`.
- `lib/features/workout/session_screen.dart` — (crear) UI de la sesión (log de series, descanso, terminar).
- `lib/features/plan/plan_screen.dart` — (modificar) botón "Empezar" en días de fuerza → navega a la sesión.
- Tests: `test/core/progression/progression_test.dart`, `test/core/db/exercise_state_test.dart`, `test/features/session_controller_test.dart`, `test/features/session_screen_test.dart`.

---

### Task 1: Motor de auto-regulación

**Files:**
- Create: `lib/core/progression/progression.dart`
- Test: `test/core/progression/progression_test.dart`

**Interfaces:**
- Produces: `class ProgressionResult {double nextWeight; int nextStallCount; bool deload;}`; `ProgressionResult decideProgression({required int repLow, required int repHigh, required double currentWeight, required List<int> repsPerSet, required int targetSets, required double increment, required int stallCount, int deloadThreshold = 3})`.

- [ ] **Step 1: Write the failing test**

Crear `test/core/progression/progression_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/core/progression/progression.dart';

ProgressionResult decide(List<int> reps, {double w = 100, int stall = 0}) =>
    decideProgression(
      repLow: 6,
      repHigh: 12,
      currentWeight: w,
      repsPerSet: reps,
      targetSets: 3,
      increment: 2.5,
      stallCount: stall,
    );

void main() {
  test('todas las series al tope => sube peso y resetea estancamiento', () {
    final r = decide([12, 12, 12], stall: 1);
    expect(r.nextWeight, 102.5);
    expect(r.nextStallCount, 0);
    expect(r.deload, isFalse);
  });

  test('dentro del rango sin tope => mantiene peso (doble progresión)', () {
    final r = decide([10, 9, 8]);
    expect(r.nextWeight, 100);
    expect(r.deload, isFalse);
  });

  test('falla por debajo del mínimo => no sube y suma estancamiento', () {
    final r = decide([6, 5, 4], stall: 0);
    expect(r.nextWeight, 100);
    expect(r.nextStallCount, 1);
    expect(r.deload, isFalse);
  });

  test('estancamiento alcanza el umbral => deload -10% y resetea', () {
    final r = decide([5, 4, 3], stall: 2); // 3er fallo => deload
    expect(r.nextWeight, closeTo(90, 0.001));
    expect(r.nextStallCount, 0);
    expect(r.deload, isTrue);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/progression/progression_test.dart`
Expected: FAIL — `decideProgression` no existe.

- [ ] **Step 3: Implement the engine**

Crear `lib/core/progression/progression.dart`:
```dart
class ProgressionResult {
  final double nextWeight;
  final int nextStallCount;
  final bool deload;
  const ProgressionResult({
    required this.nextWeight,
    required this.nextStallCount,
    required this.deload,
  });
}

/// Auto-regulación por doble progresión + deload.
/// - Todas las series al tope del rango (>= repHigh) => sube [increment].
/// - Dentro del rango (sin tope) => mantiene peso (busca más reps).
/// - Alguna serie por debajo de [repLow] => estancamiento +1; al alcanzar
///   [deloadThreshold] => deload (-10%) y resetea.
ProgressionResult decideProgression({
  required int repLow,
  required int repHigh,
  required double currentWeight,
  required List<int> repsPerSet,
  required int targetSets,
  required double increment,
  required int stallCount,
  int deloadThreshold = 3,
}) {
  final completedAll = repsPerSet.length >= targetSets &&
      repsPerSet.every((r) => r >= repHigh);
  if (completedAll) {
    return ProgressionResult(
      nextWeight: currentWeight + increment,
      nextStallCount: 0,
      deload: false,
    );
  }

  final failedLow = repsPerSet.any((r) => r < repLow);
  if (failedLow) {
    final newStall = stallCount + 1;
    if (newStall >= deloadThreshold) {
      return ProgressionResult(
        nextWeight: currentWeight * 0.9,
        nextStallCount: 0,
        deload: true,
      );
    }
    return ProgressionResult(
      nextWeight: currentWeight,
      nextStallCount: newStall,
      deload: false,
    );
  }

  // Dentro del rango pero sin llegar al tope: doble progresión (más reps).
  return ProgressionResult(
    nextWeight: currentWeight,
    nextStallCount: stallCount,
    deload: false,
  );
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/core/progression/progression_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/core/progression/progression.dart test/core/progression/progression_test.dart
git commit -m "feat(core): motor de auto-regulacion (doble progresion + deload)

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 2: Persistencia del estado por ejercicio

**Files:**
- Modify: `lib/core/db/database.dart` (tabla `ExerciseStates` + métodos + migración v3)
- Regenerate: `lib/core/db/database.g.dart`
- Test: `test/core/db/exercise_state_test.dart`

**Interfaces:**
- Produces: tabla drift `ExerciseStates` (`exercise_id` PK, `current_weight` REAL, `stall_count` INT); `Future<({double weight, int stall})?> FraguaDatabase.exerciseState(String exerciseId)`; `Future<void> FraguaDatabase.saveExerciseState(String exerciseId, double weight, int stall)`.

- [ ] **Step 1: Write the failing test**

Crear `test/core/db/exercise_state_test.dart`:
```dart
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/core/db/database.dart';

void main() {
  test('guarda y recupera el estado por ejercicio (upsert)', () async {
    final db = FraguaDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    expect(await db.exerciseState('squat'), isNull);

    await db.saveExerciseState('squat', 100, 0);
    var s = await db.exerciseState('squat');
    expect(s!.weight, 100);
    expect(s.stall, 0);

    await db.saveExerciseState('squat', 102.5, 1);
    s = await db.exerciseState('squat');
    expect(s!.weight, 102.5);
    expect(s.stall, 1);

    final rows = await db.select(db.exerciseStates).get();
    expect(rows, hasLength(1));
  });
}
```

- [ ] **Step 2: Add the table, methods and migration**

En `lib/core/db/database.dart`:
- Añade la tabla (junto a las otras):
```dart
@DataClassName('ExerciseStateRow')
class ExerciseStates extends Table {
  TextColumn get exerciseId => text().named('exercise_id')();
  RealColumn get currentWeight => real().named('current_weight')();
  IntColumn get stallCount => integer().named('stall_count').withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {exerciseId};
}
```
- Regístrala: `@DriftDatabase(tables: [Exercises, UserProfiles, Plans, ExerciseStates])`.
- Sube `schemaVersion` a `3` y añade en `onUpgrade`: `if (from < 3) await m.createTable(exerciseStates);`.
- Añade los métodos en `FraguaDatabase`:
```dart
  Future<({double weight, int stall})?> exerciseState(String exerciseId) async {
    final row = await (select(exerciseStates)
          ..where((t) => t.exerciseId.equals(exerciseId)))
        .getSingleOrNull();
    if (row == null) return null;
    return (weight: row.currentWeight, stall: row.stallCount);
  }

  Future<void> saveExerciseState(
      String exerciseId, double weight, int stall) async {
    await into(exerciseStates).insertOnConflictUpdate(
      ExerciseStatesCompanion.insert(
        exerciseId: exerciseId,
        currentWeight: weight,
        stallCount: Value(stall),
      ),
    );
  }
```

- [ ] **Step 3: Run codegen**

Run: `dart run build_runner build`
Expected: regenera `database.g.dart` con `ExerciseStates`.

- [ ] **Step 4: Run tests**

Run: `flutter test test/core/db/`
Expected: PASS (estado por ejercicio + sin regresiones).

- [ ] **Step 5: Commit**

```bash
git add lib/core/db/database.dart lib/core/db/database.g.dart test/core/db/exercise_state_test.dart
git commit -m "feat(core): persistencia del estado por ejercicio (peso/estancamiento)

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 3: Controlador de la sesión

**Files:**
- Create: `lib/features/workout/session_controller.dart`
- Test: `test/features/session_controller_test.dart`

**Interfaces:**
- Consumes: `FraguaDatabase`, `PlanDay`, `PlanExercise`, `decideProgression`.
- Produces: `class WorkoutSessionState {PlanDay day; int exerciseIndex; Map<String,double> weights; Map<String,List<int>> loggedReps; bool finished;}` (con `PlanExercise get current`, `bool get isLastExercise`); `class WorkoutSessionController extends StateNotifier<WorkoutSessionState>` con `void setWeight(double)`, `void logSet(int reps)`, `void nextExercise()`, `Future<void> finish()` (aplica `decideProgression` y guarda `exerciseState` de cada ejercicio).

- [ ] **Step 1: Write the failing test**

Crear `test/features/session_controller_test.dart`:
```dart
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/core/db/database.dart';
import 'package:fragua/core/models/plan.dart';
import 'package:fragua/features/workout/session_controller.dart';

PlanDay day() => const PlanDay(
      name: 'Push',
      type: DayType.strength,
      format: WorkoutFormat.straightSets,
      rounds: 1,
      exercises: [
        PlanExercise(
          exerciseId: 'bench',
          exerciseName: 'Bench',
          sets: 3,
          repLow: 6,
          repHigh: 12,
          restSeconds: 90,
        ),
      ],
    );

void main() {
  test('al terminar aplica la progresión y guarda el estado', () async {
    final db = FraguaDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db.saveExerciseState('bench', 100, 0);

    final c = WorkoutSessionController(db: db, day: day(), initialWeights: {'bench': 100});
    c.setWeight(100);
    c.logSet(12);
    c.logSet(12);
    c.logSet(12);
    await c.finish();

    expect(c.state.finished, isTrue);
    final s = await db.exerciseState('bench');
    expect(s!.weight, 102.5); // subió por completar el tope
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/session_controller_test.dart`
Expected: FAIL — `WorkoutSessionController` no existe.

- [ ] **Step 3: Implement the controller**

Crear `lib/features/workout/session_controller.dart`:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/database.dart';
import '../../core/models/plan.dart';
import '../../core/progression/progression.dart';

class WorkoutSessionState {
  final PlanDay day;
  final int exerciseIndex;
  final Map<String, double> weights;
  final Map<String, List<int>> loggedReps;
  final bool finished;

  const WorkoutSessionState({
    required this.day,
    required this.exerciseIndex,
    required this.weights,
    required this.loggedReps,
    required this.finished,
  });

  PlanExercise get current => day.exercises[exerciseIndex];
  bool get isLastExercise => exerciseIndex >= day.exercises.length - 1;
  List<int> get currentReps => loggedReps[current.exerciseId] ?? const [];

  WorkoutSessionState copyWith({
    int? exerciseIndex,
    Map<String, double>? weights,
    Map<String, List<int>>? loggedReps,
    bool? finished,
  }) {
    return WorkoutSessionState(
      day: day,
      exerciseIndex: exerciseIndex ?? this.exerciseIndex,
      weights: weights ?? this.weights,
      loggedReps: loggedReps ?? this.loggedReps,
      finished: finished ?? this.finished,
    );
  }
}

class WorkoutSessionController extends StateNotifier<WorkoutSessionState> {
  WorkoutSessionController({
    required this.db,
    required PlanDay day,
    required Map<String, double> initialWeights,
  }) : super(WorkoutSessionState(
          day: day,
          exerciseIndex: 0,
          weights: Map<String, double>.from(initialWeights),
          loggedReps: {},
          finished: false,
        ));

  final FraguaDatabase db;

  void setWeight(double weight) {
    state = state.copyWith(
      weights: {...state.weights, state.current.exerciseId: weight},
    );
  }

  void logSet(int reps) {
    final id = state.current.exerciseId;
    final repsList = [...(state.loggedReps[id] ?? const []), reps];
    state = state.copyWith(loggedReps: {...state.loggedReps, id: repsList});
  }

  void nextExercise() {
    if (!state.isLastExercise) {
      state = state.copyWith(exerciseIndex: state.exerciseIndex + 1);
    }
  }

  Future<void> finish() async {
    for (final e in state.day.exercises) {
      final reps = state.loggedReps[e.exerciseId];
      if (reps == null || reps.isEmpty) continue;
      final weight = state.weights[e.exerciseId] ?? 0;
      final prev = await db.exerciseState(e.exerciseId);
      final result = decideProgression(
        repLow: e.repLow,
        repHigh: e.repHigh,
        currentWeight: weight,
        repsPerSet: reps,
        targetSets: e.sets,
        increment: 2.5,
        stallCount: prev?.stall ?? 0,
      );
      await db.saveExerciseState(
          e.exerciseId, result.nextWeight, result.nextStallCount);
    }
    state = state.copyWith(finished: true);
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/session_controller_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/workout/session_controller.dart test/features/session_controller_test.dart
git commit -m "feat(workout): controlador de sesion (log de series + progresion al terminar)

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 4: Pantalla de sesión + voz + enlace desde el plan

**Files:**
- Create: `lib/services/voice/voice_cues.dart`
- Modify: `lib/app/providers.dart` (`voiceProvider`)
- Create: `lib/features/workout/session_screen.dart`
- Modify: `lib/features/plan/plan_screen.dart` (botón "Empezar" en días de fuerza)
- Modify: `pubspec.yaml` (`flutter_tts`)
- Test: `test/features/session_screen_test.dart`

**Interfaces:**
- Consumes: `WorkoutSessionController`, `databaseProvider`, `VoiceCues`.
- Produces: `abstract class VoiceCues { Future<void> say(String text); }`, `SilentVoiceCues`, `TtsVoiceCues`; `voiceProvider` (Provider<VoiceCues>); `SessionScreen` (registra series, descanso con cuenta atrás + voz, terminar).

- [ ] **Step 1: Add dependency + voice seam**

Run: `flutter pub add flutter_tts`
Crear `lib/services/voice/voice_cues.dart`:
```dart
import 'package:flutter_tts/flutter_tts.dart';

abstract class VoiceCues {
  Future<void> say(String text);
}

/// Sin voz (tests / usuario que la desactiva).
class SilentVoiceCues implements VoiceCues {
  const SilentVoiceCues();
  @override
  Future<void> say(String text) async {}
}

/// Voz del dispositivo (offline) vía flutter_tts, en español.
class TtsVoiceCues implements VoiceCues {
  TtsVoiceCues() {
    _tts.setLanguage('es-ES');
    _tts.setSpeechRate(0.5);
  }
  final FlutterTts _tts = FlutterTts();

  @override
  Future<void> say(String text) => _tts.speak(text);
}
```

- [ ] **Step 2: Add the voice provider**

En `lib/app/providers.dart` añade (importa el seam):
```dart
import '../services/voice/voice_cues.dart';
```
```dart
/// Override con TtsVoiceCues() en main(); SilentVoiceCues por defecto (tests).
final voiceProvider = Provider<VoiceCues>((ref) => const SilentVoiceCues());
```

- [ ] **Step 3: Write the failing widget test**

Crear `test/features/session_screen_test.dart`:
```dart
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/app/providers.dart';
import 'package:fragua/core/db/database.dart';
import 'package:fragua/core/models/plan.dart';
import 'package:fragua/features/workout/session_screen.dart';

PlanDay day() => const PlanDay(
      name: 'Push',
      type: DayType.strength,
      format: WorkoutFormat.straightSets,
      rounds: 1,
      exercises: [
        PlanExercise(
          exerciseId: 'bench',
          exerciseName: 'Bench',
          sets: 1,
          repLow: 6,
          repHigh: 12,
          restSeconds: 1,
        ),
      ],
    );

void main() {
  testWidgets('registra una serie y termina => progresión persistida',
      (tester) async {
    final db = FraguaDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db.saveExerciseState('bench', 100, 0);

    await tester.pumpWidget(ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: MaterialApp(home: SessionScreen(day: day())),
    ));
    await tester.pumpAndSettle(); // deja que cargue el peso persistido

    await tester.tap(find.byKey(const Key('log-set')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('finish-session')));
    await tester.pumpAndSettle();

    final s = await db.exerciseState('bench');
    expect(s!.weight, 102.5); // 12 reps por defecto => subió
  });
}
```

- [ ] **Step 4: Implement the session screen**

Crear `lib/features/workout/session_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/models/plan.dart';
import 'session_controller.dart';

class SessionScreen extends ConsumerStatefulWidget {
  const SessionScreen({super.key, required this.day});
  final PlanDay day;

  @override
  ConsumerState<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends ConsumerState<SessionScreen> {
  WorkoutSessionController? _c;
  int _reps = 12;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final db = ref.read(databaseProvider);
    final weights = <String, double>{};
    for (final e in widget.day.exercises) {
      final st = await db.exerciseState(e.exerciseId);
      weights[e.exerciseId] = st?.weight ?? 20; // 20 kg por defecto
    }
    if (mounted) {
      setState(() {
        _c = WorkoutSessionController(
            db: db, day: widget.day, initialWeights: weights);
      });
    }
  }

  @override
  void dispose() {
    _c?.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await _c!.finish();
    if (mounted) Navigator.of(context).pop();
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
    final voice = ref.read(voiceProvider);
    return Scaffold(
      appBar: AppBar(title: Text(widget.day.name)),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final st = controller.state;
          final ex = st.current;
          final done = st.currentReps.length;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ex.exerciseName,
                    style: Theme.of(context).textTheme.titleLarge),
                Text('Objetivo: ${ex.sets} x ${ex.repLow}-${ex.repHigh}'),
                Text('Series hechas: $done / ${ex.sets}'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Reps: '),
                    IconButton(
                      onPressed: () =>
                          setState(() => _reps = (_reps - 1).clamp(0, 50)),
                      icon: const Icon(Icons.remove),
                    ),
                    Text('$_reps'),
                    IconButton(
                      onPressed: () =>
                          setState(() => _reps = (_reps + 1).clamp(0, 50)),
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
                FilledButton(
                  key: const Key('log-set'),
                  onPressed: () {
                    controller.logSet(_reps);
                    voice.say('Descanso ${ex.restSeconds} segundos');
                  },
                  child: const Text('Registrar serie'),
                ),
                const Spacer(),
                if (!st.isLastExercise)
                  OutlinedButton(
                    onPressed: controller.nextExercise,
                    child: const Text('Siguiente ejercicio'),
                  ),
                FilledButton(
                  key: const Key('finish-session'),
                  onPressed: _finish,
                  child: const Text('Terminar entreno'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
```

- [ ] **Step 5: Link from the plan + wire real voice in main**

En `lib/features/plan/plan_screen.dart`, dentro de `_DayCard`, tras el `Divider()` y los ejercicios, añade un botón solo para días de fuerza (importa `session_screen.dart`):
```dart
            if (day.type == DayType.strength && day.exercises.isNotEmpty)
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => SessionScreen(day: day)),
                  ),
                  child: const Text('Empezar'),
                ),
              ),
```
(`_DayCard` pasa a necesitar `BuildContext`, que ya tiene en `build`.)

En `lib/main.dart`, añade el override de voz real:
```dart
import 'app/providers.dart';
import 'services/voice/voice_cues.dart';
```
```dart
  runApp(ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(db),
      voiceProvider.overrideWithValue(TtsVoiceCues()),
    ],
    child: const FraguaApp(),
  ));
```

- [ ] **Step 6: Run tests + analyze**

Run: `flutter test test/features/session_screen_test.dart` → PASS.
Run: `flutter test` → verde. `flutter analyze` → limpio. `tools/.venv/bin/python -m pytest tools/ -q` → verde.

- [ ] **Step 7: Commit**

```bash
git add lib/services/voice/voice_cues.dart lib/app/providers.dart lib/features/workout/session_screen.dart lib/features/plan/plan_screen.dart lib/main.dart pubspec.yaml pubspec.lock test/features/session_screen_test.dart
git commit -m "feat(workout): pantalla de sesion de fuerza + voz (flutter_tts)

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

## Verificación de M3 (Definition of Done)

- `flutter analyze` limpio · `flutter test` verde (progresión, estado por ejercicio, controlador, pantalla) · `pytest` verde.
- Desde el plan se puede empezar un día de fuerza, registrar series y terminar; el peso de trabajo se auto-regula y persiste.
- Mergeado a `master`; push a `origin`.

## Cobertura de la spec (self-review)

- §7.3 auto-regulación (doble progresión + deload) → Task 1. §7.4 ejecución de sesión de fuerza (log series, descanso) → Tasks 3, 4. §7.6 voz → Task 4 (flutter_tts; banco "Álvaro" edge-tts = mejora futura). §8 estado por ejercicio → Task 2.
- **Fuera de M3:** temporizador de descanso con cuenta atrás animada y RIR (simplificados; reps por defecto en la UI), historial de sesiones para stats (M7), modo guiado (M4), banco de voz Álvaro.
