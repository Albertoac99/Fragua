import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import 'metric_line_chart.dart';

const _kinds = <String, String>{
  'bodyweight': 'Peso corporal',
  'waist': 'Cintura',
  'arm': 'Brazo',
  'chest': 'Pecho',
  'thigh': 'Pierna',
};

class BodyMetricsScreen extends ConsumerStatefulWidget {
  const BodyMetricsScreen({super.key});

  @override
  ConsumerState<BodyMetricsScreen> createState() => _BodyMetricsScreenState();
}

class _BodyMetricsScreenState extends ConsumerState<BodyMetricsScreen> {
  String _kind = 'bodyweight';
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final v = double.tryParse(_controller.text.replaceAll(',', '.'));
    if (v == null) return;
    await ref
        .read(databaseProvider)
        .addBodyMetric(kind: _kind, value: v, measuredAt: DateTime.now());
    _controller.clear();
    ref.invalidate(bodyMetricProvider(_kind));
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(bodyMetricProvider(_kind));
    return Scaffold(
      appBar: AppBar(title: const Text('Cuerpo')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButton<String>(
            value: _kind,
            isExpanded: true,
            items: [
              for (final e in _kinds.entries)
                DropdownMenuItem(value: e.key, child: Text(e.value)),
            ],
            onChanged: (v) => setState(() => _kind = v ?? 'bodyweight'),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  key: const Key('metric-value'),
                  controller: _controller,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Valor'),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                key: const Key('add-metric'),
                onPressed: _add,
                child: const Text('Añadir'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          data.when(
            loading: () => const SizedBox(
                height: 200, child: Center(child: CircularProgressIndicator())),
            error: (e, _) => Text('Error: $e'),
            data: (rows) =>
                MetricLineChart(values: [for (final r in rows) r.value]),
          ),
        ],
      ),
    );
  }
}
