import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/core/coach/rules.dart';
import 'package:fragua/core/models/enums.dart';
import 'package:fragua/core/models/plan.dart';

void main() {
  group('guidedDaysFor', () {
    test('fuerza/hipertrofia con cargas => 0 guiados', () {
      expect(guidedDaysFor(Goal.strength, 4, false), 0);
      expect(guidedDaysFor(Goal.hypertrophy, 5, false), 0);
    });
    test('solo peso corporal => todo guiado', () {
      expect(guidedDaysFor(Goal.strength, 4, true), 4);
    });
    test('pérdida de grasa => 1-2 guiados', () {
      expect(guidedDaysFor(Goal.fatLoss, 3, false), 1);
      expect(guidedDaysFor(Goal.fatLoss, 5, false), 2);
    });
  });

  group('splitFor', () {
    test('mapea días de fuerza a split', () {
      expect(splitFor(2), SplitType.fullBody);
      expect(splitFor(3), SplitType.fullBody);
      expect(splitFor(4), SplitType.upperLower);
      expect(splitFor(6), SplitType.pushPullLegs);
    });
  });

  group('repSchemeFor', () {
    test('fuerza => pocas reps, descanso largo', () {
      final s = repSchemeFor(Goal.strength, ExperienceLevel.intermediate);
      expect(s.repLow, 3);
      expect(s.repHigh, 6);
      expect(s.restSeconds, greaterThanOrEqualTo(150));
    });
    test('hipertrofia => rango medio', () {
      final s = repSchemeFor(Goal.hypertrophy, ExperienceLevel.beginner);
      expect(s.repLow, 6);
      expect(s.repHigh, 12);
      expect(s.sets, 3); // principiante
    });
  });

  test('strengthDayTemplates: PPL da 3 días con grupos coherentes', () {
    final t = strengthDayTemplates(SplitType.pushPullLegs, 6);
    expect(t.map((d) => d.name), containsAll(['Push', 'Pull', 'Piernas']));
    expect(t.firstWhere((d) => d.name == 'Push').groups, contains('chest'));
  });
}
