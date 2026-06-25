# Fragua M7 — Seguimiento (gráficas de progreso): Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Registrar el progreso a lo largo del tiempo y visualizarlo: por **fuerza** (PR / 1RM estimado Epley / volumen y su evolución por ejercicio) y por **cuerpo** (peso corporal + medidas), con gráficas (`fl_chart`).

**Architecture:** El cálculo de estadísticas es **Dart puro y determinista** en `lib/core/stats/` (Epley, mejor 1RM/PR, volumen, series temporales) sobre un DTO `ExerciseLog` sin Flutter. La persistencia (drift, migración **v6**) añade `exercise_logs` (una fila por ejercicio terminado en cada sesión) y `body_metrics` (peso corporal y medidas, por `kind`). La sesión de fuerza (M3) registra un `exercise_log` por ejercicio al `finish()`. La UI (`fl_chart`) añade una pantalla de **Progreso** con dos secciones: **Fuerza** (selector de ejercicio → PR, gráfica de 1RM, volumen) y **Cuerpo** (peso/medidas: añadir + gráfica).

**Tech Stack:** Dart puro (stats) · drift · flutter_riverpod · fl_chart (nuevo) · flutter_test.

## Global Constraints

- `lib/core/**` NUNCA importa Flutter. El cálculo de estadísticas es **puro y determinista** (testeable sin BD ni UI) sobre DTOs.
- Persistencia drift: columnas snake_case con `.named(...)`; migración **versionada** (`if (from < 6)`). Tablas de historial con `autoIncrement()`.
- Integración **no intrusiva**: la firma del controlador de sesión no cambia; `finish()` añade el registro del log (las tablas existen en los tests vía `createAll`, así que los tests M3/M6 siguen verdes).
- 1RM estimado por **Epley**: `peso * (1 + reps/30)`.
- Commits frecuentes, uno por tarea. Mensajes terminan con `Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>`.

---

## File Structure

- `lib/core/stats/exercise_log.dart` — (crear) DTO `ExerciseLog`.
- `lib/core/stats/stats.dart` — (crear) `estimatedOneRm`, `bestOneRm`, `totalVolume`, `oneRmSeries`.
- `lib/core/db/database.dart` — (modificar) tablas `ExerciseLogs`/`BodyMetrics` + métodos; migración v6.
- `lib/core/db/database.g.dart` — (regenerar).
- `lib/features/workout/session_controller.dart` — (modificar) registrar `exercise_log` en `finish()`.
- `lib/app/providers.dart` — (modificar) providers de stats/medidas.
- `lib/features/stats/metric_line_chart.dart` — (crear) gráfica de línea reutilizable (fl_chart).
- `lib/features/stats/body_metrics_screen.dart` — (crear) peso corporal + medidas.
- `lib/features/stats/strength_stats_screen.dart` — (crear) PR + 1RM + volumen por ejercicio.
- `lib/features/stats/stats_screen.dart` — (crear) hub de Progreso.
- `lib/features/home/home_screen.dart` — (modificar) acceso a Progreso.
- `pubspec.yaml` — (modificar) `fl_chart`.
- Tests: `test/core/stats/stats_test.dart`, `test/core/db/exercise_log_test.dart`, `test/features/session_log_test.dart`, `test/features/body_metrics_screen_test.dart`, `test/features/strength_stats_screen_test.dart`.

---

### Task 1: Motor de estadísticas (puro)

**Files:**
- Create: `lib/core/stats/exercise_log.dart`
- Create: `lib/core/stats/stats.dart`
- Test: `test/core/stats/stats_test.dart`

**Interfaces:**
- Produces:
  - `class ExerciseLog { final String exerciseId; final String exerciseName; final DateTime performedAt; final double weight; final int totalReps; final int sets; final int maxReps; const ExerciseLog({required ...}); }`.
  - `double estimatedOneRm(double weight, int reps)` (Epley).
  - `double bestOneRm(List<ExerciseLog> logs)` (máx `estimatedOneRm(weight, maxReps)`; 0 si vacío).
  - `double totalVolume(List<ExerciseLog> logs)` (suma `weight * totalReps`).
  - `List<({DateTime date, double oneRm})> oneRmSeries(List<ExerciseLog> logs)` (orden ascendente por fecha).

- [ ] **Step 1: Write the failing test**

Crear `test/core/stats/stats_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/core/stats/exercise_log.dart';
import 'package:fragua/core/stats/stats.dart';

ExerciseLog log(double w, int maxReps, int totalReps, DateTime at) => ExerciseLog(
      exerciseId: 'bench',
      exerciseName: 'Bench',
      performedAt: at,
      weight: w,
      totalReps: totalReps,
      sets: 3,
      maxReps: maxReps,
    );

void main() {
  test('Epley: 100kg x 10 ≈ 133.3', () {
    expect(estimatedOneRm(100, 10), closeTo(133.33, 0.01));
    expect(estimatedOneRm(60, 1), closeTo(62.0, 0.01));
  });

  test('bestOneRm escoge el máximo estimado', () {
    final logs = [
      log(100, 5, 15, DateTime(2026, 6, 1)), // 100*(1+5/30)=116.67
      log(90, 12, 36, DateTime(2026, 6, 8)), // 90*(1+12/30)=126.0
    ];
    expect(bestOneRm(logs), closeTo(126.0, 0.01));
    expect(bestOneRm(const []), 0);
  });

  test('totalVolume suma peso*reps', () {
    final logs = [
      log(100, 8, 24, DateTime(2026, 6, 1)), // 2400
      log(80, 10, 30, DateTime(2026, 6, 8)), // 2400
    ];
    expect(totalVolume(logs), 4800);
  });

  test('oneRmSeries va ordenada por fecha ascendente', () {
    final logs = [
      log(100, 5, 15, DateTime(2026, 6, 8)),
      log(90, 12, 36, DateTime(2026, 6, 1)),
    ];
    final s = oneRmSeries(logs);
    expect(s.map((e) => e.date).toList(),
        [DateTime(2026, 6, 1), DateTime(2026, 6, 8)]);
    expect(s.first.oneRm, closeTo(126.0, 0.01));
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/stats/stats_test.dart`
Expected: FAIL — símbolos no existen.

- [ ] **Step 3: Implement**

Crear `lib/core/stats/exercise_log.dart`:
```dart
/// Resumen de un ejercicio realizado en una sesión (una fila por ejercicio/sesión).
class ExerciseLog {
  final String exerciseId;
  final String exerciseName;
  final DateTime performedAt;
  final double weight;
  final int totalReps;
  final int sets;
  final int maxReps;

  const ExerciseLog({
    required this.exerciseId,
    required this.exerciseName,
    required this.performedAt,
    required this.weight,
    required this.totalReps,
    required this.sets,
    required this.maxReps,
  });
}
```

Crear `lib/core/stats/stats.dart`:
```dart
import 'exercise_log.dart';

/// 1RM estimado por la fórmula de Epley.
double estimatedOneRm(double weight, int reps) => weight * (1 + reps / 30.0);

/// Mejor 1RM estimado (PR) sobre una lista de logs; 0 si está vacía.
double bestOneRm(List<ExerciseLog> logs) {
  var best = 0.0;
  for (final l in logs) {
    final e = estimatedOneRm(l.weight, l.maxReps);
    if (e > best) best = e;
  }
  return best;
}

/// Volumen total (suma de peso * repeticiones totales).
double totalVolume(List<ExerciseLog> logs) {
  var v = 0.0;
  for (final l in logs) {
    v += l.weight * l.totalReps;
  }
  return v;
}

/// Serie temporal de 1RM estimado, ordenada por fecha ascendente.
List<({DateTime date, double oneRm})> oneRmSeries(List<ExerciseLog> logs) {
  final sorted = [...logs]..sort((a, b) => a.performedAt.compareTo(b.performedAt));
  return [
    for (final l in sorted)
      (date: l.performedAt, oneRm: estimatedOneRm(l.weight, l.maxReps)),
  ];
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/core/stats/stats_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/core/stats/exercise_log.dart lib/core/stats/stats.dart test/core/stats/stats_test.dart
git commit -m "feat(core): motor de estadisticas (Epley/PR/volumen/series)

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 2: Persistencia de logs y medidas (migración v6)

**Files:**
- Modify: `lib/core/db/database.dart`
- Regenerate: `lib/core/db/database.g.dart`
- Test: `test/core/db/exercise_log_test.dart`

**Interfaces:**
- Consumes: `ExerciseLog` (Task 1).
- Produces: tablas `ExerciseLogs`/`BodyMetrics`; migración v6; métodos:
  - `Future<void> addExerciseLog({required String exerciseId, required String exerciseName, required DateTime performedAt, required double weight, required int totalReps, required int sets, required int maxReps})`
  - `Future<List<ExerciseLog>> loadExerciseLogs(String exerciseId)` (orden ascendente por fecha)
  - `Future<List<({String id, String name})>> loggedExercises()` (ejercicios distintos con log, para el selector)
  - `Future<void> addBodyMetric({required String kind, required double value, required DateTime measuredAt})`
  - `Future<List<({DateTime at, double value})>> loadBodyMetrics(String kind)` (orden ascendente)

- [ ] **Step 1: Write the failing test**

Crear `test/core/db/exercise_log_test.dart`:
```dart
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/core/db/database.dart';

void main() {
  test('exercise_logs: inserta y lee filtrado por ejercicio y ordenado', () async {
    final db = FraguaDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await db.addExerciseLog(
        exerciseId: 'bench', exerciseName: 'Bench',
        performedAt: DateTime(2026, 6, 8), weight: 100, totalReps: 24,
        sets: 3, maxReps: 8);
    await db.addExerciseLog(
        exerciseId: 'bench', exerciseName: 'Bench',
        performedAt: DateTime(2026, 6, 1), weight: 95, totalReps: 30,
        sets: 3, maxReps: 10);
    await db.addExerciseLog(
        exerciseId: 'squat', exerciseName: 'Squat',
        performedAt: DateTime(2026, 6, 2), weight: 120, totalReps: 15,
        sets: 3, maxReps: 5);

    final bench = await db.loadExerciseLogs('bench');
    expect(bench, hasLength(2));
    expect(bench.first.performedAt, DateTime(2026, 6, 1)); // ascendente
    expect(bench.first.weight, 95);

    final logged = await db.loggedExercises();
    expect(logged.map((e) => e.id).toSet(), {'bench', 'squat'});
  });

  test('body_metrics: inserta y lee por tipo ordenado', () async {
    final db = FraguaDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await db.addBodyMetric(
        kind: 'bodyweight', value: 80.5, measuredAt: DateTime(2026, 6, 8));
    await db.addBodyMetric(
        kind: 'bodyweight', value: 81.0, measuredAt: DateTime(2026, 6, 1));
    await db.addBodyMetric(
        kind: 'waist', value: 85, measuredAt: DateTime(2026, 6, 1));

    final bw = await db.loadBodyMetrics('bodyweight');
    expect(bw.map((e) => e.value).toList(), [81.0, 80.5]); // ascendente por fecha
    expect(await db.loadBodyMetrics('waist'), hasLength(1));
  });
}
```

- [ ] **Step 2: Add tables, methods and migration**

En `lib/core/db/database.dart`:

- Importa el DTO al principio (junto a los otros imports de core):
```dart
import '../stats/exercise_log.dart';
```

- Añade las tablas (junto a `Achievements`):
```dart
@DataClassName('ExerciseLogRow2')
class ExerciseLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get exerciseId => text().named('exercise_id')();
  TextColumn get exerciseName => text().named('exercise_name')();
  DateTimeColumn get performedAt => dateTime().named('performed_at')();
  RealColumn get weight => real().named('weight')();
  IntColumn get totalReps => integer().named('total_reps')();
  IntColumn get sets => integer().named('sets')();
  IntColumn get maxReps => integer().named('max_reps')();
}

@DataClassName('BodyMetricRow')
class BodyMetrics extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get kind => text().named('kind')();
  RealColumn get value => real().named('value')();
  DateTimeColumn get measuredAt => dateTime().named('measured_at')();
}
```
(Nota: `@DataClassName('ExerciseLogRow2')` evita colisión con `ExerciseStateRow`/`ExerciseRow` existentes; el DTO de dominio se llama `ExerciseLog`.)

- Regístralas en `@DriftDatabase` (añade `ExerciseLogs, BodyMetrics` a la lista).

- Sube `schemaVersion` a `6`.

- Añade en `onUpgrade` (tras el bloque `if (from < 5)`):
```dart
          if (from < 6) {
            await m.createTable(exerciseLogs);
            await m.createTable(bodyMetrics);
          }
```

- Añade los métodos en `FraguaDatabase` (tras `unlockAchievement`):
```dart
  Future<void> addExerciseLog({
    required String exerciseId,
    required String exerciseName,
    required DateTime performedAt,
    required double weight,
    required int totalReps,
    required int sets,
    required int maxReps,
  }) async {
    await into(exerciseLogs).insert(
      ExerciseLogsCompanion.insert(
        exerciseId: exerciseId,
        exerciseName: exerciseName,
        performedAt: performedAt,
        weight: weight,
        totalReps: totalReps,
        sets: sets,
        maxReps: maxReps,
      ),
    );
  }

  Future<List<ExerciseLog>> loadExerciseLogs(String exerciseId) async {
    final rows = await (select(exerciseLogs)
          ..where((t) => t.exerciseId.equals(exerciseId))
          ..orderBy([(t) => OrderingTerm(expression: t.performedAt)]))
        .get();
    return [
      for (final r in rows)
        ExerciseLog(
          exerciseId: r.exerciseId,
          exerciseName: r.exerciseName,
          performedAt: r.performedAt,
          weight: r.weight,
          totalReps: r.totalReps,
          sets: r.sets,
          maxReps: r.maxReps,
        ),
    ];
  }

  Future<List<({String id, String name})>> loggedExercises() async {
    final q = selectOnly(exerciseLogs, distinct: true)
      ..addColumns([exerciseLogs.exerciseId, exerciseLogs.exerciseName]);
    final rows = await q.get();
    return [
      for (final r in rows)
        (
          id: r.read(exerciseLogs.exerciseId)!,
          name: r.read(exerciseLogs.exerciseName)!,
        ),
    ];
  }

  Future<void> addBodyMetric({
    required String kind,
    required double value,
    required DateTime measuredAt,
  }) async {
    await into(bodyMetrics).insert(
      BodyMetricsCompanion.insert(
        kind: kind,
        value: value,
        measuredAt: measuredAt,
      ),
    );
  }

  Future<List<({DateTime at, double value})>> loadBodyMetrics(String kind) async {
    final rows = await (select(bodyMetrics)
          ..where((t) => t.kind.equals(kind))
          ..orderBy([(t) => OrderingTerm(expression: t.measuredAt)]))
        .get();
    return [for (final r in rows) (at: r.measuredAt, value: r.value)];
  }
```

- [ ] **Step 3: Run codegen**

Run: `dart run build_runner build`
Expected: regenera `database.g.dart` con las nuevas tablas/companions.

- [ ] **Step 4: Run tests**

Run: `flutter test test/core/db/`
Expected: PASS (logs + medidas + sin regresiones).

- [ ] **Step 5: Commit**

```bash
git add lib/core/db/database.dart lib/core/db/database.g.dart test/core/db/exercise_log_test.dart
git commit -m "feat(core): persistencia de logs de ejercicio y medidas (migracion v6)

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 3: La sesión de fuerza registra el log

**Files:**
- Modify: `lib/features/workout/session_controller.dart`
- Test: `test/features/session_log_test.dart`

**Interfaces:**
- Consumes: `FraguaDatabase.addExerciseLog`.
- Produces: `WorkoutSessionController.finish()` registra un `exercise_log` por cada ejercicio con series (peso, reps totales, series, reps máximas, fecha actual).

- [ ] **Step 1: Write the failing test**

Crear `test/features/session_log_test.dart`:
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
  test('finish() registra un exercise_log con reps totales y máximas', () async {
    final db = FraguaDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final c = WorkoutSessionController(
        db: db, day: day(), initialWeights: {'bench': 100});
    c.setWeight(100);
    c.logSet(10);
    c.logSet(8);
    c.logSet(6);
    await c.finish();

    final logs = await db.loadExerciseLogs('bench');
    expect(logs, hasLength(1));
    expect(logs.first.weight, 100);
    expect(logs.first.totalReps, 24);
    expect(logs.first.maxReps, 10);
    expect(logs.first.sets, 3);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/session_log_test.dart`
Expected: FAIL — `finish()` aún no registra logs (lista vacía).

- [ ] **Step 3: Implement**

En `lib/features/workout/session_controller.dart`, dentro del bucle de `finish()`, tras `db.saveExerciseState(...)`, añade el registro del log:
```dart
      await db.saveExerciseState(
          e.exerciseId, result.nextWeight, result.nextStallCount);
      final totalReps = reps.fold<int>(0, (a, b) => a + b);
      final maxReps = reps.reduce((a, b) => a > b ? a : b);
      await db.addExerciseLog(
        exerciseId: e.exerciseId,
        exerciseName: e.exerciseName,
        performedAt: DateTime.now(),
        weight: weight,
        totalReps: totalReps,
        sets: reps.length,
        maxReps: maxReps,
      );
```

- [ ] **Step 4: Run tests**

Run: `flutter test test/features/session_log_test.dart test/features/session_controller_test.dart`
Expected: PASS (nuevo + sin regresión del controlador).

- [ ] **Step 5: Commit**

```bash
git add lib/features/workout/session_controller.dart test/features/session_log_test.dart
git commit -m "feat(workout): la sesion de fuerza registra el log de cada ejercicio

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 4: fl_chart + seguimiento de cuerpo (peso + medidas)

**Files:**
- Modify: `pubspec.yaml` (`fl_chart`)
- Create: `lib/features/stats/metric_line_chart.dart`
- Create: `lib/features/stats/body_metrics_screen.dart`
- Modify: `lib/app/providers.dart` (provider de medidas)
- Test: `test/features/body_metrics_screen_test.dart`

**Interfaces:**
- Consumes: `databaseProvider` (`addBodyMetric`/`loadBodyMetrics`).
- Produces:
  - `class MetricLineChart extends StatelessWidget { final List<double> values; const MetricLineChart({super.key, required this.values}); }` (envuelve `LineChart` de fl_chart en alto fijo; si `values` vacío muestra un texto).
  - `final bodyMetricProvider = FutureProvider.family<List<({DateTime at, double value})>, String>((ref, kind) => ref.watch(databaseProvider).loadBodyMetrics(kind));`.
  - `class BodyMetricsScreen extends ConsumerStatefulWidget` (selector de tipo [peso/cintura/brazo/pecho/pierna], campo de valor + botón añadir `key: Key('add-metric')`, y gráfica del tipo seleccionado).

- [ ] **Step 1: Add dependency**

Run: `flutter pub add fl_chart`

- [ ] **Step 2: Add the chart widget + provider**

Crear `lib/features/stats/metric_line_chart.dart`:
```dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Gráfica de línea simple a partir de una serie de valores (en orden temporal).
class MetricLineChart extends StatelessWidget {
  const MetricLineChart({super.key, required this.values});
  final List<double> values;

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('Aún no hay datos')),
      );
    }
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: [
                for (var i = 0; i < values.length; i++)
                  FlSpot(i.toDouble(), values[i]),
              ],
              isCurved: false,
              dotData: const FlDotData(show: true),
            ),
          ],
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
}
```

En `lib/app/providers.dart` añade (al final):
```dart
final bodyMetricProvider =
    FutureProvider.family<List<({DateTime at, double value})>, String>(
        (ref, kind) => ref.watch(databaseProvider).loadBodyMetrics(kind));
```

- [ ] **Step 3: Write the failing widget test**

Crear `test/features/body_metrics_screen_test.dart`:
```dart
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/app/providers.dart';
import 'package:fragua/core/db/database.dart';
import 'package:fragua/features/stats/body_metrics_screen.dart';

void main() {
  testWidgets('añade una medida y la persiste', (tester) async {
    final db = FraguaDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: const MaterialApp(home: BodyMetricsScreen()),
    ));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('metric-value')), '80.5');
    await tester.tap(find.byKey(const Key('add-metric')));
    await tester.pumpAndSettle();

    final bw = await db.loadBodyMetrics('bodyweight');
    expect(bw, hasLength(1));
    expect(bw.first.value, 80.5);
  });
}
```

- [ ] **Step 4: Implement the body metrics screen**

Crear `lib/features/stats/body_metrics_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import 'metric_line_chart.dart';

const _kinds = <String, String>{
  'bodyweight': 'Peso corporal',
  'waist': 'Cintura',
  'arm': 'Brazo',
  'chest': 'Pecho',
  'thigh': 'Pierna',
};

class BodyMetricsScreen extends ConsumerStatefulWidget {
  const BodyMetricsScreen({super.key});

  @override
  ConsumerState<BodyMetricsScreen> createState() => _BodyMetricsScreenState();
}

class _BodyMetricsScreenState extends ConsumerState<BodyMetricsScreen> {
  String _kind = 'bodyweight';
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final v = double.tryParse(_controller.text.replaceAll(',', '.'));
    if (v == null) return;
    await ref
        .read(databaseProvider)
        .addBodyMetric(kind: _kind, value: v, measuredAt: DateTime.now());
    _controller.clear();
    ref.invalidate(bodyMetricProvider(_kind));
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(bodyMetricProvider(_kind));
    return Scaffold(
      appBar: AppBar(title: const Text('Cuerpo')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButton<String>(
            value: _kind,
            isExpanded: true,
            items: [
              for (final e in _kinds.entries)
                DropdownMenuItem(value: e.key, child: Text(e.value)),
            ],
            onChanged: (v) => setState(() => _kind = v ?? 'bodyweight'),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  key: const Key('metric-value'),
                  controller: _controller,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Valor'),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                key: const Key('add-metric'),
                onPressed: _add,
                child: const Text('Añadir'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          data.when(
            loading: () => const SizedBox(
                height: 200, child: Center(child: CircularProgressIndicator())),
            error: (e, _) => Text('Error: $e'),
            data: (rows) =>
                MetricLineChart(values: [for (final r in rows) r.value]),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 5: Run the widget test**

Run: `flutter test test/features/body_metrics_screen_test.dart`
Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add pubspec.yaml pubspec.lock lib/features/stats/metric_line_chart.dart lib/features/stats/body_metrics_screen.dart lib/app/providers.dart test/features/body_metrics_screen_test.dart
git commit -m "feat(stats): seguimiento de peso y medidas con grafica (fl_chart)

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 5: Pantalla de estadísticas de fuerza

**Files:**
- Create: `lib/features/stats/strength_stats_screen.dart`
- Modify: `lib/app/providers.dart` (providers de logs)
- Test: `test/features/strength_stats_screen_test.dart`

**Interfaces:**
- Consumes: `databaseProvider` (`loggedExercises`/`loadExerciseLogs`), `bestOneRm`, `totalVolume`, `oneRmSeries`, `MetricLineChart`.
- Produces:
  - `final loggedExercisesProvider = FutureProvider<List<({String id, String name})>>((ref) => ref.watch(databaseProvider).loggedExercises());`
  - `final exerciseLogsProvider = FutureProvider.family<List<ExerciseLog>, String>((ref, id) => ref.watch(databaseProvider).loadExerciseLogs(id));`
  - `class StrengthStatsScreen extends ConsumerStatefulWidget` (selector de ejercicio con log; muestra **PR** (mejor 1RM), **volumen total** y la **gráfica de 1RM**).

- [ ] **Step 1: Write the failing widget test**

Crear `test/features/strength_stats_screen_test.dart`:
```dart
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/app/providers.dart';
import 'package:fragua/core/db/database.dart';
import 'package:fragua/features/stats/strength_stats_screen.dart';

void main() {
  testWidgets('muestra el PR del ejercicio con log', (tester) async {
    final db = FraguaDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db.addExerciseLog(
        exerciseId: 'bench', exerciseName: 'Bench',
        performedAt: DateTime(2026, 6, 1), weight: 100, totalReps: 24,
        sets: 3, maxReps: 8); // 1RM = 100*(1+8/30)=126.7

    await tester.pumpWidget(ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: const MaterialApp(home: StrengthStatsScreen()),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Bench'), findsWidgets);
    expect(find.textContaining('PR'), findsOneWidget);
    expect(find.textContaining('126'), findsOneWidget); // 1RM estimado redondeado
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/strength_stats_screen_test.dart`
Expected: FAIL — `StrengthStatsScreen` no existe.

- [ ] **Step 3: Add providers + implement the screen**

En `lib/app/providers.dart` añade (importa el DTO y stats arriba):
```dart
import '../core/stats/exercise_log.dart';
```
```dart
final loggedExercisesProvider =
    FutureProvider<List<({String id, String name})>>(
        (ref) => ref.watch(databaseProvider).loggedExercises());

final exerciseLogsProvider = FutureProvider.family<List<ExerciseLog>, String>(
    (ref, id) => ref.watch(databaseProvider).loadExerciseLogs(id));
```

Crear `lib/features/stats/strength_stats_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/stats/stats.dart';
import 'metric_line_chart.dart';

class StrengthStatsScreen extends ConsumerStatefulWidget {
  const StrengthStatsScreen({super.key});

  @override
  ConsumerState<StrengthStatsScreen> createState() =>
      _StrengthStatsScreenState();
}

class _StrengthStatsScreenState extends ConsumerState<StrengthStatsScreen> {
  String? _selected;

  @override
  Widget build(BuildContext context) {
    final exercises = ref.watch(loggedExercisesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Fuerza')),
      body: exercises.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('Aún no hay entrenos registrados'));
          }
          final selected = _selected ?? list.first.id;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              DropdownButton<String>(
                value: selected,
                isExpanded: true,
                items: [
                  for (final e in list)
                    DropdownMenuItem(value: e.id, child: Text(e.name)),
                ],
                onChanged: (v) => setState(() => _selected = v),
              ),
              const SizedBox(height: 8),
              _stats(selected),
            ],
          );
        },
      ),
    );
  }

  Widget _stats(String exerciseId) {
    final logs = ref.watch(exerciseLogsProvider(exerciseId));
    return logs.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Error: $e'),
      data: (data) {
        final pr = bestOneRm(data);
        final vol = totalVolume(data);
        final series = oneRmSeries(data);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('PR (1RM estimado): ${pr.toStringAsFixed(1)} kg',
                style: Theme.of(context).textTheme.titleMedium),
            Text('Volumen total: ${vol.toStringAsFixed(0)} kg'),
            const SizedBox(height: 16),
            MetricLineChart(values: [for (final s in series) s.oneRm]),
          ],
        );
      },
    );
  }
}
```

- [ ] **Step 4: Run the widget test**

Run: `flutter test test/features/strength_stats_screen_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/stats/strength_stats_screen.dart lib/app/providers.dart test/features/strength_stats_screen_test.dart
git commit -m "feat(stats): pantalla de fuerza (PR + 1RM + volumen)

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 6: Hub de Progreso + acceso desde Home + verificación M7

**Files:**
- Create: `lib/features/stats/stats_screen.dart`
- Modify: `lib/features/home/home_screen.dart` (acceso a Progreso)
- Test: (cubierto por las pantallas; verificación global)

**Interfaces:**
- Consumes: `StrengthStatsScreen`, `BodyMetricsScreen`.
- Produces: `class StatsScreen extends StatelessWidget` con dos accesos (Fuerza / Cuerpo). Home gana un botón "Progreso" (`key: Key('stats-button')`).

- [ ] **Step 1: Implement the hub**

Crear `lib/features/stats/stats_screen.dart`:
```dart
import 'package:flutter/material.dart';

import 'body_metrics_screen.dart';
import 'strength_stats_screen.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Progreso')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.fitness_center),
            title: const Text('Fuerza'),
            subtitle: const Text('PR, 1RM estimado y volumen'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const StrengthStatsScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.monitor_weight),
            title: const Text('Cuerpo'),
            subtitle: const Text('Peso corporal y medidas'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const BodyMetricsScreen()),
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Link from Home**

En `lib/features/home/home_screen.dart`:
- Importa el hub:
```dart
import '../stats/stats_screen.dart';
```
- Tras el botón "Liga" (dentro de la `Column`), añade:
```dart
            const SizedBox(height: 8),
            OutlinedButton.icon(
              key: const Key('stats-button'),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const StatsScreen()),
              ),
              icon: const Icon(Icons.show_chart),
              label: const Text('Progreso'),
            ),
```

- [ ] **Step 3: Full verification (Definition of Done de M7)**

Run: `flutter test`
Expected: verde (stats, persistencia v6, log de sesión, pantallas de cuerpo y fuerza, sin regresiones).

Run: `flutter analyze`
Expected: `No issues found!`

Run: `tools/.venv/bin/python -m pytest tools/ -q`
Expected: verde.

- [ ] **Step 4: Commit**

```bash
git add lib/features/stats/stats_screen.dart lib/features/home/home_screen.dart
git commit -m "feat(stats): hub de Progreso + acceso desde Home

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

## Verificación de M7 (Definition of Done)

- `flutter analyze` limpio · `flutter test` verde (stats puras, persistencia v6, log de sesión, pantallas de fuerza y cuerpo) · `pytest` verde.
- Cada sesión de fuerza deja un `exercise_log`; la pantalla de **Fuerza** muestra PR (1RM Epley), volumen y la evolución del 1RM por ejercicio.
- La pantalla de **Cuerpo** permite registrar peso corporal y medidas y ver su gráfica.
- Mergeado a `master`; push a `origin` (con el OK de Alberto).

## Cobertura de la spec (self-review)

- **§7.7 seguimiento** — fuerza (PR, 1RM Epley, volumen, evolución temporal) → Tasks 1, 3, 5; peso corporal + medidas → Tasks 2, 4; pantalla de estadísticas con fl_chart → Tasks 4, 5, 6.
- **§8 modelo** (`body_metric`) → Task 2; el historial de fuerza se materializa como `exercise_logs` (una fila por ejercicio/sesión: peso, reps totales/máximas, series), suficiente para PR/1RM/volumen/series.
- **Fuera de M7** (explícito, documentado): **fotos de progreso** (`progress_photo`) — requieren `image_picker`/cámara (no testeable en widget tests, plugin extra) y la spec las marca *off por defecto* y consumidoras de espacio; quedan como mejora aparte. Volumen por grupo muscular (se ofrece volumen por ejercicio; el agrupado por músculo necesita el join con el catálogo y se puede añadir luego). 1RM por otras fórmulas además de Epley.
