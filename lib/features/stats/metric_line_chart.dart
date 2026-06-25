import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Gráfica de línea simple a partir de una serie de valores (en orden temporal).
class MetricLineChart extends StatelessWidget {
  const MetricLineChart({super.key, required this.values});
  final List<double> values;

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('Aún no hay datos')),
      );
    }
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: [
                for (var i = 0; i < values.length; i++)
                  FlSpot(i.toDouble(), values[i]),
              ],
              isCurved: false,
              dotData: const FlDotData(show: true),
            ),
          ],
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
}
