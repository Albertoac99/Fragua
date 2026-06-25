import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/core/coach/coach.dart';
import 'package:fragua/core/models/enums.dart';
import 'package:fragua/core/models/exercise.dart';
import 'package:fragua/core/models/plan.dart';
import 'package:fragua/core/models/user_profile.dart';

Exercise ex(String id, Equipment eq, List<String> primary) => Exercise(
      id: id,
      name: id,
      category: 'strength',
      force: null,
      difficulty: ExerciseDifficulty.beginner,
      mechanic: Mechanic.compound,
      equipment: eq,
      primaryMuscles: primary,
      secondaryMuscles: const [],
      instructions: const [],
      staticImages: const [],
      gifKey: null,
      modality: Modality.both,
      variationGroup: null,
      variationRank: 0,
    );

// Catálogo mínimo que cubre todos los grupos usados por las plantillas.
List<Exercise> catalog() => [
      ex('squat', Equipment.barbell, ['quadriceps']),
      ex('bench', Equipment.barbell, ['chest']),
      ex('row', Equipment.barbell, ['lats']),
      ex('ohp', Equipment.barbell, ['shoulders']),
      ex('rdl', Equipment.barbell, ['hamstrings']),
      ex('hipthrust', Equipment.barbell, ['glutes']),
      ex('calfraise', Equipment.bodyweight, ['calves']),
      ex('curl', Equipment.dumbbell, ['biceps']),
      ex('pushdown', Equipment.dumbbell, ['triceps']),
      ex('pushup', Equipment.bodyweight, ['chest']),
      ex('plank', Equipment.bodyweight, ['abdominals']),
      ex('squat_bw', Equipment.bodyweight, ['quadriceps']),
    ];

UserProfile profile({
  required Goal goal,
  required int days,
  Set<Equipment> equip = const {Equipment.barbell, Equipment.dumbbell},
}) =>
    UserProfile(
      sex: Sex.male,
      birthDate: DateTime(1995, 1, 1),
      heightCm: 180,
      weightKg: 80,
      goal: goal,
      level: ExperienceLevel.intermediate,
      daysPerWeek: days,
      sessionMinutes: 60,
      equipment: equip,
    );

void main() {
  test('hipertrofia 4 días con barra => 4 días de fuerza Upper/Lower', () {
    final plan =
        const Coach().generate(profile(goal: Goal.hypertrophy, days: 4), catalog());
    expect(plan.split, SplitType.upperLower);
    expect(plan.days, hasLength(4));
    expect(plan.days.every((d) => d.type == DayType.strength), isTrue);
    final firstEx = plan.days.first.exercises.first;
    expect(firstEx.repLow, 6);
    expect(firstEx.repHigh, 12);
    expect(plan.days.first.exercises, isNotEmpty);
  });

  test('solo peso corporal => todos los días guiados (circuito)', () {
    final plan = const Coach().generate(
      profile(goal: Goal.strength, days: 3, equip: {Equipment.bodyweight}),
      catalog(),
    );
    expect(plan.days, hasLength(3));
    expect(plan.days.every((d) => d.type == DayType.guided), isTrue);
    expect(plan.days.first.format, WorkoutFormat.circuit);
    expect(plan.days.first.exercises, isNotEmpty);
  });

  test('pérdida de grasa 4 días => 2 fuerza + 2 guiados', () {
    final plan =
        const Coach().generate(profile(goal: Goal.fatLoss, days: 4), catalog());
    final strength = plan.days.where((d) => d.type == DayType.strength).length;
    final guided = plan.days.where((d) => d.type == DayType.guided).length;
    expect(strength, 2);
    expect(guided, 2);
  });

  test('los días guiados llevan workSeconds; los de fuerza no', () {
    final plan = const Coach().generate(
      profile(goal: Goal.strength, days: 3, equip: {Equipment.bodyweight}),
      catalog(),
    );
    final guided = plan.days.firstWhere((d) => d.type == DayType.guided);
    expect(guided.exercises.first.workSeconds, 40);

    final strengthPlan =
        const Coach().generate(profile(goal: Goal.hypertrophy, days: 4), catalog());
    final strength =
        strengthPlan.days.firstWhere((d) => d.type == DayType.strength);
    expect(strength.exercises.first.workSeconds, isNull);
  });

  test('es determinista', () {
    final p = profile(goal: Goal.hypertrophy, days: 4);
    final a = const Coach().generate(p, catalog()).toJson();
    final b = const Coach().generate(p, catalog()).toJson();
    expect(a.toString(), b.toString());
  });
}
