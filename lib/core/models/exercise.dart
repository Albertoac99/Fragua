import 'dart:convert';
import 'enums.dart';

/// Un ejercicio del catálogo (proveniente de la BD pre-construida).
class Exercise {
  final String id;
  final String name;
  final String? category;
  final ForceType? force;
  final ExerciseDifficulty difficulty;
  final Mechanic? mechanic;
  final Equipment equipment;
  final List<String> primaryMuscles;
  final List<String> secondaryMuscles;
  final List<String> instructions;
  final List<String> staticImages;
  final String? gifKey;
  final Modality modality;
  final String? variationGroup;
  final int variationRank;

  const Exercise({
    required this.id,
    required this.name,
    required this.category,
    required this.force,
    required this.difficulty,
    required this.mechanic,
    required this.equipment,
    required this.primaryMuscles,
    required this.secondaryMuscles,
    required this.instructions,
    required this.staticImages,
    required this.gifKey,
    required this.modality,
    required this.variationGroup,
    required this.variationRank,
  });

  factory Exercise.fromDbRow(Map<String, Object?> row) {
    List<String> jsonList(Object? v) =>
        (jsonDecode(v as String? ?? '[]') as List).cast<String>();

    return Exercise(
      id: row['id'] as String,
      name: row['name'] as String,
      category: row['category'] as String?,
      force: _forceFrom(row['force'] as String?),
      difficulty: ExerciseDifficulty.values.byName(row['difficulty'] as String),
      mechanic: _mechanicFrom(row['mechanic'] as String?),
      equipment: Equipment.values.byName(row['equipment'] as String),
      primaryMuscles: jsonList(row['primary_muscles']),
      secondaryMuscles: jsonList(row['secondary_muscles']),
      instructions: jsonList(row['instructions']),
      staticImages: jsonList(row['static_images']),
      gifKey: row['gif_key'] as String?,
      modality: Modality.values.byName(row['modality'] as String),
      variationGroup: row['variation_group'] as String?,
      variationRank: (row['variation_rank'] as int?) ?? 0,
    );
  }

  static ForceType? _forceFrom(String? raw) {
    switch (raw) {
      case 'push':
        return ForceType.push;
      case 'pull':
        return ForceType.pull;
      case 'static':
        return ForceType.staticHold;
      default:
        return null;
    }
  }

  static Mechanic? _mechanicFrom(String? raw) {
    switch (raw) {
      case 'compound':
        return Mechanic.compound;
      case 'isolation':
        return Mechanic.isolation;
      default:
        return null;
    }
  }
}
