import 'dart:convert';

import 'package:drift/drift.dart';

import '../models/enums.dart';
import '../models/exercise.dart';
import '../models/plan.dart';
import '../models/user_profile.dart';
import '../notifications/notification_settings.dart';
import '../stats/exercise_log.dart';

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

@DataClassName('GuidedStateRow')
class GuidedStates extends Table {
  TextColumn get dayKey => text().named('day_key')();
  IntColumn get workSeconds => integer().named('work_seconds')();
  IntColumn get rounds => integer().named('rounds')();
  IntColumn get streak =>
      integer().named('streak').withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {dayKey};
}

@DataClassName('LeagueStateRow')
class LeagueStates extends Table {
  IntColumn get id => integer().named('id').withDefault(const Constant(0))();
  TextColumn get division =>
      text().named('division').withDefault(const Constant('bronze'))();
  IntColumn get weekId =>
      integer().named('week_id').withDefault(const Constant(0))();
  IntColumn get weeklyXp =>
      integer().named('weekly_xp').withDefault(const Constant(0))();
  IntColumn get streakCurrent =>
      integer().named('streak_current').withDefault(const Constant(0))();
  IntColumn get streakRecord =>
      integer().named('streak_record').withDefault(const Constant(0))();
  IntColumn get lastActiveDay => integer().named('last_active_day').nullable()();
  IntColumn get totalWorkouts =>
      integer().named('total_workouts').withDefault(const Constant(0))();
  IntColumn get totalPrs =>
      integer().named('total_prs').withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('XpEntryRow')
class XpEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get weekId => integer().named('week_id')();
  TextColumn get source => text().named('source')();
  IntColumn get amount => integer().named('amount')();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
}

@DataClassName('AchievementRow')
class Achievements extends Table {
  TextColumn get type => text().named('type')();
  DateTimeColumn get unlockedAt => dateTime().named('unlocked_at')();

  @override
  Set<Column> get primaryKey => {type};
}

@DataClassName('ExerciseLogRow2')
class ExerciseLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get exerciseId => text().named('exercise_id')();
  TextColumn get exerciseName => text().named('exercise_name')();
  DateTimeColumn get performedAt => dateTime().named('performed_at')();
  RealColumn get weight => real().named('weight')();
  IntColumn get totalReps => integer().named('total_reps')();
  IntColumn get sets => integer().named('sets')();
  IntColumn get maxReps => integer().named('max_reps')();
}

@DataClassName('BodyMetricRow')
class BodyMetrics extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get kind => text().named('kind')();
  RealColumn get value => real().named('value')();
  DateTimeColumn get measuredAt => dateTime().named('measured_at')();
}

@DataClassName('AppSettingsRow')
class AppSettings extends Table {
  IntColumn get id => integer().named('id').withDefault(const Constant(0))();
  BoolColumn get remindersEnabled =>
      boolean().named('reminders_enabled').withDefault(const Constant(false))();
  IntColumn get reminderHour =>
      integer().named('reminder_hour').withDefault(const Constant(19))();
  IntColumn get reminderMinute =>
      integer().named('reminder_minute').withDefault(const Constant(0))();
  IntColumn get reminderDaysMask =>
      integer().named('reminder_days_mask').withDefault(const Constant(0x1F))();
  BoolColumn get streakReminderEnabled => boolean()
      .named('streak_reminder_enabled')
      .withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [
  Exercises,
  UserProfiles,
  Plans,
  ExerciseStates,
  GuidedStates,
  LeagueStates,
  XpEntries,
  Achievements,
  ExerciseLogs,
  BodyMetrics,
  AppSettings,
])
class FraguaDatabase extends _$FraguaDatabase {
  FraguaDatabase(super.e);

  @override
  int get schemaVersion => 7;

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
          if (from < 4) await m.createTable(guidedStates);
          if (from < 5) {
            await m.createTable(leagueStates);
            await m.createTable(xpEntries);
            await m.createTable(achievements);
          }
          if (from < 6) {
            await m.createTable(exerciseLogs);
            await m.createTable(bodyMetrics);
          }
          if (from < 7) await m.createTable(appSettings);
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

  Future<({int workSeconds, int rounds, int streak})?> guidedState(
      String dayKey) async {
    final row = await (select(guidedStates)
          ..where((t) => t.dayKey.equals(dayKey)))
        .getSingleOrNull();
    if (row == null) return null;
    return (
      workSeconds: row.workSeconds,
      rounds: row.rounds,
      streak: row.streak,
    );
  }

  Future<void> saveGuidedState(
      String dayKey, int workSeconds, int rounds, int streak) async {
    await into(guidedStates).insertOnConflictUpdate(
      GuidedStatesCompanion.insert(
        dayKey: dayKey,
        workSeconds: workSeconds,
        rounds: rounds,
        streak: Value(streak),
      ),
    );
  }

  Future<LeagueStateRow?> loadLeagueState() =>
      (select(leagueStates)..where((t) => t.id.equals(0))).getSingleOrNull();

  Future<void> saveLeagueState({
    required String division,
    required int weekId,
    required int weeklyXp,
    required int streakCurrent,
    required int streakRecord,
    int? lastActiveDay,
    required int totalWorkouts,
    required int totalPrs,
  }) async {
    await into(leagueStates).insertOnConflictUpdate(
      LeagueStatesCompanion.insert(
        id: const Value(0),
        division: Value(division),
        weekId: Value(weekId),
        weeklyXp: Value(weeklyXp),
        streakCurrent: Value(streakCurrent),
        streakRecord: Value(streakRecord),
        lastActiveDay: Value(lastActiveDay),
        totalWorkouts: Value(totalWorkouts),
        totalPrs: Value(totalPrs),
      ),
    );
  }

  Future<void> addXpEntry({
    required int weekId,
    required String source,
    required int amount,
    required DateTime createdAt,
  }) async {
    await into(xpEntries).insert(
      XpEntriesCompanion.insert(
        weekId: weekId,
        source: source,
        amount: amount,
        createdAt: createdAt,
      ),
    );
  }

  Future<Set<String>> loadAchievements() async {
    final rows = await select(achievements).get();
    return rows.map((r) => r.type).toSet();
  }

  Future<void> unlockAchievement(String type, DateTime at) async {
    await into(achievements).insert(
      AchievementsCompanion.insert(type: type, unlockedAt: at),
      mode: InsertMode.insertOrIgnore,
    );
  }

  Future<void> addExerciseLog({
    required String exerciseId,
    required String exerciseName,
    required DateTime performedAt,
    required double weight,
    required int totalReps,
    required int sets,
    required int maxReps,
  }) async {
    await into(exerciseLogs).insert(
      ExerciseLogsCompanion.insert(
        exerciseId: exerciseId,
        exerciseName: exerciseName,
        performedAt: performedAt,
        weight: weight,
        totalReps: totalReps,
        sets: sets,
        maxReps: maxReps,
      ),
    );
  }

  Future<List<ExerciseLog>> loadExerciseLogs(String exerciseId) async {
    final rows = await (select(exerciseLogs)
          ..where((t) => t.exerciseId.equals(exerciseId))
          ..orderBy([(t) => OrderingTerm(expression: t.performedAt)]))
        .get();
    return [
      for (final r in rows)
        ExerciseLog(
          exerciseId: r.exerciseId,
          exerciseName: r.exerciseName,
          performedAt: r.performedAt,
          weight: r.weight,
          totalReps: r.totalReps,
          sets: r.sets,
          maxReps: r.maxReps,
        ),
    ];
  }

  Future<List<({String id, String name})>> loggedExercises() async {
    final q = selectOnly(exerciseLogs, distinct: true)
      ..addColumns([exerciseLogs.exerciseId, exerciseLogs.exerciseName]);
    final rows = await q.get();
    return [
      for (final r in rows)
        (
          id: r.read(exerciseLogs.exerciseId)!,
          name: r.read(exerciseLogs.exerciseName)!,
        ),
    ];
  }

  Future<void> addBodyMetric({
    required String kind,
    required double value,
    required DateTime measuredAt,
  }) async {
    await into(bodyMetrics).insert(
      BodyMetricsCompanion.insert(
        kind: kind,
        value: value,
        measuredAt: measuredAt,
      ),
    );
  }

  Future<List<({DateTime at, double value})>> loadBodyMetrics(String kind) async {
    final rows = await (select(bodyMetrics)
          ..where((t) => t.kind.equals(kind))
          ..orderBy([(t) => OrderingTerm(expression: t.measuredAt)]))
        .get();
    return [for (final r in rows) (at: r.measuredAt, value: r.value)];
  }

  Future<NotificationSettings> loadNotificationSettings() async {
    final row = await (select(appSettings)..where((t) => t.id.equals(0)))
        .getSingleOrNull();
    if (row == null) return const NotificationSettings();
    return NotificationSettings(
      remindersEnabled: row.remindersEnabled,
      reminderHour: row.reminderHour,
      reminderMinute: row.reminderMinute,
      reminderDays: daysFromMask(row.reminderDaysMask),
      streakReminderEnabled: row.streakReminderEnabled,
    );
  }

  Future<void> saveNotificationSettings(NotificationSettings s) async {
    await into(appSettings).insertOnConflictUpdate(
      AppSettingsCompanion.insert(
        id: const Value(0),
        remindersEnabled: Value(s.remindersEnabled),
        reminderHour: Value(s.reminderHour),
        reminderMinute: Value(s.reminderMinute),
        reminderDaysMask: Value(daysMaskOf(s.reminderDays)),
        streakReminderEnabled: Value(s.streakReminderEnabled),
      ),
    );
  }
}
