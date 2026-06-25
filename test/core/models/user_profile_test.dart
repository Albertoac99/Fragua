import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/core/models/enums.dart';
import 'package:fragua/core/models/user_profile.dart';

UserProfile sample({int daysPerWeek = 4}) => UserProfile(
      sex: Sex.male,
      birthDate: DateTime(1999, 6, 20),
      heightCm: 178,
      weightKg: 75,
      goal: Goal.hypertrophy,
      level: ExperienceLevel.intermediate,
      daysPerWeek: daysPerWeek,
      sessionMinutes: 60,
      equipment: {Equipment.barbell, Equipment.dumbbell},
    );

void main() {
  group('ageOn', () {
    test('aún no ha cumplido años este año', () {
      expect(sample().ageOn(DateTime(2026, 6, 19)), 26);
    });
    test('ya ha cumplido (el mismo día cuenta)', () {
      expect(sample().ageOn(DateTime(2026, 6, 20)), 27);
    });
  });

  group('isValid', () {
    test('un perfil bien formado es válido', () {
      expect(sample().isValid, isTrue);
    });
    test('daysPerWeek fuera de [1,7] es inválido', () {
      expect(sample(daysPerWeek: 0).isValid, isFalse);
      expect(sample(daysPerWeek: 8).isValid, isFalse);
    });
  });

  test('copyWith cambia solo lo indicado', () {
    final p = sample().copyWith(weightKg: 80);
    expect(p.weightKg, 80);
    expect(p.heightCm, 178);
    expect(p.goal, Goal.hypertrophy);
  });
}
