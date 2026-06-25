import '../models/enums.dart';
import '../models/exercise.dart';

/// Elige el mejor ejercicio para los músculos objetivo, respetando equipo,
/// lesiones y exclusiones. Prioriza compuestos; determinista por id.
Exercise? selectExercise({
  required List<Exercise> catalog,
  required List<String> targetMuscles,
  required Set<Equipment> available,
  required Set<String> avoidMuscles,
  required Set<String> excludeIds,
}) {
  bool doable(Exercise e) =>
      e.equipment == Equipment.bodyweight || available.contains(e.equipment);

  final candidates = catalog.where((e) {
    if (excludeIds.contains(e.id)) return false;
    if (!e.primaryMuscles.any(targetMuscles.contains)) return false;
    if (e.primaryMuscles.any(avoidMuscles.contains)) return false;
    return doable(e);
  }).toList()
    ..sort((a, b) {
      final ac = a.mechanic == Mechanic.compound ? 0 : 1;
      final bc = b.mechanic == Mechanic.compound ? 0 : 1;
      if (ac != bc) return ac - bc;
      return a.id.compareTo(b.id);
    });

  return candidates.isEmpty ? null : candidates.first;
}
