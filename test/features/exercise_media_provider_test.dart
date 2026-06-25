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
