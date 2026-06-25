import 'package:drift/drift.dart';

part 'database.g.dart';

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

@DriftDatabase(tables: [Exercises])
class FraguaDatabase extends _$FraguaDatabase {
  FraguaDatabase(super.e);

  @override
  int get schemaVersion => 1;
}
