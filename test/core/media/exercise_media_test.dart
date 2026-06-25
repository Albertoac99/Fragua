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
