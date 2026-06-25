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
