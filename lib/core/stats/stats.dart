import 'exercise_log.dart';

/// 1RM estimado por la fórmula de Epley.
double estimatedOneRm(double weight, int reps) => weight * (1 + reps / 30.0);

/// Mejor 1RM estimado (PR) sobre una lista de logs; 0 si está vacía.
double bestOneRm(List<ExerciseLog> logs) {
  var best = 0.0;
  for (final l in logs) {
    final e = estimatedOneRm(l.weight, l.maxReps);
    if (e > best) best = e;
  }
  return best;
}

/// Volumen total (suma de peso * repeticiones totales).
double totalVolume(List<ExerciseLog> logs) {
  var v = 0.0;
  for (final l in logs) {
    v += l.weight * l.totalReps;
  }
  return v;
}

/// Serie temporal de 1RM estimado, ordenada por fecha ascendente.
List<({DateTime date, double oneRm})> oneRmSeries(List<ExerciseLog> logs) {
  final sorted = [...logs]..sort((a, b) => a.performedAt.compareTo(b.performedAt));
  return [
    for (final l in sorted)
      (date: l.performedAt, oneRm: estimatedOneRm(l.weight, l.maxReps)),
  ];
}
