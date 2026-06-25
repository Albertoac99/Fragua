import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/core/models/enums.dart';

void main() {
  group('equipmentFromRaw', () {
    test('mapea valores conocidos de free-exercise-db', () {
      expect(equipmentFromRaw('body only'), Equipment.bodyweight);
      expect(equipmentFromRaw('dumbbell'), Equipment.dumbbell);
      expect(equipmentFromRaw('barbell'), Equipment.barbell);
      expect(equipmentFromRaw('e-z curl bar'), Equipment.barbell);
      expect(equipmentFromRaw('machine'), Equipment.machine);
      expect(equipmentFromRaw('cable'), Equipment.cable);
      expect(equipmentFromRaw('kettlebells'), Equipment.kettlebell);
      expect(equipmentFromRaw('bands'), Equipment.bands);
    });

    test('null, vacío o desconocido => bodyweight/other', () {
      expect(equipmentFromRaw(null), Equipment.bodyweight);
      expect(equipmentFromRaw(''), Equipment.bodyweight);
      expect(equipmentFromRaw('medicine ball'), Equipment.other);
    });

    test('es case-insensitive y tolera espacios', () {
      expect(equipmentFromRaw('  Dumbbell '), Equipment.dumbbell);
    });
  });
}
