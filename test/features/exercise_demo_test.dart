import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/app/providers.dart';
import 'package:fragua/core/media/exercise_media.dart';
import 'package:fragua/features/exercise/exercise_demo.dart';

// La SELECCIÓN de rama (gif / fotogramas / texto) está cubierta a fondo por el
// test del resolver (exercise_media_provider_test.dart). Aquí sólo verificamos
// el cableado provider -> UI con la rama de texto: las ramas que renderizan
// `Image.file` no se prueban como widget porque cargar imágenes reales en
// widget tests es un antipatrón (bloquea el binding esperando el stream).
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
    expect(find.text('• Paso 1'), findsOneWidget);
  });
}
