import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider).valueOrNull;
    final count = ref.watch(exerciseCountProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Fragua', key: Key('home-title'))),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.fitness_center, size: 64),
            const SizedBox(height: 12),
            Text(profile == null
                ? 'Sin perfil'
                : 'Objetivo: ${profile.goal.name} · ${profile.daysPerWeek} días/sem'),
            const SizedBox(height: 8),
            count.when(
              loading: () => const Text('Cargando catálogo…'),
              error: (e, _) => Text('Error catálogo: $e'),
              data: (n) => Text('$n ejercicios en el catálogo'),
            ),
          ],
        ),
      ),
    );
  }
}
