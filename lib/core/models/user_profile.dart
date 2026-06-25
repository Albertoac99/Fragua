import 'enums.dart';

/// Datos del usuario recogidos en el onboarding; alimentan al coach.
class UserProfile {
  final Sex sex;
  final DateTime birthDate;
  final double heightCm;
  final double weightKg;
  final Goal goal;
  final ExperienceLevel level;
  final int daysPerWeek;
  final int sessionMinutes;
  final Set<Equipment> equipment;
  final Set<String> limitations;

  const UserProfile({
    required this.sex,
    required this.birthDate,
    required this.heightCm,
    required this.weightKg,
    required this.goal,
    required this.level,
    required this.daysPerWeek,
    required this.sessionMinutes,
    this.equipment = const {Equipment.bodyweight},
    this.limitations = const {},
  });

  int ageOn(DateTime now) {
    var age = now.year - birthDate.year;
    final hadBirthday = now.month > birthDate.month ||
        (now.month == birthDate.month && now.day >= birthDate.day);
    if (!hadBirthday) age -= 1;
    return age;
  }

  bool get isValid =>
      heightCm > 0 &&
      weightKg > 0 &&
      daysPerWeek >= 1 &&
      daysPerWeek <= 7 &&
      sessionMinutes >= 10 &&
      equipment.isNotEmpty;

  UserProfile copyWith({
    Sex? sex,
    DateTime? birthDate,
    double? heightCm,
    double? weightKg,
    Goal? goal,
    ExperienceLevel? level,
    int? daysPerWeek,
    int? sessionMinutes,
    Set<Equipment>? equipment,
    Set<String>? limitations,
  }) {
    return UserProfile(
      sex: sex ?? this.sex,
      birthDate: birthDate ?? this.birthDate,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      goal: goal ?? this.goal,
      level: level ?? this.level,
      daysPerWeek: daysPerWeek ?? this.daysPerWeek,
      sessionMinutes: sessionMinutes ?? this.sessionMinutes,
      equipment: equipment ?? this.equipment,
      limitations: limitations ?? this.limitations,
    );
  }
}
