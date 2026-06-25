import '../models/enums.dart';
import '../models/plan.dart';

/// Nº de días guiados (circuitos/HIIT) según objetivo y equipo.
int guidedDaysFor(Goal goal, int daysPerWeek, bool onlyBodyweight) {
  if (onlyBodyweight) return daysPerWeek; // sin cargas => calistenia/circuitos
  switch (goal) {
    case Goal.fatLoss:
      return daysPerWeek >= 4 ? 2 : 1;
    case Goal.endurance:
      return (daysPerWeek / 2).ceil();
    case Goal.generalFitness:
      return daysPerWeek >= 3 ? 1 : 0;
    case Goal.strength:
    case Goal.hypertrophy:
      return 0;
  }
}

SplitType splitFor(int strengthDays) {
  if (strengthDays <= 3) return SplitType.fullBody;
  if (strengthDays == 4) return SplitType.upperLower;
  return SplitType.pushPullLegs;
}

class RepScheme {
  final int sets;
  final int repLow;
  final int repHigh;
  final int restSeconds;
  const RepScheme({
    required this.sets,
    required this.repLow,
    required this.repHigh,
    required this.restSeconds,
  });
}

RepScheme repSchemeFor(Goal goal, ExperienceLevel level) {
  final sets = level == ExperienceLevel.beginner ? 3 : 4;
  switch (goal) {
    case Goal.strength:
      return RepScheme(sets: sets, repLow: 3, repHigh: 6, restSeconds: 180);
    case Goal.hypertrophy:
      return RepScheme(sets: sets, repLow: 6, repHigh: 12, restSeconds: 90);
    case Goal.endurance:
      return RepScheme(sets: sets, repLow: 12, repHigh: 20, restSeconds: 45);
    case Goal.fatLoss:
      return RepScheme(sets: sets, repLow: 8, repHigh: 15, restSeconds: 60);
    case Goal.generalFitness:
      return RepScheme(sets: sets, repLow: 8, repHigh: 12, restSeconds: 75);
  }
}

/// Etiqueta de grupo -> músculos de free-exercise-db que la componen.
const Map<String, List<String>> muscleGroups = {
  'chest': ['chest'],
  'back': ['lats', 'middle back', 'lower back', 'traps'],
  'shoulders': ['shoulders'],
  'biceps': ['biceps'],
  'triceps': ['triceps'],
  'quadriceps': ['quadriceps'],
  'hamstrings': ['hamstrings'],
  'glutes': ['glutes'],
  'calves': ['calves'],
  'abdominals': ['abdominals'],
};

typedef DayTemplate = ({String name, List<String> groups});

/// Plantillas de días de FUERZA según el split.
List<DayTemplate> strengthDayTemplates(SplitType split, int strengthDays) {
  switch (split) {
    case SplitType.fullBody:
      const groups = [
        'quadriceps',
        'chest',
        'back',
        'shoulders',
        'hamstrings',
      ];
      return List.generate(
        strengthDays,
        (i) => (name: 'Full Body ${i + 1}', groups: groups),
      );
    case SplitType.upperLower:
      return <DayTemplate>[
        (name: 'Tren superior', groups: ['chest', 'back', 'shoulders', 'biceps', 'triceps']),
        (name: 'Tren inferior', groups: ['quadriceps', 'hamstrings', 'glutes', 'calves']),
        (name: 'Tren superior 2', groups: ['back', 'chest', 'shoulders', 'triceps', 'biceps']),
        (name: 'Tren inferior 2', groups: ['quadriceps', 'glutes', 'hamstrings', 'calves']),
      ].take(strengthDays).toList();
    case SplitType.pushPullLegs:
      final base = <DayTemplate>[
        (name: 'Push', groups: ['chest', 'shoulders', 'triceps']),
        (name: 'Pull', groups: ['back', 'biceps']),
        (name: 'Piernas', groups: ['quadriceps', 'hamstrings', 'glutes', 'calves']),
      ];
      return List.generate(strengthDays, (i) => base[i % base.length]);
  }
}
