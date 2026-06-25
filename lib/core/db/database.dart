import 'dart:convert';

import 'package:drift/drift.dart';

import '../models/enums.dart';
import '../models/user_profile.dart';

part 'database.g.dart';

@DataClassName('ExerciseRow')
class Exercises extends Table {
  TextColumn get id => text().named('id')();
  TextColumn get name => text().named('name')();
  TextColumn get category => text().named('category').nullable()();
  TextColumn get force => text().named('force').nullable()();
  TextColumn get difficulty => text().named('difficulty')();
  TextColumn get mechanic => text().named('mechanic').nullable()();
  TextColumn get equipment => text().named('equipment')();
  TextColumn get primaryMuscles => text().named('primary_muscles')();
  TextColumn get secondaryMuscles => text().named('secondary_muscles')();
  TextColumn get instructions => text().named('instructions')();
  TextColumn get staticImages => text().named('static_images')();
  TextColumn get gifKey => text().named('gif_key').nullable()();
  TextColumn get modality => text().named('modality')();
  TextColumn get variationGroup => text().named('variation_group').nullable()();
  IntColumn get variationRank =>
      integer().named('variation_rank').withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('UserProfileRow')
class UserProfiles extends Table {
  IntColumn get id => integer().named('id').withDefault(const Constant(0))();
  TextColumn get sex => text().named('sex')();
  DateTimeColumn get birthDate => dateTime().named('birth_date')();
  RealColumn get heightCm => real().named('height_cm')();
  RealColumn get weightKg => real().named('weight_kg')();
  TextColumn get goal => text().named('goal')();
  TextColumn get level => text().named('level')();
  IntColumn get daysPerWeek => integer().named('days_per_week')();
  IntColumn get sessionMinutes => integer().named('session_minutes')();
  TextColumn get equipment => text().named('equipment')(); // JSON: nombres de enum
  TextColumn get limitations => text().named('limitations')(); // JSON: strings

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Exercises, UserProfiles])
class FraguaDatabase extends _$FraguaDatabase {
  FraguaDatabase(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          // El asset bundleado solo trae `exercises` (user_version=0).
          // Crea las tablas de usuario que falten.
          await m.createTable(userProfiles);
        },
      );

  Future<void> saveProfile(UserProfile p) async {
    await into(userProfiles).insertOnConflictUpdate(
      UserProfilesCompanion.insert(
        id: const Value(0),
        sex: p.sex.name,
        birthDate: p.birthDate,
        heightCm: p.heightCm,
        weightKg: p.weightKg,
        goal: p.goal.name,
        level: p.level.name,
        daysPerWeek: p.daysPerWeek,
        sessionMinutes: p.sessionMinutes,
        equipment: jsonEncode(p.equipment.map((e) => e.name).toList()),
        limitations: jsonEncode(p.limitations.toList()),
      ),
    );
  }

  Future<UserProfile?> loadProfile() async {
    final row = await (select(userProfiles)..where((t) => t.id.equals(0)))
        .getSingleOrNull();
    if (row == null) return null;
    return UserProfile(
      sex: Sex.values.byName(row.sex),
      birthDate: row.birthDate,
      heightCm: row.heightCm,
      weightKg: row.weightKg,
      goal: Goal.values.byName(row.goal),
      level: ExperienceLevel.values.byName(row.level),
      daysPerWeek: row.daysPerWeek,
      sessionMinutes: row.sessionMinutes,
      equipment: (jsonDecode(row.equipment) as List)
          .map((e) => Equipment.values.byName(e as String))
          .toSet(),
      limitations: (jsonDecode(row.limitations) as List).cast<String>().toSet(),
    );
  }
}
