/// Resumen de un ejercicio realizado en una sesión (una fila por ejercicio/sesión).
class ExerciseLog {
  final String exerciseId;
  final String exerciseName;
  final DateTime performedAt;
  final double weight;
  final int totalReps;
  final int sets;
  final int maxReps;

  const ExerciseLog({
    required this.exerciseId,
    required this.exerciseName,
    required this.performedAt,
    required this.weight,
    required this.totalReps,
    required this.sets,
    required this.maxReps,
  });
}
