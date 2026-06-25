# Fragua M5 — Animaciones (GIFs + caché + fallback): Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Mostrar una **demostración animada** de cada ejercicio durante la sesión: **GIF real** cuando el mapeo lo encuentra y, si no, las **2 imágenes start/finish** de free-exercise-db como animación de 2 fotogramas (cobertura 873/873), con **descarga bajo demanda + caché** en almacenamiento privado, **cadena de fallback** (GIF → fotogramas → texto) y ajustes para **pre-descargar** y **vaciar caché**.

**Architecture:** Decisión de fuente media = **ambas a la vez** (decisión de Alberto, 2026-06-25). El pipeline `build_exercise_db.py` puebla `gif_key` mapeando por **nombre exacto-normalizado** contra el dataset abierto **`hasaneyldrm/exercises-dataset`** (no comercial → permitido por ser uso personal sin redistribución, spec §5.2); cobertura real ~15% (133/873), el resto cae a fotogramas. La **lógica de selección** es Dart puro en `lib/core/media/` (URLs + orden de candidatos, testeable). La **caché** es un seam inyectable `MediaCache` (`HttpMediaCache` real con `http`+`path_provider`; `NoopMediaCache` por defecto en tests, `FakeMediaCache` para asserts). Un `exerciseMediaProvider` (Riverpod) resuelve por ejercicio el primer candidato disponible (cacheado o descargable) → `ResolvedMedia(kind, files, instructions)`. El widget `ExerciseDemo` renderiza GIF (`Image.file` animado), animación de 2 fotogramas, o instrucciones de texto. Se engancha en las pantallas de sesión (fuerza y guiada) y hay una `SettingsScreen` para pre-descargar/vaciar/ver tamaño.

**Tech Stack:** Python (pipeline) · Dart puro (core media) · drift · flutter_riverpod · `http` (nuevo) · `path_provider` (ya presente) · `path` · flutter_test.

## Global Constraints

- `lib/core/**` NUNCA importa Flutter. La caché (IO/red) vive en `lib/services/**`; los widgets en `lib/features/**`.
- Lógica de selección de media **pura y testeable**; la caché es un **seam inyectable** vía Riverpod (tests sin red ni IO). `mediaCacheProvider` por defecto = `NoopMediaCache` (las pantallas existentes que ahora incrustan `ExerciseDemo` caen a texto sin tocar la red).
- **Fuente GIF**: `https://raw.githubusercontent.com/hasaneyldrm/exercises-dataset/main/<gif_key>` (gif_key = ruta relativa, p.ej. `videos/0001-2gPfomN.gif`). **Fuente estática**: `https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/<imagePath>` (imagePath = p.ej. `Ab_Crunch_Machine/0.jpg`). Ambas verificadas (HTTP 200).
- Cadena de fallback **siempre** termina en texto: la app funciona sin red.
- Cambios retrocompatibles; sin renombrar columnas. `normalize_exercise(raw, gif_index=None)` mantiene la firma de 1 argumento (gif_key = None) para no romper los tests existentes.
- Commits frecuentes, uno por tarea. Mensajes terminan con `Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>`.

---

## File Structure

- `tools/build_exercise_db.py` — (modificar) `normalize_name`, `build_gif_index`, `_load_gif_dataset`, `normalize_exercise(raw, gif_index)`; `main()` mapea gif_key.
- `tools/test_build_exercise_db.py` — (ampliar) tests de normalización/índice/mapeo.
- `assets/exercise_db.sqlite` — (regenerar) ahora con `gif_key` poblado (~133).
- `lib/core/media/exercise_media.dart` — (crear) URLs + `MediaKind`/`MediaCandidate` + `mediaCandidates(...)`.
- `lib/services/media/media_cache.dart` — (crear) `MediaCache` (abstracta), `NoopMediaCache`, `HttpMediaCache`.
- `lib/app/providers.dart` — (modificar) `mediaCacheProvider`, `exerciseMediaProvider`.
- `lib/main.dart` — (modificar) override `mediaCacheProvider` con `HttpMediaCache()`.
- `lib/features/exercise/exercise_demo.dart` — (crear) `ResolvedMedia`, `ExerciseDemo`, `_FrameAnimation`.
- `lib/features/settings/settings_screen.dart` — (crear) tamaño caché + vaciar + pre-descargar.
- `lib/features/home/home_screen.dart` — (modificar) acción de Ajustes en el AppBar.
- `lib/core/session/guided_session.dart` — (modificar) `SessionStep.exerciseId`.
- `lib/features/workout/session_screen.dart` — (modificar) incrustar `ExerciseDemo`.
- `lib/features/workout/guided_session_screen.dart` — (modificar) incrustar `ExerciseDemo`.
- `pubspec.yaml` — (modificar) `http`.
- Tests: `test/core/media/exercise_media_test.dart`, `test/features/exercise_media_provider_test.dart`, `test/features/exercise_demo_test.dart`, `test/features/settings_screen_test.dart`, `test/core/session/guided_session_test.dart` (ampliar).

---

### Task 1: Pipeline — mapear `gif_key` por nombre y regenerar la BD

**Files:**
- Modify: `tools/build_exercise_db.py`
- Test: `tools/test_build_exercise_db.py`
- Regenerate: `assets/exercise_db.sqlite`

**Interfaces:**
- Produces: `normalize_name(str) -> str` (minúsculas, solo `[a-z0-9]`); `build_gif_index(records: list[dict]) -> dict[str,str]` (nombre normalizado → `gif_url`); `normalize_exercise(raw, gif_index=None)` que setea `gif_key = gif_index.get(normalize_name(raw["name"]))` cuando hay índice; `_load_gif_dataset() -> list[dict]` (remoto).

- [ ] **Step 1: Write the failing tests**

Añade al final de `tools/test_build_exercise_db.py`:
```python
def test_normalize_name():
    assert b.normalize_name("3/4 Sit-Up") == "34situp"
    assert b.normalize_name("45° side bend") == "45sidebend"
    assert b.normalize_name("Barbell  Bench Press") == "barbellbenchpress"


def test_build_gif_index_dedupes():
    idx = b.build_gif_index([
        {"name": "Air Bike", "gif_url": "videos/0003.gif"},
        {"name": "air bike", "gif_url": "videos/dup.gif"},  # se ignora (ya existe)
    ])
    assert idx == {"airbike": "videos/0003.gif"}


def test_normalize_exercise_sets_gif_key_on_match():
    raw = json.loads(FIXTURE.read_text())[0]  # Barbell Squat
    idx = b.build_gif_index([{"name": "barbell squat", "gif_url": "videos/sq.gif"}])
    row = b.normalize_exercise(raw, idx)
    assert row["gif_key"] == "videos/sq.gif"


def test_normalize_exercise_gif_key_none_when_no_match():
    raw = json.loads(FIXTURE.read_text())[1]  # Plank
    idx = b.build_gif_index([{"name": "barbell squat", "gif_url": "videos/sq.gif"}])
    assert b.normalize_exercise(raw, idx)["gif_key"] is None
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `tools/.venv/bin/python -m pytest tools/ -q`
Expected: FAIL — `normalize_name`/`build_gif_index` no existen.

- [ ] **Step 3: Implement the mapping**

En `tools/build_exercise_db.py`:

- Añade el import al principio:
```python
import re
```

- Añade la constante (junto a `DATA_URL`):
```python
GIF_DATA_URL = "https://raw.githubusercontent.com/hasaneyldrm/exercises-dataset/main/data/exercises.json"
```

- Añade las funciones de mapeo (antes de `normalize_exercise`):
```python
def normalize_name(name):
    return re.sub(r"[^a-z0-9]", "", name.lower())


def build_gif_index(records):
    """nombre normalizado -> gif_url (relativo). Se queda con la 1ª aparición."""
    idx = {}
    for rec in records:
        idx.setdefault(normalize_name(rec["name"]), rec["gif_url"])
    return idx
```

- Cambia la firma e implementación de `normalize_exercise` para aceptar el índice y setear `gif_key`:
```python
def normalize_exercise(raw, gif_index=None):
    equipment = map_equipment(raw.get("equipment"))
    gif_key = None
    if gif_index:
        gif_key = gif_index.get(normalize_name(raw["name"]))
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
        "gif_key": gif_key,
        "modality": infer_modality(equipment),
        "variation_group": None,
        "variation_rank": 0,
    }
```

- Añade el loader remoto del dataset de GIFs (junto a `_load_remote`):
```python
def _load_gif_dataset():
    import requests
    resp = requests.get(GIF_DATA_URL, timeout=60)
    resp.raise_for_status()
    return resp.json()
```

- En `main()`, construye el índice y pásalo al normalizador:
```python
def main():
    ap = argparse.ArgumentParser()
    ap.add_argument(
        "--out",
        default=str(Path(__file__).parent.parent / "assets" / "exercise_db.sqlite"),
    )
    args = ap.parse_args()
    raw = _load_remote()
    gif_index = build_gif_index(_load_gif_dataset())
    rows = [normalize_exercise(r, gif_index) for r in raw]
    matched = sum(1 for r in rows if r["gif_key"])
    out = build_db(rows, args.out)
    print(f"Escritos {len(rows)} ejercicios en {out} ({matched} con GIF)")
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `tools/.venv/bin/python -m pytest tools/ -q`
Expected: PASS (nuevos + los existentes; `test_normalize_exercise_shape` sigue verde porque la firma de 1 argumento deja `gif_key=None`).

- [ ] **Step 5: Regenerate the asset DB**

Run: `tools/.venv/bin/python tools/build_exercise_db.py`
Expected: imprime algo como `Escritos 873 ejercicios en .../assets/exercise_db.sqlite (133 con GIF)`.

Verifica el recuento:
```bash
tools/.venv/bin/python -c "import sqlite3; c=sqlite3.connect('assets/exercise_db.sqlite'); print('total', c.execute('SELECT COUNT(*) FROM exercises').fetchone()[0], 'con_gif', c.execute('SELECT COUNT(*) FROM exercises WHERE gif_key IS NOT NULL').fetchone()[0])"
```
Expected: `total 873 con_gif 133` (aprox.; ≥100).

- [ ] **Step 6: Commit**

```bash
git add tools/build_exercise_db.py tools/test_build_exercise_db.py assets/exercise_db.sqlite
git commit -m "feat(tools): mapea gif_key por nombre desde hasaneyldrm/exercises-dataset

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 2: Core media (puro) — URLs y orden de candidatos

**Files:**
- Create: `lib/core/media/exercise_media.dart`
- Test: `test/core/media/exercise_media_test.dart`

**Interfaces:**
- Produces: `String freeExerciseImageUrl(String imagePath)`; `String? gifUrlFromKey(String? gifKey)`; `enum MediaKind { gif, frames, text }`; `class MediaCandidate { final MediaKind kind; final List<String> urls; const MediaCandidate(this.kind, this.urls); }`; `List<MediaCandidate> mediaCandidates({String? gifKey, required List<String> staticImages})` → orden: gif (si hay key) → frames (si hay imágenes) → text (siempre, urls vacío).

- [ ] **Step 1: Write the failing test**

Crear `test/core/media/exercise_media_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/core/media/exercise_media.dart';

void main() {
  test('construye URLs de imagen estática y de GIF', () {
    expect(freeExerciseImageUrl('Ab_Crunch_Machine/0.jpg'),
        'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Ab_Crunch_Machine/0.jpg');
    expect(gifUrlFromKey('videos/0001.gif'),
        'https://raw.githubusercontent.com/hasaneyldrm/exercises-dataset/main/videos/0001.gif');
    expect(gifUrlFromKey(null), isNull);
    expect(gifUrlFromKey(''), isNull);
  });

  test('candidatos: gif -> frames -> text cuando hay todo', () {
    final c = mediaCandidates(gifKey: 'videos/x.gif', staticImages: ['A/0.jpg', 'A/1.jpg']);
    expect(c.map((e) => e.kind).toList(),
        [MediaKind.gif, MediaKind.frames, MediaKind.text]);
    expect(c[0].urls.single, gifUrlFromKey('videos/x.gif'));
    expect(c[1].urls, hasLength(2));
    expect(c[1].urls.first, freeExerciseImageUrl('A/0.jpg'));
    expect(c.last.urls, isEmpty);
  });

  test('sin gif_key => no hay candidato gif', () {
    final c = mediaCandidates(gifKey: null, staticImages: ['A/0.jpg']);
    expect(c.map((e) => e.kind).toList(), [MediaKind.frames, MediaKind.text]);
  });

  test('sin imágenes ni gif => solo text', () {
    final c = mediaCandidates(gifKey: null, staticImages: const []);
    expect(c.map((e) => e.kind).toList(), [MediaKind.text]);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/media/exercise_media_test.dart`
Expected: FAIL — `exercise_media.dart` no existe.

- [ ] **Step 3: Implement the core media logic**

Crear `lib/core/media/exercise_media.dart`:
```dart
/// Base raw de las imágenes estáticas (start/finish) de free-exercise-db.
const _imageBase =
    'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/';

/// Base raw del set de GIFs (hasaneyldrm/exercises-dataset). gif_key = ruta relativa.
const _gifBase =
    'https://raw.githubusercontent.com/hasaneyldrm/exercises-dataset/main/';

String freeExerciseImageUrl(String imagePath) => '$_imageBase$imagePath';

String? gifUrlFromKey(String? gifKey) =>
    (gifKey == null || gifKey.isEmpty) ? null : '$_gifBase$gifKey';

enum MediaKind { gif, frames, text }

/// Una opción de demostración: su tipo y las URLs remotas que necesita.
class MediaCandidate {
  final MediaKind kind;
  final List<String> urls;
  const MediaCandidate(this.kind, this.urls);
}

/// Candidatos en orden de preferencia: GIF real → 2 fotogramas estáticos → texto.
/// El último (text) siempre está presente: la app nunca se queda sin demo.
List<MediaCandidate> mediaCandidates({
  String? gifKey,
  required List<String> staticImages,
}) {
  final out = <MediaCandidate>[];
  final gif = gifUrlFromKey(gifKey);
  if (gif != null) out.add(MediaCandidate(MediaKind.gif, [gif]));
  if (staticImages.isNotEmpty) {
    out.add(MediaCandidate(
        MediaKind.frames, [for (final p in staticImages) freeExerciseImageUrl(p)]));
  }
  out.add(const MediaCandidate(MediaKind.text, []));
  return out;
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/core/media/exercise_media_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/core/media/exercise_media.dart test/core/media/exercise_media_test.dart
git commit -m "feat(core): URLs de media + orden de candidatos (gif/frames/text)

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 3: Caché de media (seam) + resolver por ejercicio

**Files:**
- Create: `lib/services/media/media_cache.dart`
- Modify: `lib/app/providers.dart` (`mediaCacheProvider`, `exerciseMediaProvider`)
- Modify: `lib/main.dart` (override real)
- Modify: `pubspec.yaml` (`http`)
- Test: `test/features/exercise_media_provider_test.dart`

**Interfaces:**
- Consumes: `mediaCandidates`, `MediaKind`, `catalogProvider`, `Exercise`.
- Produces:
  - `abstract class MediaCache { Future<File?> getIfCached(String url); Future<File?> fetch(String url); Future<int> sizeBytes(); Future<void> clear(); }`; `NoopMediaCache` (todo null/0/no-op); `HttpMediaCache` (real).
  - `final mediaCacheProvider = Provider<MediaCache>((ref) => const NoopMediaCache());` (override en main con `HttpMediaCache()`).
  - `class ResolvedMedia { final MediaKind kind; final List<File> files; final List<String> instructions; const ResolvedMedia(this.kind, this.files, this.instructions); }`.
  - `final exerciseMediaProvider = FutureProvider.family<ResolvedMedia, String>((ref, exerciseId) async {...})` — busca el ejercicio en el catálogo, recorre `mediaCandidates`, y para cada candidato intenta `getIfCached(url) ?? fetch(url)` de todas sus URLs; devuelve el primer candidato completo; si ninguno, `ResolvedMedia(text, [], instructions)`.

- [ ] **Step 1: Add the http dependency + the cache seam**

Run: `flutter pub add http`

Crear `lib/services/media/media_cache.dart`:
```dart
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Caché de archivos de media (GIFs e imágenes) en almacenamiento privado.
abstract class MediaCache {
  Future<File?> getIfCached(String url);
  Future<File?> fetch(String url); // descarga + cachea; null si falla
  Future<int> sizeBytes();
  Future<void> clear();
}

/// Sin caché (tests / por defecto): nunca hay nada y no se descarga nada,
/// de modo que las pantallas caen a la cadena de fallback (texto) sin red.
class NoopMediaCache implements MediaCache {
  const NoopMediaCache();
  @override
  Future<File?> getIfCached(String url) async => null;
  @override
  Future<File?> fetch(String url) async => null;
  @override
  Future<int> sizeBytes() async => 0;
  @override
  Future<void> clear() async {}
}

/// Caché real: descarga con http y guarda en `<appSupport>/media_cache`.
class HttpMediaCache implements MediaCache {
  Directory? _dir;

  Future<Directory> _dirFor() async {
    if (_dir != null) return _dir!;
    final base = await getApplicationSupportDirectory();
    final d = Directory(p.join(base.path, 'media_cache'));
    await d.create(recursive: true);
    return _dir = d;
  }

  // Nombre de archivo determinista (estable entre ejecuciones) a partir de la URL.
  String _fileName(String url) => Uri.parse(url).pathSegments.join('_');

  @override
  Future<File?> getIfCached(String url) async {
    final f = File(p.join((await _dirFor()).path, _fileName(url)));
    return await f.exists() ? f : null;
  }

  @override
  Future<File?> fetch(String url) async {
    try {
      final resp = await http.get(Uri.parse(url));
      if (resp.statusCode != 200) return null;
      final f = File(p.join((await _dirFor()).path, _fileName(url)));
      await f.writeAsBytes(resp.bodyBytes);
      return f;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<int> sizeBytes() async {
    final d = await _dirFor();
    var total = 0;
    await for (final e in d.list()) {
      if (e is File) total += await e.length();
    }
    return total;
  }

  @override
  Future<void> clear() async {
    final d = await _dirFor();
    if (!await d.exists()) return;
    await for (final e in d.list()) {
      if (e is File) await e.delete();
    }
  }
}
```

- [ ] **Step 2: Add the providers**

En `lib/app/providers.dart`:

- Añade los imports:
```dart
import 'dart:io';

import '../core/media/exercise_media.dart';
import '../services/media/media_cache.dart';
```

- Añade al final del archivo:
```dart
/// Override con HttpMediaCache() en main(); NoopMediaCache por defecto (tests).
final mediaCacheProvider =
    Provider<MediaCache>((ref) => const NoopMediaCache());

class ResolvedMedia {
  final MediaKind kind;
  final List<File> files; // gif: 1 archivo · frames: N · text: vacío
  final List<String> instructions;
  const ResolvedMedia(this.kind, this.files, this.instructions);
}

/// Resuelve la demostración de un ejercicio: primer candidato cuyas URLs estén
/// cacheadas o se puedan descargar; si ninguno, texto (instrucciones).
final exerciseMediaProvider =
    FutureProvider.family<ResolvedMedia, String>((ref, exerciseId) async {
  final catalog = await ref.watch(catalogProvider.future);
  Exercise? ex;
  for (final e in catalog) {
    if (e.id == exerciseId) {
      ex = e;
      break;
    }
  }
  if (ex == null) return const ResolvedMedia(MediaKind.text, [], []);
  final cache = ref.read(mediaCacheProvider);
  for (final cand in mediaCandidates(
      gifKey: ex.gifKey, staticImages: ex.staticImages)) {
    if (cand.kind == MediaKind.text) break;
    final files = <File>[];
    var ok = true;
    for (final url in cand.urls) {
      final f = await cache.getIfCached(url) ?? await cache.fetch(url);
      if (f == null) {
        ok = false;
        break;
      }
      files.add(f);
    }
    if (ok && files.isNotEmpty) {
      return ResolvedMedia(cand.kind, files, ex.instructions);
    }
  }
  return ResolvedMedia(MediaKind.text, const [], ex.instructions);
});
```
(El import de `Exercise` ya existe en `providers.dart`.)

- [ ] **Step 3: Wire the real cache in main**

En `lib/main.dart` añade el import:
```dart
import 'services/media/media_cache.dart';
```
y añade el override al `ProviderScope` (junto a los de database y voz):
```dart
      mediaCacheProvider.overrideWithValue(HttpMediaCache()),
```

- [ ] **Step 4: Write the failing resolver test**

Crear `test/features/exercise_media_provider_test.dart`:
```dart
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/app/providers.dart';
import 'package:fragua/core/media/exercise_media.dart';
import 'package:fragua/core/models/enums.dart';
import 'package:fragua/core/models/exercise.dart';
import 'package:fragua/services/media/media_cache.dart';

class FakeMediaCache implements MediaCache {
  FakeMediaCache(this.fetchable);
  final Set<String> fetchable; // URLs que "se descargan"
  @override
  Future<File?> getIfCached(String url) async => null;
  @override
  Future<File?> fetch(String url) async =>
      fetchable.contains(url) ? File('cached_${url.hashCode}') : null;
  @override
  Future<int> sizeBytes() async => 0;
  @override
  Future<void> clear() async {}
}

Exercise sample({String? gifKey}) => Exercise(
      id: 'x',
      name: 'X',
      category: null,
      force: null,
      difficulty: ExerciseDifficulty.beginner,
      mechanic: null,
      equipment: Equipment.bodyweight,
      primaryMuscles: const [],
      secondaryMuscles: const [],
      instructions: const ['Paso 1', 'Paso 2'],
      staticImages: const ['X/0.jpg', 'X/1.jpg'],
      gifKey: gifKey,
      modality: Modality.both,
      variationGroup: null,
      variationRank: 0,
    );

Future<ResolvedMedia> resolve(Exercise ex, Set<String> fetchable) async {
  final c = ProviderContainer(overrides: [
    catalogProvider.overrideWith((ref) async => [ex]),
    mediaCacheProvider.overrideWithValue(FakeMediaCache(fetchable)),
  ]);
  addTearDown(c.dispose);
  return c.read(exerciseMediaProvider('x').future);
}

void main() {
  test('GIF disponible => kind gif (1 archivo)', () async {
    final ex = sample(gifKey: 'videos/x.gif');
    final m = await resolve(ex, {gifUrlFromKey('videos/x.gif')!});
    expect(m.kind, MediaKind.gif);
    expect(m.files, hasLength(1));
  });

  test('GIF falla pero frames disponibles => kind frames (2 archivos)', () async {
    final ex = sample(gifKey: 'videos/x.gif');
    final m = await resolve(ex, {
      freeExerciseImageUrl('X/0.jpg'),
      freeExerciseImageUrl('X/1.jpg'),
    });
    expect(m.kind, MediaKind.frames);
    expect(m.files, hasLength(2));
  });

  test('nada descargable => kind text con instrucciones', () async {
    final ex = sample(gifKey: 'videos/x.gif');
    final m = await resolve(ex, <String>{});
    expect(m.kind, MediaKind.text);
    expect(m.instructions, ['Paso 1', 'Paso 2']);
  });

  test('ejercicio inexistente => text vacío', () async {
    final c = ProviderContainer(overrides: [
      catalogProvider.overrideWith((ref) async => <Exercise>[]),
      mediaCacheProvider.overrideWithValue(FakeMediaCache({})),
    ]);
    addTearDown(c.dispose);
    final m = await c.read(exerciseMediaProvider('nope').future);
    expect(m.kind, MediaKind.text);
  });
}
```

- [ ] **Step 5: Run tests to verify they pass**

Run: `flutter test test/features/exercise_media_provider_test.dart`
Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add lib/services/media/media_cache.dart lib/app/providers.dart lib/main.dart pubspec.yaml pubspec.lock test/features/exercise_media_provider_test.dart
git commit -m "feat(media): cache inyectable + resolver de demo por ejercicio

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 4: Widget `ExerciseDemo` (GIF / 2 fotogramas / texto)

**Files:**
- Create: `lib/features/exercise/exercise_demo.dart`
- Test: `test/features/exercise_demo_test.dart`

**Interfaces:**
- Consumes: `exerciseMediaProvider`, `ResolvedMedia`, `MediaKind`.
- Produces: `class ExerciseDemo extends ConsumerWidget { final String exerciseId; }` que renderiza según `kind`: `gif` → `Image.file` (Flutter anima los GIF); `frames` → `_FrameAnimation` (alterna las 2 imágenes cada ~900 ms); `text` → lista de instrucciones. `_FrameAnimation` cancela su `Timer` en `dispose`.

- [ ] **Step 1: Write the failing widget test**

Crear `test/features/exercise_demo_test.dart`:
```dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/app/providers.dart';
import 'package:fragua/core/media/exercise_media.dart';
import 'package:fragua/features/exercise/exercise_demo.dart';

void main() {
  testWidgets('kind text => muestra las instrucciones', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        exerciseMediaProvider('x').overrideWith(
            (ref) async => const ResolvedMedia(MediaKind.text, [], ['Paso 1'])),
      ],
      child: const MaterialApp(home: Scaffold(body: ExerciseDemo(exerciseId: 'x'))),
    ));
    await tester.pump(); // resuelve el future
    expect(find.text('Paso 1'), findsOneWidget);
  });

  testWidgets('kind frames => renderiza una imagen', (tester) async {
    final tmp = await Directory.systemTemp.createTemp('fragua_demo');
    addTearDown(() => tmp.delete(recursive: true));
    final f0 = File('${tmp.path}/0.jpg')..writeAsBytesSync([0]);
    final f1 = File('${tmp.path}/1.jpg')..writeAsBytesSync([0]);

    await tester.pumpWidget(ProviderScope(
      overrides: [
        exerciseMediaProvider('x').overrideWith(
            (ref) async => ResolvedMedia(MediaKind.frames, [f0, f1], const [])),
      ],
      child: const MaterialApp(home: Scaffold(body: ExerciseDemo(exerciseId: 'x'))),
    ));
    await tester.pump(); // resuelve el future
    expect(find.byType(Image), findsWidgets);

    await tester.pumpWidget(const SizedBox()); // descarta => cancela el Timer
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/exercise_demo_test.dart`
Expected: FAIL — `ExerciseDemo` no existe.

- [ ] **Step 3: Implement the widget**

Crear `lib/features/exercise/exercise_demo.dart`:
```dart
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/media/exercise_media.dart';

class ExerciseDemo extends ConsumerWidget {
  const ExerciseDemo({super.key, required this.exerciseId});
  final String exerciseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final media = ref.watch(exerciseMediaProvider(exerciseId));
    return SizedBox(
      height: 180,
      child: media.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const SizedBox.shrink(),
        data: (m) {
          switch (m.kind) {
            case MediaKind.gif:
              return Image.file(m.files.first,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => _instructions(context, m));
            case MediaKind.frames:
              return _FrameAnimation(frames: m.files);
            case MediaKind.text:
              return _instructions(context, m);
          }
        },
      ),
    );
  }

  Widget _instructions(BuildContext context, ResolvedMedia m) {
    if (m.instructions.isEmpty) {
      return const Center(child: Icon(Icons.fitness_center, size: 48));
    }
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [for (final s in m.instructions) Text('• $s')],
      ),
    );
  }
}

/// Anima alternando 2 (o más) fotogramas estáticos start/finish.
class _FrameAnimation extends StatefulWidget {
  const _FrameAnimation({required this.frames});
  final List<File> frames;

  @override
  State<_FrameAnimation> createState() => _FrameAnimationState();
}

class _FrameAnimationState extends State<_FrameAnimation> {
  int _i = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.frames.length > 1) {
      _timer = Timer.periodic(const Duration(milliseconds: 900), (_) {
        setState(() => _i = (_i + 1) % widget.frames.length);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: Image.file(
        widget.frames[_i],
        key: ValueKey(_i),
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) =>
            const Center(child: Icon(Icons.fitness_center, size: 48)),
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/exercise_demo_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/exercise/exercise_demo.dart test/features/exercise_demo_test.dart
git commit -m "feat(exercise): widget de demostracion (gif / 2 fotogramas / texto)

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 5: Pantalla de Ajustes (tamaño / vaciar / pre-descargar) + acceso desde Home

**Files:**
- Create: `lib/features/settings/settings_screen.dart`
- Modify: `lib/features/home/home_screen.dart`
- Test: `test/features/settings_screen_test.dart`

**Interfaces:**
- Consumes: `mediaCacheProvider`, `catalogProvider`, `mediaCandidates`, `MediaKind`.
- Produces: `class SettingsScreen extends ConsumerStatefulWidget`: muestra el tamaño de caché, botón **Vaciar caché** (`key: Key('clear-cache')` → `cache.clear()`), botón **Pre-descargar todo** (`key: Key('predownload')`) que recorre el catálogo y descarga el primer candidato de cada ejercicio mostrando progreso. Home gana una acción de Ajustes en el AppBar (`key: Key('settings-button')`).

- [ ] **Step 1: Write the failing test**

Crear `test/features/settings_screen_test.dart`:
```dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/app/providers.dart';
import 'package:fragua/core/models/exercise.dart';
import 'package:fragua/features/settings/settings_screen.dart';
import 'package:fragua/services/media/media_cache.dart';

class SpyCache implements MediaCache {
  bool cleared = false;
  @override
  Future<File?> getIfCached(String url) async => null;
  @override
  Future<File?> fetch(String url) async => null;
  @override
  Future<int> sizeBytes() async => 0;
  @override
  Future<void> clear() async => cleared = true;
}

void main() {
  testWidgets('vaciar caché llama a clear()', (tester) async {
    final spy = SpyCache();
    await tester.pumpWidget(ProviderScope(
      overrides: [
        mediaCacheProvider.overrideWithValue(spy),
        catalogProvider.overrideWith((ref) async => <Exercise>[]),
      ],
      child: const MaterialApp(home: SettingsScreen()),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('clear-cache')));
    await tester.pumpAndSettle();

    expect(spy.cleared, isTrue);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/settings_screen_test.dart`
Expected: FAIL — `SettingsScreen` no existe.

- [ ] **Step 3: Implement the settings screen**

Crear `lib/features/settings/settings_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/media/exercise_media.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  int _bytes = 0;
  String? _status;

  @override
  void initState() {
    super.initState();
    _refreshSize();
  }

  Future<void> _refreshSize() async {
    final b = await ref.read(mediaCacheProvider).sizeBytes();
    if (mounted) setState(() => _bytes = b);
  }

  Future<void> _clear() async {
    await ref.read(mediaCacheProvider).clear();
    setState(() => _status = 'Caché vaciada');
    await _refreshSize();
  }

  Future<void> _predownload() async {
    final cache = ref.read(mediaCacheProvider);
    final catalog = await ref.read(catalogProvider.future);
    var done = 0;
    for (final ex in catalog) {
      for (final cand in mediaCandidates(
          gifKey: ex.gifKey, staticImages: ex.staticImages)) {
        if (cand.kind == MediaKind.text) break;
        var ok = true;
        for (final url in cand.urls) {
          final f = await cache.getIfCached(url) ?? await cache.fetch(url);
          if (f == null) {
            ok = false;
            break;
          }
        }
        if (ok) break;
      }
      done++;
      if (mounted) setState(() => _status = 'Descargando… $done/${catalog.length}');
    }
    if (mounted) setState(() => _status = 'Descarga completa ($done)');
    await _refreshSize();
  }

  @override
  Widget build(BuildContext context) {
    final mb = (_bytes / (1024 * 1024)).toStringAsFixed(1);
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Caché de animaciones', style: Theme.of(context).textTheme.titleMedium),
          Text('Tamaño actual: $mb MB'),
          const SizedBox(height: 12),
          FilledButton.icon(
            key: const Key('predownload'),
            onPressed: _predownload,
            icon: const Icon(Icons.download),
            label: const Text('Pre-descargar todo (wifi recomendado)'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            key: const Key('clear-cache'),
            onPressed: _clear,
            icon: const Icon(Icons.delete_outline),
            label: const Text('Vaciar caché'),
          ),
          if (_status != null) ...[
            const SizedBox(height: 16),
            Text(_status!),
          ],
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Link from Home**

En `lib/features/home/home_screen.dart`:

- Añade el import:
```dart
import '../settings/settings_screen.dart';
```

- Cambia el `AppBar` para añadir la acción de ajustes:
```dart
      appBar: AppBar(
        title: const Text('Fragua', key: Key('home-title')),
        actions: [
          IconButton(
            key: const Key('settings-button'),
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
```

- [ ] **Step 5: Run tests to verify they pass**

Run: `flutter test test/features/settings_screen_test.dart`
Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add lib/features/settings/settings_screen.dart lib/features/home/home_screen.dart test/features/settings_screen_test.dart
git commit -m "feat(settings): tamano/vaciar/pre-descargar cache + acceso desde Home

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 6: Incrustar la demo en las sesiones + verificación M5

**Files:**
- Modify: `lib/core/session/guided_session.dart` (`SessionStep.exerciseId`)
- Modify: `lib/features/workout/session_screen.dart` (fuerza)
- Modify: `lib/features/workout/guided_session_screen.dart` (guiada)
- Test: `test/core/session/guided_session_test.dart` (ampliar)

**Interfaces:**
- Consumes: `ExerciseDemo`.
- Produces: `SessionStep` gana `final String exerciseId` (work = id del ejercicio; rest = `''`); ambas pantallas de sesión muestran `ExerciseDemo` del ejercicio actual.

- [ ] **Step 1: Add exerciseId to SessionStep (failing test)**

Añade al final de `test/core/session/guided_session_test.dart` (dentro de `main()`):
```dart
  test('cada paso de trabajo lleva el id del ejercicio; el descanso no', () {
    final t = buildGuidedTimeline(circuit(rounds: 1));
    expect(t[0].kind, StepKind.work);
    expect(t[0].exerciseId, 'a');
    expect(t[1].kind, StepKind.rest);
    expect(t[1].exerciseId, '');
  });
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/session/guided_session_test.dart`
Expected: FAIL — `SessionStep` no tiene `exerciseId`.

- [ ] **Step 3: Add the field and populate it**

En `lib/core/session/guided_session.dart`:

- Añade el campo a `SessionStep` (tras `kind`):
```dart
  final String exerciseId;
```
- Añade el parámetro al constructor `const SessionStep({...})` (tras `required this.kind,`):
```dart
    required this.exerciseId,
```
- En `buildGuidedTimeline`, en el paso de trabajo añade `exerciseId: e.exerciseId,` y en el de descanso `exerciseId: '',`:
```dart
      steps.add(SessionStep(
        kind: StepKind.work,
        exerciseId: e.exerciseId,
        seconds: work,
        label: e.exerciseName,
        round: r,
        totalRounds: rounds,
      ));
      steps.add(SessionStep(
        kind: StepKind.rest,
        exerciseId: '',
        seconds: e.restSeconds,
        label: restLabel,
        round: r,
        totalRounds: rounds,
      ));
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/core/session/`
Expected: PASS (nuevo + los de M4 siguen verdes; nadie construye `SessionStep` a mano salvo el builder).

- [ ] **Step 5: Show the demo in the strength session**

En `lib/features/workout/session_screen.dart`:

- Añade el import:
```dart
import '../exercise/exercise_demo.dart';
```
- Dentro de la `Column` del `build` del controlador, justo después del `Text(ex.exerciseName, ...)`, inserta:
```dart
                ExerciseDemo(exerciseId: ex.exerciseId),
```

- [ ] **Step 6: Show the demo in the guided session**

En `lib/features/workout/guided_session_screen.dart`:

- Añade el import:
```dart
import '../exercise/exercise_demo.dart';
```
- En `_timelineBody`, tras el `Text(isRest ? 'Descanso' : (step?.label ?? ''), ...)`, inserta una demo solo para los pasos de trabajo con id:
```dart
        if (step != null && step.kind == StepKind.work && step.exerciseId.isNotEmpty)
          ExerciseDemo(exerciseId: step.exerciseId),
```

- [ ] **Step 7: Full verification (Definition of Done de M5)**

Run: `flutter test`
Expected: verde (todo M0→M5; las pantallas de sesión existentes siguen pasando porque `mediaCacheProvider` por defecto es `NoopMediaCache` → la demo cae a texto sin red).

Run: `flutter analyze`
Expected: `No issues found!`

Run: `tools/.venv/bin/python -m pytest tools/ -q`
Expected: verde.

- [ ] **Step 8: Commit**

```bash
git add lib/core/session/guided_session.dart lib/features/workout/session_screen.dart lib/features/workout/guided_session_screen.dart test/core/session/guided_session_test.dart
git commit -m "feat(workout): demostracion animada del ejercicio en las sesiones

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

## Verificación de M5 (Definition of Done)

- `flutter analyze` limpio · `flutter test` verde (core media, resolver, widget, ajustes, timeline con id) · `pytest` verde (mapeo gif_key).
- La BD trae `gif_key` poblado (~133 ejercicios); el resto usa los 2 fotogramas de free-exercise-db.
- Durante una sesión (fuerza y guiada) se ve la **demostración animada** del ejercicio actual: GIF real si existe, si no la animación de 2 fotogramas, y si no hay red ni caché, las instrucciones de texto.
- Ajustes permite **pre-descargar todo**, **vaciar caché** y ver el **tamaño**.
- Mergeado a `master`; push a `origin` (con el OK de Alberto).

## Cobertura de la spec (self-review)

- **§5.2 GIFs animados + estrategia de almacenamiento** (set abierto, descarga bajo demanda + caché, fallback estática→texto, fuente documentada) → Tasks 1–4. Fuente concreta: `hasaneyldrm/exercises-dataset` (no comercial; permitido por uso personal sin redistribución).
- **§7.9 pipeline de multimedia y caché** (gif_key en la BD, lazy fetch + caché, vaciar caché, fallback) → Tasks 1, 3, 5.
- **§11 almacenamiento bajo** (GIFs fuera del APK, descarga + caché borrable) → Tasks 3, 5 (nada de media en el APK; todo bajo demanda en `<appSupport>/media_cache`).
- **§12 manejo de errores** (offline-first: cadena GIF→estática→texto; fetch tolerante a fallos) → Tasks 2–4.
- **Fuera de M5** (explícito): detección estricta de **solo-wifi** (`connectivity_plus`) — la descarga es bajo demanda/manual, el gating wifi queda como mejora; **curación manual** de más mapeos GIF (la spec §16 lo prevé; el ~15% automático es de alta precisión, el resto cae a fotogramas sin riesgo de animación equivocada); barras de progreso finas en la pre-descarga (se muestra contador); ligas/stats (M6/M7).
