// Etiquetas en español para los enums que se muestran en la UI.
// El valor del enum (su `.name`) se usa internamente y en la BD; aquí solo
// traducimos lo que ve el usuario (onboarding, home, etc.).
import 'enums.dart';

extension SexLabel on Sex {
  String get label => switch (this) {
        Sex.male => 'Hombre',
        Sex.female => 'Mujer',
        Sex.other => 'Otro',
      };
}

extension GoalLabel on Goal {
  String get label => switch (this) {
        Goal.fatLoss => 'Pérdida de grasa',
        Goal.hypertrophy => 'Hipertrofia',
        Goal.strength => 'Fuerza',
        Goal.generalFitness => 'Forma física general',
        Goal.endurance => 'Resistencia',
      };
}

extension ExperienceLevelLabel on ExperienceLevel {
  String get label => switch (this) {
        ExperienceLevel.beginner => 'Principiante',
        ExperienceLevel.intermediate => 'Intermedio',
        ExperienceLevel.advanced => 'Avanzado',
      };
}

extension EquipmentLabel on Equipment {
  String get label => switch (this) {
        Equipment.bodyweight => 'Peso corporal',
        Equipment.dumbbell => 'Mancuerna',
        Equipment.barbell => 'Barra',
        Equipment.machine => 'Máquina',
        Equipment.cable => 'Polea',
        Equipment.kettlebell => 'Pesa rusa',
        Equipment.bands => 'Bandas',
        Equipment.pullupBar => 'Barra de dominadas',
        Equipment.bench => 'Banco',
        Equipment.other => 'Otro',
      };
}
