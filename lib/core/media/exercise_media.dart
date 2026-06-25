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
