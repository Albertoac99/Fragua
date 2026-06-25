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

class $PlansTable extends Plans with TableInfo<$PlansTable, PlanRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlansTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
    'data',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, data];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plans';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlanRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlanRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlanRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data'],
      )!,
    );
  }

  @override
  $PlansTable createAlias(String alias) {
    return $PlansTable(attachedDatabase, alias);
  }
}

class PlanRow extends DataClass implements Insertable<PlanRow> {
  final int id;
  final String data;
  const PlanRow({required this.id, required this.data});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['data'] = Variable<String>(data);
    return map;
  }

  PlansCompanion toCompanion(bool nullToAbsent) {
    return PlansCompanion(id: Value(id), data: Value(data));
  }

  factory PlanRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlanRow(
      id: serializer.fromJson<int>(json['id']),
      data: serializer.fromJson<String>(json['data']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'data': serializer.toJson<String>(data),
    };
  }

  PlanRow copyWith({int? id, String? data}) =>
      PlanRow(id: id ?? this.id, data: data ?? this.data);
  PlanRow copyWithCompanion(PlansCompanion data) {
    return PlanRow(
      id: data.id.present ? data.id.value : this.id,
      data: data.data.present ? data.data.value : this.data,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlanRow(')
          ..write('id: $id, ')
          ..write('data: $data')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, data);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlanRow && other.id == this.id && other.data == this.data);
}

class PlansCompanion extends UpdateCompanion<PlanRow> {
  final Value<int> id;
  final Value<String> data;
  const PlansCompanion({
    this.id = const Value.absent(),
    this.data = const Value.absent(),
  });
  PlansCompanion.insert({this.id = const Value.absent(), required String data})
    : data = Value(data);
  static Insertable<PlanRow> custom({
    Expression<int>? id,
    Expression<String>? data,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (data != null) 'data': data,
    });
  }

  PlansCompanion copyWith({Value<int>? id, Value<String>? data}) {
    return PlansCompanion(id: id ?? this.id, data: data ?? this.data);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlansCompanion(')
          ..write('id: $id, ')
          ..write('data: $data')
          ..write(')'))
        .toString();
  }
}

class $ExerciseStatesTable extends ExerciseStates
    with TableInfo<$ExerciseStatesTable, ExerciseStateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExerciseStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentWeightMeta = const VerificationMeta(
    'currentWeight',
  );
  @override
  late final GeneratedColumn<double> currentWeight = GeneratedColumn<double>(
    'current_weight',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stallCountMeta = const VerificationMeta(
    'stallCount',
  );
  @override
  late final GeneratedColumn<int> stallCount = GeneratedColumn<int>(
    'stall_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [exerciseId, currentWeight, stallCount];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercise_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExerciseStateRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('current_weight')) {
      context.handle(
        _currentWeightMeta,
        currentWeight.isAcceptableOrUnknown(
          data['current_weight']!,
          _currentWeightMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currentWeightMeta);
    }
    if (data.containsKey('stall_count')) {
      context.handle(
        _stallCountMeta,
        stallCount.isAcceptableOrUnknown(data['stall_count']!, _stallCountMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {exerciseId};
  @override
  ExerciseStateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExerciseStateRow(
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_id'],
      )!,
      currentWeight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}current_weight'],
      )!,
      stallCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stall_count'],
      )!,
    );
  }

  @override
  $ExerciseStatesTable createAlias(String alias) {
    return $ExerciseStatesTable(attachedDatabase, alias);
  }
}

class ExerciseStateRow extends DataClass
    implements Insertable<ExerciseStateRow> {
  final String exerciseId;
  final double currentWeight;
  final int stallCount;
  const ExerciseStateRow({
    required this.exerciseId,
    required this.currentWeight,
    required this.stallCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['exercise_id'] = Variable<String>(exerciseId);
    map['current_weight'] = Variable<double>(currentWeight);
    map['stall_count'] = Variable<int>(stallCount);
    return map;
  }

  ExerciseStatesCompanion toCompanion(bool nullToAbsent) {
    return ExerciseStatesCompanion(
      exerciseId: Value(exerciseId),
      currentWeight: Value(currentWeight),
      stallCount: Value(stallCount),
    );
  }

  factory ExerciseStateRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExerciseStateRow(
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      currentWeight: serializer.fromJson<double>(json['currentWeight']),
      stallCount: serializer.fromJson<int>(json['stallCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'exerciseId': serializer.toJson<String>(exerciseId),
      'currentWeight': serializer.toJson<double>(currentWeight),
      'stallCount': serializer.toJson<int>(stallCount),
    };
  }

  ExerciseStateRow copyWith({
    String? exerciseId,
    double? currentWeight,
    int? stallCount,
  }) => ExerciseStateRow(
    exerciseId: exerciseId ?? this.exerciseId,
    currentWeight: currentWeight ?? this.currentWeight,
    stallCount: stallCount ?? this.stallCount,
  );
  ExerciseStateRow copyWithCompanion(ExerciseStatesCompanion data) {
    return ExerciseStateRow(
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      currentWeight: data.currentWeight.present
          ? data.currentWeight.value
          : this.currentWeight,
      stallCount: data.stallCount.present
          ? data.stallCount.value
          : this.stallCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseStateRow(')
          ..write('exerciseId: $exerciseId, ')
          ..write('currentWeight: $currentWeight, ')
          ..write('stallCount: $stallCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(exerciseId, currentWeight, stallCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExerciseStateRow &&
          other.exerciseId == this.exerciseId &&
          other.currentWeight == this.currentWeight &&
          other.stallCount == this.stallCount);
}

class ExerciseStatesCompanion extends UpdateCompanion<ExerciseStateRow> {
  final Value<String> exerciseId;
  final Value<double> currentWeight;
  final Value<int> stallCount;
  final Value<int> rowid;
  const ExerciseStatesCompanion({
    this.exerciseId = const Value.absent(),
    this.currentWeight = const Value.absent(),
    this.stallCount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExerciseStatesCompanion.insert({
    required String exerciseId,
    required double currentWeight,
    this.stallCount = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : exerciseId = Value(exerciseId),
       currentWeight = Value(currentWeight);
  static Insertable<ExerciseStateRow> custom({
    Expression<String>? exerciseId,
    Expression<double>? currentWeight,
    Expression<int>? stallCount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (currentWeight != null) 'current_weight': currentWeight,
      if (stallCount != null) 'stall_count': stallCount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExerciseStatesCompanion copyWith({
    Value<String>? exerciseId,
    Value<double>? currentWeight,
    Value<int>? stallCount,
    Value<int>? rowid,
  }) {
    return ExerciseStatesCompanion(
      exerciseId: exerciseId ?? this.exerciseId,
      currentWeight: currentWeight ?? this.currentWeight,
      stallCount: stallCount ?? this.stallCount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (currentWeight.present) {
      map['current_weight'] = Variable<double>(currentWeight.value);
    }
    if (stallCount.present) {
      map['stall_count'] = Variable<int>(stallCount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseStatesCompanion(')
          ..write('exerciseId: $exerciseId, ')
          ..write('currentWeight: $currentWeight, ')
          ..write('stallCount: $stallCount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GuidedStatesTable extends GuidedStates
    with TableInfo<$GuidedStatesTable, GuidedStateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GuidedStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dayKeyMeta = const VerificationMeta('dayKey');
  @override
  late final GeneratedColumn<String> dayKey = GeneratedColumn<String>(
    'day_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workSecondsMeta = const VerificationMeta(
    'workSeconds',
  );
  @override
  late final GeneratedColumn<int> workSeconds = GeneratedColumn<int>(
    'work_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roundsMeta = const VerificationMeta('rounds');
  @override
  late final GeneratedColumn<int> rounds = GeneratedColumn<int>(
    'rounds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _streakMeta = const VerificationMeta('streak');
  @override
  late final GeneratedColumn<int> streak = GeneratedColumn<int>(
    'streak',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [dayKey, workSeconds, rounds, streak];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'guided_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<GuidedStateRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('day_key')) {
      context.handle(
        _dayKeyMeta,
        dayKey.isAcceptableOrUnknown(data['day_key']!, _dayKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_dayKeyMeta);
    }
    if (data.containsKey('work_seconds')) {
      context.handle(
        _workSecondsMeta,
        workSeconds.isAcceptableOrUnknown(
          data['work_seconds']!,
          _workSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workSecondsMeta);
    }
    if (data.containsKey('rounds')) {
      context.handle(
        _roundsMeta,
        rounds.isAcceptableOrUnknown(data['rounds']!, _roundsMeta),
      );
    } else if (isInserting) {
      context.missing(_roundsMeta);
    }
    if (data.containsKey('streak')) {
      context.handle(
        _streakMeta,
        streak.isAcceptableOrUnknown(data['streak']!, _streakMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {dayKey};
  @override
  GuidedStateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GuidedStateRow(
      dayKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day_key'],
      )!,
      workSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}work_seconds'],
      )!,
      rounds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rounds'],
      )!,
      streak: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}streak'],
      )!,
    );
  }

  @override
  $GuidedStatesTable createAlias(String alias) {
    return $GuidedStatesTable(attachedDatabase, alias);
  }
}

class GuidedStateRow extends DataClass implements Insertable<GuidedStateRow> {
  final String dayKey;
  final int workSeconds;
  final int rounds;
  final int streak;
  const GuidedStateRow({
    required this.dayKey,
    required this.workSeconds,
    required this.rounds,
    required this.streak,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['day_key'] = Variable<String>(dayKey);
    map['work_seconds'] = Variable<int>(workSeconds);
    map['rounds'] = Variable<int>(rounds);
    map['streak'] = Variable<int>(streak);
    return map;
  }

  GuidedStatesCompanion toCompanion(bool nullToAbsent) {
    return GuidedStatesCompanion(
      dayKey: Value(dayKey),
      workSeconds: Value(workSeconds),
      rounds: Value(rounds),
      streak: Value(streak),
    );
  }

  factory GuidedStateRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GuidedStateRow(
      dayKey: serializer.fromJson<String>(json['dayKey']),
      workSeconds: serializer.fromJson<int>(json['workSeconds']),
      rounds: serializer.fromJson<int>(json['rounds']),
      streak: serializer.fromJson<int>(json['streak']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'dayKey': serializer.toJson<String>(dayKey),
      'workSeconds': serializer.toJson<int>(workSeconds),
      'rounds': serializer.toJson<int>(rounds),
      'streak': serializer.toJson<int>(streak),
    };
  }

  GuidedStateRow copyWith({
    String? dayKey,
    int? workSeconds,
    int? rounds,
    int? streak,
  }) => GuidedStateRow(
    dayKey: dayKey ?? this.dayKey,
    workSeconds: workSeconds ?? this.workSeconds,
    rounds: rounds ?? this.rounds,
    streak: streak ?? this.streak,
  );
  GuidedStateRow copyWithCompanion(GuidedStatesCompanion data) {
    return GuidedStateRow(
      dayKey: data.dayKey.present ? data.dayKey.value : this.dayKey,
      workSeconds: data.workSeconds.present
          ? data.workSeconds.value
          : this.workSeconds,
      rounds: data.rounds.present ? data.rounds.value : this.rounds,
      streak: data.streak.present ? data.streak.value : this.streak,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GuidedStateRow(')
          ..write('dayKey: $dayKey, ')
          ..write('workSeconds: $workSeconds, ')
          ..write('rounds: $rounds, ')
          ..write('streak: $streak')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(dayKey, workSeconds, rounds, streak);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GuidedStateRow &&
          other.dayKey == this.dayKey &&
          other.workSeconds == this.workSeconds &&
          other.rounds == this.rounds &&
          other.streak == this.streak);
}

class GuidedStatesCompanion extends UpdateCompanion<GuidedStateRow> {
  final Value<String> dayKey;
  final Value<int> workSeconds;
  final Value<int> rounds;
  final Value<int> streak;
  final Value<int> rowid;
  const GuidedStatesCompanion({
    this.dayKey = const Value.absent(),
    this.workSeconds = const Value.absent(),
    this.rounds = const Value.absent(),
    this.streak = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GuidedStatesCompanion.insert({
    required String dayKey,
    required int workSeconds,
    required int rounds,
    this.streak = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : dayKey = Value(dayKey),
       workSeconds = Value(workSeconds),
       rounds = Value(rounds);
  static Insertable<GuidedStateRow> custom({
    Expression<String>? dayKey,
    Expression<int>? workSeconds,
    Expression<int>? rounds,
    Expression<int>? streak,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (dayKey != null) 'day_key': dayKey,
      if (workSeconds != null) 'work_seconds': workSeconds,
      if (rounds != null) 'rounds': rounds,
      if (streak != null) 'streak': streak,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GuidedStatesCompanion copyWith({
    Value<String>? dayKey,
    Value<int>? workSeconds,
    Value<int>? rounds,
    Value<int>? streak,
    Value<int>? rowid,
  }) {
    return GuidedStatesCompanion(
      dayKey: dayKey ?? this.dayKey,
      workSeconds: workSeconds ?? this.workSeconds,
      rounds: rounds ?? this.rounds,
      streak: streak ?? this.streak,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (dayKey.present) {
      map['day_key'] = Variable<String>(dayKey.value);
    }
    if (workSeconds.present) {
      map['work_seconds'] = Variable<int>(workSeconds.value);
    }
    if (rounds.present) {
      map['rounds'] = Variable<int>(rounds.value);
    }
    if (streak.present) {
      map['streak'] = Variable<int>(streak.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GuidedStatesCompanion(')
          ..write('dayKey: $dayKey, ')
          ..write('workSeconds: $workSeconds, ')
          ..write('rounds: $rounds, ')
          ..write('streak: $streak, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LeagueStatesTable extends LeagueStates
    with TableInfo<$LeagueStatesTable, LeagueStateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LeagueStatesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _divisionMeta = const VerificationMeta(
    'division',
  );
  @override
  late final GeneratedColumn<String> division = GeneratedColumn<String>(
    'division',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('bronze'),
  );
  static const VerificationMeta _weekIdMeta = const VerificationMeta('weekId');
  @override
  late final GeneratedColumn<int> weekId = GeneratedColumn<int>(
    'week_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _weeklyXpMeta = const VerificationMeta(
    'weeklyXp',
  );
  @override
  late final GeneratedColumn<int> weeklyXp = GeneratedColumn<int>(
    'weekly_xp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _streakCurrentMeta = const VerificationMeta(
    'streakCurrent',
  );
  @override
  late final GeneratedColumn<int> streakCurrent = GeneratedColumn<int>(
    'streak_current',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _streakRecordMeta = const VerificationMeta(
    'streakRecord',
  );
  @override
  late final GeneratedColumn<int> streakRecord = GeneratedColumn<int>(
    'streak_record',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastActiveDayMeta = const VerificationMeta(
    'lastActiveDay',
  );
  @override
  late final GeneratedColumn<int> lastActiveDay = GeneratedColumn<int>(
    'last_active_day',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalWorkoutsMeta = const VerificationMeta(
    'totalWorkouts',
  );
  @override
  late final GeneratedColumn<int> totalWorkouts = GeneratedColumn<int>(
    'total_workouts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalPrsMeta = const VerificationMeta(
    'totalPrs',
  );
  @override
  late final GeneratedColumn<int> totalPrs = GeneratedColumn<int>(
    'total_prs',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    division,
    weekId,
    weeklyXp,
    streakCurrent,
    streakRecord,
    lastActiveDay,
    totalWorkouts,
    totalPrs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'league_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<LeagueStateRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('division')) {
      context.handle(
        _divisionMeta,
        division.isAcceptableOrUnknown(data['division']!, _divisionMeta),
      );
    }
    if (data.containsKey('week_id')) {
      context.handle(
        _weekIdMeta,
        weekId.isAcceptableOrUnknown(data['week_id']!, _weekIdMeta),
      );
    }
    if (data.containsKey('weekly_xp')) {
      context.handle(
        _weeklyXpMeta,
        weeklyXp.isAcceptableOrUnknown(data['weekly_xp']!, _weeklyXpMeta),
      );
    }
    if (data.containsKey('streak_current')) {
      context.handle(
        _streakCurrentMeta,
        streakCurrent.isAcceptableOrUnknown(
          data['streak_current']!,
          _streakCurrentMeta,
        ),
      );
    }
    if (data.containsKey('streak_record')) {
      context.handle(
        _streakRecordMeta,
        streakRecord.isAcceptableOrUnknown(
          data['streak_record']!,
          _streakRecordMeta,
        ),
      );
    }
    if (data.containsKey('last_active_day')) {
      context.handle(
        _lastActiveDayMeta,
        lastActiveDay.isAcceptableOrUnknown(
          data['last_active_day']!,
          _lastActiveDayMeta,
        ),
      );
    }
    if (data.containsKey('total_workouts')) {
      context.handle(
        _totalWorkoutsMeta,
        totalWorkouts.isAcceptableOrUnknown(
          data['total_workouts']!,
          _totalWorkoutsMeta,
        ),
      );
    }
    if (data.containsKey('total_prs')) {
      context.handle(
        _totalPrsMeta,
        totalPrs.isAcceptableOrUnknown(data['total_prs']!, _totalPrsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LeagueStateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LeagueStateRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      division: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}division'],
      )!,
      weekId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}week_id'],
      )!,
      weeklyXp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weekly_xp'],
      )!,
      streakCurrent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}streak_current'],
      )!,
      streakRecord: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}streak_record'],
      )!,
      lastActiveDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_active_day'],
      ),
      totalWorkouts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_workouts'],
      )!,
      totalPrs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_prs'],
      )!,
    );
  }

  @override
  $LeagueStatesTable createAlias(String alias) {
    return $LeagueStatesTable(attachedDatabase, alias);
  }
}

class LeagueStateRow extends DataClass implements Insertable<LeagueStateRow> {
  final int id;
  final String division;
  final int weekId;
  final int weeklyXp;
  final int streakCurrent;
  final int streakRecord;
  final int? lastActiveDay;
  final int totalWorkouts;
  final int totalPrs;
  const LeagueStateRow({
    required this.id,
    required this.division,
    required this.weekId,
    required this.weeklyXp,
    required this.streakCurrent,
    required this.streakRecord,
    this.lastActiveDay,
    required this.totalWorkouts,
    required this.totalPrs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['division'] = Variable<String>(division);
    map['week_id'] = Variable<int>(weekId);
    map['weekly_xp'] = Variable<int>(weeklyXp);
    map['streak_current'] = Variable<int>(streakCurrent);
    map['streak_record'] = Variable<int>(streakRecord);
    if (!nullToAbsent || lastActiveDay != null) {
      map['last_active_day'] = Variable<int>(lastActiveDay);
    }
    map['total_workouts'] = Variable<int>(totalWorkouts);
    map['total_prs'] = Variable<int>(totalPrs);
    return map;
  }

  LeagueStatesCompanion toCompanion(bool nullToAbsent) {
    return LeagueStatesCompanion(
      id: Value(id),
      division: Value(division),
      weekId: Value(weekId),
      weeklyXp: Value(weeklyXp),
      streakCurrent: Value(streakCurrent),
      streakRecord: Value(streakRecord),
      lastActiveDay: lastActiveDay == null && nullToAbsent
          ? const Value.absent()
          : Value(lastActiveDay),
      totalWorkouts: Value(totalWorkouts),
      totalPrs: Value(totalPrs),
    );
  }

  factory LeagueStateRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LeagueStateRow(
      id: serializer.fromJson<int>(json['id']),
      division: serializer.fromJson<String>(json['division']),
      weekId: serializer.fromJson<int>(json['weekId']),
      weeklyXp: serializer.fromJson<int>(json['weeklyXp']),
      streakCurrent: serializer.fromJson<int>(json['streakCurrent']),
      streakRecord: serializer.fromJson<int>(json['streakRecord']),
      lastActiveDay: serializer.fromJson<int?>(json['lastActiveDay']),
      totalWorkouts: serializer.fromJson<int>(json['totalWorkouts']),
      totalPrs: serializer.fromJson<int>(json['totalPrs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'division': serializer.toJson<String>(division),
      'weekId': serializer.toJson<int>(weekId),
      'weeklyXp': serializer.toJson<int>(weeklyXp),
      'streakCurrent': serializer.toJson<int>(streakCurrent),
      'streakRecord': serializer.toJson<int>(streakRecord),
      'lastActiveDay': serializer.toJson<int?>(lastActiveDay),
      'totalWorkouts': serializer.toJson<int>(totalWorkouts),
      'totalPrs': serializer.toJson<int>(totalPrs),
    };
  }

  LeagueStateRow copyWith({
    int? id,
    String? division,
    int? weekId,
    int? weeklyXp,
    int? streakCurrent,
    int? streakRecord,
    Value<int?> lastActiveDay = const Value.absent(),
    int? totalWorkouts,
    int? totalPrs,
  }) => LeagueStateRow(
    id: id ?? this.id,
    division: division ?? this.division,
    weekId: weekId ?? this.weekId,
    weeklyXp: weeklyXp ?? this.weeklyXp,
    streakCurrent: streakCurrent ?? this.streakCurrent,
    streakRecord: streakRecord ?? this.streakRecord,
    lastActiveDay: lastActiveDay.present
        ? lastActiveDay.value
        : this.lastActiveDay,
    totalWorkouts: totalWorkouts ?? this.totalWorkouts,
    totalPrs: totalPrs ?? this.totalPrs,
  );
  LeagueStateRow copyWithCompanion(LeagueStatesCompanion data) {
    return LeagueStateRow(
      id: data.id.present ? data.id.value : this.id,
      division: data.division.present ? data.division.value : this.division,
      weekId: data.weekId.present ? data.weekId.value : this.weekId,
      weeklyXp: data.weeklyXp.present ? data.weeklyXp.value : this.weeklyXp,
      streakCurrent: data.streakCurrent.present
          ? data.streakCurrent.value
          : this.streakCurrent,
      streakRecord: data.streakRecord.present
          ? data.streakRecord.value
          : this.streakRecord,
      lastActiveDay: data.lastActiveDay.present
          ? data.lastActiveDay.value
          : this.lastActiveDay,
      totalWorkouts: data.totalWorkouts.present
          ? data.totalWorkouts.value
          : this.totalWorkouts,
      totalPrs: data.totalPrs.present ? data.totalPrs.value : this.totalPrs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LeagueStateRow(')
          ..write('id: $id, ')
          ..write('division: $division, ')
          ..write('weekId: $weekId, ')
          ..write('weeklyXp: $weeklyXp, ')
          ..write('streakCurrent: $streakCurrent, ')
          ..write('streakRecord: $streakRecord, ')
          ..write('lastActiveDay: $lastActiveDay, ')
          ..write('totalWorkouts: $totalWorkouts, ')
          ..write('totalPrs: $totalPrs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    division,
    weekId,
    weeklyXp,
    streakCurrent,
    streakRecord,
    lastActiveDay,
    totalWorkouts,
    totalPrs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LeagueStateRow &&
          other.id == this.id &&
          other.division == this.division &&
          other.weekId == this.weekId &&
          other.weeklyXp == this.weeklyXp &&
          other.streakCurrent == this.streakCurrent &&
          other.streakRecord == this.streakRecord &&
          other.lastActiveDay == this.lastActiveDay &&
          other.totalWorkouts == this.totalWorkouts &&
          other.totalPrs == this.totalPrs);
}

class LeagueStatesCompanion extends UpdateCompanion<LeagueStateRow> {
  final Value<int> id;
  final Value<String> division;
  final Value<int> weekId;
  final Value<int> weeklyXp;
  final Value<int> streakCurrent;
  final Value<int> streakRecord;
  final Value<int?> lastActiveDay;
  final Value<int> totalWorkouts;
  final Value<int> totalPrs;
  const LeagueStatesCompanion({
    this.id = const Value.absent(),
    this.division = const Value.absent(),
    this.weekId = const Value.absent(),
    this.weeklyXp = const Value.absent(),
    this.streakCurrent = const Value.absent(),
    this.streakRecord = const Value.absent(),
    this.lastActiveDay = const Value.absent(),
    this.totalWorkouts = const Value.absent(),
    this.totalPrs = const Value.absent(),
  });
  LeagueStatesCompanion.insert({
    this.id = const Value.absent(),
    this.division = const Value.absent(),
    this.weekId = const Value.absent(),
    this.weeklyXp = const Value.absent(),
    this.streakCurrent = const Value.absent(),
    this.streakRecord = const Value.absent(),
    this.lastActiveDay = const Value.absent(),
    this.totalWorkouts = const Value.absent(),
    this.totalPrs = const Value.absent(),
  });
  static Insertable<LeagueStateRow> custom({
    Expression<int>? id,
    Expression<String>? division,
    Expression<int>? weekId,
    Expression<int>? weeklyXp,
    Expression<int>? streakCurrent,
    Expression<int>? streakRecord,
    Expression<int>? lastActiveDay,
    Expression<int>? totalWorkouts,
    Expression<int>? totalPrs,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (division != null) 'division': division,
      if (weekId != null) 'week_id': weekId,
      if (weeklyXp != null) 'weekly_xp': weeklyXp,
      if (streakCurrent != null) 'streak_current': streakCurrent,
      if (streakRecord != null) 'streak_record': streakRecord,
      if (lastActiveDay != null) 'last_active_day': lastActiveDay,
      if (totalWorkouts != null) 'total_workouts': totalWorkouts,
      if (totalPrs != null) 'total_prs': totalPrs,
    });
  }

  LeagueStatesCompanion copyWith({
    Value<int>? id,
    Value<String>? division,
    Value<int>? weekId,
    Value<int>? weeklyXp,
    Value<int>? streakCurrent,
    Value<int>? streakRecord,
    Value<int?>? lastActiveDay,
    Value<int>? totalWorkouts,
    Value<int>? totalPrs,
  }) {
    return LeagueStatesCompanion(
      id: id ?? this.id,
      division: division ?? this.division,
      weekId: weekId ?? this.weekId,
      weeklyXp: weeklyXp ?? this.weeklyXp,
      streakCurrent: streakCurrent ?? this.streakCurrent,
      streakRecord: streakRecord ?? this.streakRecord,
      lastActiveDay: lastActiveDay ?? this.lastActiveDay,
      totalWorkouts: totalWorkouts ?? this.totalWorkouts,
      totalPrs: totalPrs ?? this.totalPrs,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (division.present) {
      map['division'] = Variable<String>(division.value);
    }
    if (weekId.present) {
      map['week_id'] = Variable<int>(weekId.value);
    }
    if (weeklyXp.present) {
      map['weekly_xp'] = Variable<int>(weeklyXp.value);
    }
    if (streakCurrent.present) {
      map['streak_current'] = Variable<int>(streakCurrent.value);
    }
    if (streakRecord.present) {
      map['streak_record'] = Variable<int>(streakRecord.value);
    }
    if (lastActiveDay.present) {
      map['last_active_day'] = Variable<int>(lastActiveDay.value);
    }
    if (totalWorkouts.present) {
      map['total_workouts'] = Variable<int>(totalWorkouts.value);
    }
    if (totalPrs.present) {
      map['total_prs'] = Variable<int>(totalPrs.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LeagueStatesCompanion(')
          ..write('id: $id, ')
          ..write('division: $division, ')
          ..write('weekId: $weekId, ')
          ..write('weeklyXp: $weeklyXp, ')
          ..write('streakCurrent: $streakCurrent, ')
          ..write('streakRecord: $streakRecord, ')
          ..write('lastActiveDay: $lastActiveDay, ')
          ..write('totalWorkouts: $totalWorkouts, ')
          ..write('totalPrs: $totalPrs')
          ..write(')'))
        .toString();
  }
}

class $XpEntriesTable extends XpEntries
    with TableInfo<$XpEntriesTable, XpEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $XpEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _weekIdMeta = const VerificationMeta('weekId');
  @override
  late final GeneratedColumn<int> weekId = GeneratedColumn<int>(
    'week_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, weekId, source, amount, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'xp_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<XpEntryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('week_id')) {
      context.handle(
        _weekIdMeta,
        weekId.isAcceptableOrUnknown(data['week_id']!, _weekIdMeta),
      );
    } else if (isInserting) {
      context.missing(_weekIdMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  XpEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return XpEntryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      weekId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}week_id'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $XpEntriesTable createAlias(String alias) {
    return $XpEntriesTable(attachedDatabase, alias);
  }
}

class XpEntryRow extends DataClass implements Insertable<XpEntryRow> {
  final int id;
  final int weekId;
  final String source;
  final int amount;
  final DateTime createdAt;
  const XpEntryRow({
    required this.id,
    required this.weekId,
    required this.source,
    required this.amount,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['week_id'] = Variable<int>(weekId);
    map['source'] = Variable<String>(source);
    map['amount'] = Variable<int>(amount);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  XpEntriesCompanion toCompanion(bool nullToAbsent) {
    return XpEntriesCompanion(
      id: Value(id),
      weekId: Value(weekId),
      source: Value(source),
      amount: Value(amount),
      createdAt: Value(createdAt),
    );
  }

  factory XpEntryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return XpEntryRow(
      id: serializer.fromJson<int>(json['id']),
      weekId: serializer.fromJson<int>(json['weekId']),
      source: serializer.fromJson<String>(json['source']),
      amount: serializer.fromJson<int>(json['amount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'weekId': serializer.toJson<int>(weekId),
      'source': serializer.toJson<String>(source),
      'amount': serializer.toJson<int>(amount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  XpEntryRow copyWith({
    int? id,
    int? weekId,
    String? source,
    int? amount,
    DateTime? createdAt,
  }) => XpEntryRow(
    id: id ?? this.id,
    weekId: weekId ?? this.weekId,
    source: source ?? this.source,
    amount: amount ?? this.amount,
    createdAt: createdAt ?? this.createdAt,
  );
  XpEntryRow copyWithCompanion(XpEntriesCompanion data) {
    return XpEntryRow(
      id: data.id.present ? data.id.value : this.id,
      weekId: data.weekId.present ? data.weekId.value : this.weekId,
      source: data.source.present ? data.source.value : this.source,
      amount: data.amount.present ? data.amount.value : this.amount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('XpEntryRow(')
          ..write('id: $id, ')
          ..write('weekId: $weekId, ')
          ..write('source: $source, ')
          ..write('amount: $amount, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, weekId, source, amount, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is XpEntryRow &&
          other.id == this.id &&
          other.weekId == this.weekId &&
          other.source == this.source &&
          other.amount == this.amount &&
          other.createdAt == this.createdAt);
}

class XpEntriesCompanion extends UpdateCompanion<XpEntryRow> {
  final Value<int> id;
  final Value<int> weekId;
  final Value<String> source;
  final Value<int> amount;
  final Value<DateTime> createdAt;
  const XpEntriesCompanion({
    this.id = const Value.absent(),
    this.weekId = const Value.absent(),
    this.source = const Value.absent(),
    this.amount = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  XpEntriesCompanion.insert({
    this.id = const Value.absent(),
    required int weekId,
    required String source,
    required int amount,
    required DateTime createdAt,
  }) : weekId = Value(weekId),
       source = Value(source),
       amount = Value(amount),
       createdAt = Value(createdAt);
  static Insertable<XpEntryRow> custom({
    Expression<int>? id,
    Expression<int>? weekId,
    Expression<String>? source,
    Expression<int>? amount,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (weekId != null) 'week_id': weekId,
      if (source != null) 'source': source,
      if (amount != null) 'amount': amount,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  XpEntriesCompanion copyWith({
    Value<int>? id,
    Value<int>? weekId,
    Value<String>? source,
    Value<int>? amount,
    Value<DateTime>? createdAt,
  }) {
    return XpEntriesCompanion(
      id: id ?? this.id,
      weekId: weekId ?? this.weekId,
      source: source ?? this.source,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (weekId.present) {
      map['week_id'] = Variable<int>(weekId.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('XpEntriesCompanion(')
          ..write('id: $id, ')
          ..write('weekId: $weekId, ')
          ..write('source: $source, ')
          ..write('amount: $amount, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $AchievementsTable extends Achievements
    with TableInfo<$AchievementsTable, AchievementRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AchievementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unlockedAtMeta = const VerificationMeta(
    'unlockedAt',
  );
  @override
  late final GeneratedColumn<DateTime> unlockedAt = GeneratedColumn<DateTime>(
    'unlocked_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [type, unlockedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'achievements';
  @override
  VerificationContext validateIntegrity(
    Insertable<AchievementRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('unlocked_at')) {
      context.handle(
        _unlockedAtMeta,
        unlockedAt.isAcceptableOrUnknown(data['unlocked_at']!, _unlockedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_unlockedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {type};
  @override
  AchievementRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AchievementRow(
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      unlockedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}unlocked_at'],
      )!,
    );
  }

  @override
  $AchievementsTable createAlias(String alias) {
    return $AchievementsTable(attachedDatabase, alias);
  }
}

class AchievementRow extends DataClass implements Insertable<AchievementRow> {
  final String type;
  final DateTime unlockedAt;
  const AchievementRow({required this.type, required this.unlockedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['type'] = Variable<String>(type);
    map['unlocked_at'] = Variable<DateTime>(unlockedAt);
    return map;
  }

  AchievementsCompanion toCompanion(bool nullToAbsent) {
    return AchievementsCompanion(
      type: Value(type),
      unlockedAt: Value(unlockedAt),
    );
  }

  factory AchievementRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AchievementRow(
      type: serializer.fromJson<String>(json['type']),
      unlockedAt: serializer.fromJson<DateTime>(json['unlockedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'type': serializer.toJson<String>(type),
      'unlockedAt': serializer.toJson<DateTime>(unlockedAt),
    };
  }

  AchievementRow copyWith({String? type, DateTime? unlockedAt}) =>
      AchievementRow(
        type: type ?? this.type,
        unlockedAt: unlockedAt ?? this.unlockedAt,
      );
  AchievementRow copyWithCompanion(AchievementsCompanion data) {
    return AchievementRow(
      type: data.type.present ? data.type.value : this.type,
      unlockedAt: data.unlockedAt.present
          ? data.unlockedAt.value
          : this.unlockedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AchievementRow(')
          ..write('type: $type, ')
          ..write('unlockedAt: $unlockedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(type, unlockedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AchievementRow &&
          other.type == this.type &&
          other.unlockedAt == this.unlockedAt);
}

class AchievementsCompanion extends UpdateCompanion<AchievementRow> {
  final Value<String> type;
  final Value<DateTime> unlockedAt;
  final Value<int> rowid;
  const AchievementsCompanion({
    this.type = const Value.absent(),
    this.unlockedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AchievementsCompanion.insert({
    required String type,
    required DateTime unlockedAt,
    this.rowid = const Value.absent(),
  }) : type = Value(type),
       unlockedAt = Value(unlockedAt);
  static Insertable<AchievementRow> custom({
    Expression<String>? type,
    Expression<DateTime>? unlockedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (type != null) 'type': type,
      if (unlockedAt != null) 'unlocked_at': unlockedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AchievementsCompanion copyWith({
    Value<String>? type,
    Value<DateTime>? unlockedAt,
    Value<int>? rowid,
  }) {
    return AchievementsCompanion(
      type: type ?? this.type,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (unlockedAt.present) {
      map['unlocked_at'] = Variable<DateTime>(unlockedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AchievementsCompanion(')
          ..write('type: $type, ')
          ..write('unlockedAt: $unlockedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$FraguaDatabase extends GeneratedDatabase {
  _$FraguaDatabase(QueryExecutor e) : super(e);
  $FraguaDatabaseManager get managers => $FraguaDatabaseManager(this);
  late final $ExercisesTable exercises = $ExercisesTable(this);
  late final $UserProfilesTable userProfiles = $UserProfilesTable(this);
  late final $PlansTable plans = $PlansTable(this);
  late final $ExerciseStatesTable exerciseStates = $ExerciseStatesTable(this);
  late final $GuidedStatesTable guidedStates = $GuidedStatesTable(this);
  late final $LeagueStatesTable leagueStates = $LeagueStatesTable(this);
  late final $XpEntriesTable xpEntries = $XpEntriesTable(this);
  late final $AchievementsTable achievements = $AchievementsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    exercises,
    userProfiles,
    plans,
    exerciseStates,
    guidedStates,
    leagueStates,
    xpEntries,
    achievements,
  ];
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
typedef $$PlansTableCreateCompanionBuilder =
    PlansCompanion Function({Value<int> id, required String data});
typedef $$PlansTableUpdateCompanionBuilder =
    PlansCompanion Function({Value<int> id, Value<String> data});

class $$PlansTableFilterComposer
    extends Composer<_$FraguaDatabase, $PlansTable> {
  $$PlansTableFilterComposer({
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

  ColumnFilters<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlansTableOrderingComposer
    extends Composer<_$FraguaDatabase, $PlansTable> {
  $$PlansTableOrderingComposer({
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

  ColumnOrderings<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlansTableAnnotationComposer
    extends Composer<_$FraguaDatabase, $PlansTable> {
  $$PlansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);
}

class $$PlansTableTableManager
    extends
        RootTableManager<
          _$FraguaDatabase,
          $PlansTable,
          PlanRow,
          $$PlansTableFilterComposer,
          $$PlansTableOrderingComposer,
          $$PlansTableAnnotationComposer,
          $$PlansTableCreateCompanionBuilder,
          $$PlansTableUpdateCompanionBuilder,
          (PlanRow, BaseReferences<_$FraguaDatabase, $PlansTable, PlanRow>),
          PlanRow,
          PrefetchHooks Function()
        > {
  $$PlansTableTableManager(_$FraguaDatabase db, $PlansTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> data = const Value.absent(),
              }) => PlansCompanion(id: id, data: data),
          createCompanionCallback:
              ({Value<int> id = const Value.absent(), required String data}) =>
                  PlansCompanion.insert(id: id, data: data),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlansTableProcessedTableManager =
    ProcessedTableManager<
      _$FraguaDatabase,
      $PlansTable,
      PlanRow,
      $$PlansTableFilterComposer,
      $$PlansTableOrderingComposer,
      $$PlansTableAnnotationComposer,
      $$PlansTableCreateCompanionBuilder,
      $$PlansTableUpdateCompanionBuilder,
      (PlanRow, BaseReferences<_$FraguaDatabase, $PlansTable, PlanRow>),
      PlanRow,
      PrefetchHooks Function()
    >;
typedef $$ExerciseStatesTableCreateCompanionBuilder =
    ExerciseStatesCompanion Function({
      required String exerciseId,
      required double currentWeight,
      Value<int> stallCount,
      Value<int> rowid,
    });
typedef $$ExerciseStatesTableUpdateCompanionBuilder =
    ExerciseStatesCompanion Function({
      Value<String> exerciseId,
      Value<double> currentWeight,
      Value<int> stallCount,
      Value<int> rowid,
    });

class $$ExerciseStatesTableFilterComposer
    extends Composer<_$FraguaDatabase, $ExerciseStatesTable> {
  $$ExerciseStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get currentWeight => $composableBuilder(
    column: $table.currentWeight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stallCount => $composableBuilder(
    column: $table.stallCount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExerciseStatesTableOrderingComposer
    extends Composer<_$FraguaDatabase, $ExerciseStatesTable> {
  $$ExerciseStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get currentWeight => $composableBuilder(
    column: $table.currentWeight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stallCount => $composableBuilder(
    column: $table.stallCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExerciseStatesTableAnnotationComposer
    extends Composer<_$FraguaDatabase, $ExerciseStatesTable> {
  $$ExerciseStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get currentWeight => $composableBuilder(
    column: $table.currentWeight,
    builder: (column) => column,
  );

  GeneratedColumn<int> get stallCount => $composableBuilder(
    column: $table.stallCount,
    builder: (column) => column,
  );
}

class $$ExerciseStatesTableTableManager
    extends
        RootTableManager<
          _$FraguaDatabase,
          $ExerciseStatesTable,
          ExerciseStateRow,
          $$ExerciseStatesTableFilterComposer,
          $$ExerciseStatesTableOrderingComposer,
          $$ExerciseStatesTableAnnotationComposer,
          $$ExerciseStatesTableCreateCompanionBuilder,
          $$ExerciseStatesTableUpdateCompanionBuilder,
          (
            ExerciseStateRow,
            BaseReferences<
              _$FraguaDatabase,
              $ExerciseStatesTable,
              ExerciseStateRow
            >,
          ),
          ExerciseStateRow,
          PrefetchHooks Function()
        > {
  $$ExerciseStatesTableTableManager(
    _$FraguaDatabase db,
    $ExerciseStatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExerciseStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExerciseStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExerciseStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> exerciseId = const Value.absent(),
                Value<double> currentWeight = const Value.absent(),
                Value<int> stallCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExerciseStatesCompanion(
                exerciseId: exerciseId,
                currentWeight: currentWeight,
                stallCount: stallCount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String exerciseId,
                required double currentWeight,
                Value<int> stallCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExerciseStatesCompanion.insert(
                exerciseId: exerciseId,
                currentWeight: currentWeight,
                stallCount: stallCount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExerciseStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$FraguaDatabase,
      $ExerciseStatesTable,
      ExerciseStateRow,
      $$ExerciseStatesTableFilterComposer,
      $$ExerciseStatesTableOrderingComposer,
      $$ExerciseStatesTableAnnotationComposer,
      $$ExerciseStatesTableCreateCompanionBuilder,
      $$ExerciseStatesTableUpdateCompanionBuilder,
      (
        ExerciseStateRow,
        BaseReferences<
          _$FraguaDatabase,
          $ExerciseStatesTable,
          ExerciseStateRow
        >,
      ),
      ExerciseStateRow,
      PrefetchHooks Function()
    >;
typedef $$GuidedStatesTableCreateCompanionBuilder =
    GuidedStatesCompanion Function({
      required String dayKey,
      required int workSeconds,
      required int rounds,
      Value<int> streak,
      Value<int> rowid,
    });
typedef $$GuidedStatesTableUpdateCompanionBuilder =
    GuidedStatesCompanion Function({
      Value<String> dayKey,
      Value<int> workSeconds,
      Value<int> rounds,
      Value<int> streak,
      Value<int> rowid,
    });

class $$GuidedStatesTableFilterComposer
    extends Composer<_$FraguaDatabase, $GuidedStatesTable> {
  $$GuidedStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get dayKey => $composableBuilder(
    column: $table.dayKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get workSeconds => $composableBuilder(
    column: $table.workSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rounds => $composableBuilder(
    column: $table.rounds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get streak => $composableBuilder(
    column: $table.streak,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GuidedStatesTableOrderingComposer
    extends Composer<_$FraguaDatabase, $GuidedStatesTable> {
  $$GuidedStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get dayKey => $composableBuilder(
    column: $table.dayKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get workSeconds => $composableBuilder(
    column: $table.workSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rounds => $composableBuilder(
    column: $table.rounds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get streak => $composableBuilder(
    column: $table.streak,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GuidedStatesTableAnnotationComposer
    extends Composer<_$FraguaDatabase, $GuidedStatesTable> {
  $$GuidedStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get dayKey =>
      $composableBuilder(column: $table.dayKey, builder: (column) => column);

  GeneratedColumn<int> get workSeconds => $composableBuilder(
    column: $table.workSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rounds =>
      $composableBuilder(column: $table.rounds, builder: (column) => column);

  GeneratedColumn<int> get streak =>
      $composableBuilder(column: $table.streak, builder: (column) => column);
}

class $$GuidedStatesTableTableManager
    extends
        RootTableManager<
          _$FraguaDatabase,
          $GuidedStatesTable,
          GuidedStateRow,
          $$GuidedStatesTableFilterComposer,
          $$GuidedStatesTableOrderingComposer,
          $$GuidedStatesTableAnnotationComposer,
          $$GuidedStatesTableCreateCompanionBuilder,
          $$GuidedStatesTableUpdateCompanionBuilder,
          (
            GuidedStateRow,
            BaseReferences<
              _$FraguaDatabase,
              $GuidedStatesTable,
              GuidedStateRow
            >,
          ),
          GuidedStateRow,
          PrefetchHooks Function()
        > {
  $$GuidedStatesTableTableManager(_$FraguaDatabase db, $GuidedStatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GuidedStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GuidedStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GuidedStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> dayKey = const Value.absent(),
                Value<int> workSeconds = const Value.absent(),
                Value<int> rounds = const Value.absent(),
                Value<int> streak = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GuidedStatesCompanion(
                dayKey: dayKey,
                workSeconds: workSeconds,
                rounds: rounds,
                streak: streak,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String dayKey,
                required int workSeconds,
                required int rounds,
                Value<int> streak = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GuidedStatesCompanion.insert(
                dayKey: dayKey,
                workSeconds: workSeconds,
                rounds: rounds,
                streak: streak,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GuidedStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$FraguaDatabase,
      $GuidedStatesTable,
      GuidedStateRow,
      $$GuidedStatesTableFilterComposer,
      $$GuidedStatesTableOrderingComposer,
      $$GuidedStatesTableAnnotationComposer,
      $$GuidedStatesTableCreateCompanionBuilder,
      $$GuidedStatesTableUpdateCompanionBuilder,
      (
        GuidedStateRow,
        BaseReferences<_$FraguaDatabase, $GuidedStatesTable, GuidedStateRow>,
      ),
      GuidedStateRow,
      PrefetchHooks Function()
    >;
typedef $$LeagueStatesTableCreateCompanionBuilder =
    LeagueStatesCompanion Function({
      Value<int> id,
      Value<String> division,
      Value<int> weekId,
      Value<int> weeklyXp,
      Value<int> streakCurrent,
      Value<int> streakRecord,
      Value<int?> lastActiveDay,
      Value<int> totalWorkouts,
      Value<int> totalPrs,
    });
typedef $$LeagueStatesTableUpdateCompanionBuilder =
    LeagueStatesCompanion Function({
      Value<int> id,
      Value<String> division,
      Value<int> weekId,
      Value<int> weeklyXp,
      Value<int> streakCurrent,
      Value<int> streakRecord,
      Value<int?> lastActiveDay,
      Value<int> totalWorkouts,
      Value<int> totalPrs,
    });

class $$LeagueStatesTableFilterComposer
    extends Composer<_$FraguaDatabase, $LeagueStatesTable> {
  $$LeagueStatesTableFilterComposer({
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

  ColumnFilters<String> get division => $composableBuilder(
    column: $table.division,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weekId => $composableBuilder(
    column: $table.weekId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weeklyXp => $composableBuilder(
    column: $table.weeklyXp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get streakCurrent => $composableBuilder(
    column: $table.streakCurrent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get streakRecord => $composableBuilder(
    column: $table.streakRecord,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastActiveDay => $composableBuilder(
    column: $table.lastActiveDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalWorkouts => $composableBuilder(
    column: $table.totalWorkouts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalPrs => $composableBuilder(
    column: $table.totalPrs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LeagueStatesTableOrderingComposer
    extends Composer<_$FraguaDatabase, $LeagueStatesTable> {
  $$LeagueStatesTableOrderingComposer({
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

  ColumnOrderings<String> get division => $composableBuilder(
    column: $table.division,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weekId => $composableBuilder(
    column: $table.weekId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weeklyXp => $composableBuilder(
    column: $table.weeklyXp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get streakCurrent => $composableBuilder(
    column: $table.streakCurrent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get streakRecord => $composableBuilder(
    column: $table.streakRecord,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastActiveDay => $composableBuilder(
    column: $table.lastActiveDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalWorkouts => $composableBuilder(
    column: $table.totalWorkouts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalPrs => $composableBuilder(
    column: $table.totalPrs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LeagueStatesTableAnnotationComposer
    extends Composer<_$FraguaDatabase, $LeagueStatesTable> {
  $$LeagueStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get division =>
      $composableBuilder(column: $table.division, builder: (column) => column);

  GeneratedColumn<int> get weekId =>
      $composableBuilder(column: $table.weekId, builder: (column) => column);

  GeneratedColumn<int> get weeklyXp =>
      $composableBuilder(column: $table.weeklyXp, builder: (column) => column);

  GeneratedColumn<int> get streakCurrent => $composableBuilder(
    column: $table.streakCurrent,
    builder: (column) => column,
  );

  GeneratedColumn<int> get streakRecord => $composableBuilder(
    column: $table.streakRecord,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastActiveDay => $composableBuilder(
    column: $table.lastActiveDay,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalWorkouts => $composableBuilder(
    column: $table.totalWorkouts,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalPrs =>
      $composableBuilder(column: $table.totalPrs, builder: (column) => column);
}

class $$LeagueStatesTableTableManager
    extends
        RootTableManager<
          _$FraguaDatabase,
          $LeagueStatesTable,
          LeagueStateRow,
          $$LeagueStatesTableFilterComposer,
          $$LeagueStatesTableOrderingComposer,
          $$LeagueStatesTableAnnotationComposer,
          $$LeagueStatesTableCreateCompanionBuilder,
          $$LeagueStatesTableUpdateCompanionBuilder,
          (
            LeagueStateRow,
            BaseReferences<
              _$FraguaDatabase,
              $LeagueStatesTable,
              LeagueStateRow
            >,
          ),
          LeagueStateRow,
          PrefetchHooks Function()
        > {
  $$LeagueStatesTableTableManager(_$FraguaDatabase db, $LeagueStatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LeagueStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LeagueStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LeagueStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> division = const Value.absent(),
                Value<int> weekId = const Value.absent(),
                Value<int> weeklyXp = const Value.absent(),
                Value<int> streakCurrent = const Value.absent(),
                Value<int> streakRecord = const Value.absent(),
                Value<int?> lastActiveDay = const Value.absent(),
                Value<int> totalWorkouts = const Value.absent(),
                Value<int> totalPrs = const Value.absent(),
              }) => LeagueStatesCompanion(
                id: id,
                division: division,
                weekId: weekId,
                weeklyXp: weeklyXp,
                streakCurrent: streakCurrent,
                streakRecord: streakRecord,
                lastActiveDay: lastActiveDay,
                totalWorkouts: totalWorkouts,
                totalPrs: totalPrs,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> division = const Value.absent(),
                Value<int> weekId = const Value.absent(),
                Value<int> weeklyXp = const Value.absent(),
                Value<int> streakCurrent = const Value.absent(),
                Value<int> streakRecord = const Value.absent(),
                Value<int?> lastActiveDay = const Value.absent(),
                Value<int> totalWorkouts = const Value.absent(),
                Value<int> totalPrs = const Value.absent(),
              }) => LeagueStatesCompanion.insert(
                id: id,
                division: division,
                weekId: weekId,
                weeklyXp: weeklyXp,
                streakCurrent: streakCurrent,
                streakRecord: streakRecord,
                lastActiveDay: lastActiveDay,
                totalWorkouts: totalWorkouts,
                totalPrs: totalPrs,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LeagueStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$FraguaDatabase,
      $LeagueStatesTable,
      LeagueStateRow,
      $$LeagueStatesTableFilterComposer,
      $$LeagueStatesTableOrderingComposer,
      $$LeagueStatesTableAnnotationComposer,
      $$LeagueStatesTableCreateCompanionBuilder,
      $$LeagueStatesTableUpdateCompanionBuilder,
      (
        LeagueStateRow,
        BaseReferences<_$FraguaDatabase, $LeagueStatesTable, LeagueStateRow>,
      ),
      LeagueStateRow,
      PrefetchHooks Function()
    >;
typedef $$XpEntriesTableCreateCompanionBuilder =
    XpEntriesCompanion Function({
      Value<int> id,
      required int weekId,
      required String source,
      required int amount,
      required DateTime createdAt,
    });
typedef $$XpEntriesTableUpdateCompanionBuilder =
    XpEntriesCompanion Function({
      Value<int> id,
      Value<int> weekId,
      Value<String> source,
      Value<int> amount,
      Value<DateTime> createdAt,
    });

class $$XpEntriesTableFilterComposer
    extends Composer<_$FraguaDatabase, $XpEntriesTable> {
  $$XpEntriesTableFilterComposer({
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

  ColumnFilters<int> get weekId => $composableBuilder(
    column: $table.weekId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$XpEntriesTableOrderingComposer
    extends Composer<_$FraguaDatabase, $XpEntriesTable> {
  $$XpEntriesTableOrderingComposer({
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

  ColumnOrderings<int> get weekId => $composableBuilder(
    column: $table.weekId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$XpEntriesTableAnnotationComposer
    extends Composer<_$FraguaDatabase, $XpEntriesTable> {
  $$XpEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get weekId =>
      $composableBuilder(column: $table.weekId, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$XpEntriesTableTableManager
    extends
        RootTableManager<
          _$FraguaDatabase,
          $XpEntriesTable,
          XpEntryRow,
          $$XpEntriesTableFilterComposer,
          $$XpEntriesTableOrderingComposer,
          $$XpEntriesTableAnnotationComposer,
          $$XpEntriesTableCreateCompanionBuilder,
          $$XpEntriesTableUpdateCompanionBuilder,
          (
            XpEntryRow,
            BaseReferences<_$FraguaDatabase, $XpEntriesTable, XpEntryRow>,
          ),
          XpEntryRow,
          PrefetchHooks Function()
        > {
  $$XpEntriesTableTableManager(_$FraguaDatabase db, $XpEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$XpEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$XpEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$XpEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> weekId = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => XpEntriesCompanion(
                id: id,
                weekId: weekId,
                source: source,
                amount: amount,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int weekId,
                required String source,
                required int amount,
                required DateTime createdAt,
              }) => XpEntriesCompanion.insert(
                id: id,
                weekId: weekId,
                source: source,
                amount: amount,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$XpEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$FraguaDatabase,
      $XpEntriesTable,
      XpEntryRow,
      $$XpEntriesTableFilterComposer,
      $$XpEntriesTableOrderingComposer,
      $$XpEntriesTableAnnotationComposer,
      $$XpEntriesTableCreateCompanionBuilder,
      $$XpEntriesTableUpdateCompanionBuilder,
      (
        XpEntryRow,
        BaseReferences<_$FraguaDatabase, $XpEntriesTable, XpEntryRow>,
      ),
      XpEntryRow,
      PrefetchHooks Function()
    >;
typedef $$AchievementsTableCreateCompanionBuilder =
    AchievementsCompanion Function({
      required String type,
      required DateTime unlockedAt,
      Value<int> rowid,
    });
typedef $$AchievementsTableUpdateCompanionBuilder =
    AchievementsCompanion Function({
      Value<String> type,
      Value<DateTime> unlockedAt,
      Value<int> rowid,
    });

class $$AchievementsTableFilterComposer
    extends Composer<_$FraguaDatabase, $AchievementsTable> {
  $$AchievementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AchievementsTableOrderingComposer
    extends Composer<_$FraguaDatabase, $AchievementsTable> {
  $$AchievementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AchievementsTableAnnotationComposer
    extends Composer<_$FraguaDatabase, $AchievementsTable> {
  $$AchievementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => column,
  );
}

class $$AchievementsTableTableManager
    extends
        RootTableManager<
          _$FraguaDatabase,
          $AchievementsTable,
          AchievementRow,
          $$AchievementsTableFilterComposer,
          $$AchievementsTableOrderingComposer,
          $$AchievementsTableAnnotationComposer,
          $$AchievementsTableCreateCompanionBuilder,
          $$AchievementsTableUpdateCompanionBuilder,
          (
            AchievementRow,
            BaseReferences<
              _$FraguaDatabase,
              $AchievementsTable,
              AchievementRow
            >,
          ),
          AchievementRow,
          PrefetchHooks Function()
        > {
  $$AchievementsTableTableManager(_$FraguaDatabase db, $AchievementsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AchievementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AchievementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AchievementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> type = const Value.absent(),
                Value<DateTime> unlockedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AchievementsCompanion(
                type: type,
                unlockedAt: unlockedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String type,
                required DateTime unlockedAt,
                Value<int> rowid = const Value.absent(),
              }) => AchievementsCompanion.insert(
                type: type,
                unlockedAt: unlockedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AchievementsTableProcessedTableManager =
    ProcessedTableManager<
      _$FraguaDatabase,
      $AchievementsTable,
      AchievementRow,
      $$AchievementsTableFilterComposer,
      $$AchievementsTableOrderingComposer,
      $$AchievementsTableAnnotationComposer,
      $$AchievementsTableCreateCompanionBuilder,
      $$AchievementsTableUpdateCompanionBuilder,
      (
        AchievementRow,
        BaseReferences<_$FraguaDatabase, $AchievementsTable, AchievementRow>,
      ),
      AchievementRow,
      PrefetchHooks Function()
    >;

class $FraguaDatabaseManager {
  final _$FraguaDatabase _db;
  $FraguaDatabaseManager(this._db);
  $$ExercisesTableTableManager get exercises =>
      $$ExercisesTableTableManager(_db, _db.exercises);
  $$UserProfilesTableTableManager get userProfiles =>
      $$UserProfilesTableTableManager(_db, _db.userProfiles);
  $$PlansTableTableManager get plans =>
      $$PlansTableTableManager(_db, _db.plans);
  $$ExerciseStatesTableTableManager get exerciseStates =>
      $$ExerciseStatesTableTableManager(_db, _db.exerciseStates);
  $$GuidedStatesTableTableManager get guidedStates =>
      $$GuidedStatesTableTableManager(_db, _db.guidedStates);
  $$LeagueStatesTableTableManager get leagueStates =>
      $$LeagueStatesTableTableManager(_db, _db.leagueStates);
  $$XpEntriesTableTableManager get xpEntries =>
      $$XpEntriesTableTableManager(_db, _db.xpEntries);
  $$AchievementsTableTableManager get achievements =>
      $$AchievementsTableTableManager(_db, _db.achievements);
}
