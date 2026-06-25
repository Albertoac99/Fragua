import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/models/plan.dart';
import '../workout/session_screen.dart';

class PlanScreen extends ConsumerWidget {
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(planProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Mi plan')),
      body: plan.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (p) => p == null
            ? const Center(child: Text('Aún no hay plan'))
            : ListView(
                children: [for (final day in p.days) _DayCard(day: day)],
              ),
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  const _DayCard({required this.day});
  final PlanDay day;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(day.name, style: Theme.of(context).textTheme.titleMedium),
            Text(day.type == DayType.guided
                ? 'Circuito · ${day.rounds} rondas'
                : 'Fuerza'),
            const Divider(),
            for (final e in day.exercises)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(e.exerciseName)),
                    Text('${e.sets} x ${e.repLow}-${e.repHigh}'),
                  ],
                ),
              ),
            if (day.type == DayType.strength && day.exercises.isNotEmpty)
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => SessionScreen(day: day)),
                  ),
                  child: const Text('Empezar'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
