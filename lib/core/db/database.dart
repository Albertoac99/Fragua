import 'dart:convert';

import 'package:drift/drift.dart';

import '../models/enums.dart';
import '../models/exercise.dart';
import '../models/plan.dart';
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

@DataClassName('PlanRow')
class Plans extends Table {
  IntColumn get id => integer().named('id').withDefault(const Constant(0))();
  TextColumn get data => text().named('data')(); // JSON del Plan

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ExerciseStateRow')
class ExerciseStates extends Table {
  TextColumn get exerciseId => text().named('exercise_id')();
  RealColumn get currentWeight => real().named('current_weight')();
  IntColumn get stallCount =>
      integer().named('stall_count').withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {exerciseId};
}

@DriftDatabase(tables: [Exercises, UserProfiles, Plans, ExerciseStates])
class FraguaDatabase extends _$FraguaDatabase {
  FraguaDatabase(super.e);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          // El asset bundleado solo trae `exercises` (user_version=0); crea
          // las tablas de usuario que falten según la versión de origen.
          if (from < 1) await m.createTable(userProfiles);
          if (from < 2) await m.createTable(plans);
          if (from < 3) await m.createTable(exerciseStates);
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

  Future<List<Exercise>> loadExercises() async {
    final rows = await select(exercises).get();
    return rows
        .map((r) => Exercise.fromDbRow({
              'id': r.id,
              'name': r.name,
              'category': r.category,
              'force': r.force,
              'difficulty': r.difficulty,
              'mechanic': r.mechanic,
              'equipment': r.equipment,
              'primary_muscles': r.primaryMuscles,
              'secondary_muscles': r.secondaryMuscles,
              'instructions': r.instructions,
              'static_images': r.staticImages,
              'gif_key': r.gifKey,
              'modality': r.modality,
              'variation_group': r.variationGroup,
              'variation_rank': r.variationRank,
            }))
        .toList();
  }

  Future<void> savePlan(Plan plan) async {
    await into(plans).insertOnConflictUpdate(
      PlansCompanion.insert(id: const Value(0), data: jsonEncode(plan.toJson())),
    );
  }

  Future<Plan?> loadPlan() async {
    final row =
        await (select(plans)..where((t) => t.id.equals(0))).getSingleOrNull();
    if (row == null) return null;
    return Plan.fromJson((jsonDecode(row.data) as Map).cast<String, Object?>());
  }

  Future<({double weight, int stall})?> exerciseState(String exerciseId) async {
    final row = await (select(exerciseStates)
          ..where((t) => t.exerciseId.equals(exerciseId)))
        .getSingleOrNull();
    if (row == null) return null;
    return (weight: row.currentWeight, stall: row.stallCount);
  }

  Future<void> saveExerciseState(
      String exerciseId, double weight, int stall) async {
    await into(exerciseStates).insertOnConflictUpdate(
      ExerciseStatesCompanion.insert(
        exerciseId: exerciseId,
        currentWeight: weight,
        stallCount: Value(stall),
      ),
    );
  }
}
