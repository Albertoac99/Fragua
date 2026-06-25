enum SplitType { fullBody, upperLower, pushPullLegs }

enum DayType { strength, guided }

enum WorkoutFormat { straightSets, circuit }

class PlanExercise {
  final String exerciseId;
  final String exerciseName;
  final int sets;
  final int repLow;
  final int repHigh;
  final int restSeconds;

  const PlanExercise({
    required this.exerciseId,
    required this.exerciseName,
    required this.sets,
    required this.repLow,
    required this.repHigh,
    required this.restSeconds,
  });

  Map<String, Object?> toJson() => {
        'exerciseId': exerciseId,
        'exerciseName': exerciseName,
        'sets': sets,
        'repLow': repLow,
        'repHigh': repHigh,
        'restSeconds': restSeconds,
      };

  factory PlanExercise.fromJson(Map<String, Object?> j) => PlanExercise(
        exerciseId: j['exerciseId'] as String,
        exerciseName: j['exerciseName'] as String,
        sets: j['sets'] as int,
        repLow: j['repLow'] as int,
        repHigh: j['repHigh'] as int,
        restSeconds: j['restSeconds'] as int,
      );
}

class PlanDay {
  final String name;
  final DayType type;
  final WorkoutFormat format;
  final int rounds;
  final List<PlanExercise> exercises;

  const PlanDay({
    required this.name,
    required this.type,
    required this.format,
    required this.rounds,
    required this.exercises,
  });

  Map<String, Object?> toJson() => {
        'name': name,
        'type': type.name,
        'format': format.name,
        'rounds': rounds,
        'exercises': exercises.map((e) => e.toJson()).toList(),
      };

  factory PlanDay.fromJson(Map<String, Object?> j) => PlanDay(
        name: j['name'] as String,
        type: DayType.values.byName(j['type'] as String),
        format: WorkoutFormat.values.byName(j['format'] as String),
        rounds: j['rounds'] as int,
        exercises: (j['exercises'] as List)
            .map((e) => PlanExercise.fromJson((e as Map).cast<String, Object?>()))
            .toList(),
      );
}

class Plan {
  final SplitType split;
  final List<PlanDay> days;

  const Plan({required this.split, required this.days});

  Map<String, Object?> toJson() => {
        'split': split.name,
        'days': days.map((d) => d.toJson()).toList(),
      };

  factory Plan.fromJson(Map<String, Object?> j) => Plan(
        split: SplitType.values.byName(j['split'] as String),
        days: (j['days'] as List)
            .map((d) => PlanDay.fromJson((d as Map).cast<String, Object?>()))
            .toList(),
      );
}
