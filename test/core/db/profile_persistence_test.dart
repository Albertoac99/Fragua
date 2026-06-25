import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fragua/core/db/database.dart';
import 'package:fragua/core/models/enums.dart';
import 'package:fragua/core/models/user_profile.dart';

void main() {
  test('guarda y recupera el UserProfile (una sola fila)', () async {
    final db = FraguaDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final p = UserProfile(
      sex: Sex.female,
      birthDate: DateTime(2000, 1, 15),
      heightCm: 165,
      weightKg: 60,
      goal: Goal.fatLoss,
      level: ExperienceLevel.beginner,
      daysPerWeek: 3,
      sessionMinutes: 45,
      equipment: {Equipment.dumbbell, Equipment.bands},
      limitations: {'knee'},
    );

    expect(await db.loadProfile(), isNull);
    await db.saveProfile(p);

    final loaded = await db.loadProfile();
    expect(loaded, isNotNull);
    expect(loaded!.sex, Sex.female);
    expect(loaded.goal, Goal.fatLoss);
    expect(loaded.equipment, {Equipment.dumbbell, Equipment.bands});
    expect(loaded.limitations, {'knee'});
    expect(loaded.daysPerWeek, 3);

    // Guardar de nuevo NO duplica (upsert sobre id=0).
    await db.saveProfile(p.copyWith(weightKg: 58));
    final rows = await db.select(db.userProfiles).get();
    expect(rows, hasLength(1));
    expect((await db.loadProfile())!.weightKg, 58);
  });
}
