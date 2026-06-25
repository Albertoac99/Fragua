# Fragua M6 — Ligas + gamificación: Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Tras cada entreno, ganar **XP**, mantener **racha** y desbloquear **logros**; competir en una **liga semanal** (divisiones bronce→leyenda) contra ~19 **rivales simulados** reproducibles por semilla, con **ascensos/descensos** al cambiar de semana. Todo **offline y determinista**.

**Architecture:** El núcleo es **Dart puro y determinista** en `lib/core/leagues/`: XP por sesión, generación de la cohorte de bots (sembrada con el `weekId`), leaderboard, zonas de ascenso/descenso, racha y logros. La persistencia (drift, migración **v5**) guarda el estado de liga + racha + contadores en una fila única `league_states`, el historial en `xp_entries` y los `achievements` desbloqueados. Los bots **no se almacenan**: se regeneran deterministamente desde `weekId`+división. Un `LeaguesService` (feature) orquesta: detecta cambio de semana (rollover → asc/desc), suma XP, actualiza racha/contadores y desbloquea logros; lo invocan las pantallas de sesión tras `finish()`. La `LeaguesScreen` muestra división, leaderboard (tú + bots), tu zona, racha y logros.

**Tech Stack:** Dart puro (XP/bots/leaderboard/racha/logros) · `dart:math` (Random sembrado) · drift · flutter_riverpod · flutter_test.

## Global Constraints

- `lib/core/**` NUNCA importa Flutter. Lógica de ligas **pura y determinista** (sembrada con `weekId`): mismos inputs → mismo leaderboard, **testeable**.
- Bots **reproducibles**: generados con `Random(seed)` donde `seed` deriva de `weekId` y división; **no se persisten**.
- Persistencia drift: columnas snake_case con `.named(...)`, fila única `id=0` para `league_states`. Migración **versionada** (`if (from < 5)`).
- Integración **no intrusiva**: los controladores de sesión (M3/M4) y sus tests no cambian de firma; el premio de XP lo disparan las **pantallas** tras `finish()`. `leaguesServiceProvider` usa el `databaseProvider` ya existente (en tests las tablas existen vía `createAll`).
- Commits frecuentes, uno por tarea. Mensajes terminan con `Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>`.

---

## File Structure

- `lib/core/models/enums.dart` — (modificar) `Division`, `BotArchetype`, `XpSource`, `AchievementType`.
- `lib/core/leagues/divisions.dart` — (crear) `promote`/`relegate`/`weekIdFor`.
- `lib/core/leagues/xp.dart` — (crear) `computeSessionXp(...)`.
- `lib/core/leagues/bots.dart` — (crear) `LeagueBot`, `generateCohort(...)`.
- `lib/core/leagues/leaderboard.dart` — (crear) `LeagueStanding`, `buildLeaderboard(...)`, `LeagueZone`, `zoneFor(...)`, `applyWeekRollover(...)`.
- `lib/core/leagues/streak.dart` — (crear) `StreakResult`, `updateStreak(...)`, `dayNumber(...)`.
- `lib/core/leagues/achievements.dart` — (crear) `unlockedAchievements(...)`.
- `lib/core/db/database.dart` — (modificar) tablas `LeagueStates`/`XpEntries`/`Achievements` + métodos; migración v5.
- `lib/core/db/database.g.dart` — (regenerar).
- `lib/features/leagues/leagues_service.dart` — (crear) `LeaguesService` + `awardForSession`/`ensureCurrentWeek`.
- `lib/app/providers.dart` — (modificar) `leaguesServiceProvider`.
- `lib/features/leagues/leagues_screen.dart` — (crear) UI de liga + racha + logros.
- `lib/features/workout/session_screen.dart` — (modificar) premiar XP tras `_finish`.
- `lib/features/workout/guided_session_screen.dart` — (modificar) premiar XP tras `_finishAndLeave`.
- `lib/features/workout/session_controller.dart` — (modificar) `int get prCount` (PRs de la sesión).
- `lib/features/home/home_screen.dart` — (modificar) acceso a Liga + racha.
- Tests: `test/core/leagues/divisions_test.dart`, `xp_test.dart`, `bots_test.dart`, `leaderboard_test.dart`, `streak_test.dart`, `achievements_test.dart`, `test/core/db/league_state_test.dart`, `test/features/leagues_service_test.dart`, `test/features/leagues_screen_test.dart`.

---

### Task 1: Enums + helpers de división/semana

**Files:**
- Modify: `lib/core/models/enums.dart`
- Create: `lib/core/leagues/divisions.dart`
- Test: `test/core/leagues/divisions_test.dart`

**Interfaces:**
- Produces: `enum Division { bronze, silver, gold, platinum, diamond, legend }`; `enum BotArchetype { steady, sporadic, beginner, grinder }`; `enum XpSource { workout, set, pr, streak }`; `enum AchievementType { firstWorkout, tenWorkouts, fiftyWorkouts, hundredWorkouts, firstPr, streak7, streak30 }`; `Division? promote(Division)` (null en legend); `Division? relegate(Division)` (null en bronze); `int weekIdFor(DateTime)` (nº de semana absoluto desde epoch, UTC).

- [ ] **Step 1: Write the failing test**

Crear `test/core/leagues/divisions_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/core/leagues/divisions.dart';
import 'package:fragua/core/models/enums.dart';

void main() {
  test('promote sube una división y topa en leyenda', () {
    expect(promote(Division.bronze), Division.silver);
    expect(promote(Division.diamond), Division.legend);
    expect(promote(Division.legend), isNull);
  });

  test('relegate baja una división y topa en bronce', () {
    expect(relegate(Division.silver), Division.bronze);
    expect(relegate(Division.bronze), isNull);
  });

  test('weekIdFor es estable dentro de la semana y cambia entre semanas', () {
    final a = DateTime.utc(2026, 6, 22); // lunes
    final b = DateTime.utc(2026, 6, 25); // mismo bloque de 7 días
    final c = DateTime.utc(2026, 7, 6); // dos semanas después
    expect(weekIdFor(a), weekIdFor(b));
    expect(weekIdFor(c), greaterThan(weekIdFor(a)));
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/leagues/divisions_test.dart`
Expected: FAIL — enums/funciones no existen.

- [ ] **Step 3: Implement**

En `lib/core/models/enums.dart`, añade al final:
```dart
/// Divisiones de la liga (orden ascendente).
enum Division { bronze, silver, gold, platinum, diamond, legend }

/// Arquetipo de los rivales simulados (define su distribución de XP semanal).
enum BotArchetype { steady, sporadic, beginner, grinder }

/// Fuente de una entrada de XP.
enum XpSource { workout, set, pr, streak }

/// Logros desbloqueables.
enum AchievementType {
  firstWorkout,
  tenWorkouts,
  fiftyWorkouts,
  hundredWorkouts,
  firstPr,
  streak7,
  streak30,
}
```

Crear `lib/core/leagues/divisions.dart`:
```dart
import '../models/enums.dart';

/// Sube una división; `null` si ya está en la cima (leyenda).
Division? promote(Division d) =>
    d == Division.legend ? null : Division.values[d.index + 1];

/// Baja una división; `null` si ya está en el suelo (bronce).
Division? relegate(Division d) =>
    d == Division.bronze ? null : Division.values[d.index - 1];

/// Identificador absoluto de la semana (bloques de 7 días desde epoch, UTC).
/// Estable dentro de la semana y reproducible (sirve de semilla de la cohorte).
int weekIdFor(DateTime dt) {
  final days = dt.toUtc().difference(DateTime.utc(1970)).inDays;
  return days ~/ 7;
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/core/leagues/divisions_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/core/models/enums.dart lib/core/leagues/divisions.dart test/core/leagues/divisions_test.dart
git commit -m "feat(core): enums de liga + helpers de division/semana

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 2: Motor de XP por sesión

**Files:**
- Create: `lib/core/leagues/xp.dart`
- Test: `test/core/leagues/xp_test.dart`

**Interfaces:**
- Produces: `int computeSessionXp({required int unitsCompleted, required int prCount, required bool completed, required int streakDays, int base = 50, int perUnit = 5, int perPr = 20, int streakCap = 7, int perStreakDay = 2})`.

- [ ] **Step 1: Write the failing test**

Crear `test/core/leagues/xp_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/core/leagues/xp.dart';

void main() {
  test('entreno completado: base + unidades + PR + racha (con tope)', () {
    // 50 base + 8*5 + 2*20 + min(10,7)*2 = 50+40+40+14 = 144
    final xp = computeSessionXp(
        unitsCompleted: 8, prCount: 2, completed: true, streakDays: 10);
    expect(xp, 144);
  });

  test('sin completar pero con unidades: sin base', () {
    // 0 + 3*5 + 0 + 0 = 15
    final xp = computeSessionXp(
        unitsCompleted: 3, prCount: 0, completed: false, streakDays: 0);
    expect(xp, 15);
  });

  test('sin completar y sin unidades: 0', () {
    expect(
        computeSessionXp(
            unitsCompleted: 0, prCount: 0, completed: false, streakDays: 5),
        0);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/leagues/xp_test.dart`
Expected: FAIL — `computeSessionXp` no existe.

- [ ] **Step 3: Implement**

Crear `lib/core/leagues/xp.dart`:
```dart
/// XP de una sesión: base por completar + por unidad (serie/bloque) + por PR +
/// bonus de racha (con tope). Determinista.
int computeSessionXp({
  required int unitsCompleted,
  required int prCount,
  required bool completed,
  required int streakDays,
  int base = 50,
  int perUnit = 5,
  int perPr = 20,
  int streakCap = 7,
  int perStreakDay = 2,
}) {
  if (!completed && unitsCompleted == 0) return 0;
  var xp = completed ? base : 0;
  xp += unitsCompleted * perUnit;
  xp += prCount * perPr;
  xp += streakDays.clamp(0, streakCap) * perStreakDay;
  return xp;
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/core/leagues/xp_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/core/leagues/xp.dart test/core/leagues/xp_test.dart
git commit -m "feat(core): motor de XP por sesion

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 3: Cohorte de bots (sembrada, reproducible)

**Files:**
- Create: `lib/core/leagues/bots.dart`
- Test: `test/core/leagues/bots_test.dart`

**Interfaces:**
- Consumes: `Division`, `BotArchetype`.
- Produces: `class LeagueBot { final String name; final BotArchetype archetype; final int weeklyXp; const LeagueBot({required this.name, required this.archetype, required this.weeklyXp}); }`; `List<LeagueBot> generateCohort({required int weekId, required Division division, int count = 19})` — determinista (misma entrada → misma lista), nombres únicos, `weeklyXp >= 0` con rango según arquetipo.

- [ ] **Step 1: Write the failing test**

Crear `test/core/leagues/bots_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/core/leagues/bots.dart';
import 'package:fragua/core/models/enums.dart';

void main() {
  test('es reproducible: misma semana+división => misma cohorte', () {
    final a = generateCohort(weekId: 100, division: Division.gold);
    final b = generateCohort(weekId: 100, division: Division.gold);
    expect(a.map((e) => '${e.name}:${e.weeklyXp}:${e.archetype}').toList(),
        b.map((e) => '${e.name}:${e.weeklyXp}:${e.archetype}').toList());
  });

  test('cambia entre semanas o divisiones', () {
    final a = generateCohort(weekId: 100, division: Division.gold);
    final c = generateCohort(weekId: 101, division: Division.gold);
    final d = generateCohort(weekId: 100, division: Division.silver);
    expect(a.map((e) => e.weeklyXp).toList() == c.map((e) => e.weeklyXp).toList(),
        isFalse);
    expect(a.map((e) => e.weeklyXp).toList() == d.map((e) => e.weeklyXp).toList(),
        isFalse);
  });

  test('genera el número pedido, nombres únicos y XP no negativa', () {
    final cohort = generateCohort(weekId: 7, division: Division.bronze, count: 19);
    expect(cohort, hasLength(19));
    expect(cohort.map((e) => e.name).toSet(), hasLength(19));
    expect(cohort.every((e) => e.weeklyXp >= 0), isTrue);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/leagues/bots_test.dart`
Expected: FAIL — `generateCohort` no existe.

- [ ] **Step 3: Implement**

Crear `lib/core/leagues/bots.dart`:
```dart
import 'dart:math';

import '../models/enums.dart';

class LeagueBot {
  final String name;
  final BotArchetype archetype;
  final int weeklyXp;
  const LeagueBot({
    required this.name,
    required this.archetype,
    required this.weeklyXp,
  });
}

const _names = <String>[
  'Lucas', 'Marta', 'Diego', 'Sara', 'Pablo', 'Lucía', 'Hugo', 'Elena',
  'Mario', 'Carla', 'Iván', 'Nora', 'Bruno', 'Alba', 'Gael', 'Vega',
  'Leo', 'Daniela', 'Adrián', 'Noa', 'Marco', 'Irene', 'Nico', 'Julia',
  'Raúl', 'Olga', 'Saúl', 'Lola',
];

/// Rango [min, max] de XP semanal por arquetipo.
({int min, int max}) _xpRange(BotArchetype a) {
  switch (a) {
    case BotArchetype.beginner:
      return (min: 60, max: 260);
    case BotArchetype.sporadic:
      return (min: 100, max: 700);
    case BotArchetype.steady:
      return (min: 300, max: 520);
    case BotArchetype.grinder:
      return (min: 560, max: 900);
  }
}

/// Genera la cohorte semanal de rivales simulados de forma **determinista**:
/// la semilla deriva de [weekId] y [division], así el leaderboard es estable
/// durante la semana y reproducible en tests.
List<LeagueBot> generateCohort({
  required int weekId,
  required Division division,
  int count = 19,
}) {
  final rng = Random(weekId * 1000003 + division.index * 97 + 17);
  final archetypes = BotArchetype.values;
  final bots = <LeagueBot>[];
  for (var i = 0; i < count; i++) {
    final name = _names[(rng.nextInt(_names.length) + i) % _names.length];
    final archetype = archetypes[rng.nextInt(archetypes.length)];
    final r = _xpRange(archetype);
    final xp = r.min + rng.nextInt(r.max - r.min + 1);
    bots.add(LeagueBot(name: name, archetype: archetype, weeklyXp: xp));
  }
  // Garantiza nombres únicos sufijándolos si se repiten (determinista por orden).
  final seen = <String, int>{};
  return [
    for (final b in bots)
      if ((seen[b.name] = (seen[b.name] ?? 0) + 1) == 1)
        b
      else
        LeagueBot(
            name: '${b.name} ${seen[b.name]}',
            archetype: b.archetype,
            weeklyXp: b.weeklyXp),
  ];
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/core/leagues/bots_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/core/leagues/bots.dart test/core/leagues/bots_test.dart
git commit -m "feat(core): cohorte de bots sembrada y reproducible

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 4: Leaderboard + zonas de ascenso/descenso

**Files:**
- Create: `lib/core/leagues/leaderboard.dart`
- Test: `test/core/leagues/leaderboard_test.dart`

**Interfaces:**
- Consumes: `LeagueBot`, `Division`, `promote`, `relegate`, `BotArchetype`.
- Produces: `class LeagueStanding { final int rank; final String name; final int xp; final bool isUser; final BotArchetype? archetype; const LeagueStanding({required this.rank, required this.name, required this.xp, required this.isUser, this.archetype}); }`; `List<LeagueStanding> buildLeaderboard({required List<LeagueBot> bots, required int userXp, String userName = 'Tú'})` (orden desc por XP, empate a favor del usuario, ranks 1..n); `enum LeagueZone { promote, hold, relegate }`; `LeagueZone zoneFor({required int rank, required int cohortSize, required Division division, int promoteTop = 5, int relegateBottom = 5})`; `Division applyWeekRollover({required Division current, required int finalRank, required int cohortSize, int promoteTop = 5, int relegateBottom = 5})`.

- [ ] **Step 1: Write the failing test**

Crear `test/core/leagues/leaderboard_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/core/leagues/bots.dart';
import 'package:fragua/core/leagues/leaderboard.dart';
import 'package:fragua/core/models/enums.dart';

List<LeagueBot> bots(List<int> xps) => [
      for (var i = 0; i < xps.length; i++)
        LeagueBot(
            name: 'B$i', archetype: BotArchetype.steady, weeklyXp: xps[i]),
    ];

void main() {
  test('ordena desc, marca al usuario y asigna ranks', () {
    final lb = buildLeaderboard(bots: bots([100, 300, 200]), userXp: 250);
    expect(lb.map((e) => e.xp).toList(), [300, 250, 200, 100]);
    expect(lb[1].isUser, isTrue);
    expect(lb.first.rank, 1);
    expect(lb.last.rank, 4);
  });

  test('empate: el usuario queda por delante del bot', () {
    final lb = buildLeaderboard(bots: bots([200]), userXp: 200);
    expect(lb.first.isUser, isTrue);
  });

  test('zonas: top asciende, cola desciende, medio se mantiene', () {
    expect(zoneFor(rank: 3, cohortSize: 20, division: Division.gold),
        LeagueZone.promote);
    expect(zoneFor(rank: 18, cohortSize: 20, division: Division.gold),
        LeagueZone.relegate);
    expect(zoneFor(rank: 10, cohortSize: 20, division: Division.gold),
        LeagueZone.hold);
  });

  test('bronce no desciende y leyenda no asciende', () {
    expect(zoneFor(rank: 20, cohortSize: 20, division: Division.bronze),
        LeagueZone.hold);
    expect(zoneFor(rank: 1, cohortSize: 20, division: Division.legend),
        LeagueZone.hold);
  });

  test('applyWeekRollover mueve la división según la zona', () {
    expect(
        applyWeekRollover(current: Division.gold, finalRank: 2, cohortSize: 20),
        Division.platinum);
    expect(
        applyWeekRollover(current: Division.gold, finalRank: 19, cohortSize: 20),
        Division.silver);
    expect(
        applyWeekRollover(current: Division.gold, finalRank: 10, cohortSize: 20),
        Division.gold);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/leagues/leaderboard_test.dart`
Expected: FAIL — símbolos no existen.

- [ ] **Step 3: Implement**

Crear `lib/core/leagues/leaderboard.dart`:
```dart
import '../models/enums.dart';
import 'bots.dart';
import 'divisions.dart';

class LeagueStanding {
  final int rank;
  final String name;
  final int xp;
  final bool isUser;
  final BotArchetype? archetype;
  const LeagueStanding({
    required this.rank,
    required this.name,
    required this.xp,
    required this.isUser,
    this.archetype,
  });
}

/// Construye el leaderboard (bots + usuario) ordenado por XP desc. En empate el
/// usuario va por delante; el resto se desempata por nombre (determinista).
List<LeagueStanding> buildLeaderboard({
  required List<LeagueBot> bots,
  required int userXp,
  String userName = 'Tú',
}) {
  final entries = <({String name, int xp, bool isUser, BotArchetype? a})>[
    (name: userName, xp: userXp, isUser: true, a: null),
    for (final b in bots) (name: b.name, xp: b.weeklyXp, isUser: false, a: b.archetype),
  ];
  entries.sort((x, y) {
    if (x.xp != y.xp) return y.xp.compareTo(x.xp); // desc
    if (x.isUser != y.isUser) return x.isUser ? -1 : 1; // usuario primero
    return x.name.compareTo(y.name);
  });
  return [
    for (var i = 0; i < entries.length; i++)
      LeagueStanding(
        rank: i + 1,
        name: entries[i].name,
        xp: entries[i].xp,
        isUser: entries[i].isUser,
        archetype: entries[i].a,
      ),
  ];
}

enum LeagueZone { promote, hold, relegate }

/// Zona del puesto [rank] (1-based) en una cohorte de [cohortSize]: ascenso si
/// está en el top [promoteTop] (salvo leyenda), descenso si está en la cola
/// [relegateBottom] (salvo bronce), si no se mantiene.
LeagueZone zoneFor({
  required int rank,
  required int cohortSize,
  required Division division,
  int promoteTop = 5,
  int relegateBottom = 5,
}) {
  if (division != Division.legend && rank <= promoteTop) return LeagueZone.promote;
  if (division != Division.bronze && rank > cohortSize - relegateBottom) {
    return LeagueZone.relegate;
  }
  return LeagueZone.hold;
}

/// Nueva división tras cerrar la semana, según la zona del puesto final.
Division applyWeekRollover({
  required Division current,
  required int finalRank,
  required int cohortSize,
  int promoteTop = 5,
  int relegateBottom = 5,
}) {
  switch (zoneFor(
      rank: finalRank,
      cohortSize: cohortSize,
      division: current,
      promoteTop: promoteTop,
      relegateBottom: relegateBottom)) {
    case LeagueZone.promote:
      return promote(current) ?? current;
    case LeagueZone.relegate:
      return relegate(current) ?? current;
    case LeagueZone.hold:
      return current;
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/core/leagues/leaderboard_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/core/leagues/leaderboard.dart test/core/leagues/leaderboard_test.dart
git commit -m "feat(core): leaderboard + zonas de ascenso/descenso

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 5: Racha + logros (puro)

**Files:**
- Create: `lib/core/leagues/streak.dart`
- Create: `lib/core/leagues/achievements.dart`
- Test: `test/core/leagues/streak_test.dart`
- Test: `test/core/leagues/achievements_test.dart`

**Interfaces:**
- Produces:
  - `int dayNumber(DateTime)` (día absoluto desde epoch, UTC); `class StreakResult { final int current; final int record; const StreakResult(this.current, this.record); }`; `StreakResult updateStreak({required int today, int? lastActiveDay, required int current, required int record})`.
  - `Set<AchievementType> unlockedAchievements({required int totalWorkouts, required int streakRecord, required int totalPrs})`.

- [ ] **Step 1: Write the failing tests**

Crear `test/core/leagues/streak_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/core/leagues/streak.dart';

void main() {
  test('primer día: racha 1', () {
    final r = updateStreak(today: 100, lastActiveDay: null, current: 0, record: 0);
    expect(r.current, 1);
    expect(r.record, 1);
  });

  test('día consecutivo: +1 y actualiza récord', () {
    final r = updateStreak(today: 101, lastActiveDay: 100, current: 1, record: 1);
    expect(r.current, 2);
    expect(r.record, 2);
  });

  test('mismo día: no cambia', () {
    final r = updateStreak(today: 100, lastActiveDay: 100, current: 3, record: 5);
    expect(r.current, 3);
    expect(r.record, 5);
  });

  test('hueco: se reinicia a 1 pero conserva el récord', () {
    final r = updateStreak(today: 105, lastActiveDay: 100, current: 4, record: 4);
    expect(r.current, 1);
    expect(r.record, 4);
  });
}
```

Crear `test/core/leagues/achievements_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/core/leagues/achievements.dart';
import 'package:fragua/core/models/enums.dart';

void main() {
  test('primer entreno y primer PR', () {
    final a = unlockedAchievements(totalWorkouts: 1, streakRecord: 0, totalPrs: 1);
    expect(a, contains(AchievementType.firstWorkout));
    expect(a, contains(AchievementType.firstPr));
    expect(a, isNot(contains(AchievementType.tenWorkouts)));
  });

  test('hitos de volumen y racha', () {
    final a =
        unlockedAchievements(totalWorkouts: 50, streakRecord: 7, totalPrs: 0);
    expect(a, containsAll([
      AchievementType.firstWorkout,
      AchievementType.tenWorkouts,
      AchievementType.fiftyWorkouts,
      AchievementType.streak7,
    ]));
    expect(a, isNot(contains(AchievementType.hundredWorkouts)));
    expect(a, isNot(contains(AchievementType.streak30)));
  });

  test('sin actividad: vacío', () {
    expect(unlockedAchievements(totalWorkouts: 0, streakRecord: 0, totalPrs: 0),
        isEmpty);
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/core/leagues/streak_test.dart test/core/leagues/achievements_test.dart`
Expected: FAIL — símbolos no existen.

- [ ] **Step 3: Implement**

Crear `lib/core/leagues/streak.dart`:
```dart
/// Día absoluto desde epoch (UTC), para comparar fechas sin la hora.
int dayNumber(DateTime dt) => dt.toUtc().difference(DateTime.utc(1970)).inDays;

class StreakResult {
  final int current;
  final int record;
  const StreakResult(this.current, this.record);
}

/// Actualiza la racha al registrar actividad en [today] (día absoluto):
/// primer día o hueco => 1; día consecutivo => +1; mismo día => sin cambio.
StreakResult updateStreak({
  required int today,
  int? lastActiveDay,
  required int current,
  required int record,
}) {
  int next;
  if (lastActiveDay == null) {
    next = 1;
  } else {
    final diff = today - lastActiveDay;
    if (diff == 0) {
      next = current;
    } else if (diff == 1) {
      next = current + 1;
    } else {
      next = 1;
    }
  }
  return StreakResult(next, next > record ? next : record);
}
```

Crear `lib/core/leagues/achievements.dart`:
```dart
import '../models/enums.dart';

/// Logros desbloqueados a partir de los contadores acumulados. Determinista.
Set<AchievementType> unlockedAchievements({
  required int totalWorkouts,
  required int streakRecord,
  required int totalPrs,
}) {
  final out = <AchievementType>{};
  if (totalWorkouts >= 1) out.add(AchievementType.firstWorkout);
  if (totalWorkouts >= 10) out.add(AchievementType.tenWorkouts);
  if (totalWorkouts >= 50) out.add(AchievementType.fiftyWorkouts);
  if (totalWorkouts >= 100) out.add(AchievementType.hundredWorkouts);
  if (totalPrs >= 1) out.add(AchievementType.firstPr);
  if (streakRecord >= 7) out.add(AchievementType.streak7);
  if (streakRecord >= 30) out.add(AchievementType.streak30);
  return out;
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/core/leagues/streak_test.dart test/core/leagues/achievements_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/core/leagues/streak.dart lib/core/leagues/achievements.dart test/core/leagues/streak_test.dart test/core/leagues/achievements_test.dart
git commit -m "feat(core): motores de racha y logros

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 6: Persistencia de liga/XP/logros (migración v5)

**Files:**
- Modify: `lib/core/db/database.dart`
- Regenerate: `lib/core/db/database.g.dart`
- Test: `test/core/db/league_state_test.dart`

**Interfaces:**
- Produces: tablas `LeagueStates` (fila única id=0), `XpEntries` (autoinc), `Achievements` (type PK); migración v5; métodos:
  - `Future<LeagueStateRow?> loadLeagueState()`
  - `Future<void> saveLeagueState({required String division, required int weekId, required int weeklyXp, required int streakCurrent, required int streakRecord, int? lastActiveDay, required int totalWorkouts, required int totalPrs})`
  - `Future<void> addXpEntry({required int weekId, required String source, required int amount, required DateTime createdAt})`
  - `Future<Set<String>> loadAchievements()`
  - `Future<void> unlockAchievement(String type, DateTime at)` (no sobrescribe si ya existe)

- [ ] **Step 1: Write the failing test**

Crear `test/core/db/league_state_test.dart`:
```dart
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/core/db/database.dart';

void main() {
  test('league_state: upsert de fila única', () async {
    final db = FraguaDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    expect(await db.loadLeagueState(), isNull);

    await db.saveLeagueState(
      division: 'gold',
      weekId: 42,
      weeklyXp: 120,
      streakCurrent: 3,
      streakRecord: 5,
      lastActiveDay: 1000,
      totalWorkouts: 7,
      totalPrs: 2,
    );
    var s = await db.loadLeagueState();
    expect(s!.division, 'gold');
    expect(s.weeklyXp, 120);
    expect(s.streakRecord, 5);
    expect(s.totalWorkouts, 7);

    await db.saveLeagueState(
      division: 'platinum',
      weekId: 43,
      weeklyXp: 0,
      streakCurrent: 4,
      streakRecord: 5,
      lastActiveDay: 1001,
      totalWorkouts: 8,
      totalPrs: 2,
    );
    s = await db.loadLeagueState();
    expect(s!.division, 'platinum');
    expect(s.weeklyXp, 0);
    expect(await db.select(db.leagueStates).get(), hasLength(1));
  });

  test('xp_entries y achievements', () async {
    final db = FraguaDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await db.addXpEntry(
        weekId: 1, source: 'workout', amount: 50, createdAt: DateTime(2026, 6, 25));
    await db.addXpEntry(
        weekId: 1, source: 'pr', amount: 20, createdAt: DateTime(2026, 6, 25));
    expect(await db.select(db.xpEntries).get(), hasLength(2));

    expect(await db.loadAchievements(), isEmpty);
    await db.unlockAchievement('firstWorkout', DateTime(2026, 6, 25));
    await db.unlockAchievement('firstWorkout', DateTime(2026, 6, 26)); // no duplica
    final got = await db.loadAchievements();
    expect(got, {'firstWorkout'});
  });
}
```

- [ ] **Step 2: Add tables, methods and migration**

En `lib/core/db/database.dart`:

- Añade las tablas (junto a `GuidedStates`):
```dart
@DataClassName('LeagueStateRow')
class LeagueStates extends Table {
  IntColumn get id => integer().named('id').withDefault(const Constant(0))();
  TextColumn get division =>
      text().named('division').withDefault(const Constant('bronze'))();
  IntColumn get weekId => integer().named('week_id').withDefault(const Constant(0))();
  IntColumn get weeklyXp =>
      integer().named('weekly_xp').withDefault(const Constant(0))();
  IntColumn get streakCurrent =>
      integer().named('streak_current').withDefault(const Constant(0))();
  IntColumn get streakRecord =>
      integer().named('streak_record').withDefault(const Constant(0))();
  IntColumn get lastActiveDay => integer().named('last_active_day').nullable()();
  IntColumn get totalWorkouts =>
      integer().named('total_workouts').withDefault(const Constant(0))();
  IntColumn get totalPrs =>
      integer().named('total_prs').withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('XpEntryRow')
class XpEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get weekId => integer().named('week_id')();
  TextColumn get source => text().named('source')();
  IntColumn get amount => integer().named('amount')();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
}

@DataClassName('AchievementRow')
class Achievements extends Table {
  TextColumn get type => text().named('type')();
  DateTimeColumn get unlockedAt => dateTime().named('unlocked_at')();

  @override
  Set<Column> get primaryKey => {type};
}
```

- Regístralas en `@DriftDatabase`:
```dart
@DriftDatabase(tables: [
  Exercises,
  UserProfiles,
  Plans,
  ExerciseStates,
  GuidedStates,
  LeagueStates,
  XpEntries,
  Achievements,
])
```

- Sube `schemaVersion` a `5`.

- Añade en `onUpgrade` (tras la línea de `guidedStates`):
```dart
          if (from < 5) {
            await m.createTable(leagueStates);
            await m.createTable(xpEntries);
            await m.createTable(achievements);
          }
```

- Añade los métodos en `FraguaDatabase` (tras `saveGuidedState`):
```dart
  Future<LeagueStateRow?> loadLeagueState() =>
      (select(leagueStates)..where((t) => t.id.equals(0))).getSingleOrNull();

  Future<void> saveLeagueState({
    required String division,
    required int weekId,
    required int weeklyXp,
    required int streakCurrent,
    required int streakRecord,
    int? lastActiveDay,
    required int totalWorkouts,
    required int totalPrs,
  }) async {
    await into(leagueStates).insertOnConflictUpdate(
      LeagueStatesCompanion.insert(
        id: const Value(0),
        division: Value(division),
        weekId: Value(weekId),
        weeklyXp: Value(weeklyXp),
        streakCurrent: Value(streakCurrent),
        streakRecord: Value(streakRecord),
        lastActiveDay: Value(lastActiveDay),
        totalWorkouts: Value(totalWorkouts),
        totalPrs: Value(totalPrs),
      ),
    );
  }

  Future<void> addXpEntry({
    required int weekId,
    required String source,
    required int amount,
    required DateTime createdAt,
  }) async {
    await into(xpEntries).insert(
      XpEntriesCompanion.insert(
        weekId: weekId,
        source: source,
        amount: amount,
        createdAt: createdAt,
      ),
    );
  }

  Future<Set<String>> loadAchievements() async {
    final rows = await select(achievements).get();
    return rows.map((r) => r.type).toSet();
  }

  Future<void> unlockAchievement(String type, DateTime at) async {
    await into(achievements).insert(
      AchievementsCompanion.insert(type: type, unlockedAt: at),
      mode: InsertMode.insertOrIgnore,
    );
  }
```

- [ ] **Step 3: Run codegen**

Run: `dart run build_runner build`
Expected: regenera `database.g.dart` con las nuevas tablas/companions.

- [ ] **Step 4: Run tests**

Run: `flutter test test/core/db/`
Expected: PASS (liga/XP/logros + sin regresiones).

- [ ] **Step 5: Commit**

```bash
git add lib/core/db/database.dart lib/core/db/database.g.dart test/core/db/league_state_test.dart
git commit -m "feat(core): persistencia de liga/XP/logros (migracion v5)

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 7: LeaguesService + premio de XP al terminar la sesión

**Files:**
- Create: `lib/features/leagues/leagues_service.dart`
- Modify: `lib/app/providers.dart` (`leaguesServiceProvider`)
- Modify: `lib/features/workout/session_controller.dart` (`int get prCount`)
- Modify: `lib/features/workout/session_screen.dart` (premiar tras `_finish`)
- Modify: `lib/features/workout/guided_session_screen.dart` (premiar tras `_finishAndLeave`)
- Test: `test/features/leagues_service_test.dart`

**Interfaces:**
- Consumes: `FraguaDatabase`, `computeSessionXp`, `weekIdFor`, `applyWeekRollover`, `generateCohort`, `buildLeaderboard`, `updateStreak`, `dayNumber`, `unlockedAchievements`, `Division`.
- Produces:
  - `class LeaguesService { LeaguesService(this.db); final FraguaDatabase db; Future<LeagueStateRow> ensureCurrentWeek(DateTime now); Future<void> awardForSession({required int unitsCompleted, required int prCount, required bool completed, required DateTime now}); }`.
  - `final leaguesServiceProvider = Provider<LeaguesService>((ref) => LeaguesService(ref.read(databaseProvider)));`.
  - `WorkoutSessionController` gana `int get prCount` (nº de ejercicios cuyo peso subió en `finish()`).

- [ ] **Step 1: Write the failing test**

Crear `test/features/leagues_service_test.dart`:
```dart
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/core/db/database.dart';
import 'package:fragua/core/leagues/divisions.dart';
import 'package:fragua/features/leagues/leagues_service.dart';

void main() {
  test('primer entreno: crea estado, suma XP, racha 1 y logro firstWorkout', () async {
    final db = FraguaDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final svc = LeaguesService(db);
    final now = DateTime.utc(2026, 6, 25);

    await svc.awardForSession(
        unitsCompleted: 6, prCount: 1, completed: true, now: now);

    final s = (await db.loadLeagueState())!;
    expect(s.weekId, weekIdFor(now));
    // 50 base + 6*5 + 1*20 + min(1,7)*2 = 102
    expect(s.weeklyXp, 102);
    expect(s.streakCurrent, 1);
    expect(s.totalWorkouts, 1);
    expect(s.totalPrs, 1);
    expect(await db.loadAchievements(), containsAll({'firstWorkout', 'firstPr'}));
  });

  test('dos entrenos la misma semana acumulan XP', () async {
    final db = FraguaDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final svc = LeaguesService(db);
    final d1 = DateTime.utc(2026, 6, 25);
    final d2 = DateTime.utc(2026, 6, 26);

    await svc.awardForSession(
        unitsCompleted: 0, prCount: 0, completed: true, now: d1); // 50
    await svc.awardForSession(
        unitsCompleted: 0, prCount: 0, completed: true, now: d2); // +50 +racha2*2

    final s = (await db.loadLeagueState())!;
    expect(s.streakCurrent, 2);
    expect(s.weeklyXp, greaterThanOrEqualTo(100));
    expect(s.totalWorkouts, 2);
  });

  test('cambio de semana: rollover de división y reset de XP semanal', () async {
    final db = FraguaDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final svc = LeaguesService(db);

    // Semana antigua con XP alta: al entrar en la nueva semana debe hacer rollover.
    await db.saveLeagueState(
      division: 'gold',
      weekId: weekIdFor(DateTime.utc(2026, 6, 1)),
      weeklyXp: 99999, // garantiza top => ascenso
      streakCurrent: 1,
      streakRecord: 1,
      lastActiveDay: null,
      totalWorkouts: 5,
      totalPrs: 0,
    );

    final s = await svc.ensureCurrentWeek(DateTime.utc(2026, 6, 25));
    expect(s.weekId, weekIdFor(DateTime.utc(2026, 6, 25)));
    expect(s.weeklyXp, 0); // reseteada
    expect(s.division, 'platinum'); // ascendió desde gold
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/leagues_service_test.dart`
Expected: FAIL — `LeaguesService` no existe.

- [ ] **Step 3: Implement the service**

Crear `lib/features/leagues/leagues_service.dart`:
```dart
import '../../core/db/database.dart';
import '../../core/leagues/achievements.dart';
import '../../core/leagues/bots.dart';
import '../../core/leagues/divisions.dart';
import '../../core/leagues/leaderboard.dart';
import '../../core/leagues/streak.dart';
import '../../core/leagues/xp.dart';
import '../../core/models/enums.dart';

class LeaguesService {
  LeaguesService(this.db);
  final FraguaDatabase db;

  Division _divisionFrom(String name) =>
      Division.values.firstWhere((d) => d.name == name,
          orElse: () => Division.bronze);

  /// Asegura que el estado corresponde a la semana de [now]. Si cambió de semana,
  /// cierra la anterior: calcula el puesto final del usuario en su cohorte y
  /// aplica ascenso/descenso, resetea la XP semanal y fija la nueva semana.
  Future<LeagueStateRow> ensureCurrentWeek(DateTime now) async {
    final week = weekIdFor(now);
    final existing = await db.loadLeagueState();
    if (existing == null) {
      await db.saveLeagueState(
        division: Division.bronze.name,
        weekId: week,
        weeklyXp: 0,
        streakCurrent: 0,
        streakRecord: 0,
        lastActiveDay: null,
        totalWorkouts: 0,
        totalPrs: 0,
      );
      return (await db.loadLeagueState())!;
    }
    if (existing.weekId == week) return existing;

    // Rollover: puesto final en la cohorte de la semana que se cierra.
    final division = _divisionFrom(existing.division);
    final cohort = generateCohort(weekId: existing.weekId, division: division);
    final board = buildLeaderboard(bots: cohort, userXp: existing.weeklyXp);
    final rank = board.firstWhere((s) => s.isUser).rank;
    final newDivision = applyWeekRollover(
        current: division, finalRank: rank, cohortSize: board.length);

    await db.saveLeagueState(
      division: newDivision.name,
      weekId: week,
      weeklyXp: 0,
      streakCurrent: existing.streakCurrent,
      streakRecord: existing.streakRecord,
      lastActiveDay: existing.lastActiveDay,
      totalWorkouts: existing.totalWorkouts,
      totalPrs: existing.totalPrs,
    );
    return (await db.loadLeagueState())!;
  }

  /// Premia una sesión terminada: actualiza racha, suma XP (con bonus de racha),
  /// incrementa contadores, registra la entrada de XP y desbloquea logros.
  Future<void> awardForSession({
    required int unitsCompleted,
    required int prCount,
    required bool completed,
    required DateTime now,
  }) async {
    final state = await ensureCurrentWeek(now);

    final streak = updateStreak(
      today: dayNumber(now),
      lastActiveDay: state.lastActiveDay,
      current: state.streakCurrent,
      record: state.streakRecord,
    );

    final xp = computeSessionXp(
      unitsCompleted: unitsCompleted,
      prCount: prCount,
      completed: completed,
      streakDays: streak.current,
    );

    final totalWorkouts = state.totalWorkouts + (completed ? 1 : 0);
    final totalPrs = state.totalPrs + prCount;

    await db.saveLeagueState(
      division: state.division,
      weekId: state.weekId,
      weeklyXp: state.weeklyXp + xp,
      streakCurrent: streak.current,
      streakRecord: streak.record,
      lastActiveDay: dayNumber(now),
      totalWorkouts: totalWorkouts,
      totalPrs: totalPrs,
    );
    if (xp > 0) {
      await db.addXpEntry(
          weekId: state.weekId,
          source: XpSource.workout.name,
          amount: xp,
          createdAt: now);
    }
    for (final a in unlockedAchievements(
        totalWorkouts: totalWorkouts,
        streakRecord: streak.record,
        totalPrs: totalPrs)) {
      await db.unlockAchievement(a.name, now);
    }
  }
}
```

- [ ] **Step 4: Add prCount to the strength controller**

En `lib/features/workout/session_controller.dart`:

- Añade el campo y getter (junto a los demás campos de la clase):
```dart
  int _prCount = 0;
  int get prCount => _prCount;
```
- Dentro de `finish()`, donde se calcula `result`, cuenta los PR (subidas de peso). Sustituye el cuerpo del bucle de `finish()` para incrementar el contador cuando sube el peso:
```dart
      final result = decideProgression(
        repLow: e.repLow,
        repHigh: e.repHigh,
        currentWeight: weight,
        repsPerSet: reps,
        targetSets: e.sets,
        increment: 2.5,
        stallCount: prev?.stall ?? 0,
      );
      if (result.nextWeight > weight) _prCount++;
      await db.saveExerciseState(
          e.exerciseId, result.nextWeight, result.nextStallCount);
```

- [ ] **Step 5: Add the provider + wire the screens**

En `lib/app/providers.dart`:
- Importa el servicio:
```dart
import '../features/leagues/leagues_service.dart';
```
- Añade el provider al final:
```dart
final leaguesServiceProvider =
    Provider<LeaguesService>((ref) => LeaguesService(ref.read(databaseProvider)));
```

En `lib/features/workout/session_screen.dart`, dentro de `_finish()`, premia antes de salir:
```dart
  Future<void> _finish() async {
    await _c!.finish();
    final st = _c!.state;
    final units =
        st.loggedReps.values.fold<int>(0, (a, b) => a + b.length);
    await ref.read(leaguesServiceProvider).awardForSession(
          unitsCompleted: units,
          prCount: _c!.prCount,
          completed: true,
          now: DateTime.now(),
        );
    if (mounted) Navigator.of(context).pop();
  }
```

En `lib/features/workout/guided_session_screen.dart`, dentro de `_finishAndLeave()`:
```dart
  Future<void> _finishAndLeave() async {
    await _c!.finish();
    final st = _c!.state;
    final units = st.isAmrap
        ? st.completedRounds
        : st.timeline.where((s) => s.kind == StepKind.work).length;
    await ref.read(leaguesServiceProvider).awardForSession(
          unitsCompleted: units,
          prCount: 0,
          completed: st.finished,
          now: DateTime.now(),
        );
    if (mounted) Navigator.of(context).pop();
  }
```
(`StepKind` ya está importado en esa pantalla vía `guided_session.dart`.)

- [ ] **Step 6: Run tests**

Run: `flutter test test/features/leagues_service_test.dart`
Expected: PASS.
Run: `flutter test test/features/session_controller_test.dart test/features/session_screen_test.dart test/features/guided_session_screen_test.dart`
Expected: PASS (sin regresiones; los tests de pantalla ahora también premian XP usando la BD en memoria, que tiene las tablas).

- [ ] **Step 7: Commit**

```bash
git add lib/features/leagues/leagues_service.dart lib/app/providers.dart lib/features/workout/session_controller.dart lib/features/workout/session_screen.dart lib/features/workout/guided_session_screen.dart test/features/leagues_service_test.dart
git commit -m "feat(leagues): servicio de premio de XP/racha/logros al terminar la sesion

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 8: Pantalla de Liga + acceso desde Home + verificación M6

**Files:**
- Create: `lib/features/leagues/leagues_screen.dart`
- Modify: `lib/features/home/home_screen.dart` (acceso a Liga + racha)
- Test: `test/features/leagues_screen_test.dart`

**Interfaces:**
- Consumes: `leaguesServiceProvider`, `databaseProvider`, `generateCohort`, `buildLeaderboard`, `zoneFor`, `weekIdFor`, `Division`, `LeagueZone`.
- Produces: `class LeaguesScreen extends ConsumerStatefulWidget` que: llama `ensureCurrentWeek(now)`, genera la cohorte de la semana, construye el leaderboard con la XP del usuario, y muestra división, racha, lista ordenada (resaltando al usuario y las zonas asc/desc). Home gana un botón a la Liga (`key: Key('leagues-button')`) y muestra la racha.

- [ ] **Step 1: Write the failing widget test**

Crear `test/features/leagues_screen_test.dart`:
```dart
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/app/providers.dart';
import 'package:fragua/core/db/database.dart';
import 'package:fragua/core/leagues/divisions.dart';
import 'package:fragua/features/leagues/leagues_screen.dart';

void main() {
  testWidgets('muestra la división y al usuario en el leaderboard', (tester) async {
    final db = FraguaDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db.saveLeagueState(
      division: 'silver',
      weekId: weekIdFor(DateTime.now()),
      weeklyXp: 250,
      streakCurrent: 3,
      streakRecord: 4,
      lastActiveDay: null,
      totalWorkouts: 5,
      totalPrs: 1,
    );

    await tester.pumpWidget(ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: const MaterialApp(home: LeaguesScreen()),
    ));
    await tester.pumpAndSettle();

    expect(find.textContaining('Silver', findRichText: true), findsWidgets);
    expect(find.text('Tú'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/leagues_screen_test.dart`
Expected: FAIL — `LeaguesScreen` no existe.

- [ ] **Step 3: Implement the leagues screen**

Crear `lib/features/leagues/leagues_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/db/database.dart';
import '../../core/leagues/bots.dart';
import '../../core/leagues/divisions.dart';
import '../../core/leagues/leaderboard.dart';
import '../../core/models/enums.dart';

const _divisionLabels = {
  'bronze': 'Bronce',
  'silver': 'Plata',
  'gold': 'Oro',
  'platinum': 'Platino',
  'diamond': 'Diamante',
  'legend': 'Leyenda',
};

class LeaguesScreen extends ConsumerStatefulWidget {
  const LeaguesScreen({super.key});

  @override
  ConsumerState<LeaguesScreen> createState() => _LeaguesScreenState();
}

class _LeaguesScreenState extends ConsumerState<LeaguesScreen> {
  LeagueStateRow? _state;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = await ref.read(leaguesServiceProvider).ensureCurrentWeek(DateTime.now());
    if (mounted) setState(() => _state = s);
  }

  @override
  Widget build(BuildContext context) {
    final s = _state;
    return Scaffold(
      appBar: AppBar(title: const Text('Liga')),
      body: s == null
          ? const Center(child: CircularProgressIndicator())
          : _body(s),
    );
  }

  Widget _body(LeagueStateRow s) {
    final division = Division.values
        .firstWhere((d) => d.name == s.division, orElse: () => Division.bronze);
    final cohort = generateCohort(weekId: s.weekId, division: division);
    final board = buildLeaderboard(bots: cohort, userXp: s.weeklyXp);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text('División: ${_divisionLabels[s.division] ?? s.division}',
                  style: Theme.of(context).textTheme.titleLarge),
              Text('🔥 Racha: ${s.streakCurrent} días (récord ${s.streakRecord})'),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            itemCount: board.length,
            itemBuilder: (context, i) {
              final e = board[i];
              final zone = zoneFor(
                  rank: e.rank, cohortSize: board.length, division: division);
              final color = zone == LeagueZone.promote
                  ? Colors.green
                  : zone == LeagueZone.relegate
                      ? Colors.red
                      : null;
              return ListTile(
                leading: CircleAvatar(child: Text('${e.rank}')),
                title: Text(e.name,
                    style: TextStyle(
                        fontWeight:
                            e.isUser ? FontWeight.bold : FontWeight.normal)),
                trailing: Text('${e.xp} XP',
                    style: TextStyle(color: color)),
                tileColor:
                    e.isUser ? Theme.of(context).colorScheme.primaryContainer : null,
              );
            },
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 4: Link from Home + show streak**

En `lib/features/home/home_screen.dart`:
- Importa la pantalla:
```dart
import '../leagues/leagues_screen.dart';
```
- Tras el botón "Ver mi plan" (dentro de la `Column`), añade el acceso a la liga:
```dart
            const SizedBox(height: 8),
            OutlinedButton.icon(
              key: const Key('leagues-button'),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LeaguesScreen()),
              ),
              icon: const Icon(Icons.emoji_events),
              label: const Text('Liga'),
            ),
```

- [ ] **Step 5: Run the widget test**

Run: `flutter test test/features/leagues_screen_test.dart`
Expected: PASS.

- [ ] **Step 6: Full verification (Definition of Done de M6)**

Run: `flutter test`
Expected: verde (core de ligas + persistencia + servicio + pantallas + sin regresiones).

Run: `flutter analyze`
Expected: `No issues found!`

Run: `tools/.venv/bin/python -m pytest tools/ -q`
Expected: verde.

- [ ] **Step 7: Commit**

```bash
git add lib/features/leagues/leagues_screen.dart lib/features/home/home_screen.dart test/features/leagues_screen_test.dart
git commit -m "feat(leagues): pantalla de liga (leaderboard + racha) + acceso desde Home

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

## Verificación de M6 (Definition of Done)

- `flutter analyze` limpio · `flutter test` verde (XP, bots reproducibles, leaderboard, zonas asc/desc, racha, logros, persistencia v5, servicio, pantalla) · `pytest` verde.
- Al terminar un entreno (fuerza o guiado) se gana **XP**, sube la **racha** y se desbloquean **logros**; todo persistido.
- La **Liga** muestra la división, tu posición entre ~19 bots reproducibles y las zonas de ascenso/descenso; al cambiar de semana se aplica el **rollover** (asc/desc) y se resetea la XP semanal.
- Mergeado a `master`; push a `origin` (con el OK de Alberto).

## Cobertura de la spec (self-review)

- **§7.5 sistema de ligas** (XP por entreno/series/PR/racha; 6 divisiones; cohorte ~20 bots seeded con arquetipos; top asciende / cola desciende con suelo y techo; rachas; logros) → Tasks 2–8. La cohorte es de 1 usuario + 19 bots = 20.
- **§8 modelo** (`xp_entry`, `league_state`, `league_bot` [generado, no almacenado], `achievement`, `streak` [dentro de league_state]) → Tasks 6, 7.
- **§13 testing** (bots reproducibles por semilla; lógica de XP y asc/desc) → Tasks 3, 4, 7.
- **Fuera de M6** (explícito): notificaciones de "racha en peligro" (M8); gráficas/medallas visuales ricas y pantalla de logros dedicada (la liga muestra racha y el modelo guarda los logros; la galería de medallas es refinamiento/M7); bonus de XP por volumen/intensidad fino (se usa XP por unidad + PR + racha); PR en guiado (0 por ahora; el de fuerza usa la subida de peso real).
