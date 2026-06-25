// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ExercisesTable extends Exercises
    with TableInfo<$ExercisesTable, ExerciseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _forceMeta = const VerificationMeta('force');
  @override
  late final GeneratedColumn<String> force = GeneratedColumn<String>(
    'force',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _difficultyMeta = const VerificationMeta(
    'difficulty',
  );
  @override
  late final GeneratedColumn<String> difficulty = GeneratedColumn<String>(
    'difficulty',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mechanicMeta = const VerificationMeta(
    'mechanic',
  );
  @override
  late final GeneratedColumn<String> mechanic = GeneratedColumn<String>(
    'mechanic',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _equipmentMeta = const VerificationMeta(
    'equipment',
  );
  @override
  late final GeneratedColumn<String> equipment = GeneratedColumn<String>(
    'equipment',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _primaryMusclesMeta = const VerificationMeta(
    'primaryMuscles',
  );
  @override
  late final GeneratedColumn<String> primaryMuscles = GeneratedColumn<String>(
    'primary_muscles',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _secondaryMusclesMeta = const VerificationMeta(
    'secondaryMuscles',
  );
  @override
  late final GeneratedColumn<String> secondaryMuscles = GeneratedColumn<String>(
    'secondary_muscles',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _instructionsMeta = const VerificationMeta(
    'instructions',
  );
  @override
  late final GeneratedColumn<String> instructions = GeneratedColumn<String>(
    'instructions',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _staticImagesMeta = const VerificationMeta(
    'staticImages',
  );
  @override
  late final GeneratedColumn<String> staticImages = GeneratedColumn<String>(
    'static_images',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gifKeyMeta = const VerificationMeta('gifKey');
  @override
  late final GeneratedColumn<String> gifKey = GeneratedColumn<String>(
    'gif_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _modalityMeta = const VerificationMeta(
    'modality',
  );
  @override
  late final GeneratedColumn<String> modality = GeneratedColumn<String>(
    'modality',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _variationGroupMeta = const VerificationMeta(
    'variationGroup',
  );
  @override
  late final GeneratedColumn<String> variationGroup = GeneratedColumn<String>(
    'variation_group',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _variationRankMeta = const VerificationMeta(
    'variationRank',
  );
  @override
  late final GeneratedColumn<int> variationRank = GeneratedColumn<int>(
    'variation_rank',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    category,
    force,
    difficulty,
    mechanic,
    equipment,
    primaryMuscles,
    secondaryMuscles,
    instructions,
    staticImages,
    gifKey,
    modality,
    variationGroup,
    variationRank,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercises';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExerciseRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('force')) {
      context.handle(
        _forceMeta,
        force.isAcceptableOrUnknown(data['force']!, _forceMeta),
      );
    }
    if (data.containsKey('difficulty')) {
      context.handle(
        _difficultyMeta,
        difficulty.isAcceptableOrUnknown(data['difficulty']!, _difficultyMeta),
      );
    } else if (isInserting) {
      context.missing(_difficultyMeta);
    }
    if (data.containsKey('mechanic')) {
      context.handle(
        _mechanicMeta,
        mechanic.isAcceptableOrUnknown(data['mechanic']!, _mechanicMeta),
      );
    }
    if (data.containsKey('equipment')) {
      context.handle(
        _equipmentMeta,
        equipment.isAcceptableOrUnknown(data['equipment']!, _equipmentMeta),
      );
    } else if (isInserting) {
      context.missing(_equipmentMeta);
    }
    if (data.containsKey('primary_muscles')) {
      context.handle(
        _primaryMusclesMeta,
        primaryMuscles.isAcceptableOrUnknown(
          data['primary_muscles']!,
          _primaryMusclesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_primaryMusclesMeta);
    }
    if (data.containsKey('secondary_muscles')) {
      context.handle(
        _secondaryMusclesMeta,
        secondaryMuscles.isAcceptableOrUnknown(
          data['secondary_muscles']!,
          _secondaryMusclesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_secondaryMusclesMeta);
    }
    if (data.containsKey('instructions')) {
      context.handle(
        _instructionsMeta,
        instructions.isAcceptableOrUnknown(
          data['instructions']!,
          _instructionsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_instructionsMeta);
    }
    if (data.containsKey('static_images')) {
      context.handle(
        _staticImagesMeta,
        staticImages.isAcceptableOrUnknown(
          data['static_images']!,
          _staticImagesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_staticImagesMeta);
    }
    if (data.containsKey('gif_key')) {
      context.handle(
        _gifKeyMeta,
        gifKey.isAcceptableOrUnknown(data['gif_key']!, _gifKeyMeta),
      );
    }
    if (data.containsKey('modality')) {
      context.handle(
        _modalityMeta,
        modality.isAcceptableOrUnknown(data['modality']!, _modalityMeta),
      );
    } else if (isInserting) {
      context.missing(_modalityMeta);
    }
    if (data.containsKey('variation_group')) {
      context.handle(
        _variationGroupMeta,
        variationGroup.isAcceptableOrUnknown(
          data['variation_group']!,
          _variationGroupMeta,
        ),
      );
    }
    if (data.containsKey('variation_rank')) {
      context.handle(
        _variationRankMeta,
        variationRank.isAcceptableOrUnknown(
          data['variation_rank']!,
          _variationRankMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExerciseRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExerciseRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      force: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}force'],
      ),
      difficulty: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}difficulty'],
      )!,
      mechanic: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mechanic'],
      ),
      equipment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}equipment'],
      )!,
      primaryMuscles: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}primary_muscles'],
      )!,
      secondaryMuscles: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}secondary_muscles'],
      )!,
      instructions: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}instructions'],
      )!,
      staticImages: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}static_images'],
      )!,
      gifKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gif_key'],
      ),
      modality: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}modality'],
      )!,
      variationGroup: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}variation_group'],
      ),
      variationRank: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}variation_rank'],
      )!,
    );
  }

  @override
  $ExercisesTable createAlias(String alias) {
    return $ExercisesTable(attachedDatabase, alias);
  }
}

class ExerciseRow extends DataClass implements Insertable<ExerciseRow> {
  final String id;
  final String name;
  final String? category;
  final String? force;
  final String difficulty;
  final String? mechanic;
  final String equipment;
  final String primaryMuscles;
  final String secondaryMuscles;
  final String instructions;
  final String staticImages;
  final String? gifKey;
  final String modality;
  final String? variationGroup;
  final int variationRank;
  const ExerciseRow({
    required this.id,
    required this.name,
    this.category,
    this.force,
    required this.difficulty,
    this.mechanic,
    required this.equipment,
    required this.primaryMuscles,
    required this.secondaryMuscles,
    required this.instructions,
    required this.staticImages,
    this.gifKey,
    required this.modality,
    this.variationGroup,
    required this.variationRank,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    if (!nullToAbsent || force != null) {
      map['force'] = Variable<String>(force);
    }
    map['difficulty'] = Variable<String>(difficulty);
    if (!nullToAbsent || mechanic != null) {
      map['mechanic'] = Variable<String>(mechanic);
    }
    map['equipment'] = Variable<String>(equipment);
    map['primary_muscles'] = Variable<String>(primaryMuscles);
    map['secondary_muscles'] = Variable<String>(secondaryMuscles);
    map['instructions'] = Variable<String>(instructions);
    map['static_images'] = Variable<String>(staticImages);
    if (!nullToAbsent || gifKey != null) {
      map['gif_key'] = Variable<String>(gifKey);
    }
    map['modality'] = Variable<String>(modality);
    if (!nullToAbsent || variationGroup != null) {
      map['variation_group'] = Variable<String>(variationGroup);
    }
    map['variation_rank'] = Variable<int>(variationRank);
    return map;
  }

  ExercisesCompanion toCompanion(bool nullToAbsent) {
    return ExercisesCompanion(
      id: Value(id),
      name: Value(name),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      force: force == null && nullToAbsent
          ? const Value.absent()
          : Value(force),
      difficulty: Value(difficulty),
      mechanic: mechanic == null && nullToAbsent
          ? const Value.absent()
          : Value(mechanic),
      equipment: Value(equipment),
      primaryMuscles: Value(primaryMuscles),
      secondaryMuscles: Value(secondaryMuscles),
      instructions: Value(instructions),
      staticImages: Value(staticImages),
      gifKey: gifKey == null && nullToAbsent
          ? const Value.absent()
          : Value(gifKey),
      modality: Value(modality),
      variationGroup: variationGroup == null && nullToAbsent
          ? const Value.absent()
          : Value(variationGroup),
      variationRank: Value(variationRank),
    );
  }

  factory ExerciseRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExerciseRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      category: serializer.fromJson<String?>(json['category']),
      force: serializer.fromJson<String?>(json['force']),
      difficulty: serializer.fromJson<String>(json['difficulty']),
      mechanic: serializer.fromJson<String?>(json['mechanic']),
      equipment: serializer.fromJson<String>(json['equipment']),
      primaryMuscles: serializer.fromJson<String>(json['primaryMuscles']),
      secondaryMuscles: serializer.fromJson<String>(json['secondaryMuscles']),
      instructions: serializer.fromJson<String>(json['instructions']),
      staticImages: serializer.fromJson<String>(json['staticImages']),
      gifKey: serializer.fromJson<String?>(json['gifKey']),
      modality: serializer.fromJson<String>(json['modality']),
      variationGroup: serializer.fromJson<String?>(json['variationGroup']),
      variationRank: serializer.fromJson<int>(json['variationRank']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'category': serializer.toJson<String?>(category),
      'force': serializer.toJson<String?>(force),
      'difficulty': serializer.toJson<String>(difficulty),
      'mechanic': serializer.toJson<String?>(mechanic),
      'equipment': serializer.toJson<String>(equipment),
      'primaryMuscles': serializer.toJson<String>(primaryMuscles),
      'secondaryMuscles': serializer.toJson<String>(secondaryMuscles),
      'instructions': serializer.toJson<String>(instructions),
      'staticImages': serializer.toJson<String>(staticImages),
      'gifKey': serializer.toJson<String?>(gifKey),
      'modality': serializer.toJson<String>(modality),
      'variationGroup': serializer.toJson<String?>(variationGroup),
      'variationRank': serializer.toJson<int>(variationRank),
    };
  }

  ExerciseRow copyWith({
    String? id,
    String? name,
    Value<String?> category = const Value.absent(),
    Value<String?> force = const Value.absent(),
    String? difficulty,
    Value<String?> mechanic = const Value.absent(),
    String? equipment,
    String? primaryMuscles,
    String? secondaryMuscles,
    String? instructions,
    String? staticImages,
    Value<String?> gifKey = const Value.absent(),
    String? modality,
    Value<String?> variationGroup = const Value.absent(),
    int? variationRank,
  }) => ExerciseRow(
    id: id ?? this.id,
    name: name ?? this.name,
    category: category.present ? category.value : this.category,
    force: force.present ? force.value : this.force,
    difficulty: difficulty ?? this.difficulty,
    mechanic: mechanic.present ? mechanic.value : this.mechanic,
    equipment: equipment ?? this.equipment,
    primaryMuscles: primaryMuscles ?? this.primaryMuscles,
    secondaryMuscles: secondaryMuscles ?? this.secondaryMuscles,
    instructions: instructions ?? this.instructions,
    staticImages: staticImages ?? this.staticImages,
    gifKey: gifKey.present ? gifKey.value : this.gifKey,
    modality: modality ?? this.modality,
    variationGroup: variationGroup.present
        ? variationGroup.value
        : this.variationGroup,
    variationRank: variationRank ?? this.variationRank,
  );
  ExerciseRow copyWithCompanion(ExercisesCompanion data) {
    return ExerciseRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
      force: data.force.present ? data.force.value : this.force,
      difficulty: data.difficulty.present
          ? data.difficulty.value
          : this.difficulty,
      mechanic: data.mechanic.present ? data.mechanic.value : this.mechanic,
      equipment: data.equipment.present ? data.equipment.value : this.equipment,
      primaryMuscles: data.primaryMuscles.present
          ? data.primaryMuscles.value
          : this.primaryMuscles,
      secondaryMuscles: data.secondaryMuscles.present
          ? data.secondaryMuscles.value
          : this.secondaryMuscles,
      instructions: data.instructions.present
          ? data.instructions.value
          : this.instructions,
      staticImages: data.staticImages.present
          ? data.staticImages.value
          : this.staticImages,
      gifKey: data.gifKey.present ? data.gifKey.value : this.gifKey,
      modality: data.modality.present ? data.modality.value : this.modality,
      variationGroup: data.variationGroup.present
          ? data.variationGroup.value
          : this.variationGroup,
      variationRank: data.variationRank.present
          ? data.variationRank.value
          : this.variationRank,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('force: $force, ')
          ..write('difficulty: $difficulty, ')
          ..write('mechanic: $mechanic, ')
          ..write('equipment: $equipment, ')
          ..write('primaryMuscles: $primaryMuscles, ')
          ..write('secondaryMuscles: $secondaryMuscles, ')
          ..write('instructions: $instructions, ')
          ..write('staticImages: $staticImages, ')
          ..write('gifKey: $gifKey, ')
          ..write('modality: $modality, ')
          ..write('variationGroup: $variationGroup, ')
          ..write('variationRank: $variationRank')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    category,
    force,
    difficulty,
    mechanic,
    equipment,
    primaryMuscles,
    secondaryMuscles,
    instructions,
    staticImages,
    gifKey,
    modality,
    variationGroup,
    variationRank,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExerciseRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.category == this.category &&
          other.force == this.force &&
          other.difficulty == this.difficulty &&
          other.mechanic == this.mechanic &&
          other.equipment == this.equipment &&
          other.primaryMuscles == this.primaryMuscles &&
          other.secondaryMuscles == this.secondaryMuscles &&
          other.instructions == this.instructions &&
          other.staticImages == this.staticImages &&
          other.gifKey == this.gifKey &&
          other.modality == this.modality &&
          other.variationGroup == this.variationGroup &&
          other.variationRank == this.variationRank);
}

class ExercisesCompanion extends UpdateCompanion<ExerciseRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> category;
  final Value<String?> force;
  final Value<String> difficulty;
  final Value<String?> mechanic;
  final Value<String> equipment;
  final Value<String> primaryMuscles;
  final Value<String> secondaryMuscles;
  final Value<String> instructions;
  final Value<String> staticImages;
  final Value<String?> gifKey;
  final Value<String> modality;
  final Value<String?> variationGroup;
  final Value<int> variationRank;
  final Value<int> rowid;
  const ExercisesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.force = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.mechanic = const Value.absent(),
    this.equipment = const Value.absent(),
    this.primaryMuscles = const Value.absent(),
    this.secondaryMuscles = const Value.absent(),
    this.instructions = const Value.absent(),
    this.staticImages = const Value.absent(),
    this.gifKey = const Value.absent(),
    this.modality = const Value.absent(),
    this.variationGroup = const Value.absent(),
    this.variationRank = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExercisesCompanion.insert({
    required String id,
    required String name,
    this.category = const Value.absent(),
    this.force = const Value.absent(),
    required String difficulty,
    this.mechanic = const Value.absent(),
    required String equipment,
    required String primaryMuscles,
    required String secondaryMuscles,
    required String instructions,
    required String staticImages,
    this.gifKey = const Value.absent(),
    required String modality,
    this.variationGroup = const Value.absent(),
    this.variationRank = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       difficulty = Value(difficulty),
       equipment = Value(equipment),
       primaryMuscles = Value(primaryMuscles),
       secondaryMuscles = Value(secondaryMuscles),
       instructions = Value(instructions),
       staticImages = Value(staticImages),
       modality = Value(modality);
  static Insertable<ExerciseRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? category,
    Expression<String>? force,
    Expression<String>? difficulty,
    Expression<String>? mechanic,
    Expression<String>? equipment,
    Expression<String>? primaryMuscles,
    Expression<String>? secondaryMuscles,
    Expression<String>? instructions,
    Expression<String>? staticImages,
    Expression<String>? gifKey,
    Expression<String>? modality,
    Expression<String>? variationGroup,
    Expression<int>? variationRank,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (force != null) 'force': force,
      if (difficulty != null) 'difficulty': difficulty,
      if (mechanic != null) 'mechanic': mechanic,
      if (equipment != null) 'equipment': equipment,
      if (primaryMuscles != null) 'primary_muscles': primaryMuscles,
      if (secondaryMuscles != null) 'secondary_muscles': secondaryMuscles,
      if (instructions != null) 'instructions': instructions,
      if (staticImages != null) 'static_images': staticImages,
      if (gifKey != null) 'gif_key': gifKey,
      if (modality != null) 'modality': modality,
      if (variationGroup != null) 'variation_group': variationGroup,
      if (variationRank != null) 'variation_rank': variationRank,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExercisesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? category,
    Value<String?>? force,
    Value<String>? difficulty,
    Value<String?>? mechanic,
    Value<String>? equipment,
    Value<String>? primaryMuscles,
    Value<String>? secondaryMuscles,
    Value<String>? instructions,
    Value<String>? staticImages,
    Value<String?>? gifKey,
    Value<String>? modality,
    Value<String?>? variationGroup,
    Value<int>? variationRank,
    Value<int>? rowid,
  }) {
    return ExercisesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      force: force ?? this.force,
      difficulty: difficulty ?? this.difficulty,
      mechanic: mechanic ?? this.mechanic,
      equipment: equipment ?? this.equipment,
      primaryMuscles: primaryMuscles ?? this.primaryMuscles,
      secondaryMuscles: secondaryMuscles ?? this.secondaryMuscles,
      instructions: instructions ?? this.instructions,
      staticImages: staticImages ?? this.staticImages,
      gifKey: gifKey ?? this.gifKey,
      modality: modality ?? this.modality,
      variationGroup: variationGroup ?? this.variationGroup,
      variationRank: variationRank ?? this.variationRank,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (force.present) {
      map['force'] = Variable<String>(force.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<String>(difficulty.value);
    }
    if (mechanic.present) {
      map['mechanic'] = Variable<String>(mechanic.value);
    }
    if (equipment.present) {
      map['equipment'] = Variable<String>(equipment.value);
    }
    if (primaryMuscles.present) {
      map['primary_muscles'] = Variable<String>(primaryMuscles.value);
    }
    if (secondaryMuscles.present) {
      map['secondary_muscles'] = Variable<String>(secondaryMuscles.value);
    }
    if (instructions.present) {
      map['instructions'] = Variable<String>(instructions.value);
    }
    if (staticImages.present) {
      map['static_images'] = Variable<String>(staticImages.value);
    }
    if (gifKey.present) {
      map['gif_key'] = Variable<String>(gifKey.value);
    }
    if (modality.present) {
      map['modality'] = Variable<String>(modality.value);
    }
    if (variationGroup.present) {
      map['variation_group'] = Variable<String>(variationGroup.value);
    }
    if (variationRank.present) {
      map['variation_rank'] = Variable<int>(variationRank.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExercisesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('force: $force, ')
          ..write('difficulty: $difficulty, ')
          ..write('mechanic: $mechanic, ')
          ..write('equipment: $equipment, ')
          ..write('primaryMuscles: $primaryMuscles, ')
          ..write('secondaryMuscles: $secondaryMuscles, ')
          ..write('instructions: $instructions, ')
          ..write('staticImages: $staticImages, ')
          ..write('gifKey: $gifKey, ')
          ..write('modality: $modality, ')
          ..write('variationGroup: $variationGroup, ')
          ..write('variationRank: $variationRank, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserProfilesTable extends UserProfiles
    with TableInfo<$UserProfilesTable, UserProfileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _sexMeta = const VerificationMeta('sex');
  @override
  late final GeneratedColumn<String> sex = GeneratedColumn<String>(
    'sex',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _birthDateMeta = const VerificationMeta(
    'birthDate',
  );
  @override
  late final GeneratedColumn<DateTime> birthDate = GeneratedColumn<DateTime>(
    'birth_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _heightCmMeta = const VerificationMeta(
    'heightCm',
  );
  @override
  late final GeneratedColumn<double> heightCm = GeneratedColumn<double>(
    'height_cm',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightKgMeta = const VerificationMeta(
    'weightKg',
  );
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _goalMeta = const VerificationMeta('goal');
  @override
  late final GeneratedColumn<String> goal = GeneratedColumn<String>(
    'goal',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<String> level = GeneratedColumn<String>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _daysPerWeekMeta = const VerificationMeta(
    'daysPerWeek',
  );
  @override
  late final GeneratedColumn<int> daysPerWeek = GeneratedColumn<int>(
    'days_per_week',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionMinutesMeta = const VerificationMeta(
    'sessionMinutes',
  );
  @override
  late final GeneratedColumn<int> sessionMinutes = GeneratedColumn<int>(
    'session_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _equipmentMeta = const VerificationMeta(
    'equipment',
  );
  @override
  late final GeneratedColumn<String> equipment = GeneratedColumn<String>(
    'equipment',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _limitationsMeta = const VerificationMeta(
    'limitations',
  );
  @override
  late final GeneratedColumn<String> limitations = GeneratedColumn<String>(
    'limitations',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sex,
    birthDate,
    heightCm,
    weightKg,
    goal,
    level,
    daysPerWeek,
    sessionMinutes,
    equipment,
    limitations,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserProfileRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sex')) {
      context.handle(
        _sexMeta,
        sex.isAcceptableOrUnknown(data['sex']!, _sexMeta),
      );
    } else if (isInserting) {
      context.missing(_sexMeta);
    }
    if (data.containsKey('birth_date')) {
      context.handle(
        _birthDateMeta,
        birthDate.isAcceptableOrUnknown(data['birth_date']!, _birthDateMeta),
      );
    } else if (isInserting) {
      context.missing(_birthDateMeta);
    }
    if (data.containsKey('height_cm')) {
      context.handle(
        _heightCmMeta,
        heightCm.isAcceptableOrUnknown(data['height_cm']!, _heightCmMeta),
      );
    } else if (isInserting) {
      context.missing(_heightCmMeta);
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    } else if (isInserting) {
      context.missing(_weightKgMeta);
    }
    if (data.containsKey('goal')) {
      context.handle(
        _goalMeta,
        goal.isAcceptableOrUnknown(data['goal']!, _goalMeta),
      );
    } else if (isInserting) {
      context.missing(_goalMeta);
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    } else if (isInserting) {
      context.missing(_levelMeta);
    }
    if (data.containsKey('days_per_week')) {
      context.handle(
        _daysPerWeekMeta,
        daysPerWeek.isAcceptableOrUnknown(
          data['days_per_week']!,
          _daysPerWeekMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_daysPerWeekMeta);
    }
    if (data.containsKey('session_minutes')) {
      context.handle(
        _sessionMinutesMeta,
        sessionMinutes.isAcceptableOrUnknown(
          data['session_minutes']!,
          _sessionMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sessionMinutesMeta);
    }
    if (data.containsKey('equipment')) {
      context.handle(
        _equipmentMeta,
        equipment.isAcceptableOrUnknown(data['equipment']!, _equipmentMeta),
      );
    } else if (isInserting) {
      context.missing(_equipmentMeta);
    }
    if (data.containsKey('limitations')) {
      context.handle(
        _limitationsMeta,
        limitations.isAcceptableOrUnknown(
          data['limitations']!,
          _limitationsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_limitationsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserProfileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProfileRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sex'],
      )!,
      birthDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}birth_date'],
      )!,
      heightCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}height_cm'],
      )!,
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      )!,
      goal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}goal'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}level'],
      )!,
      daysPerWeek: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}days_per_week'],
      )!,
      sessionMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_minutes'],
      )!,
      equipment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}equipment'],
      )!,
      limitations: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}limitations'],
      )!,
    );
  }

  @override
  $UserProfilesTable createAlias(String alias) {
    return $UserProfilesTable(attachedDatabase, alias);
  }
}

class UserProfileRow extends DataClass implements Insertable<UserProfileRow> {
  final int id;
  final String sex;
  final DateTime birthDate;
  final double heightCm;
  final double weightKg;
  final String goal;
  final String level;
  final int daysPerWeek;
  final int sessionMinutes;
  final String equipment;
  final String limitations;
  const UserProfileRow({
    required this.id,
    required this.sex,
    required this.birthDate,
    required this.heightCm,
    required this.weightKg,
    required this.goal,
    required this.level,
    required this.daysPerWeek,
    required this.sessionMinutes,
    required this.equipment,
    required this.limitations,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['sex'] = Variable<String>(sex);
    map['birth_date'] = Variable<DateTime>(birthDate);
    map['height_cm'] = Variable<double>(heightCm);
    map['weight_kg'] = Variable<double>(weightKg);
    map['goal'] = Variable<String>(goal);
    map['level'] = Variable<String>(level);
    map['days_per_week'] = Variable<int>(daysPerWeek);
    map['session_minutes'] = Variable<int>(sessionMinutes);
    map['equipment'] = Variable<String>(equipment);
    map['limitations'] = Variable<String>(limitations);
    return map;
  }

  UserProfilesCompanion toCompanion(bool nullToAbsent) {
    return UserProfilesCompanion(
      id: Value(id),
      sex: Value(sex),
      birthDate: Value(birthDate),
      heightCm: Value(heightCm),
      weightKg: Value(weightKg),
      goal: Value(goal),
      level: Value(level),
      daysPerWeek: Value(daysPerWeek),
      sessionMinutes: Value(sessionMinutes),
      equipment: Value(equipment),
      limitations: Value(limitations),
    );
  }

  factory UserProfileRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProfileRow(
      id: serializer.fromJson<int>(json['id']),
      sex: serializer.fromJson<String>(json['sex']),
      birthDate: serializer.fromJson<DateTime>(json['birthDate']),
      heightCm: serializer.fromJson<double>(json['heightCm']),
      weightKg: serializer.fromJson<double>(json['weightKg']),
      goal: serializer.fromJson<String>(json['goal']),
      level: serializer.fromJson<String>(json['level']),
      daysPerWeek: serializer.fromJson<int>(json['daysPerWeek']),
      sessionMinutes: serializer.fromJson<int>(json['sessionMinutes']),
      equipment: serializer.fromJson<String>(json['equipment']),
      limitations: serializer.fromJson<String>(json['limitations']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sex': serializer.toJson<String>(sex),
      'birthDate': serializer.toJson<DateTime>(birthDate),
      'heightCm': serializer.toJson<double>(heightCm),
      'weightKg': serializer.toJson<double>(weightKg),
      'goal': serializer.toJson<String>(goal),
      'level': serializer.toJson<String>(level),
      'daysPerWeek': serializer.toJson<int>(daysPerWeek),
      'sessionMinutes': serializer.toJson<int>(sessionMinutes),
      'equipment': serializer.toJson<String>(equipment),
      'limitations': serializer.toJson<String>(limitations),
    };
  }

  UserProfileRow copyWith({
    int? id,
    String? sex,
    DateTime? birthDate,
    double? heightCm,
    double? weightKg,
    String? goal,
    String? level,
    int? daysPerWeek,
    int? sessionMinutes,
    String? equipment,
    String? limitations,
  }) => UserProfileRow(
    id: id ?? this.id,
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
  UserProfileRow copyWithCompanion(UserProfilesCompanion data) {
    return UserProfileRow(
      id: data.id.present ? data.id.value : this.id,
      sex: data.sex.present ? data.sex.value : this.sex,
      birthDate: data.birthDate.present ? data.birthDate.value : this.birthDate,
      heightCm: data.heightCm.present ? data.heightCm.value : this.heightCm,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      goal: data.goal.present ? data.goal.value : this.goal,
      level: data.level.present ? data.level.value : this.level,
      daysPerWeek: data.daysPerWeek.present
          ? data.daysPerWeek.value
          : this.daysPerWeek,
      sessionMinutes: data.sessionMinutes.present
          ? data.sessionMinutes.value
          : this.sessionMinutes,
      equipment: data.equipment.present ? data.equipment.value : this.equipment,
      limitations: data.limitations.present
          ? data.limitations.value
          : this.limitations,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProfileRow(')
          ..write('id: $id, ')
          ..write('sex: $sex, ')
          ..write('birthDate: $birthDate, ')
          ..write('heightCm: $heightCm, ')
          ..write('weightKg: $weightKg, ')
          ..write('goal: $goal, ')
          ..write('level: $level, ')
          ..write('daysPerWeek: $daysPerWeek, ')
          ..write('sessionMinutes: $sessionMinutes, ')
          ..write('equipment: $equipment, ')
          ..write('limitations: $limitations')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sex,
    birthDate,
    heightCm,
    weightKg,
    goal,
    level,
    daysPerWeek,
    sessionMinutes,
    equipment,
    limitations,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProfileRow &&
          other.id == this.id &&
          other.sex == this.sex &&
          other.birthDate == this.birthDate &&
          other.heightCm == this.heightCm &&
          other.weightKg == this.weightKg &&
          other.goal == this.goal &&
          other.level == this.level &&
          other.daysPerWeek == this.daysPerWeek &&
          other.sessionMinutes == this.sessionMinutes &&
          other.equipment == this.equipment &&
          other.limitations == this.limitations);
}

class UserProfilesCompanion extends UpdateCompanion<UserProfileRow> {
  final Value<int> id;
  final Value<String> sex;
  final Value<DateTime> birthDate;
  final Value<double> heightCm;
  final Value<double> weightKg;
  final Value<String> goal;
  final Value<String> level;
  final Value<int> daysPerWeek;
  final Value<int> sessionMinutes;
  final Value<String> equipment;
  final Value<String> limitations;
  const UserProfilesCompanion({
    this.id = const Value.absent(),
    this.sex = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.goal = const Value.absent(),
    this.level = const Value.absent(),
    this.daysPerWeek = const Value.absent(),
    this.sessionMinutes = const Value.absent(),
    this.equipment = const Value.absent(),
    this.limitations = const Value.absent(),
  });
  UserProfilesCompanion.insert({
    this.id = const Value.absent(),
    required String sex,
    required DateTime birthDate,
    required double heightCm,
    required double weightKg,
    required String goal,
    required String level,
    required int daysPerWeek,
    required int sessionMinutes,
    required String equipment,
    required String limitations,
  }) : sex = Value(sex),
       birthDate = Value(birthDate),
       heightCm = Value(heightCm),
       weightKg = Value(weightKg),
       goal = Value(goal),
       level = Value(level),
       daysPerWeek = Value(daysPerWeek),
       sessionMinutes = Value(sessionMinutes),
       equipment = Value(equipment),
       limitations = Value(limitations);
  static Insertable<UserProfileRow> custom({
    Expression<int>? id,
    Expression<String>? sex,
    Expression<DateTime>? birthDate,
    Expression<double>? heightCm,
    Expression<double>? weightKg,
    Expression<String>? goal,
    Expression<String>? level,
    Expression<int>? daysPerWeek,
    Expression<int>? sessionMinutes,
    Expression<String>? equipment,
    Expression<String>? limitations,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sex != null) 'sex': sex,
      if (birthDate != null) 'birth_date': birthDate,
      if (heightCm != null) 'height_cm': heightCm,
      if (weightKg != null) 'weight_kg': weightKg,
      if (goal != null) 'goal': goal,
      if (level != null) 'level': level,
      if (daysPerWeek != null) 'days_per_week': daysPerWeek,
      if (sessionMinutes != null) 'session_minutes': sessionMinutes,
      if (equipment != null) 'equipment': equipment,
      if (limitations != null) 'limitations': limitations,
    });
  }

  UserProfilesCompanion copyWith({
    Value<int>? id,
    Value<String>? sex,
    Value<DateTime>? birthDate,
    Value<double>? heightCm,
    Value<double>? weightKg,
    Value<String>? goal,
    Value<String>? level,
    Value<int>? daysPerWeek,
    Value<int>? sessionMinutes,
    Value<String>? equipment,
    Value<String>? limitations,
  }) {
    return UserProfilesCompanion(
      id: id ?? this.id,
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

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sex.present) {
      map['sex'] = Variable<String>(sex.value);
    }
    if (birthDate.present) {
      map['birth_date'] = Variable<DateTime>(birthDate.value);
    }
    if (heightCm.present) {
      map['height_cm'] = Variable<double>(heightCm.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (goal.present) {
      map['goal'] = Variable<String>(goal.value);
    }
    if (level.present) {
      map['level'] = Variable<String>(level.value);
    }
    if (daysPerWeek.present) {
      map['days_per_week'] = Variable<int>(daysPerWeek.value);
    }
    if (sessionMinutes.present) {
      map['session_minutes'] = Variable<int>(sessionMinutes.value);
    }
    if (equipment.present) {
      map['equipment'] = Variable<String>(equipment.value);
    }
    if (limitations.present) {
      map['limitations'] = Variable<String>(limitations.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProfilesCompanion(')
          ..write('id: $id, ')
          ..write('sex: $sex, ')
          ..write('birthDate: $birthDate, ')
          ..write('heightCm: $heightCm, ')
          ..write('weightKg: $weightKg, ')
          ..write('goal: $goal, ')
          ..write('level: $level, ')
          ..write('daysPerWeek: $daysPerWeek, ')
          ..write('sessionMinutes: $sessionMinutes, ')
          ..write('equipment: $equipment, ')
          ..write('limitations: $limitations')
          ..write(')'))
        .toString();
  }
}

abstract class _$FraguaDatabase extends GeneratedDatabase {
  _$FraguaDatabase(QueryExecutor e) : super(e);
  $FraguaDatabaseManager get managers => $FraguaDatabaseManager(this);
  late final $ExercisesTable exercises = $ExercisesTable(this);
  late final $UserProfilesTable userProfiles = $UserProfilesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [exercises, userProfiles];
}

typedef $$ExercisesTableCreateCompanionBuilder =
    ExercisesCompanion Function({
      required String id,
      required String name,
      Value<String?> category,
      Value<String?> force,
      required String difficulty,
      Value<String?> mechanic,
      required String equipment,
      required String primaryMuscles,
      required String secondaryMuscles,
      required String instructions,
      required String staticImages,
      Value<String?> gifKey,
      required String modality,
      Value<String?> variationGroup,
      Value<int> variationRank,
      Value<int> rowid,
    });
typedef $$ExercisesTableUpdateCompanionBuilder =
    ExercisesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> category,
      Value<String?> force,
      Value<String> difficulty,
      Value<String?> mechanic,
      Value<String> equipment,
      Value<String> primaryMuscles,
      Value<String> secondaryMuscles,
      Value<String> instructions,
      Value<String> staticImages,
      Value<String?> gifKey,
      Value<String> modality,
      Value<String?> variationGroup,
      Value<int> variationRank,
      Value<int> rowid,
    });

class $$ExercisesTableFilterComposer
    extends Composer<_$FraguaDatabase, $ExercisesTable> {
  $$ExercisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get force => $composableBuilder(
    column: $table.force,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mechanic => $composableBuilder(
    column: $table.mechanic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get equipment => $composableBuilder(
    column: $table.equipment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get primaryMuscles => $composableBuilder(
    column: $table.primaryMuscles,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get secondaryMuscles => $composableBuilder(
    column: $table.secondaryMuscles,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get instructions => $composableBuilder(
    column: $table.instructions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get staticImages => $composableBuilder(
    column: $table.staticImages,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gifKey => $composableBuilder(
    column: $table.gifKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modality => $composableBuilder(
    column: $table.modality,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get variationGroup => $composableBuilder(
    column: $table.variationGroup,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get variationRank => $composableBuilder(
    column: $table.variationRank,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExercisesTableOrderingComposer
    extends Composer<_$FraguaDatabase, $ExercisesTable> {
  $$ExercisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get force => $composableBuilder(
    column: $table.force,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mechanic => $composableBuilder(
    column: $table.mechanic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get equipment => $composableBuilder(
    column: $table.equipment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get primaryMuscles => $composableBuilder(
    column: $table.primaryMuscles,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get secondaryMuscles => $composableBuilder(
    column: $table.secondaryMuscles,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get instructions => $composableBuilder(
    column: $table.instructions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get staticImages => $composableBuilder(
    column: $table.staticImages,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gifKey => $composableBuilder(
    column: $table.gifKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modality => $composableBuilder(
    column: $table.modality,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get variationGroup => $composableBuilder(
    column: $table.variationGroup,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get variationRank => $composableBuilder(
    column: $table.variationRank,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExercisesTableAnnotationComposer
    extends Composer<_$FraguaDatabase, $ExercisesTable> {
  $$ExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get force =>
      $composableBuilder(column: $table.force, builder: (column) => column);

  GeneratedColumn<String> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mechanic =>
      $composableBuilder(column: $table.mechanic, builder: (column) => column);

  GeneratedColumn<String> get equipment =>
      $composableBuilder(column: $table.equipment, builder: (column) => column);

  GeneratedColumn<String> get primaryMuscles => $composableBuilder(
    column: $table.primaryMuscles,
    builder: (column) => column,
  );

  GeneratedColumn<String> get secondaryMuscles => $composableBuilder(
    column: $table.secondaryMuscles,
    builder: (column) => column,
  );

  GeneratedColumn<String> get instructions => $composableBuilder(
    column: $table.instructions,
    builder: (column) => column,
  );

  GeneratedColumn<String> get staticImages => $composableBuilder(
    column: $table.staticImages,
    builder: (column) => column,
  );

  GeneratedColumn<String> get gifKey =>
      $composableBuilder(column: $table.gifKey, builder: (column) => column);

  GeneratedColumn<String> get modality =>
      $composableBuilder(column: $table.modality, builder: (column) => column);

  GeneratedColumn<String> get variationGroup => $composableBuilder(
    column: $table.variationGroup,
    builder: (column) => column,
  );

  GeneratedColumn<int> get variationRank => $composableBuilder(
    column: $table.variationRank,
    builder: (column) => column,
  );
}

class $$ExercisesTableTableManager
    extends
        RootTableManager<
          _$FraguaDatabase,
          $ExercisesTable,
          ExerciseRow,
          $$ExercisesTableFilterComposer,
          $$ExercisesTableOrderingComposer,
          $$ExercisesTableAnnotationComposer,
          $$ExercisesTableCreateCompanionBuilder,
          $$ExercisesTableUpdateCompanionBuilder,
          (
            ExerciseRow,
            BaseReferences<_$FraguaDatabase, $ExercisesTable, ExerciseRow>,
          ),
          ExerciseRow,
          PrefetchHooks Function()
        > {
  $$ExercisesTableTableManager(_$FraguaDatabase db, $ExercisesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExercisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExercisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<String?> force = const Value.absent(),
                Value<String> difficulty = const Value.absent(),
                Value<String?> mechanic = const Value.absent(),
                Value<String> equipment = const Value.absent(),
                Value<String> primaryMuscles = const Value.absent(),
                Value<String> secondaryMuscles = const Value.absent(),
                Value<String> instructions = const Value.absent(),
                Value<String> staticImages = const Value.absent(),
                Value<String?> gifKey = const Value.absent(),
                Value<String> modality = const Value.absent(),
                Value<String?> variationGroup = const Value.absent(),
                Value<int> variationRank = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExercisesCompanion(
                id: id,
                name: name,
                category: category,
                force: force,
                difficulty: difficulty,
                mechanic: mechanic,
                equipment: equipment,
                primaryMuscles: primaryMuscles,
                secondaryMuscles: secondaryMuscles,
                instructions: instructions,
                staticImages: staticImages,
                gifKey: gifKey,
                modality: modality,
                variationGroup: variationGroup,
                variationRank: variationRank,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> category = const Value.absent(),
                Value<String?> force = const Value.absent(),
                required String difficulty,
                Value<String?> mechanic = const Value.absent(),
                required String equipment,
                required String primaryMuscles,
                required String secondaryMuscles,
                required String instructions,
                required String staticImages,
                Value<String?> gifKey = const Value.absent(),
                required String modality,
                Value<String?> variationGroup = const Value.absent(),
                Value<int> variationRank = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExercisesCompanion.insert(
                id: id,
                name: name,
                category: category,
                force: force,
                difficulty: difficulty,
                mechanic: mechanic,
                equipment: equipment,
                primaryMuscles: primaryMuscles,
                secondaryMuscles: secondaryMuscles,
                instructions: instructions,
                staticImages: staticImages,
                gifKey: gifKey,
                modality: modality,
                variationGroup: variationGroup,
                variationRank: variationRank,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExercisesTableProcessedTableManager =
    ProcessedTableManager<
      _$FraguaDatabase,
      $ExercisesTable,
      ExerciseRow,
      $$ExercisesTableFilterComposer,
      $$ExercisesTableOrderingComposer,
      $$ExercisesTableAnnotationComposer,
      $$ExercisesTableCreateCompanionBuilder,
      $$ExercisesTableUpdateCompanionBuilder,
      (
        ExerciseRow,
        BaseReferences<_$FraguaDatabase, $ExercisesTable, ExerciseRow>,
      ),
      ExerciseRow,
      PrefetchHooks Function()
    >;
typedef $$UserProfilesTableCreateCompanionBuilder =
    UserProfilesCompanion Function({
      Value<int> id,
      required String sex,
      required DateTime birthDate,
      required double heightCm,
      required double weightKg,
      required String goal,
      required String level,
      required int daysPerWeek,
      required int sessionMinutes,
      required String equipment,
      required String limitations,
    });
typedef $$UserProfilesTableUpdateCompanionBuilder =
    UserProfilesCompanion Function({
      Value<int> id,
      Value<String> sex,
      Value<DateTime> birthDate,
      Value<double> heightCm,
      Value<double> weightKg,
      Value<String> goal,
      Value<String> level,
      Value<int> daysPerWeek,
      Value<int> sessionMinutes,
      Value<String> equipment,
      Value<String> limitations,
    });

class $$UserProfilesTableFilterComposer
    extends Composer<_$FraguaDatabase, $UserProfilesTable> {
  $$UserProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sex => $composableBuilder(
    column: $table.sex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get goal => $composableBuilder(
    column: $table.goal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get daysPerWeek => $composableBuilder(
    column: $table.daysPerWeek,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sessionMinutes => $composableBuilder(
    column: $table.sessionMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get equipment => $composableBuilder(
    column: $table.equipment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get limitations => $composableBuilder(
    column: $table.limitations,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserProfilesTableOrderingComposer
    extends Composer<_$FraguaDatabase, $UserProfilesTable> {
  $$UserProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sex => $composableBuilder(
    column: $table.sex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get goal => $composableBuilder(
    column: $table.goal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get daysPerWeek => $composableBuilder(
    column: $table.daysPerWeek,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sessionMinutes => $composableBuilder(
    column: $table.sessionMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get equipment => $composableBuilder(
    column: $table.equipment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get limitations => $composableBuilder(
    column: $table.limitations,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserProfilesTableAnnotationComposer
    extends Composer<_$FraguaDatabase, $UserProfilesTable> {
  $$UserProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sex =>
      $composableBuilder(column: $table.sex, builder: (column) => column);

  GeneratedColumn<DateTime> get birthDate =>
      $composableBuilder(column: $table.birthDate, builder: (column) => column);

  GeneratedColumn<double> get heightCm =>
      $composableBuilder(column: $table.heightCm, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<String> get goal =>
      $composableBuilder(column: $table.goal, builder: (column) => column);

  GeneratedColumn<String> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<int> get daysPerWeek => $composableBuilder(
    column: $table.daysPerWeek,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sessionMinutes => $composableBuilder(
    column: $table.sessionMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get equipment =>
      $composableBuilder(column: $table.equipment, builder: (column) => column);

  GeneratedColumn<String> get limitations => $composableBuilder(
    column: $table.limitations,
    builder: (column) => column,
  );
}

class $$UserProfilesTableTableManager
    extends
        RootTableManager<
          _$FraguaDatabase,
          $UserProfilesTable,
          UserProfileRow,
          $$UserProfilesTableFilterComposer,
          $$UserProfilesTableOrderingComposer,
          $$UserProfilesTableAnnotationComposer,
          $$UserProfilesTableCreateCompanionBuilder,
          $$UserProfilesTableUpdateCompanionBuilder,
          (
            UserProfileRow,
            BaseReferences<
              _$FraguaDatabase,
              $UserProfilesTable,
              UserProfileRow
            >,
          ),
          UserProfileRow,
          PrefetchHooks Function()
        > {
  $$UserProfilesTableTableManager(_$FraguaDatabase db, $UserProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> sex = const Value.absent(),
                Value<DateTime> birthDate = const Value.absent(),
                Value<double> heightCm = const Value.absent(),
                Value<double> weightKg = const Value.absent(),
                Value<String> goal = const Value.absent(),
                Value<String> level = const Value.absent(),
                Value<int> daysPerWeek = const Value.absent(),
                Value<int> sessionMinutes = const Value.absent(),
                Value<String> equipment = const Value.absent(),
                Value<String> limitations = const Value.absent(),
              }) => UserProfilesCompanion(
                id: id,
                sex: sex,
                birthDate: birthDate,
                heightCm: heightCm,
                weightKg: weightKg,
                goal: goal,
                level: level,
                daysPerWeek: daysPerWeek,
                sessionMinutes: sessionMinutes,
                equipment: equipment,
                limitations: limitations,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String sex,
                required DateTime birthDate,
                required double heightCm,
                required double weightKg,
                required String goal,
                required String level,
                required int daysPerWeek,
                required int sessionMinutes,
                required String equipment,
                required String limitations,
              }) => UserProfilesCompanion.insert(
                id: id,
                sex: sex,
                birthDate: birthDate,
                heightCm: heightCm,
                weightKg: weightKg,
                goal: goal,
                level: level,
                daysPerWeek: daysPerWeek,
                sessionMinutes: sessionMinutes,
                equipment: equipment,
                limitations: limitations,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$FraguaDatabase,
      $UserProfilesTable,
      UserProfileRow,
      $$UserProfilesTableFilterComposer,
      $$UserProfilesTableOrderingComposer,
      $$UserProfilesTableAnnotationComposer,
      $$UserProfilesTableCreateCompanionBuilder,
      $$UserProfilesTableUpdateCompanionBuilder,
      (
        UserProfileRow,
        BaseReferences<_$FraguaDatabase, $UserProfilesTable, UserProfileRow>,
      ),
      UserProfileRow,
      PrefetchHooks Function()
    >;

class $FraguaDatabaseManager {
  final _$FraguaDatabase _db;
  $FraguaDatabaseManager(this._db);
  $$ExercisesTableTableManager get exercises =>
      $$ExercisesTableTableManager(_db, _db.exercises);
  $$UserProfilesTableTableManager get userProfiles =>
      $$UserProfilesTableTableManager(_db, _db.userProfiles);
}
