import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/db/database.dart';
import '../core/media/exercise_media.dart';
import '../core/models/exercise.dart';
import '../core/models/plan.dart';
import '../core/models/user_profile.dart';
import '../services/media/media_cache.dart';
import '../services/voice/voice_cues.dart';

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

final catalogProvider = FutureProvider<List<Exercise>>((ref) {
  return ref.watch(databaseProvider).loadExercises();
});

final planProvider = FutureProvider<Plan?>((ref) {
  return ref.watch(databaseProvider).loadPlan();
});

/// Override con TtsVoiceCues() en main(); SilentVoiceCues por defecto (tests).
final voiceProvider = Provider<VoiceCues>((ref) => const SilentVoiceCues());

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
  for (final cand
      in mediaCandidates(gifKey: ex.gifKey, staticImages: ex.staticImages)) {
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
