import 'package:flutter/material.dart';

import 'body_metrics_screen.dart';
import 'strength_stats_screen.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Progreso')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.fitness_center),
            title: const Text('Fuerza'),
            subtitle: const Text('PR, 1RM estimado y volumen'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const StrengthStatsScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.monitor_weight),
            title: const Text('Cuerpo'),
            subtitle: const Text('Peso corporal y medidas'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const BodyMetricsScreen()),
            ),
          ),
        ],
      ),
    );
  }
}
