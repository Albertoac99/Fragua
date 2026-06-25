// Enums de dominio de Fragua. Dart puro: no debe importar Flutter.

enum Sex { male, female, other }

enum Goal { fatLoss, hypertrophy, strength, generalFitness, endurance }

enum ExperienceLevel { beginner, intermediate, advanced }

enum Modality { strength, guided, both }

enum ForceType { push, pull, staticHold }

enum Mechanic { compound, isolation }

enum ExerciseDifficulty { beginner, intermediate, expert }

/// Equipo que el usuario puede tener / que un ejercicio requiere.
enum Equipment {
  bodyweight,
  dumbbell,
  barbell,
  machine,
  cable,
  kettlebell,
  bands,
  pullupBar,
  bench,
  other,
}

/// Convierte el campo `equipment` crudo de free-exercise-db en [Equipment].
Equipment equipmentFromRaw(String? raw) {
  switch (raw?.toLowerCase().trim()) {
    case null:
    case '':
    case 'body only':
      return Equipment.bodyweight;
    case 'dumbbell':
      return Equipment.dumbbell;
    case 'barbell':
    case 'e-z curl bar':
      return Equipment.barbell;
    case 'machine':
      return Equipment.machine;
    case 'cable':
      return Equipment.cable;
    case 'kettlebells':
      return Equipment.kettlebell;
    case 'bands':
      return Equipment.bands;
    default:
      return Equipment.other;
  }
}
