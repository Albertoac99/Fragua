import '../models/enums.dart';
import '../models/exercise.dart';
import '../models/plan.dart';
import '../models/user_profile.dart';
import 'exercise_selection.dart';
import 'rules.dart';

class Coach {
  const Coach();

  Plan generate(UserProfile profile, List<Exercise> catalog) {
    final onlyBodyweight = profile.equipment.length == 1 &&
        profile.equipment.contains(Equipment.bodyweight);
    final guided =
        guidedDaysFor(profile.goal, profile.daysPerWeek, onlyBodyweight);
    final strengthDays = profile.daysPerWeek - guided;
    final split = strengthDays > 0 ? splitFor(strengthDays) : SplitType.fullBody;
    final scheme = repSchemeFor(profile.goal, profile.level);

    final days = <PlanDay>[];

    // --- Días de fuerza ---
    final used = <String>{};
    for (final tpl in strengthDayTemplates(split, strengthDays)) {
      final exercises = <PlanExercise>[];
      for (final group in tpl.groups) {
        final picked = selectExercise(
          catalog: catalog,
          targetMuscles: muscleGroups[group]!,
          available: profile.equipment,
          avoidMuscles: profile.limitations,
          excludeIds: used,
        );
        if (picked != null) {
          used.add(picked.id);
          exercises.add(PlanExercise(
            exerciseId: picked.id,
            exerciseName: picked.name,
            sets: scheme.sets,
            repLow: scheme.repLow,
            repHigh: scheme.repHigh,
            restSeconds: scheme.restSeconds,
          ));
        }
      }
      days.add(PlanDay(
        name: tpl.name,
        type: DayType.strength,
        format: WorkoutFormat.straightSets,
        rounds: 1,
        exercises: exercises,
      ));
    }

    // --- Días guiados (circuito de cuerpo completo) ---
    const circuitGroups = [
      'quadriceps',
      'chest',
      'back',
      'glutes',
      'abdominals',
    ];
    final rounds = profile.level == ExperienceLevel.beginner ? 3 : 4;
    for (var i = 0; i < guided; i++) {
      final exercises = <PlanExercise>[];
      for (final group in circuitGroups) {
        final picked = selectExercise(
          catalog: catalog,
          targetMuscles: muscleGroups[group]!,
          available: profile.equipment,
          avoidMuscles: profile.limitations,
          excludeIds: {},
        );
        if (picked != null) {
          exercises.add(PlanExercise(
            exerciseId: picked.id,
            exerciseName: picked.name,
            sets: 1,
            repLow: 10,
            repHigh: 15,
            restSeconds: 20,
          ));
        }
      }
      days.add(PlanDay(
        name: 'Circuito ${i + 1}',
        type: DayType.guided,
        format: WorkoutFormat.circuit,
        rounds: rounds,
        exercises: exercises,
      ));
    }

    return Plan(split: split, days: days);
  }
}
