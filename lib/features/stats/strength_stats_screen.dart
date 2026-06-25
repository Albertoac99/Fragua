import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/stats/stats.dart';
import 'metric_line_chart.dart';

class StrengthStatsScreen extends ConsumerStatefulWidget {
  const StrengthStatsScreen({super.key});

  @override
  ConsumerState<StrengthStatsScreen> createState() =>
      _StrengthStatsScreenState();
}

class _StrengthStatsScreenState extends ConsumerState<StrengthStatsScreen> {
  String? _selected;

  @override
  Widget build(BuildContext context) {
    final exercises = ref.watch(loggedExercisesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Fuerza')),
      body: exercises.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('Aún no hay entrenos registrados'));
          }
          final selected = _selected ?? list.first.id;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              DropdownButton<String>(
                value: selected,
                isExpanded: true,
                items: [
                  for (final e in list)
                    DropdownMenuItem(value: e.id, child: Text(e.name)),
                ],
                onChanged: (v) => setState(() => _selected = v),
              ),
              const SizedBox(height: 8),
              _stats(selected),
            ],
          );
        },
      ),
    );
  }

  Widget _stats(String exerciseId) {
    final logs = ref.watch(exerciseLogsProvider(exerciseId));
    return logs.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Error: $e'),
      data: (data) {
        final pr = bestOneRm(data);
        final vol = totalVolume(data);
        final series = oneRmSeries(data);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('PR (1RM estimado): ${pr.toStringAsFixed(1)} kg',
                style: Theme.of(context).textTheme.titleMedium),
            Text('Volumen total: ${vol.toStringAsFixed(0)} kg'),
            const SizedBox(height: 16),
            MetricLineChart(values: [for (final s in series) s.oneRm]),
          ],
        );
      },
    );
  }
}
