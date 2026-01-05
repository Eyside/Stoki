// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $IngredientsTable extends Ingredients
    with TableInfo<$IngredientsTable, Ingredient> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IngredientsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _caloriesPer100gMeta =
      const VerificationMeta('caloriesPer100g');
  @override
  late final GeneratedColumn<double> caloriesPer100g = GeneratedColumn<double>(
      'calories_per100g', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _proteinsPer100gMeta =
      const VerificationMeta('proteinsPer100g');
  @override
  late final GeneratedColumn<double> proteinsPer100g = GeneratedColumn<double>(
      'proteins_per100g', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _fatsPer100gMeta =
      const VerificationMeta('fatsPer100g');
  @override
  late final GeneratedColumn<double> fatsPer100g = GeneratedColumn<double>(
      'fats_per100g', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _carbsPer100gMeta =
      const VerificationMeta('carbsPer100g');
  @override
  late final GeneratedColumn<double> carbsPer100g = GeneratedColumn<double>(
      'carbs_per100g', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _fibersPer100gMeta =
      const VerificationMeta('fibersPer100g');
  @override
  late final GeneratedColumn<double> fibersPer100g = GeneratedColumn<double>(
      'fibers_per100g', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _saltPer100gMeta =
      const VerificationMeta('saltPer100g');
  @override
  late final GeneratedColumn<double> saltPer100g = GeneratedColumn<double>(
      'salt_per100g', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _densityGPerMlMeta =
      const VerificationMeta('densityGPerMl');
  @override
  late final GeneratedColumn<double> densityGPerMl = GeneratedColumn<double>(
      'density_g_per_ml', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _avgWeightPerUnitGMeta =
      const VerificationMeta('avgWeightPerUnitG');
  @override
  late final GeneratedColumn<double> avgWeightPerUnitG =
      GeneratedColumn<double>('avg_weight_per_unit_g', aliasedName, true,
          type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _barcodeMeta =
      const VerificationMeta('barcode');
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
      'barcode', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _nutriscoreMeta =
      const VerificationMeta('nutriscore');
  @override
  late final GeneratedColumn<String> nutriscore = GeneratedColumn<String>(
      'nutriscore', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isCustomMeta =
      const VerificationMeta('isCustom');
  @override
  late final GeneratedColumn<bool> isCustom = GeneratedColumn<bool>(
      'is_custom', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_custom" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        caloriesPer100g,
        proteinsPer100g,
        fatsPer100g,
        carbsPer100g,
        fibersPer100g,
        saltPer100g,
        densityGPerMl,
        avgWeightPerUnitG,
        barcode,
        category,
        nutriscore,
        isCustom,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ingredients';
  @override
  VerificationContext validateIntegrity(Insertable<Ingredient> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('calories_per100g')) {
      context.handle(
          _caloriesPer100gMeta,
          caloriesPer100g.isAcceptableOrUnknown(
              data['calories_per100g']!, _caloriesPer100gMeta));
    }
    if (data.containsKey('proteins_per100g')) {
      context.handle(
          _proteinsPer100gMeta,
          proteinsPer100g.isAcceptableOrUnknown(
              data['proteins_per100g']!, _proteinsPer100gMeta));
    }
    if (data.containsKey('fats_per100g')) {
      context.handle(
          _fatsPer100gMeta,
          fatsPer100g.isAcceptableOrUnknown(
              data['fats_per100g']!, _fatsPer100gMeta));
    }
    if (data.containsKey('carbs_per100g')) {
      context.handle(
          _carbsPer100gMeta,
          carbsPer100g.isAcceptableOrUnknown(
              data['carbs_per100g']!, _carbsPer100gMeta));
    }
    if (data.containsKey('fibers_per100g')) {
      context.handle(
          _fibersPer100gMeta,
          fibersPer100g.isAcceptableOrUnknown(
              data['fibers_per100g']!, _fibersPer100gMeta));
    }
    if (data.containsKey('salt_per100g')) {
      context.handle(
          _saltPer100gMeta,
          saltPer100g.isAcceptableOrUnknown(
              data['salt_per100g']!, _saltPer100gMeta));
    }
    if (data.containsKey('density_g_per_ml')) {
      context.handle(
          _densityGPerMlMeta,
          densityGPerMl.isAcceptableOrUnknown(
              data['density_g_per_ml']!, _densityGPerMlMeta));
    }
    if (data.containsKey('avg_weight_per_unit_g')) {
      context.handle(
          _avgWeightPerUnitGMeta,
          avgWeightPerUnitG.isAcceptableOrUnknown(
              data['avg_weight_per_unit_g']!, _avgWeightPerUnitGMeta));
    }
    if (data.containsKey('barcode')) {
      context.handle(_barcodeMeta,
          barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta));
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    }
    if (data.containsKey('nutriscore')) {
      context.handle(
          _nutriscoreMeta,
          nutriscore.isAcceptableOrUnknown(
              data['nutriscore']!, _nutriscoreMeta));
    }
    if (data.containsKey('is_custom')) {
      context.handle(_isCustomMeta,
          isCustom.isAcceptableOrUnknown(data['is_custom']!, _isCustomMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Ingredient map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Ingredient(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      caloriesPer100g: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}calories_per100g'])!,
      proteinsPer100g: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}proteins_per100g'])!,
      fatsPer100g: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}fats_per100g'])!,
      carbsPer100g: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}carbs_per100g'])!,
      fibersPer100g: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}fibers_per100g'])!,
      saltPer100g: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}salt_per100g'])!,
      densityGPerMl: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}density_g_per_ml']),
      avgWeightPerUnitG: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}avg_weight_per_unit_g']),
      barcode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}barcode']),
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category']),
      nutriscore: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nutriscore']),
      isCustom: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_custom'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $IngredientsTable createAlias(String alias) {
    return $IngredientsTable(attachedDatabase, alias);
  }
}

class Ingredient extends DataClass implements Insertable<Ingredient> {
  final int id;
  final String name;
  final double caloriesPer100g;
  final double proteinsPer100g;
  final double fatsPer100g;
  final double carbsPer100g;
  final double fibersPer100g;
  final double saltPer100g;
  final double? densityGPerMl;
  final double? avgWeightPerUnitG;
  final String? barcode;
  final String? category;
  final String? nutriscore;
  final bool isCustom;
  final DateTime createdAt;
  const Ingredient(
      {required this.id,
      required this.name,
      required this.caloriesPer100g,
      required this.proteinsPer100g,
      required this.fatsPer100g,
      required this.carbsPer100g,
      required this.fibersPer100g,
      required this.saltPer100g,
      this.densityGPerMl,
      this.avgWeightPerUnitG,
      this.barcode,
      this.category,
      this.nutriscore,
      required this.isCustom,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['calories_per100g'] = Variable<double>(caloriesPer100g);
    map['proteins_per100g'] = Variable<double>(proteinsPer100g);
    map['fats_per100g'] = Variable<double>(fatsPer100g);
    map['carbs_per100g'] = Variable<double>(carbsPer100g);
    map['fibers_per100g'] = Variable<double>(fibersPer100g);
    map['salt_per100g'] = Variable<double>(saltPer100g);
    if (!nullToAbsent || densityGPerMl != null) {
      map['density_g_per_ml'] = Variable<double>(densityGPerMl);
    }
    if (!nullToAbsent || avgWeightPerUnitG != null) {
      map['avg_weight_per_unit_g'] = Variable<double>(avgWeightPerUnitG);
    }
    if (!nullToAbsent || barcode != null) {
      map['barcode'] = Variable<String>(barcode);
    }
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    if (!nullToAbsent || nutriscore != null) {
      map['nutriscore'] = Variable<String>(nutriscore);
    }
    map['is_custom'] = Variable<bool>(isCustom);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  IngredientsCompanion toCompanion(bool nullToAbsent) {
    return IngredientsCompanion(
      id: Value(id),
      name: Value(name),
      caloriesPer100g: Value(caloriesPer100g),
      proteinsPer100g: Value(proteinsPer100g),
      fatsPer100g: Value(fatsPer100g),
      carbsPer100g: Value(carbsPer100g),
      fibersPer100g: Value(fibersPer100g),
      saltPer100g: Value(saltPer100g),
      densityGPerMl: densityGPerMl == null && nullToAbsent
          ? const Value.absent()
          : Value(densityGPerMl),
      avgWeightPerUnitG: avgWeightPerUnitG == null && nullToAbsent
          ? const Value.absent()
          : Value(avgWeightPerUnitG),
      barcode: barcode == null && nullToAbsent
          ? const Value.absent()
          : Value(barcode),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      nutriscore: nutriscore == null && nullToAbsent
          ? const Value.absent()
          : Value(nutriscore),
      isCustom: Value(isCustom),
      createdAt: Value(createdAt),
    );
  }

  factory Ingredient.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Ingredient(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      caloriesPer100g: serializer.fromJson<double>(json['caloriesPer100g']),
      proteinsPer100g: serializer.fromJson<double>(json['proteinsPer100g']),
      fatsPer100g: serializer.fromJson<double>(json['fatsPer100g']),
      carbsPer100g: serializer.fromJson<double>(json['carbsPer100g']),
      fibersPer100g: serializer.fromJson<double>(json['fibersPer100g']),
      saltPer100g: serializer.fromJson<double>(json['saltPer100g']),
      densityGPerMl: serializer.fromJson<double?>(json['densityGPerMl']),
      avgWeightPerUnitG:
          serializer.fromJson<double?>(json['avgWeightPerUnitG']),
      barcode: serializer.fromJson<String?>(json['barcode']),
      category: serializer.fromJson<String?>(json['category']),
      nutriscore: serializer.fromJson<String?>(json['nutriscore']),
      isCustom: serializer.fromJson<bool>(json['isCustom']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'caloriesPer100g': serializer.toJson<double>(caloriesPer100g),
      'proteinsPer100g': serializer.toJson<double>(proteinsPer100g),
      'fatsPer100g': serializer.toJson<double>(fatsPer100g),
      'carbsPer100g': serializer.toJson<double>(carbsPer100g),
      'fibersPer100g': serializer.toJson<double>(fibersPer100g),
      'saltPer100g': serializer.toJson<double>(saltPer100g),
      'densityGPerMl': serializer.toJson<double?>(densityGPerMl),
      'avgWeightPerUnitG': serializer.toJson<double?>(avgWeightPerUnitG),
      'barcode': serializer.toJson<String?>(barcode),
      'category': serializer.toJson<String?>(category),
      'nutriscore': serializer.toJson<String?>(nutriscore),
      'isCustom': serializer.toJson<bool>(isCustom),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Ingredient copyWith(
          {int? id,
          String? name,
          double? caloriesPer100g,
          double? proteinsPer100g,
          double? fatsPer100g,
          double? carbsPer100g,
          double? fibersPer100g,
          double? saltPer100g,
          Value<double?> densityGPerMl = const Value.absent(),
          Value<double?> avgWeightPerUnitG = const Value.absent(),
          Value<String?> barcode = const Value.absent(),
          Value<String?> category = const Value.absent(),
          Value<String?> nutriscore = const Value.absent(),
          bool? isCustom,
          DateTime? createdAt}) =>
      Ingredient(
        id: id ?? this.id,
        name: name ?? this.name,
        caloriesPer100g: caloriesPer100g ?? this.caloriesPer100g,
        proteinsPer100g: proteinsPer100g ?? this.proteinsPer100g,
        fatsPer100g: fatsPer100g ?? this.fatsPer100g,
        carbsPer100g: carbsPer100g ?? this.carbsPer100g,
        fibersPer100g: fibersPer100g ?? this.fibersPer100g,
        saltPer100g: saltPer100g ?? this.saltPer100g,
        densityGPerMl:
            densityGPerMl.present ? densityGPerMl.value : this.densityGPerMl,
        avgWeightPerUnitG: avgWeightPerUnitG.present
            ? avgWeightPerUnitG.value
            : this.avgWeightPerUnitG,
        barcode: barcode.present ? barcode.value : this.barcode,
        category: category.present ? category.value : this.category,
        nutriscore: nutriscore.present ? nutriscore.value : this.nutriscore,
        isCustom: isCustom ?? this.isCustom,
        createdAt: createdAt ?? this.createdAt,
      );
  Ingredient copyWithCompanion(IngredientsCompanion data) {
    return Ingredient(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      caloriesPer100g: data.caloriesPer100g.present
          ? data.caloriesPer100g.value
          : this.caloriesPer100g,
      proteinsPer100g: data.proteinsPer100g.present
          ? data.proteinsPer100g.value
          : this.proteinsPer100g,
      fatsPer100g:
          data.fatsPer100g.present ? data.fatsPer100g.value : this.fatsPer100g,
      carbsPer100g: data.carbsPer100g.present
          ? data.carbsPer100g.value
          : this.carbsPer100g,
      fibersPer100g: data.fibersPer100g.present
          ? data.fibersPer100g.value
          : this.fibersPer100g,
      saltPer100g:
          data.saltPer100g.present ? data.saltPer100g.value : this.saltPer100g,
      densityGPerMl: data.densityGPerMl.present
          ? data.densityGPerMl.value
          : this.densityGPerMl,
      avgWeightPerUnitG: data.avgWeightPerUnitG.present
          ? data.avgWeightPerUnitG.value
          : this.avgWeightPerUnitG,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      category: data.category.present ? data.category.value : this.category,
      nutriscore:
          data.nutriscore.present ? data.nutriscore.value : this.nutriscore,
      isCustom: data.isCustom.present ? data.isCustom.value : this.isCustom,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Ingredient(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('caloriesPer100g: $caloriesPer100g, ')
          ..write('proteinsPer100g: $proteinsPer100g, ')
          ..write('fatsPer100g: $fatsPer100g, ')
          ..write('carbsPer100g: $carbsPer100g, ')
          ..write('fibersPer100g: $fibersPer100g, ')
          ..write('saltPer100g: $saltPer100g, ')
          ..write('densityGPerMl: $densityGPerMl, ')
          ..write('avgWeightPerUnitG: $avgWeightPerUnitG, ')
          ..write('barcode: $barcode, ')
          ..write('category: $category, ')
          ..write('nutriscore: $nutriscore, ')
          ..write('isCustom: $isCustom, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      caloriesPer100g,
      proteinsPer100g,
      fatsPer100g,
      carbsPer100g,
      fibersPer100g,
      saltPer100g,
      densityGPerMl,
      avgWeightPerUnitG,
      barcode,
      category,
      nutriscore,
      isCustom,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Ingredient &&
          other.id == this.id &&
          other.name == this.name &&
          other.caloriesPer100g == this.caloriesPer100g &&
          other.proteinsPer100g == this.proteinsPer100g &&
          other.fatsPer100g == this.fatsPer100g &&
          other.carbsPer100g == this.carbsPer100g &&
          other.fibersPer100g == this.fibersPer100g &&
          other.saltPer100g == this.saltPer100g &&
          other.densityGPerMl == this.densityGPerMl &&
          other.avgWeightPerUnitG == this.avgWeightPerUnitG &&
          other.barcode == this.barcode &&
          other.category == this.category &&
          other.nutriscore == this.nutriscore &&
          other.isCustom == this.isCustom &&
          other.createdAt == this.createdAt);
}

class IngredientsCompanion extends UpdateCompanion<Ingredient> {
  final Value<int> id;
  final Value<String> name;
  final Value<double> caloriesPer100g;
  final Value<double> proteinsPer100g;
  final Value<double> fatsPer100g;
  final Value<double> carbsPer100g;
  final Value<double> fibersPer100g;
  final Value<double> saltPer100g;
  final Value<double?> densityGPerMl;
  final Value<double?> avgWeightPerUnitG;
  final Value<String?> barcode;
  final Value<String?> category;
  final Value<String?> nutriscore;
  final Value<bool> isCustom;
  final Value<DateTime> createdAt;
  const IngredientsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.caloriesPer100g = const Value.absent(),
    this.proteinsPer100g = const Value.absent(),
    this.fatsPer100g = const Value.absent(),
    this.carbsPer100g = const Value.absent(),
    this.fibersPer100g = const Value.absent(),
    this.saltPer100g = const Value.absent(),
    this.densityGPerMl = const Value.absent(),
    this.avgWeightPerUnitG = const Value.absent(),
    this.barcode = const Value.absent(),
    this.category = const Value.absent(),
    this.nutriscore = const Value.absent(),
    this.isCustom = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  IngredientsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.caloriesPer100g = const Value.absent(),
    this.proteinsPer100g = const Value.absent(),
    this.fatsPer100g = const Value.absent(),
    this.carbsPer100g = const Value.absent(),
    this.fibersPer100g = const Value.absent(),
    this.saltPer100g = const Value.absent(),
    this.densityGPerMl = const Value.absent(),
    this.avgWeightPerUnitG = const Value.absent(),
    this.barcode = const Value.absent(),
    this.category = const Value.absent(),
    this.nutriscore = const Value.absent(),
    this.isCustom = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Ingredient> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<double>? caloriesPer100g,
    Expression<double>? proteinsPer100g,
    Expression<double>? fatsPer100g,
    Expression<double>? carbsPer100g,
    Expression<double>? fibersPer100g,
    Expression<double>? saltPer100g,
    Expression<double>? densityGPerMl,
    Expression<double>? avgWeightPerUnitG,
    Expression<String>? barcode,
    Expression<String>? category,
    Expression<String>? nutriscore,
    Expression<bool>? isCustom,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (caloriesPer100g != null) 'calories_per100g': caloriesPer100g,
      if (proteinsPer100g != null) 'proteins_per100g': proteinsPer100g,
      if (fatsPer100g != null) 'fats_per100g': fatsPer100g,
      if (carbsPer100g != null) 'carbs_per100g': carbsPer100g,
      if (fibersPer100g != null) 'fibers_per100g': fibersPer100g,
      if (saltPer100g != null) 'salt_per100g': saltPer100g,
      if (densityGPerMl != null) 'density_g_per_ml': densityGPerMl,
      if (avgWeightPerUnitG != null) 'avg_weight_per_unit_g': avgWeightPerUnitG,
      if (barcode != null) 'barcode': barcode,
      if (category != null) 'category': category,
      if (nutriscore != null) 'nutriscore': nutriscore,
      if (isCustom != null) 'is_custom': isCustom,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  IngredientsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<double>? caloriesPer100g,
      Value<double>? proteinsPer100g,
      Value<double>? fatsPer100g,
      Value<double>? carbsPer100g,
      Value<double>? fibersPer100g,
      Value<double>? saltPer100g,
      Value<double?>? densityGPerMl,
      Value<double?>? avgWeightPerUnitG,
      Value<String?>? barcode,
      Value<String?>? category,
      Value<String?>? nutriscore,
      Value<bool>? isCustom,
      Value<DateTime>? createdAt}) {
    return IngredientsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      caloriesPer100g: caloriesPer100g ?? this.caloriesPer100g,
      proteinsPer100g: proteinsPer100g ?? this.proteinsPer100g,
      fatsPer100g: fatsPer100g ?? this.fatsPer100g,
      carbsPer100g: carbsPer100g ?? this.carbsPer100g,
      fibersPer100g: fibersPer100g ?? this.fibersPer100g,
      saltPer100g: saltPer100g ?? this.saltPer100g,
      densityGPerMl: densityGPerMl ?? this.densityGPerMl,
      avgWeightPerUnitG: avgWeightPerUnitG ?? this.avgWeightPerUnitG,
      barcode: barcode ?? this.barcode,
      category: category ?? this.category,
      nutriscore: nutriscore ?? this.nutriscore,
      isCustom: isCustom ?? this.isCustom,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (caloriesPer100g.present) {
      map['calories_per100g'] = Variable<double>(caloriesPer100g.value);
    }
    if (proteinsPer100g.present) {
      map['proteins_per100g'] = Variable<double>(proteinsPer100g.value);
    }
    if (fatsPer100g.present) {
      map['fats_per100g'] = Variable<double>(fatsPer100g.value);
    }
    if (carbsPer100g.present) {
      map['carbs_per100g'] = Variable<double>(carbsPer100g.value);
    }
    if (fibersPer100g.present) {
      map['fibers_per100g'] = Variable<double>(fibersPer100g.value);
    }
    if (saltPer100g.present) {
      map['salt_per100g'] = Variable<double>(saltPer100g.value);
    }
    if (densityGPerMl.present) {
      map['density_g_per_ml'] = Variable<double>(densityGPerMl.value);
    }
    if (avgWeightPerUnitG.present) {
      map['avg_weight_per_unit_g'] = Variable<double>(avgWeightPerUnitG.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (nutriscore.present) {
      map['nutriscore'] = Variable<String>(nutriscore.value);
    }
    if (isCustom.present) {
      map['is_custom'] = Variable<bool>(isCustom.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IngredientsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('caloriesPer100g: $caloriesPer100g, ')
          ..write('proteinsPer100g: $proteinsPer100g, ')
          ..write('fatsPer100g: $fatsPer100g, ')
          ..write('carbsPer100g: $carbsPer100g, ')
          ..write('fibersPer100g: $fibersPer100g, ')
          ..write('saltPer100g: $saltPer100g, ')
          ..write('densityGPerMl: $densityGPerMl, ')
          ..write('avgWeightPerUnitG: $avgWeightPerUnitG, ')
          ..write('barcode: $barcode, ')
          ..write('category: $category, ')
          ..write('nutriscore: $nutriscore, ')
          ..write('isCustom: $isCustom, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $FrigoTable extends Frigo with TableInfo<$FrigoTable, FrigoData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FrigoTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _ingredientIdMeta =
      const VerificationMeta('ingredientId');
  @override
  late final GeneratedColumn<int> ingredientId = GeneratedColumn<int>(
      'ingredient_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES ingredients (id) ON DELETE CASCADE'));
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
      'quantity', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
      'unit', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('g'));
  static const VerificationMeta _bestBeforeMeta =
      const VerificationMeta('bestBefore');
  @override
  late final GeneratedColumn<DateTime> bestBefore = GeneratedColumn<DateTime>(
      'best_before', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _locationMeta =
      const VerificationMeta('location');
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
      'location', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('frigo'));
  static const VerificationMeta _addedAtMeta =
      const VerificationMeta('addedAt');
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
      'added_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, ingredientId, quantity, unit, bestBefore, location, addedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'frigo';
  @override
  VerificationContext validateIntegrity(Insertable<FrigoData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('ingredient_id')) {
      context.handle(
          _ingredientIdMeta,
          ingredientId.isAcceptableOrUnknown(
              data['ingredient_id']!, _ingredientIdMeta));
    } else if (isInserting) {
      context.missing(_ingredientIdMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    }
    if (data.containsKey('unit')) {
      context.handle(
          _unitMeta, unit.isAcceptableOrUnknown(data['unit']!, _unitMeta));
    }
    if (data.containsKey('best_before')) {
      context.handle(
          _bestBeforeMeta,
          bestBefore.isAcceptableOrUnknown(
              data['best_before']!, _bestBeforeMeta));
    }
    if (data.containsKey('location')) {
      context.handle(_locationMeta,
          location.isAcceptableOrUnknown(data['location']!, _locationMeta));
    }
    if (data.containsKey('added_at')) {
      context.handle(_addedAtMeta,
          addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FrigoData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FrigoData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      ingredientId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ingredient_id'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}quantity'])!,
      unit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit'])!,
      bestBefore: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}best_before']),
      location: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}location'])!,
      addedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}added_at'])!,
    );
  }

  @override
  $FrigoTable createAlias(String alias) {
    return $FrigoTable(attachedDatabase, alias);
  }
}

class FrigoData extends DataClass implements Insertable<FrigoData> {
  final int id;
  final int ingredientId;
  final double quantity;
  final String unit;
  final DateTime? bestBefore;
  final String location;
  final DateTime addedAt;
  const FrigoData(
      {required this.id,
      required this.ingredientId,
      required this.quantity,
      required this.unit,
      this.bestBefore,
      required this.location,
      required this.addedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['ingredient_id'] = Variable<int>(ingredientId);
    map['quantity'] = Variable<double>(quantity);
    map['unit'] = Variable<String>(unit);
    if (!nullToAbsent || bestBefore != null) {
      map['best_before'] = Variable<DateTime>(bestBefore);
    }
    map['location'] = Variable<String>(location);
    map['added_at'] = Variable<DateTime>(addedAt);
    return map;
  }

  FrigoCompanion toCompanion(bool nullToAbsent) {
    return FrigoCompanion(
      id: Value(id),
      ingredientId: Value(ingredientId),
      quantity: Value(quantity),
      unit: Value(unit),
      bestBefore: bestBefore == null && nullToAbsent
          ? const Value.absent()
          : Value(bestBefore),
      location: Value(location),
      addedAt: Value(addedAt),
    );
  }

  factory FrigoData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FrigoData(
      id: serializer.fromJson<int>(json['id']),
      ingredientId: serializer.fromJson<int>(json['ingredientId']),
      quantity: serializer.fromJson<double>(json['quantity']),
      unit: serializer.fromJson<String>(json['unit']),
      bestBefore: serializer.fromJson<DateTime?>(json['bestBefore']),
      location: serializer.fromJson<String>(json['location']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'ingredientId': serializer.toJson<int>(ingredientId),
      'quantity': serializer.toJson<double>(quantity),
      'unit': serializer.toJson<String>(unit),
      'bestBefore': serializer.toJson<DateTime?>(bestBefore),
      'location': serializer.toJson<String>(location),
      'addedAt': serializer.toJson<DateTime>(addedAt),
    };
  }

  FrigoData copyWith(
          {int? id,
          int? ingredientId,
          double? quantity,
          String? unit,
          Value<DateTime?> bestBefore = const Value.absent(),
          String? location,
          DateTime? addedAt}) =>
      FrigoData(
        id: id ?? this.id,
        ingredientId: ingredientId ?? this.ingredientId,
        quantity: quantity ?? this.quantity,
        unit: unit ?? this.unit,
        bestBefore: bestBefore.present ? bestBefore.value : this.bestBefore,
        location: location ?? this.location,
        addedAt: addedAt ?? this.addedAt,
      );
  FrigoData copyWithCompanion(FrigoCompanion data) {
    return FrigoData(
      id: data.id.present ? data.id.value : this.id,
      ingredientId: data.ingredientId.present
          ? data.ingredientId.value
          : this.ingredientId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unit: data.unit.present ? data.unit.value : this.unit,
      bestBefore:
          data.bestBefore.present ? data.bestBefore.value : this.bestBefore,
      location: data.location.present ? data.location.value : this.location,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FrigoData(')
          ..write('id: $id, ')
          ..write('ingredientId: $ingredientId, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('bestBefore: $bestBefore, ')
          ..write('location: $location, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, ingredientId, quantity, unit, bestBefore, location, addedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FrigoData &&
          other.id == this.id &&
          other.ingredientId == this.ingredientId &&
          other.quantity == this.quantity &&
          other.unit == this.unit &&
          other.bestBefore == this.bestBefore &&
          other.location == this.location &&
          other.addedAt == this.addedAt);
}

class FrigoCompanion extends UpdateCompanion<FrigoData> {
  final Value<int> id;
  final Value<int> ingredientId;
  final Value<double> quantity;
  final Value<String> unit;
  final Value<DateTime?> bestBefore;
  final Value<String> location;
  final Value<DateTime> addedAt;
  const FrigoCompanion({
    this.id = const Value.absent(),
    this.ingredientId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unit = const Value.absent(),
    this.bestBefore = const Value.absent(),
    this.location = const Value.absent(),
    this.addedAt = const Value.absent(),
  });
  FrigoCompanion.insert({
    this.id = const Value.absent(),
    required int ingredientId,
    this.quantity = const Value.absent(),
    this.unit = const Value.absent(),
    this.bestBefore = const Value.absent(),
    this.location = const Value.absent(),
    this.addedAt = const Value.absent(),
  }) : ingredientId = Value(ingredientId);
  static Insertable<FrigoData> custom({
    Expression<int>? id,
    Expression<int>? ingredientId,
    Expression<double>? quantity,
    Expression<String>? unit,
    Expression<DateTime>? bestBefore,
    Expression<String>? location,
    Expression<DateTime>? addedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ingredientId != null) 'ingredient_id': ingredientId,
      if (quantity != null) 'quantity': quantity,
      if (unit != null) 'unit': unit,
      if (bestBefore != null) 'best_before': bestBefore,
      if (location != null) 'location': location,
      if (addedAt != null) 'added_at': addedAt,
    });
  }

  FrigoCompanion copyWith(
      {Value<int>? id,
      Value<int>? ingredientId,
      Value<double>? quantity,
      Value<String>? unit,
      Value<DateTime?>? bestBefore,
      Value<String>? location,
      Value<DateTime>? addedAt}) {
    return FrigoCompanion(
      id: id ?? this.id,
      ingredientId: ingredientId ?? this.ingredientId,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      bestBefore: bestBefore ?? this.bestBefore,
      location: location ?? this.location,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (ingredientId.present) {
      map['ingredient_id'] = Variable<int>(ingredientId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (bestBefore.present) {
      map['best_before'] = Variable<DateTime>(bestBefore.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FrigoCompanion(')
          ..write('id: $id, ')
          ..write('ingredientId: $ingredientId, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('bestBefore: $bestBefore, ')
          ..write('location: $location, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }
}

class $RecettesTable extends Recettes with TableInfo<$RecettesTable, Recette> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecettesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _instructionsMeta =
      const VerificationMeta('instructions');
  @override
  late final GeneratedColumn<String> instructions = GeneratedColumn<String>(
      'instructions', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _servingsMeta =
      const VerificationMeta('servings');
  @override
  late final GeneratedColumn<int> servings = GeneratedColumn<int>(
      'servings', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _imageUrlMeta =
      const VerificationMeta('imageUrl');
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
      'image_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, instructions, servings, notes, imageUrl, category, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recettes';
  @override
  VerificationContext validateIntegrity(Insertable<Recette> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('instructions')) {
      context.handle(
          _instructionsMeta,
          instructions.isAcceptableOrUnknown(
              data['instructions']!, _instructionsMeta));
    }
    if (data.containsKey('servings')) {
      context.handle(_servingsMeta,
          servings.isAcceptableOrUnknown(data['servings']!, _servingsMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('image_url')) {
      context.handle(_imageUrlMeta,
          imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta));
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Recette map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Recette(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      instructions: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}instructions']),
      servings: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}servings'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      imageUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_url']),
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $RecettesTable createAlias(String alias) {
    return $RecettesTable(attachedDatabase, alias);
  }
}

class Recette extends DataClass implements Insertable<Recette> {
  final int id;
  final String name;
  final String? instructions;
  final int servings;
  final String? notes;
  final String? imageUrl;
  final String? category;
  final DateTime createdAt;
  const Recette(
      {required this.id,
      required this.name,
      this.instructions,
      required this.servings,
      this.notes,
      this.imageUrl,
      this.category,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || instructions != null) {
      map['instructions'] = Variable<String>(instructions);
    }
    map['servings'] = Variable<int>(servings);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  RecettesCompanion toCompanion(bool nullToAbsent) {
    return RecettesCompanion(
      id: Value(id),
      name: Value(name),
      instructions: instructions == null && nullToAbsent
          ? const Value.absent()
          : Value(instructions),
      servings: Value(servings),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      createdAt: Value(createdAt),
    );
  }

  factory Recette.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Recette(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      instructions: serializer.fromJson<String?>(json['instructions']),
      servings: serializer.fromJson<int>(json['servings']),
      notes: serializer.fromJson<String?>(json['notes']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      category: serializer.fromJson<String?>(json['category']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'instructions': serializer.toJson<String?>(instructions),
      'servings': serializer.toJson<int>(servings),
      'notes': serializer.toJson<String?>(notes),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'category': serializer.toJson<String?>(category),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Recette copyWith(
          {int? id,
          String? name,
          Value<String?> instructions = const Value.absent(),
          int? servings,
          Value<String?> notes = const Value.absent(),
          Value<String?> imageUrl = const Value.absent(),
          Value<String?> category = const Value.absent(),
          DateTime? createdAt}) =>
      Recette(
        id: id ?? this.id,
        name: name ?? this.name,
        instructions:
            instructions.present ? instructions.value : this.instructions,
        servings: servings ?? this.servings,
        notes: notes.present ? notes.value : this.notes,
        imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
        category: category.present ? category.value : this.category,
        createdAt: createdAt ?? this.createdAt,
      );
  Recette copyWithCompanion(RecettesCompanion data) {
    return Recette(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      instructions: data.instructions.present
          ? data.instructions.value
          : this.instructions,
      servings: data.servings.present ? data.servings.value : this.servings,
      notes: data.notes.present ? data.notes.value : this.notes,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      category: data.category.present ? data.category.value : this.category,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Recette(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('instructions: $instructions, ')
          ..write('servings: $servings, ')
          ..write('notes: $notes, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('category: $category, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, name, instructions, servings, notes, imageUrl, category, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Recette &&
          other.id == this.id &&
          other.name == this.name &&
          other.instructions == this.instructions &&
          other.servings == this.servings &&
          other.notes == this.notes &&
          other.imageUrl == this.imageUrl &&
          other.category == this.category &&
          other.createdAt == this.createdAt);
}

class RecettesCompanion extends UpdateCompanion<Recette> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> instructions;
  final Value<int> servings;
  final Value<String?> notes;
  final Value<String?> imageUrl;
  final Value<String?> category;
  final Value<DateTime> createdAt;
  const RecettesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.instructions = const Value.absent(),
    this.servings = const Value.absent(),
    this.notes = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.category = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  RecettesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.instructions = const Value.absent(),
    this.servings = const Value.absent(),
    this.notes = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.category = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Recette> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? instructions,
    Expression<int>? servings,
    Expression<String>? notes,
    Expression<String>? imageUrl,
    Expression<String>? category,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (instructions != null) 'instructions': instructions,
      if (servings != null) 'servings': servings,
      if (notes != null) 'notes': notes,
      if (imageUrl != null) 'image_url': imageUrl,
      if (category != null) 'category': category,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  RecettesCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String?>? instructions,
      Value<int>? servings,
      Value<String?>? notes,
      Value<String?>? imageUrl,
      Value<String?>? category,
      Value<DateTime>? createdAt}) {
    return RecettesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      instructions: instructions ?? this.instructions,
      servings: servings ?? this.servings,
      notes: notes ?? this.notes,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (instructions.present) {
      map['instructions'] = Variable<String>(instructions.value);
    }
    if (servings.present) {
      map['servings'] = Variable<int>(servings.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecettesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('instructions: $instructions, ')
          ..write('servings: $servings, ')
          ..write('notes: $notes, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('category: $category, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $RecetteIngredientsTable extends RecetteIngredients
    with TableInfo<$RecetteIngredientsTable, RecetteIngredient> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecetteIngredientsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _recetteIdMeta =
      const VerificationMeta('recetteId');
  @override
  late final GeneratedColumn<int> recetteId = GeneratedColumn<int>(
      'recette_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES recettes (id) ON DELETE CASCADE'));
  static const VerificationMeta _ingredientIdMeta =
      const VerificationMeta('ingredientId');
  @override
  late final GeneratedColumn<int> ingredientId = GeneratedColumn<int>(
      'ingredient_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES ingredients (id) ON DELETE CASCADE'));
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
      'quantity', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
      'unit', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('g'));
  static const VerificationMeta _densityGPerMlMeta =
      const VerificationMeta('densityGPerMl');
  @override
  late final GeneratedColumn<double> densityGPerMl = GeneratedColumn<double>(
      'density_g_per_ml', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _weightPerUnitGMeta =
      const VerificationMeta('weightPerUnitG');
  @override
  late final GeneratedColumn<double> weightPerUnitG = GeneratedColumn<double>(
      'weight_per_unit_g', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        recetteId,
        ingredientId,
        quantity,
        unit,
        densityGPerMl,
        weightPerUnitG
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recette_ingredients';
  @override
  VerificationContext validateIntegrity(Insertable<RecetteIngredient> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('recette_id')) {
      context.handle(_recetteIdMeta,
          recetteId.isAcceptableOrUnknown(data['recette_id']!, _recetteIdMeta));
    } else if (isInserting) {
      context.missing(_recetteIdMeta);
    }
    if (data.containsKey('ingredient_id')) {
      context.handle(
          _ingredientIdMeta,
          ingredientId.isAcceptableOrUnknown(
              data['ingredient_id']!, _ingredientIdMeta));
    } else if (isInserting) {
      context.missing(_ingredientIdMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    }
    if (data.containsKey('unit')) {
      context.handle(
          _unitMeta, unit.isAcceptableOrUnknown(data['unit']!, _unitMeta));
    }
    if (data.containsKey('density_g_per_ml')) {
      context.handle(
          _densityGPerMlMeta,
          densityGPerMl.isAcceptableOrUnknown(
              data['density_g_per_ml']!, _densityGPerMlMeta));
    }
    if (data.containsKey('weight_per_unit_g')) {
      context.handle(
          _weightPerUnitGMeta,
          weightPerUnitG.isAcceptableOrUnknown(
              data['weight_per_unit_g']!, _weightPerUnitGMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecetteIngredient map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecetteIngredient(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      recetteId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}recette_id'])!,
      ingredientId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ingredient_id'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}quantity'])!,
      unit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit'])!,
      densityGPerMl: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}density_g_per_ml']),
      weightPerUnitG: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}weight_per_unit_g']),
    );
  }

  @override
  $RecetteIngredientsTable createAlias(String alias) {
    return $RecetteIngredientsTable(attachedDatabase, alias);
  }
}

class RecetteIngredient extends DataClass
    implements Insertable<RecetteIngredient> {
  final int id;
  final int recetteId;
  final int ingredientId;
  final double quantity;
  final String unit;
  final double? densityGPerMl;
  final double? weightPerUnitG;
  const RecetteIngredient(
      {required this.id,
      required this.recetteId,
      required this.ingredientId,
      required this.quantity,
      required this.unit,
      this.densityGPerMl,
      this.weightPerUnitG});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['recette_id'] = Variable<int>(recetteId);
    map['ingredient_id'] = Variable<int>(ingredientId);
    map['quantity'] = Variable<double>(quantity);
    map['unit'] = Variable<String>(unit);
    if (!nullToAbsent || densityGPerMl != null) {
      map['density_g_per_ml'] = Variable<double>(densityGPerMl);
    }
    if (!nullToAbsent || weightPerUnitG != null) {
      map['weight_per_unit_g'] = Variable<double>(weightPerUnitG);
    }
    return map;
  }

  RecetteIngredientsCompanion toCompanion(bool nullToAbsent) {
    return RecetteIngredientsCompanion(
      id: Value(id),
      recetteId: Value(recetteId),
      ingredientId: Value(ingredientId),
      quantity: Value(quantity),
      unit: Value(unit),
      densityGPerMl: densityGPerMl == null && nullToAbsent
          ? const Value.absent()
          : Value(densityGPerMl),
      weightPerUnitG: weightPerUnitG == null && nullToAbsent
          ? const Value.absent()
          : Value(weightPerUnitG),
    );
  }

  factory RecetteIngredient.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecetteIngredient(
      id: serializer.fromJson<int>(json['id']),
      recetteId: serializer.fromJson<int>(json['recetteId']),
      ingredientId: serializer.fromJson<int>(json['ingredientId']),
      quantity: serializer.fromJson<double>(json['quantity']),
      unit: serializer.fromJson<String>(json['unit']),
      densityGPerMl: serializer.fromJson<double?>(json['densityGPerMl']),
      weightPerUnitG: serializer.fromJson<double?>(json['weightPerUnitG']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'recetteId': serializer.toJson<int>(recetteId),
      'ingredientId': serializer.toJson<int>(ingredientId),
      'quantity': serializer.toJson<double>(quantity),
      'unit': serializer.toJson<String>(unit),
      'densityGPerMl': serializer.toJson<double?>(densityGPerMl),
      'weightPerUnitG': serializer.toJson<double?>(weightPerUnitG),
    };
  }

  RecetteIngredient copyWith(
          {int? id,
          int? recetteId,
          int? ingredientId,
          double? quantity,
          String? unit,
          Value<double?> densityGPerMl = const Value.absent(),
          Value<double?> weightPerUnitG = const Value.absent()}) =>
      RecetteIngredient(
        id: id ?? this.id,
        recetteId: recetteId ?? this.recetteId,
        ingredientId: ingredientId ?? this.ingredientId,
        quantity: quantity ?? this.quantity,
        unit: unit ?? this.unit,
        densityGPerMl:
            densityGPerMl.present ? densityGPerMl.value : this.densityGPerMl,
        weightPerUnitG:
            weightPerUnitG.present ? weightPerUnitG.value : this.weightPerUnitG,
      );
  RecetteIngredient copyWithCompanion(RecetteIngredientsCompanion data) {
    return RecetteIngredient(
      id: data.id.present ? data.id.value : this.id,
      recetteId: data.recetteId.present ? data.recetteId.value : this.recetteId,
      ingredientId: data.ingredientId.present
          ? data.ingredientId.value
          : this.ingredientId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unit: data.unit.present ? data.unit.value : this.unit,
      densityGPerMl: data.densityGPerMl.present
          ? data.densityGPerMl.value
          : this.densityGPerMl,
      weightPerUnitG: data.weightPerUnitG.present
          ? data.weightPerUnitG.value
          : this.weightPerUnitG,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecetteIngredient(')
          ..write('id: $id, ')
          ..write('recetteId: $recetteId, ')
          ..write('ingredientId: $ingredientId, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('densityGPerMl: $densityGPerMl, ')
          ..write('weightPerUnitG: $weightPerUnitG')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, recetteId, ingredientId, quantity, unit,
      densityGPerMl, weightPerUnitG);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecetteIngredient &&
          other.id == this.id &&
          other.recetteId == this.recetteId &&
          other.ingredientId == this.ingredientId &&
          other.quantity == this.quantity &&
          other.unit == this.unit &&
          other.densityGPerMl == this.densityGPerMl &&
          other.weightPerUnitG == this.weightPerUnitG);
}

class RecetteIngredientsCompanion extends UpdateCompanion<RecetteIngredient> {
  final Value<int> id;
  final Value<int> recetteId;
  final Value<int> ingredientId;
  final Value<double> quantity;
  final Value<String> unit;
  final Value<double?> densityGPerMl;
  final Value<double?> weightPerUnitG;
  const RecetteIngredientsCompanion({
    this.id = const Value.absent(),
    this.recetteId = const Value.absent(),
    this.ingredientId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unit = const Value.absent(),
    this.densityGPerMl = const Value.absent(),
    this.weightPerUnitG = const Value.absent(),
  });
  RecetteIngredientsCompanion.insert({
    this.id = const Value.absent(),
    required int recetteId,
    required int ingredientId,
    this.quantity = const Value.absent(),
    this.unit = const Value.absent(),
    this.densityGPerMl = const Value.absent(),
    this.weightPerUnitG = const Value.absent(),
  })  : recetteId = Value(recetteId),
        ingredientId = Value(ingredientId);
  static Insertable<RecetteIngredient> custom({
    Expression<int>? id,
    Expression<int>? recetteId,
    Expression<int>? ingredientId,
    Expression<double>? quantity,
    Expression<String>? unit,
    Expression<double>? densityGPerMl,
    Expression<double>? weightPerUnitG,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (recetteId != null) 'recette_id': recetteId,
      if (ingredientId != null) 'ingredient_id': ingredientId,
      if (quantity != null) 'quantity': quantity,
      if (unit != null) 'unit': unit,
      if (densityGPerMl != null) 'density_g_per_ml': densityGPerMl,
      if (weightPerUnitG != null) 'weight_per_unit_g': weightPerUnitG,
    });
  }

  RecetteIngredientsCompanion copyWith(
      {Value<int>? id,
      Value<int>? recetteId,
      Value<int>? ingredientId,
      Value<double>? quantity,
      Value<String>? unit,
      Value<double?>? densityGPerMl,
      Value<double?>? weightPerUnitG}) {
    return RecetteIngredientsCompanion(
      id: id ?? this.id,
      recetteId: recetteId ?? this.recetteId,
      ingredientId: ingredientId ?? this.ingredientId,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      densityGPerMl: densityGPerMl ?? this.densityGPerMl,
      weightPerUnitG: weightPerUnitG ?? this.weightPerUnitG,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (recetteId.present) {
      map['recette_id'] = Variable<int>(recetteId.value);
    }
    if (ingredientId.present) {
      map['ingredient_id'] = Variable<int>(ingredientId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (densityGPerMl.present) {
      map['density_g_per_ml'] = Variable<double>(densityGPerMl.value);
    }
    if (weightPerUnitG.present) {
      map['weight_per_unit_g'] = Variable<double>(weightPerUnitG.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecetteIngredientsCompanion(')
          ..write('id: $id, ')
          ..write('recetteId: $recetteId, ')
          ..write('ingredientId: $ingredientId, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('densityGPerMl: $densityGPerMl, ')
          ..write('weightPerUnitG: $weightPerUnitG')
          ..write(')'))
        .toString();
  }
}

class $UserProfilesTable extends UserProfiles
    with TableInfo<$UserProfilesTable, UserProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _sexMeta = const VerificationMeta('sex');
  @override
  late final GeneratedColumn<String> sex = GeneratedColumn<String>(
      'sex', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ageMeta = const VerificationMeta('age');
  @override
  late final GeneratedColumn<int> age = GeneratedColumn<int>(
      'age', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _heightCmMeta =
      const VerificationMeta('heightCm');
  @override
  late final GeneratedColumn<double> heightCm = GeneratedColumn<double>(
      'height_cm', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _weightKgMeta =
      const VerificationMeta('weightKg');
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
      'weight_kg', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _eaterMultiplierMeta =
      const VerificationMeta('eaterMultiplier');
  @override
  late final GeneratedColumn<double> eaterMultiplier = GeneratedColumn<double>(
      'eater_multiplier', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(1.0));
  static const VerificationMeta _activityLevelMeta =
      const VerificationMeta('activityLevel');
  @override
  late final GeneratedColumn<String> activityLevel = GeneratedColumn<String>(
      'activity_level', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('sedentary'));
  static const VerificationMeta _bmrMeta = const VerificationMeta('bmr');
  @override
  late final GeneratedColumn<double> bmr = GeneratedColumn<double>(
      'bmr', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _tdeeMeta = const VerificationMeta('tdee');
  @override
  late final GeneratedColumn<double> tdee = GeneratedColumn<double>(
      'tdee', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        userId,
        sex,
        age,
        heightCm,
        weightKg,
        eaterMultiplier,
        activityLevel,
        bmr,
        tdee,
        isActive,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_profiles';
  @override
  VerificationContext validateIntegrity(Insertable<UserProfile> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('sex')) {
      context.handle(
          _sexMeta, sex.isAcceptableOrUnknown(data['sex']!, _sexMeta));
    } else if (isInserting) {
      context.missing(_sexMeta);
    }
    if (data.containsKey('age')) {
      context.handle(
          _ageMeta, age.isAcceptableOrUnknown(data['age']!, _ageMeta));
    } else if (isInserting) {
      context.missing(_ageMeta);
    }
    if (data.containsKey('height_cm')) {
      context.handle(_heightCmMeta,
          heightCm.isAcceptableOrUnknown(data['height_cm']!, _heightCmMeta));
    } else if (isInserting) {
      context.missing(_heightCmMeta);
    }
    if (data.containsKey('weight_kg')) {
      context.handle(_weightKgMeta,
          weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta));
    } else if (isInserting) {
      context.missing(_weightKgMeta);
    }
    if (data.containsKey('eater_multiplier')) {
      context.handle(
          _eaterMultiplierMeta,
          eaterMultiplier.isAcceptableOrUnknown(
              data['eater_multiplier']!, _eaterMultiplierMeta));
    }
    if (data.containsKey('activity_level')) {
      context.handle(
          _activityLevelMeta,
          activityLevel.isAcceptableOrUnknown(
              data['activity_level']!, _activityLevelMeta));
    }
    if (data.containsKey('bmr')) {
      context.handle(
          _bmrMeta, bmr.isAcceptableOrUnknown(data['bmr']!, _bmrMeta));
    }
    if (data.containsKey('tdee')) {
      context.handle(
          _tdeeMeta, tdee.isAcceptableOrUnknown(data['tdee']!, _tdeeMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProfile(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      sex: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sex'])!,
      age: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}age'])!,
      heightCm: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}height_cm'])!,
      weightKg: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}weight_kg'])!,
      eaterMultiplier: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}eater_multiplier'])!,
      activityLevel: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}activity_level'])!,
      bmr: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}bmr']),
      tdee: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}tdee']),
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $UserProfilesTable createAlias(String alias) {
    return $UserProfilesTable(attachedDatabase, alias);
  }
}

class UserProfile extends DataClass implements Insertable<UserProfile> {
  final int id;
  final String name;
  final String userId;
  final String sex;
  final int age;
  final double heightCm;
  final double weightKg;
  final double eaterMultiplier;
  final String activityLevel;
  final double? bmr;
  final double? tdee;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  const UserProfile(
      {required this.id,
      required this.name,
      required this.userId,
      required this.sex,
      required this.age,
      required this.heightCm,
      required this.weightKg,
      required this.eaterMultiplier,
      required this.activityLevel,
      this.bmr,
      this.tdee,
      required this.isActive,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['user_id'] = Variable<String>(userId);
    map['sex'] = Variable<String>(sex);
    map['age'] = Variable<int>(age);
    map['height_cm'] = Variable<double>(heightCm);
    map['weight_kg'] = Variable<double>(weightKg);
    map['eater_multiplier'] = Variable<double>(eaterMultiplier);
    map['activity_level'] = Variable<String>(activityLevel);
    if (!nullToAbsent || bmr != null) {
      map['bmr'] = Variable<double>(bmr);
    }
    if (!nullToAbsent || tdee != null) {
      map['tdee'] = Variable<double>(tdee);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UserProfilesCompanion toCompanion(bool nullToAbsent) {
    return UserProfilesCompanion(
      id: Value(id),
      name: Value(name),
      userId: Value(userId),
      sex: Value(sex),
      age: Value(age),
      heightCm: Value(heightCm),
      weightKg: Value(weightKg),
      eaterMultiplier: Value(eaterMultiplier),
      activityLevel: Value(activityLevel),
      bmr: bmr == null && nullToAbsent ? const Value.absent() : Value(bmr),
      tdee: tdee == null && nullToAbsent ? const Value.absent() : Value(tdee),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProfile(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      userId: serializer.fromJson<String>(json['userId']),
      sex: serializer.fromJson<String>(json['sex']),
      age: serializer.fromJson<int>(json['age']),
      heightCm: serializer.fromJson<double>(json['heightCm']),
      weightKg: serializer.fromJson<double>(json['weightKg']),
      eaterMultiplier: serializer.fromJson<double>(json['eaterMultiplier']),
      activityLevel: serializer.fromJson<String>(json['activityLevel']),
      bmr: serializer.fromJson<double?>(json['bmr']),
      tdee: serializer.fromJson<double?>(json['tdee']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'userId': serializer.toJson<String>(userId),
      'sex': serializer.toJson<String>(sex),
      'age': serializer.toJson<int>(age),
      'heightCm': serializer.toJson<double>(heightCm),
      'weightKg': serializer.toJson<double>(weightKg),
      'eaterMultiplier': serializer.toJson<double>(eaterMultiplier),
      'activityLevel': serializer.toJson<String>(activityLevel),
      'bmr': serializer.toJson<double?>(bmr),
      'tdee': serializer.toJson<double?>(tdee),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UserProfile copyWith(
          {int? id,
          String? name,
          String? userId,
          String? sex,
          int? age,
          double? heightCm,
          double? weightKg,
          double? eaterMultiplier,
          String? activityLevel,
          Value<double?> bmr = const Value.absent(),
          Value<double?> tdee = const Value.absent(),
          bool? isActive,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      UserProfile(
        id: id ?? this.id,
        name: name ?? this.name,
        userId: userId ?? this.userId,
        sex: sex ?? this.sex,
        age: age ?? this.age,
        heightCm: heightCm ?? this.heightCm,
        weightKg: weightKg ?? this.weightKg,
        eaterMultiplier: eaterMultiplier ?? this.eaterMultiplier,
        activityLevel: activityLevel ?? this.activityLevel,
        bmr: bmr.present ? bmr.value : this.bmr,
        tdee: tdee.present ? tdee.value : this.tdee,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  UserProfile copyWithCompanion(UserProfilesCompanion data) {
    return UserProfile(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      userId: data.userId.present ? data.userId.value : this.userId,
      sex: data.sex.present ? data.sex.value : this.sex,
      age: data.age.present ? data.age.value : this.age,
      heightCm: data.heightCm.present ? data.heightCm.value : this.heightCm,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      eaterMultiplier: data.eaterMultiplier.present
          ? data.eaterMultiplier.value
          : this.eaterMultiplier,
      activityLevel: data.activityLevel.present
          ? data.activityLevel.value
          : this.activityLevel,
      bmr: data.bmr.present ? data.bmr.value : this.bmr,
      tdee: data.tdee.present ? data.tdee.value : this.tdee,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProfile(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('userId: $userId, ')
          ..write('sex: $sex, ')
          ..write('age: $age, ')
          ..write('heightCm: $heightCm, ')
          ..write('weightKg: $weightKg, ')
          ..write('eaterMultiplier: $eaterMultiplier, ')
          ..write('activityLevel: $activityLevel, ')
          ..write('bmr: $bmr, ')
          ..write('tdee: $tdee, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      userId,
      sex,
      age,
      heightCm,
      weightKg,
      eaterMultiplier,
      activityLevel,
      bmr,
      tdee,
      isActive,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProfile &&
          other.id == this.id &&
          other.name == this.name &&
          other.userId == this.userId &&
          other.sex == this.sex &&
          other.age == this.age &&
          other.heightCm == this.heightCm &&
          other.weightKg == this.weightKg &&
          other.eaterMultiplier == this.eaterMultiplier &&
          other.activityLevel == this.activityLevel &&
          other.bmr == this.bmr &&
          other.tdee == this.tdee &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class UserProfilesCompanion extends UpdateCompanion<UserProfile> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> userId;
  final Value<String> sex;
  final Value<int> age;
  final Value<double> heightCm;
  final Value<double> weightKg;
  final Value<double> eaterMultiplier;
  final Value<String> activityLevel;
  final Value<double?> bmr;
  final Value<double?> tdee;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const UserProfilesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.userId = const Value.absent(),
    this.sex = const Value.absent(),
    this.age = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.eaterMultiplier = const Value.absent(),
    this.activityLevel = const Value.absent(),
    this.bmr = const Value.absent(),
    this.tdee = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  UserProfilesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String userId,
    required String sex,
    required int age,
    required double heightCm,
    required double weightKg,
    this.eaterMultiplier = const Value.absent(),
    this.activityLevel = const Value.absent(),
    this.bmr = const Value.absent(),
    this.tdee = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : name = Value(name),
        userId = Value(userId),
        sex = Value(sex),
        age = Value(age),
        heightCm = Value(heightCm),
        weightKg = Value(weightKg);
  static Insertable<UserProfile> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? userId,
    Expression<String>? sex,
    Expression<int>? age,
    Expression<double>? heightCm,
    Expression<double>? weightKg,
    Expression<double>? eaterMultiplier,
    Expression<String>? activityLevel,
    Expression<double>? bmr,
    Expression<double>? tdee,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (userId != null) 'user_id': userId,
      if (sex != null) 'sex': sex,
      if (age != null) 'age': age,
      if (heightCm != null) 'height_cm': heightCm,
      if (weightKg != null) 'weight_kg': weightKg,
      if (eaterMultiplier != null) 'eater_multiplier': eaterMultiplier,
      if (activityLevel != null) 'activity_level': activityLevel,
      if (bmr != null) 'bmr': bmr,
      if (tdee != null) 'tdee': tdee,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  UserProfilesCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? userId,
      Value<String>? sex,
      Value<int>? age,
      Value<double>? heightCm,
      Value<double>? weightKg,
      Value<double>? eaterMultiplier,
      Value<String>? activityLevel,
      Value<double?>? bmr,
      Value<double?>? tdee,
      Value<bool>? isActive,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return UserProfilesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      userId: userId ?? this.userId,
      sex: sex ?? this.sex,
      age: age ?? this.age,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      eaterMultiplier: eaterMultiplier ?? this.eaterMultiplier,
      activityLevel: activityLevel ?? this.activityLevel,
      bmr: bmr ?? this.bmr,
      tdee: tdee ?? this.tdee,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (sex.present) {
      map['sex'] = Variable<String>(sex.value);
    }
    if (age.present) {
      map['age'] = Variable<int>(age.value);
    }
    if (heightCm.present) {
      map['height_cm'] = Variable<double>(heightCm.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (eaterMultiplier.present) {
      map['eater_multiplier'] = Variable<double>(eaterMultiplier.value);
    }
    if (activityLevel.present) {
      map['activity_level'] = Variable<String>(activityLevel.value);
    }
    if (bmr.present) {
      map['bmr'] = Variable<double>(bmr.value);
    }
    if (tdee.present) {
      map['tdee'] = Variable<double>(tdee.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProfilesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('userId: $userId, ')
          ..write('sex: $sex, ')
          ..write('age: $age, ')
          ..write('heightCm: $heightCm, ')
          ..write('weightKg: $weightKg, ')
          ..write('eaterMultiplier: $eaterMultiplier, ')
          ..write('activityLevel: $activityLevel, ')
          ..write('bmr: $bmr, ')
          ..write('tdee: $tdee, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $GroupsTable extends Groups with TableInfo<$GroupsTable, Group> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GroupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _groupIdMeta =
      const VerificationMeta('groupId');
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
      'group_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, groupId, name, description, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'groups';
  @override
  VerificationContext validateIntegrity(Insertable<Group> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('group_id')) {
      context.handle(_groupIdMeta,
          groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta));
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Group map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Group(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      groupId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}group_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $GroupsTable createAlias(String alias) {
    return $GroupsTable(attachedDatabase, alias);
  }
}

class Group extends DataClass implements Insertable<Group> {
  final int id;
  final String groupId;
  final String name;
  final String? description;
  final DateTime createdAt;
  const Group(
      {required this.id,
      required this.groupId,
      required this.name,
      this.description,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['group_id'] = Variable<String>(groupId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  GroupsCompanion toCompanion(bool nullToAbsent) {
    return GroupsCompanion(
      id: Value(id),
      groupId: Value(groupId),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      createdAt: Value(createdAt),
    );
  }

  factory Group.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Group(
      id: serializer.fromJson<int>(json['id']),
      groupId: serializer.fromJson<String>(json['groupId']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'groupId': serializer.toJson<String>(groupId),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Group copyWith(
          {int? id,
          String? groupId,
          String? name,
          Value<String?> description = const Value.absent(),
          DateTime? createdAt}) =>
      Group(
        id: id ?? this.id,
        groupId: groupId ?? this.groupId,
        name: name ?? this.name,
        description: description.present ? description.value : this.description,
        createdAt: createdAt ?? this.createdAt,
      );
  Group copyWithCompanion(GroupsCompanion data) {
    return Group(
      id: data.id.present ? data.id.value : this.id,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Group(')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, groupId, name, description, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Group &&
          other.id == this.id &&
          other.groupId == this.groupId &&
          other.name == this.name &&
          other.description == this.description &&
          other.createdAt == this.createdAt);
}

class GroupsCompanion extends UpdateCompanion<Group> {
  final Value<int> id;
  final Value<String> groupId;
  final Value<String> name;
  final Value<String?> description;
  final Value<DateTime> createdAt;
  const GroupsCompanion({
    this.id = const Value.absent(),
    this.groupId = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  GroupsCompanion.insert({
    this.id = const Value.absent(),
    required String groupId,
    required String name,
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : groupId = Value(groupId),
        name = Value(name);
  static Insertable<Group> custom({
    Expression<int>? id,
    Expression<String>? groupId,
    Expression<String>? name,
    Expression<String>? description,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (groupId != null) 'group_id': groupId,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  GroupsCompanion copyWith(
      {Value<int>? id,
      Value<String>? groupId,
      Value<String>? name,
      Value<String?>? description,
      Value<DateTime>? createdAt}) {
    return GroupsCompanion(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GroupsCompanion(')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $GroupMembersTable extends GroupMembers
    with TableInfo<$GroupMembersTable, GroupMember> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GroupMembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _groupIdMeta =
      const VerificationMeta('groupId');
  @override
  late final GeneratedColumn<int> groupId = GeneratedColumn<int>(
      'group_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES "groups" (id) ON DELETE CASCADE'));
  static const VerificationMeta _userProfileIdMeta =
      const VerificationMeta('userProfileId');
  @override
  late final GeneratedColumn<int> userProfileId = GeneratedColumn<int>(
      'user_profile_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES user_profiles (id) ON DELETE CASCADE'));
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('member'));
  static const VerificationMeta _joinedAtMeta =
      const VerificationMeta('joinedAt');
  @override
  late final GeneratedColumn<DateTime> joinedAt = GeneratedColumn<DateTime>(
      'joined_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, groupId, userProfileId, role, joinedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'group_members';
  @override
  VerificationContext validateIntegrity(Insertable<GroupMember> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('group_id')) {
      context.handle(_groupIdMeta,
          groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta));
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('user_profile_id')) {
      context.handle(
          _userProfileIdMeta,
          userProfileId.isAcceptableOrUnknown(
              data['user_profile_id']!, _userProfileIdMeta));
    } else if (isInserting) {
      context.missing(_userProfileIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    }
    if (data.containsKey('joined_at')) {
      context.handle(_joinedAtMeta,
          joinedAt.isAcceptableOrUnknown(data['joined_at']!, _joinedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {groupId, userProfileId};
  @override
  GroupMember map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GroupMember(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      groupId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}group_id'])!,
      userProfileId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}user_profile_id'])!,
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      joinedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}joined_at'])!,
    );
  }

  @override
  $GroupMembersTable createAlias(String alias) {
    return $GroupMembersTable(attachedDatabase, alias);
  }
}

class GroupMember extends DataClass implements Insertable<GroupMember> {
  final int id;
  final int groupId;
  final int userProfileId;
  final String role;
  final DateTime joinedAt;
  const GroupMember(
      {required this.id,
      required this.groupId,
      required this.userProfileId,
      required this.role,
      required this.joinedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['group_id'] = Variable<int>(groupId);
    map['user_profile_id'] = Variable<int>(userProfileId);
    map['role'] = Variable<String>(role);
    map['joined_at'] = Variable<DateTime>(joinedAt);
    return map;
  }

  GroupMembersCompanion toCompanion(bool nullToAbsent) {
    return GroupMembersCompanion(
      id: Value(id),
      groupId: Value(groupId),
      userProfileId: Value(userProfileId),
      role: Value(role),
      joinedAt: Value(joinedAt),
    );
  }

  factory GroupMember.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GroupMember(
      id: serializer.fromJson<int>(json['id']),
      groupId: serializer.fromJson<int>(json['groupId']),
      userProfileId: serializer.fromJson<int>(json['userProfileId']),
      role: serializer.fromJson<String>(json['role']),
      joinedAt: serializer.fromJson<DateTime>(json['joinedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'groupId': serializer.toJson<int>(groupId),
      'userProfileId': serializer.toJson<int>(userProfileId),
      'role': serializer.toJson<String>(role),
      'joinedAt': serializer.toJson<DateTime>(joinedAt),
    };
  }

  GroupMember copyWith(
          {int? id,
          int? groupId,
          int? userProfileId,
          String? role,
          DateTime? joinedAt}) =>
      GroupMember(
        id: id ?? this.id,
        groupId: groupId ?? this.groupId,
        userProfileId: userProfileId ?? this.userProfileId,
        role: role ?? this.role,
        joinedAt: joinedAt ?? this.joinedAt,
      );
  GroupMember copyWithCompanion(GroupMembersCompanion data) {
    return GroupMember(
      id: data.id.present ? data.id.value : this.id,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      userProfileId: data.userProfileId.present
          ? data.userProfileId.value
          : this.userProfileId,
      role: data.role.present ? data.role.value : this.role,
      joinedAt: data.joinedAt.present ? data.joinedAt.value : this.joinedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GroupMember(')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('userProfileId: $userProfileId, ')
          ..write('role: $role, ')
          ..write('joinedAt: $joinedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, groupId, userProfileId, role, joinedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GroupMember &&
          other.id == this.id &&
          other.groupId == this.groupId &&
          other.userProfileId == this.userProfileId &&
          other.role == this.role &&
          other.joinedAt == this.joinedAt);
}

class GroupMembersCompanion extends UpdateCompanion<GroupMember> {
  final Value<int> id;
  final Value<int> groupId;
  final Value<int> userProfileId;
  final Value<String> role;
  final Value<DateTime> joinedAt;
  final Value<int> rowid;
  const GroupMembersCompanion({
    this.id = const Value.absent(),
    this.groupId = const Value.absent(),
    this.userProfileId = const Value.absent(),
    this.role = const Value.absent(),
    this.joinedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GroupMembersCompanion.insert({
    required int id,
    required int groupId,
    required int userProfileId,
    this.role = const Value.absent(),
    this.joinedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        groupId = Value(groupId),
        userProfileId = Value(userProfileId);
  static Insertable<GroupMember> custom({
    Expression<int>? id,
    Expression<int>? groupId,
    Expression<int>? userProfileId,
    Expression<String>? role,
    Expression<DateTime>? joinedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (groupId != null) 'group_id': groupId,
      if (userProfileId != null) 'user_profile_id': userProfileId,
      if (role != null) 'role': role,
      if (joinedAt != null) 'joined_at': joinedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GroupMembersCompanion copyWith(
      {Value<int>? id,
      Value<int>? groupId,
      Value<int>? userProfileId,
      Value<String>? role,
      Value<DateTime>? joinedAt,
      Value<int>? rowid}) {
    return GroupMembersCompanion(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      userProfileId: userProfileId ?? this.userProfileId,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<int>(groupId.value);
    }
    if (userProfileId.present) {
      map['user_profile_id'] = Variable<int>(userProfileId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (joinedAt.present) {
      map['joined_at'] = Variable<DateTime>(joinedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GroupMembersCompanion(')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('userProfileId: $userProfileId, ')
          ..write('role: $role, ')
          ..write('joinedAt: $joinedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MealPlanningTable extends MealPlanning
    with TableInfo<$MealPlanningTable, MealPlanningData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MealPlanningTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _mealTypeMeta =
      const VerificationMeta('mealType');
  @override
  late final GeneratedColumn<String> mealType = GeneratedColumn<String>(
      'meal_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _recetteIdMeta =
      const VerificationMeta('recetteId');
  @override
  late final GeneratedColumn<int> recetteId = GeneratedColumn<int>(
      'recette_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES recettes (id) ON DELETE CASCADE'));
  static const VerificationMeta _servingsMeta =
      const VerificationMeta('servings');
  @override
  late final GeneratedColumn<int> servings = GeneratedColumn<int>(
      'servings', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _userProfileIdMeta =
      const VerificationMeta('userProfileId');
  @override
  late final GeneratedColumn<int> userProfileId = GeneratedColumn<int>(
      'user_profile_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES user_profiles (id) ON DELETE CASCADE'));
  static const VerificationMeta _groupIdMeta =
      const VerificationMeta('groupId');
  @override
  late final GeneratedColumn<int> groupId = GeneratedColumn<int>(
      'group_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES "groups" (id) ON DELETE CASCADE'));
  static const VerificationMeta _eatersMeta = const VerificationMeta('eaters');
  @override
  late final GeneratedColumn<String> eaters = GeneratedColumn<String>(
      'eaters', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _modifiedIngredientsMeta =
      const VerificationMeta('modifiedIngredients');
  @override
  late final GeneratedColumn<String> modifiedIngredients =
      GeneratedColumn<String>('modified_ingredients', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _modifiedCaloriesMeta =
      const VerificationMeta('modifiedCalories');
  @override
  late final GeneratedColumn<double> modifiedCalories = GeneratedColumn<double>(
      'modified_calories', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _modifiedProteinsMeta =
      const VerificationMeta('modifiedProteins');
  @override
  late final GeneratedColumn<double> modifiedProteins = GeneratedColumn<double>(
      'modified_proteins', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _modifiedFatsMeta =
      const VerificationMeta('modifiedFats');
  @override
  late final GeneratedColumn<double> modifiedFats = GeneratedColumn<double>(
      'modified_fats', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _modifiedCarbsMeta =
      const VerificationMeta('modifiedCarbs');
  @override
  late final GeneratedColumn<double> modifiedCarbs = GeneratedColumn<double>(
      'modified_carbs', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _modifiedFibersMeta =
      const VerificationMeta('modifiedFibers');
  @override
  late final GeneratedColumn<double> modifiedFibers = GeneratedColumn<double>(
      'modified_fibers', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        date,
        mealType,
        recetteId,
        servings,
        userProfileId,
        groupId,
        eaters,
        modifiedIngredients,
        modifiedCalories,
        modifiedProteins,
        modifiedFats,
        modifiedCarbs,
        modifiedFibers,
        notes,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meal_planning';
  @override
  VerificationContext validateIntegrity(Insertable<MealPlanningData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('meal_type')) {
      context.handle(_mealTypeMeta,
          mealType.isAcceptableOrUnknown(data['meal_type']!, _mealTypeMeta));
    } else if (isInserting) {
      context.missing(_mealTypeMeta);
    }
    if (data.containsKey('recette_id')) {
      context.handle(_recetteIdMeta,
          recetteId.isAcceptableOrUnknown(data['recette_id']!, _recetteIdMeta));
    }
    if (data.containsKey('servings')) {
      context.handle(_servingsMeta,
          servings.isAcceptableOrUnknown(data['servings']!, _servingsMeta));
    }
    if (data.containsKey('user_profile_id')) {
      context.handle(
          _userProfileIdMeta,
          userProfileId.isAcceptableOrUnknown(
              data['user_profile_id']!, _userProfileIdMeta));
    }
    if (data.containsKey('group_id')) {
      context.handle(_groupIdMeta,
          groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta));
    }
    if (data.containsKey('eaters')) {
      context.handle(_eatersMeta,
          eaters.isAcceptableOrUnknown(data['eaters']!, _eatersMeta));
    }
    if (data.containsKey('modified_ingredients')) {
      context.handle(
          _modifiedIngredientsMeta,
          modifiedIngredients.isAcceptableOrUnknown(
              data['modified_ingredients']!, _modifiedIngredientsMeta));
    }
    if (data.containsKey('modified_calories')) {
      context.handle(
          _modifiedCaloriesMeta,
          modifiedCalories.isAcceptableOrUnknown(
              data['modified_calories']!, _modifiedCaloriesMeta));
    }
    if (data.containsKey('modified_proteins')) {
      context.handle(
          _modifiedProteinsMeta,
          modifiedProteins.isAcceptableOrUnknown(
              data['modified_proteins']!, _modifiedProteinsMeta));
    }
    if (data.containsKey('modified_fats')) {
      context.handle(
          _modifiedFatsMeta,
          modifiedFats.isAcceptableOrUnknown(
              data['modified_fats']!, _modifiedFatsMeta));
    }
    if (data.containsKey('modified_carbs')) {
      context.handle(
          _modifiedCarbsMeta,
          modifiedCarbs.isAcceptableOrUnknown(
              data['modified_carbs']!, _modifiedCarbsMeta));
    }
    if (data.containsKey('modified_fibers')) {
      context.handle(
          _modifiedFibersMeta,
          modifiedFibers.isAcceptableOrUnknown(
              data['modified_fibers']!, _modifiedFibersMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MealPlanningData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MealPlanningData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      mealType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}meal_type'])!,
      recetteId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}recette_id']),
      servings: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}servings'])!,
      userProfileId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}user_profile_id']),
      groupId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}group_id']),
      eaters: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}eaters']),
      modifiedIngredients: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}modified_ingredients']),
      modifiedCalories: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}modified_calories']),
      modifiedProteins: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}modified_proteins']),
      modifiedFats: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}modified_fats']),
      modifiedCarbs: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}modified_carbs']),
      modifiedFibers: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}modified_fibers']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $MealPlanningTable createAlias(String alias) {
    return $MealPlanningTable(attachedDatabase, alias);
  }
}

class MealPlanningData extends DataClass
    implements Insertable<MealPlanningData> {
  final int id;
  final DateTime date;
  final String mealType;
  final int? recetteId;
  final int servings;
  final int? userProfileId;
  final int? groupId;
  final String? eaters;
  final String? modifiedIngredients;
  final double? modifiedCalories;
  final double? modifiedProteins;
  final double? modifiedFats;
  final double? modifiedCarbs;
  final double? modifiedFibers;
  final String? notes;
  final DateTime createdAt;
  const MealPlanningData(
      {required this.id,
      required this.date,
      required this.mealType,
      this.recetteId,
      required this.servings,
      this.userProfileId,
      this.groupId,
      this.eaters,
      this.modifiedIngredients,
      this.modifiedCalories,
      this.modifiedProteins,
      this.modifiedFats,
      this.modifiedCarbs,
      this.modifiedFibers,
      this.notes,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    map['meal_type'] = Variable<String>(mealType);
    if (!nullToAbsent || recetteId != null) {
      map['recette_id'] = Variable<int>(recetteId);
    }
    map['servings'] = Variable<int>(servings);
    if (!nullToAbsent || userProfileId != null) {
      map['user_profile_id'] = Variable<int>(userProfileId);
    }
    if (!nullToAbsent || groupId != null) {
      map['group_id'] = Variable<int>(groupId);
    }
    if (!nullToAbsent || eaters != null) {
      map['eaters'] = Variable<String>(eaters);
    }
    if (!nullToAbsent || modifiedIngredients != null) {
      map['modified_ingredients'] = Variable<String>(modifiedIngredients);
    }
    if (!nullToAbsent || modifiedCalories != null) {
      map['modified_calories'] = Variable<double>(modifiedCalories);
    }
    if (!nullToAbsent || modifiedProteins != null) {
      map['modified_proteins'] = Variable<double>(modifiedProteins);
    }
    if (!nullToAbsent || modifiedFats != null) {
      map['modified_fats'] = Variable<double>(modifiedFats);
    }
    if (!nullToAbsent || modifiedCarbs != null) {
      map['modified_carbs'] = Variable<double>(modifiedCarbs);
    }
    if (!nullToAbsent || modifiedFibers != null) {
      map['modified_fibers'] = Variable<double>(modifiedFibers);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MealPlanningCompanion toCompanion(bool nullToAbsent) {
    return MealPlanningCompanion(
      id: Value(id),
      date: Value(date),
      mealType: Value(mealType),
      recetteId: recetteId == null && nullToAbsent
          ? const Value.absent()
          : Value(recetteId),
      servings: Value(servings),
      userProfileId: userProfileId == null && nullToAbsent
          ? const Value.absent()
          : Value(userProfileId),
      groupId: groupId == null && nullToAbsent
          ? const Value.absent()
          : Value(groupId),
      eaters:
          eaters == null && nullToAbsent ? const Value.absent() : Value(eaters),
      modifiedIngredients: modifiedIngredients == null && nullToAbsent
          ? const Value.absent()
          : Value(modifiedIngredients),
      modifiedCalories: modifiedCalories == null && nullToAbsent
          ? const Value.absent()
          : Value(modifiedCalories),
      modifiedProteins: modifiedProteins == null && nullToAbsent
          ? const Value.absent()
          : Value(modifiedProteins),
      modifiedFats: modifiedFats == null && nullToAbsent
          ? const Value.absent()
          : Value(modifiedFats),
      modifiedCarbs: modifiedCarbs == null && nullToAbsent
          ? const Value.absent()
          : Value(modifiedCarbs),
      modifiedFibers: modifiedFibers == null && nullToAbsent
          ? const Value.absent()
          : Value(modifiedFibers),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory MealPlanningData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MealPlanningData(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      mealType: serializer.fromJson<String>(json['mealType']),
      recetteId: serializer.fromJson<int?>(json['recetteId']),
      servings: serializer.fromJson<int>(json['servings']),
      userProfileId: serializer.fromJson<int?>(json['userProfileId']),
      groupId: serializer.fromJson<int?>(json['groupId']),
      eaters: serializer.fromJson<String?>(json['eaters']),
      modifiedIngredients:
          serializer.fromJson<String?>(json['modifiedIngredients']),
      modifiedCalories: serializer.fromJson<double?>(json['modifiedCalories']),
      modifiedProteins: serializer.fromJson<double?>(json['modifiedProteins']),
      modifiedFats: serializer.fromJson<double?>(json['modifiedFats']),
      modifiedCarbs: serializer.fromJson<double?>(json['modifiedCarbs']),
      modifiedFibers: serializer.fromJson<double?>(json['modifiedFibers']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'mealType': serializer.toJson<String>(mealType),
      'recetteId': serializer.toJson<int?>(recetteId),
      'servings': serializer.toJson<int>(servings),
      'userProfileId': serializer.toJson<int?>(userProfileId),
      'groupId': serializer.toJson<int?>(groupId),
      'eaters': serializer.toJson<String?>(eaters),
      'modifiedIngredients': serializer.toJson<String?>(modifiedIngredients),
      'modifiedCalories': serializer.toJson<double?>(modifiedCalories),
      'modifiedProteins': serializer.toJson<double?>(modifiedProteins),
      'modifiedFats': serializer.toJson<double?>(modifiedFats),
      'modifiedCarbs': serializer.toJson<double?>(modifiedCarbs),
      'modifiedFibers': serializer.toJson<double?>(modifiedFibers),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  MealPlanningData copyWith(
          {int? id,
          DateTime? date,
          String? mealType,
          Value<int?> recetteId = const Value.absent(),
          int? servings,
          Value<int?> userProfileId = const Value.absent(),
          Value<int?> groupId = const Value.absent(),
          Value<String?> eaters = const Value.absent(),
          Value<String?> modifiedIngredients = const Value.absent(),
          Value<double?> modifiedCalories = const Value.absent(),
          Value<double?> modifiedProteins = const Value.absent(),
          Value<double?> modifiedFats = const Value.absent(),
          Value<double?> modifiedCarbs = const Value.absent(),
          Value<double?> modifiedFibers = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          DateTime? createdAt}) =>
      MealPlanningData(
        id: id ?? this.id,
        date: date ?? this.date,
        mealType: mealType ?? this.mealType,
        recetteId: recetteId.present ? recetteId.value : this.recetteId,
        servings: servings ?? this.servings,
        userProfileId:
            userProfileId.present ? userProfileId.value : this.userProfileId,
        groupId: groupId.present ? groupId.value : this.groupId,
        eaters: eaters.present ? eaters.value : this.eaters,
        modifiedIngredients: modifiedIngredients.present
            ? modifiedIngredients.value
            : this.modifiedIngredients,
        modifiedCalories: modifiedCalories.present
            ? modifiedCalories.value
            : this.modifiedCalories,
        modifiedProteins: modifiedProteins.present
            ? modifiedProteins.value
            : this.modifiedProteins,
        modifiedFats:
            modifiedFats.present ? modifiedFats.value : this.modifiedFats,
        modifiedCarbs:
            modifiedCarbs.present ? modifiedCarbs.value : this.modifiedCarbs,
        modifiedFibers:
            modifiedFibers.present ? modifiedFibers.value : this.modifiedFibers,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
      );
  MealPlanningData copyWithCompanion(MealPlanningCompanion data) {
    return MealPlanningData(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      mealType: data.mealType.present ? data.mealType.value : this.mealType,
      recetteId: data.recetteId.present ? data.recetteId.value : this.recetteId,
      servings: data.servings.present ? data.servings.value : this.servings,
      userProfileId: data.userProfileId.present
          ? data.userProfileId.value
          : this.userProfileId,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      eaters: data.eaters.present ? data.eaters.value : this.eaters,
      modifiedIngredients: data.modifiedIngredients.present
          ? data.modifiedIngredients.value
          : this.modifiedIngredients,
      modifiedCalories: data.modifiedCalories.present
          ? data.modifiedCalories.value
          : this.modifiedCalories,
      modifiedProteins: data.modifiedProteins.present
          ? data.modifiedProteins.value
          : this.modifiedProteins,
      modifiedFats: data.modifiedFats.present
          ? data.modifiedFats.value
          : this.modifiedFats,
      modifiedCarbs: data.modifiedCarbs.present
          ? data.modifiedCarbs.value
          : this.modifiedCarbs,
      modifiedFibers: data.modifiedFibers.present
          ? data.modifiedFibers.value
          : this.modifiedFibers,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MealPlanningData(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('mealType: $mealType, ')
          ..write('recetteId: $recetteId, ')
          ..write('servings: $servings, ')
          ..write('userProfileId: $userProfileId, ')
          ..write('groupId: $groupId, ')
          ..write('eaters: $eaters, ')
          ..write('modifiedIngredients: $modifiedIngredients, ')
          ..write('modifiedCalories: $modifiedCalories, ')
          ..write('modifiedProteins: $modifiedProteins, ')
          ..write('modifiedFats: $modifiedFats, ')
          ..write('modifiedCarbs: $modifiedCarbs, ')
          ..write('modifiedFibers: $modifiedFibers, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      date,
      mealType,
      recetteId,
      servings,
      userProfileId,
      groupId,
      eaters,
      modifiedIngredients,
      modifiedCalories,
      modifiedProteins,
      modifiedFats,
      modifiedCarbs,
      modifiedFibers,
      notes,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MealPlanningData &&
          other.id == this.id &&
          other.date == this.date &&
          other.mealType == this.mealType &&
          other.recetteId == this.recetteId &&
          other.servings == this.servings &&
          other.userProfileId == this.userProfileId &&
          other.groupId == this.groupId &&
          other.eaters == this.eaters &&
          other.modifiedIngredients == this.modifiedIngredients &&
          other.modifiedCalories == this.modifiedCalories &&
          other.modifiedProteins == this.modifiedProteins &&
          other.modifiedFats == this.modifiedFats &&
          other.modifiedCarbs == this.modifiedCarbs &&
          other.modifiedFibers == this.modifiedFibers &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class MealPlanningCompanion extends UpdateCompanion<MealPlanningData> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<String> mealType;
  final Value<int?> recetteId;
  final Value<int> servings;
  final Value<int?> userProfileId;
  final Value<int?> groupId;
  final Value<String?> eaters;
  final Value<String?> modifiedIngredients;
  final Value<double?> modifiedCalories;
  final Value<double?> modifiedProteins;
  final Value<double?> modifiedFats;
  final Value<double?> modifiedCarbs;
  final Value<double?> modifiedFibers;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  const MealPlanningCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.mealType = const Value.absent(),
    this.recetteId = const Value.absent(),
    this.servings = const Value.absent(),
    this.userProfileId = const Value.absent(),
    this.groupId = const Value.absent(),
    this.eaters = const Value.absent(),
    this.modifiedIngredients = const Value.absent(),
    this.modifiedCalories = const Value.absent(),
    this.modifiedProteins = const Value.absent(),
    this.modifiedFats = const Value.absent(),
    this.modifiedCarbs = const Value.absent(),
    this.modifiedFibers = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  MealPlanningCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    required String mealType,
    this.recetteId = const Value.absent(),
    this.servings = const Value.absent(),
    this.userProfileId = const Value.absent(),
    this.groupId = const Value.absent(),
    this.eaters = const Value.absent(),
    this.modifiedIngredients = const Value.absent(),
    this.modifiedCalories = const Value.absent(),
    this.modifiedProteins = const Value.absent(),
    this.modifiedFats = const Value.absent(),
    this.modifiedCarbs = const Value.absent(),
    this.modifiedFibers = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : date = Value(date),
        mealType = Value(mealType);
  static Insertable<MealPlanningData> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<String>? mealType,
    Expression<int>? recetteId,
    Expression<int>? servings,
    Expression<int>? userProfileId,
    Expression<int>? groupId,
    Expression<String>? eaters,
    Expression<String>? modifiedIngredients,
    Expression<double>? modifiedCalories,
    Expression<double>? modifiedProteins,
    Expression<double>? modifiedFats,
    Expression<double>? modifiedCarbs,
    Expression<double>? modifiedFibers,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (mealType != null) 'meal_type': mealType,
      if (recetteId != null) 'recette_id': recetteId,
      if (servings != null) 'servings': servings,
      if (userProfileId != null) 'user_profile_id': userProfileId,
      if (groupId != null) 'group_id': groupId,
      if (eaters != null) 'eaters': eaters,
      if (modifiedIngredients != null)
        'modified_ingredients': modifiedIngredients,
      if (modifiedCalories != null) 'modified_calories': modifiedCalories,
      if (modifiedProteins != null) 'modified_proteins': modifiedProteins,
      if (modifiedFats != null) 'modified_fats': modifiedFats,
      if (modifiedCarbs != null) 'modified_carbs': modifiedCarbs,
      if (modifiedFibers != null) 'modified_fibers': modifiedFibers,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  MealPlanningCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? date,
      Value<String>? mealType,
      Value<int?>? recetteId,
      Value<int>? servings,
      Value<int?>? userProfileId,
      Value<int?>? groupId,
      Value<String?>? eaters,
      Value<String?>? modifiedIngredients,
      Value<double?>? modifiedCalories,
      Value<double?>? modifiedProteins,
      Value<double?>? modifiedFats,
      Value<double?>? modifiedCarbs,
      Value<double?>? modifiedFibers,
      Value<String?>? notes,
      Value<DateTime>? createdAt}) {
    return MealPlanningCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      mealType: mealType ?? this.mealType,
      recetteId: recetteId ?? this.recetteId,
      servings: servings ?? this.servings,
      userProfileId: userProfileId ?? this.userProfileId,
      groupId: groupId ?? this.groupId,
      eaters: eaters ?? this.eaters,
      modifiedIngredients: modifiedIngredients ?? this.modifiedIngredients,
      modifiedCalories: modifiedCalories ?? this.modifiedCalories,
      modifiedProteins: modifiedProteins ?? this.modifiedProteins,
      modifiedFats: modifiedFats ?? this.modifiedFats,
      modifiedCarbs: modifiedCarbs ?? this.modifiedCarbs,
      modifiedFibers: modifiedFibers ?? this.modifiedFibers,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (mealType.present) {
      map['meal_type'] = Variable<String>(mealType.value);
    }
    if (recetteId.present) {
      map['recette_id'] = Variable<int>(recetteId.value);
    }
    if (servings.present) {
      map['servings'] = Variable<int>(servings.value);
    }
    if (userProfileId.present) {
      map['user_profile_id'] = Variable<int>(userProfileId.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<int>(groupId.value);
    }
    if (eaters.present) {
      map['eaters'] = Variable<String>(eaters.value);
    }
    if (modifiedIngredients.present) {
      map['modified_ingredients'] = Variable<String>(modifiedIngredients.value);
    }
    if (modifiedCalories.present) {
      map['modified_calories'] = Variable<double>(modifiedCalories.value);
    }
    if (modifiedProteins.present) {
      map['modified_proteins'] = Variable<double>(modifiedProteins.value);
    }
    if (modifiedFats.present) {
      map['modified_fats'] = Variable<double>(modifiedFats.value);
    }
    if (modifiedCarbs.present) {
      map['modified_carbs'] = Variable<double>(modifiedCarbs.value);
    }
    if (modifiedFibers.present) {
      map['modified_fibers'] = Variable<double>(modifiedFibers.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MealPlanningCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('mealType: $mealType, ')
          ..write('recetteId: $recetteId, ')
          ..write('servings: $servings, ')
          ..write('userProfileId: $userProfileId, ')
          ..write('groupId: $groupId, ')
          ..write('eaters: $eaters, ')
          ..write('modifiedIngredients: $modifiedIngredients, ')
          ..write('modifiedCalories: $modifiedCalories, ')
          ..write('modifiedProteins: $modifiedProteins, ')
          ..write('modifiedFats: $modifiedFats, ')
          ..write('modifiedCarbs: $modifiedCarbs, ')
          ..write('modifiedFibers: $modifiedFibers, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ShoppingListTable extends ShoppingList
    with TableInfo<$ShoppingListTable, ShoppingListData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShoppingListTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _ingredientIdMeta =
      const VerificationMeta('ingredientId');
  @override
  late final GeneratedColumn<int> ingredientId = GeneratedColumn<int>(
      'ingredient_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES ingredients (id) ON DELETE CASCADE'));
  static const VerificationMeta _customNameMeta =
      const VerificationMeta('customName');
  @override
  late final GeneratedColumn<String> customName = GeneratedColumn<String>(
      'custom_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
      'quantity', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
      'unit', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('g'));
  static const VerificationMeta _isCheckedMeta =
      const VerificationMeta('isChecked');
  @override
  late final GeneratedColumn<bool> isChecked = GeneratedColumn<bool>(
      'is_checked', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_checked" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isAutoGeneratedMeta =
      const VerificationMeta('isAutoGenerated');
  @override
  late final GeneratedColumn<bool> isAutoGenerated = GeneratedColumn<bool>(
      'is_auto_generated', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_auto_generated" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _groupIdMeta =
      const VerificationMeta('groupId');
  @override
  late final GeneratedColumn<int> groupId = GeneratedColumn<int>(
      'group_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES "groups" (id) ON DELETE CASCADE'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        ingredientId,
        customName,
        quantity,
        unit,
        isChecked,
        isAutoGenerated,
        groupId,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shopping_list';
  @override
  VerificationContext validateIntegrity(Insertable<ShoppingListData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('ingredient_id')) {
      context.handle(
          _ingredientIdMeta,
          ingredientId.isAcceptableOrUnknown(
              data['ingredient_id']!, _ingredientIdMeta));
    }
    if (data.containsKey('custom_name')) {
      context.handle(
          _customNameMeta,
          customName.isAcceptableOrUnknown(
              data['custom_name']!, _customNameMeta));
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    }
    if (data.containsKey('unit')) {
      context.handle(
          _unitMeta, unit.isAcceptableOrUnknown(data['unit']!, _unitMeta));
    }
    if (data.containsKey('is_checked')) {
      context.handle(_isCheckedMeta,
          isChecked.isAcceptableOrUnknown(data['is_checked']!, _isCheckedMeta));
    }
    if (data.containsKey('is_auto_generated')) {
      context.handle(
          _isAutoGeneratedMeta,
          isAutoGenerated.isAcceptableOrUnknown(
              data['is_auto_generated']!, _isAutoGeneratedMeta));
    }
    if (data.containsKey('group_id')) {
      context.handle(_groupIdMeta,
          groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ShoppingListData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShoppingListData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      ingredientId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ingredient_id']),
      customName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}custom_name']),
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}quantity'])!,
      unit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit'])!,
      isChecked: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_checked'])!,
      isAutoGenerated: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}is_auto_generated'])!,
      groupId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}group_id']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ShoppingListTable createAlias(String alias) {
    return $ShoppingListTable(attachedDatabase, alias);
  }
}

class ShoppingListData extends DataClass
    implements Insertable<ShoppingListData> {
  final int id;
  final int? ingredientId;
  final String? customName;
  final double quantity;
  final String unit;
  final bool isChecked;
  final bool isAutoGenerated;
  final int? groupId;
  final DateTime createdAt;
  const ShoppingListData(
      {required this.id,
      this.ingredientId,
      this.customName,
      required this.quantity,
      required this.unit,
      required this.isChecked,
      required this.isAutoGenerated,
      this.groupId,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || ingredientId != null) {
      map['ingredient_id'] = Variable<int>(ingredientId);
    }
    if (!nullToAbsent || customName != null) {
      map['custom_name'] = Variable<String>(customName);
    }
    map['quantity'] = Variable<double>(quantity);
    map['unit'] = Variable<String>(unit);
    map['is_checked'] = Variable<bool>(isChecked);
    map['is_auto_generated'] = Variable<bool>(isAutoGenerated);
    if (!nullToAbsent || groupId != null) {
      map['group_id'] = Variable<int>(groupId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ShoppingListCompanion toCompanion(bool nullToAbsent) {
    return ShoppingListCompanion(
      id: Value(id),
      ingredientId: ingredientId == null && nullToAbsent
          ? const Value.absent()
          : Value(ingredientId),
      customName: customName == null && nullToAbsent
          ? const Value.absent()
          : Value(customName),
      quantity: Value(quantity),
      unit: Value(unit),
      isChecked: Value(isChecked),
      isAutoGenerated: Value(isAutoGenerated),
      groupId: groupId == null && nullToAbsent
          ? const Value.absent()
          : Value(groupId),
      createdAt: Value(createdAt),
    );
  }

  factory ShoppingListData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShoppingListData(
      id: serializer.fromJson<int>(json['id']),
      ingredientId: serializer.fromJson<int?>(json['ingredientId']),
      customName: serializer.fromJson<String?>(json['customName']),
      quantity: serializer.fromJson<double>(json['quantity']),
      unit: serializer.fromJson<String>(json['unit']),
      isChecked: serializer.fromJson<bool>(json['isChecked']),
      isAutoGenerated: serializer.fromJson<bool>(json['isAutoGenerated']),
      groupId: serializer.fromJson<int?>(json['groupId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'ingredientId': serializer.toJson<int?>(ingredientId),
      'customName': serializer.toJson<String?>(customName),
      'quantity': serializer.toJson<double>(quantity),
      'unit': serializer.toJson<String>(unit),
      'isChecked': serializer.toJson<bool>(isChecked),
      'isAutoGenerated': serializer.toJson<bool>(isAutoGenerated),
      'groupId': serializer.toJson<int?>(groupId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ShoppingListData copyWith(
          {int? id,
          Value<int?> ingredientId = const Value.absent(),
          Value<String?> customName = const Value.absent(),
          double? quantity,
          String? unit,
          bool? isChecked,
          bool? isAutoGenerated,
          Value<int?> groupId = const Value.absent(),
          DateTime? createdAt}) =>
      ShoppingListData(
        id: id ?? this.id,
        ingredientId:
            ingredientId.present ? ingredientId.value : this.ingredientId,
        customName: customName.present ? customName.value : this.customName,
        quantity: quantity ?? this.quantity,
        unit: unit ?? this.unit,
        isChecked: isChecked ?? this.isChecked,
        isAutoGenerated: isAutoGenerated ?? this.isAutoGenerated,
        groupId: groupId.present ? groupId.value : this.groupId,
        createdAt: createdAt ?? this.createdAt,
      );
  ShoppingListData copyWithCompanion(ShoppingListCompanion data) {
    return ShoppingListData(
      id: data.id.present ? data.id.value : this.id,
      ingredientId: data.ingredientId.present
          ? data.ingredientId.value
          : this.ingredientId,
      customName:
          data.customName.present ? data.customName.value : this.customName,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unit: data.unit.present ? data.unit.value : this.unit,
      isChecked: data.isChecked.present ? data.isChecked.value : this.isChecked,
      isAutoGenerated: data.isAutoGenerated.present
          ? data.isAutoGenerated.value
          : this.isAutoGenerated,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShoppingListData(')
          ..write('id: $id, ')
          ..write('ingredientId: $ingredientId, ')
          ..write('customName: $customName, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('isChecked: $isChecked, ')
          ..write('isAutoGenerated: $isAutoGenerated, ')
          ..write('groupId: $groupId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, ingredientId, customName, quantity, unit,
      isChecked, isAutoGenerated, groupId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShoppingListData &&
          other.id == this.id &&
          other.ingredientId == this.ingredientId &&
          other.customName == this.customName &&
          other.quantity == this.quantity &&
          other.unit == this.unit &&
          other.isChecked == this.isChecked &&
          other.isAutoGenerated == this.isAutoGenerated &&
          other.groupId == this.groupId &&
          other.createdAt == this.createdAt);
}

class ShoppingListCompanion extends UpdateCompanion<ShoppingListData> {
  final Value<int> id;
  final Value<int?> ingredientId;
  final Value<String?> customName;
  final Value<double> quantity;
  final Value<String> unit;
  final Value<bool> isChecked;
  final Value<bool> isAutoGenerated;
  final Value<int?> groupId;
  final Value<DateTime> createdAt;
  const ShoppingListCompanion({
    this.id = const Value.absent(),
    this.ingredientId = const Value.absent(),
    this.customName = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unit = const Value.absent(),
    this.isChecked = const Value.absent(),
    this.isAutoGenerated = const Value.absent(),
    this.groupId = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ShoppingListCompanion.insert({
    this.id = const Value.absent(),
    this.ingredientId = const Value.absent(),
    this.customName = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unit = const Value.absent(),
    this.isChecked = const Value.absent(),
    this.isAutoGenerated = const Value.absent(),
    this.groupId = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  static Insertable<ShoppingListData> custom({
    Expression<int>? id,
    Expression<int>? ingredientId,
    Expression<String>? customName,
    Expression<double>? quantity,
    Expression<String>? unit,
    Expression<bool>? isChecked,
    Expression<bool>? isAutoGenerated,
    Expression<int>? groupId,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ingredientId != null) 'ingredient_id': ingredientId,
      if (customName != null) 'custom_name': customName,
      if (quantity != null) 'quantity': quantity,
      if (unit != null) 'unit': unit,
      if (isChecked != null) 'is_checked': isChecked,
      if (isAutoGenerated != null) 'is_auto_generated': isAutoGenerated,
      if (groupId != null) 'group_id': groupId,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ShoppingListCompanion copyWith(
      {Value<int>? id,
      Value<int?>? ingredientId,
      Value<String?>? customName,
      Value<double>? quantity,
      Value<String>? unit,
      Value<bool>? isChecked,
      Value<bool>? isAutoGenerated,
      Value<int?>? groupId,
      Value<DateTime>? createdAt}) {
    return ShoppingListCompanion(
      id: id ?? this.id,
      ingredientId: ingredientId ?? this.ingredientId,
      customName: customName ?? this.customName,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      isChecked: isChecked ?? this.isChecked,
      isAutoGenerated: isAutoGenerated ?? this.isAutoGenerated,
      groupId: groupId ?? this.groupId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (ingredientId.present) {
      map['ingredient_id'] = Variable<int>(ingredientId.value);
    }
    if (customName.present) {
      map['custom_name'] = Variable<String>(customName.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (isChecked.present) {
      map['is_checked'] = Variable<bool>(isChecked.value);
    }
    if (isAutoGenerated.present) {
      map['is_auto_generated'] = Variable<bool>(isAutoGenerated.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<int>(groupId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShoppingListCompanion(')
          ..write('id: $id, ')
          ..write('ingredientId: $ingredientId, ')
          ..write('customName: $customName, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('isChecked: $isChecked, ')
          ..write('isAutoGenerated: $isAutoGenerated, ')
          ..write('groupId: $groupId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $CalorieTrackingTable extends CalorieTracking
    with TableInfo<$CalorieTrackingTable, CalorieTrackingData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CalorieTrackingTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _userProfileIdMeta =
      const VerificationMeta('userProfileId');
  @override
  late final GeneratedColumn<int> userProfileId = GeneratedColumn<int>(
      'user_profile_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES user_profiles (id) ON DELETE CASCADE'));
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _mealPlanningIdMeta =
      const VerificationMeta('mealPlanningId');
  @override
  late final GeneratedColumn<int> mealPlanningId = GeneratedColumn<int>(
      'meal_planning_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES meal_planning (id) ON DELETE CASCADE'));
  static const VerificationMeta _caloriesMeta =
      const VerificationMeta('calories');
  @override
  late final GeneratedColumn<double> calories = GeneratedColumn<double>(
      'calories', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _proteinsMeta =
      const VerificationMeta('proteins');
  @override
  late final GeneratedColumn<double> proteins = GeneratedColumn<double>(
      'proteins', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _fatsMeta = const VerificationMeta('fats');
  @override
  late final GeneratedColumn<double> fats = GeneratedColumn<double>(
      'fats', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _carbsMeta = const VerificationMeta('carbs');
  @override
  late final GeneratedColumn<double> carbs = GeneratedColumn<double>(
      'carbs', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _fibersMeta = const VerificationMeta('fibers');
  @override
  late final GeneratedColumn<double> fibers = GeneratedColumn<double>(
      'fibers', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _mealTypeMeta =
      const VerificationMeta('mealType');
  @override
  late final GeneratedColumn<String> mealType = GeneratedColumn<String>(
      'meal_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        userProfileId,
        date,
        mealPlanningId,
        calories,
        proteins,
        fats,
        carbs,
        fibers,
        mealType,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'calorie_tracking';
  @override
  VerificationContext validateIntegrity(
      Insertable<CalorieTrackingData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_profile_id')) {
      context.handle(
          _userProfileIdMeta,
          userProfileId.isAcceptableOrUnknown(
              data['user_profile_id']!, _userProfileIdMeta));
    } else if (isInserting) {
      context.missing(_userProfileIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('meal_planning_id')) {
      context.handle(
          _mealPlanningIdMeta,
          mealPlanningId.isAcceptableOrUnknown(
              data['meal_planning_id']!, _mealPlanningIdMeta));
    }
    if (data.containsKey('calories')) {
      context.handle(_caloriesMeta,
          calories.isAcceptableOrUnknown(data['calories']!, _caloriesMeta));
    }
    if (data.containsKey('proteins')) {
      context.handle(_proteinsMeta,
          proteins.isAcceptableOrUnknown(data['proteins']!, _proteinsMeta));
    }
    if (data.containsKey('fats')) {
      context.handle(
          _fatsMeta, fats.isAcceptableOrUnknown(data['fats']!, _fatsMeta));
    }
    if (data.containsKey('carbs')) {
      context.handle(
          _carbsMeta, carbs.isAcceptableOrUnknown(data['carbs']!, _carbsMeta));
    }
    if (data.containsKey('fibers')) {
      context.handle(_fibersMeta,
          fibers.isAcceptableOrUnknown(data['fibers']!, _fibersMeta));
    }
    if (data.containsKey('meal_type')) {
      context.handle(_mealTypeMeta,
          mealType.isAcceptableOrUnknown(data['meal_type']!, _mealTypeMeta));
    } else if (isInserting) {
      context.missing(_mealTypeMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CalorieTrackingData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CalorieTrackingData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      userProfileId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}user_profile_id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      mealPlanningId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}meal_planning_id']),
      calories: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}calories'])!,
      proteins: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}proteins'])!,
      fats: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}fats'])!,
      carbs: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}carbs'])!,
      fibers: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}fibers'])!,
      mealType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}meal_type'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $CalorieTrackingTable createAlias(String alias) {
    return $CalorieTrackingTable(attachedDatabase, alias);
  }
}

class CalorieTrackingData extends DataClass
    implements Insertable<CalorieTrackingData> {
  final int id;
  final int userProfileId;
  final DateTime date;
  final int? mealPlanningId;
  final double calories;
  final double proteins;
  final double fats;
  final double carbs;
  final double fibers;
  final String mealType;
  final DateTime createdAt;
  const CalorieTrackingData(
      {required this.id,
      required this.userProfileId,
      required this.date,
      this.mealPlanningId,
      required this.calories,
      required this.proteins,
      required this.fats,
      required this.carbs,
      required this.fibers,
      required this.mealType,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_profile_id'] = Variable<int>(userProfileId);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || mealPlanningId != null) {
      map['meal_planning_id'] = Variable<int>(mealPlanningId);
    }
    map['calories'] = Variable<double>(calories);
    map['proteins'] = Variable<double>(proteins);
    map['fats'] = Variable<double>(fats);
    map['carbs'] = Variable<double>(carbs);
    map['fibers'] = Variable<double>(fibers);
    map['meal_type'] = Variable<String>(mealType);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CalorieTrackingCompanion toCompanion(bool nullToAbsent) {
    return CalorieTrackingCompanion(
      id: Value(id),
      userProfileId: Value(userProfileId),
      date: Value(date),
      mealPlanningId: mealPlanningId == null && nullToAbsent
          ? const Value.absent()
          : Value(mealPlanningId),
      calories: Value(calories),
      proteins: Value(proteins),
      fats: Value(fats),
      carbs: Value(carbs),
      fibers: Value(fibers),
      mealType: Value(mealType),
      createdAt: Value(createdAt),
    );
  }

  factory CalorieTrackingData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CalorieTrackingData(
      id: serializer.fromJson<int>(json['id']),
      userProfileId: serializer.fromJson<int>(json['userProfileId']),
      date: serializer.fromJson<DateTime>(json['date']),
      mealPlanningId: serializer.fromJson<int?>(json['mealPlanningId']),
      calories: serializer.fromJson<double>(json['calories']),
      proteins: serializer.fromJson<double>(json['proteins']),
      fats: serializer.fromJson<double>(json['fats']),
      carbs: serializer.fromJson<double>(json['carbs']),
      fibers: serializer.fromJson<double>(json['fibers']),
      mealType: serializer.fromJson<String>(json['mealType']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userProfileId': serializer.toJson<int>(userProfileId),
      'date': serializer.toJson<DateTime>(date),
      'mealPlanningId': serializer.toJson<int?>(mealPlanningId),
      'calories': serializer.toJson<double>(calories),
      'proteins': serializer.toJson<double>(proteins),
      'fats': serializer.toJson<double>(fats),
      'carbs': serializer.toJson<double>(carbs),
      'fibers': serializer.toJson<double>(fibers),
      'mealType': serializer.toJson<String>(mealType),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CalorieTrackingData copyWith(
          {int? id,
          int? userProfileId,
          DateTime? date,
          Value<int?> mealPlanningId = const Value.absent(),
          double? calories,
          double? proteins,
          double? fats,
          double? carbs,
          double? fibers,
          String? mealType,
          DateTime? createdAt}) =>
      CalorieTrackingData(
        id: id ?? this.id,
        userProfileId: userProfileId ?? this.userProfileId,
        date: date ?? this.date,
        mealPlanningId:
            mealPlanningId.present ? mealPlanningId.value : this.mealPlanningId,
        calories: calories ?? this.calories,
        proteins: proteins ?? this.proteins,
        fats: fats ?? this.fats,
        carbs: carbs ?? this.carbs,
        fibers: fibers ?? this.fibers,
        mealType: mealType ?? this.mealType,
        createdAt: createdAt ?? this.createdAt,
      );
  CalorieTrackingData copyWithCompanion(CalorieTrackingCompanion data) {
    return CalorieTrackingData(
      id: data.id.present ? data.id.value : this.id,
      userProfileId: data.userProfileId.present
          ? data.userProfileId.value
          : this.userProfileId,
      date: data.date.present ? data.date.value : this.date,
      mealPlanningId: data.mealPlanningId.present
          ? data.mealPlanningId.value
          : this.mealPlanningId,
      calories: data.calories.present ? data.calories.value : this.calories,
      proteins: data.proteins.present ? data.proteins.value : this.proteins,
      fats: data.fats.present ? data.fats.value : this.fats,
      carbs: data.carbs.present ? data.carbs.value : this.carbs,
      fibers: data.fibers.present ? data.fibers.value : this.fibers,
      mealType: data.mealType.present ? data.mealType.value : this.mealType,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CalorieTrackingData(')
          ..write('id: $id, ')
          ..write('userProfileId: $userProfileId, ')
          ..write('date: $date, ')
          ..write('mealPlanningId: $mealPlanningId, ')
          ..write('calories: $calories, ')
          ..write('proteins: $proteins, ')
          ..write('fats: $fats, ')
          ..write('carbs: $carbs, ')
          ..write('fibers: $fibers, ')
          ..write('mealType: $mealType, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userProfileId, date, mealPlanningId,
      calories, proteins, fats, carbs, fibers, mealType, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CalorieTrackingData &&
          other.id == this.id &&
          other.userProfileId == this.userProfileId &&
          other.date == this.date &&
          other.mealPlanningId == this.mealPlanningId &&
          other.calories == this.calories &&
          other.proteins == this.proteins &&
          other.fats == this.fats &&
          other.carbs == this.carbs &&
          other.fibers == this.fibers &&
          other.mealType == this.mealType &&
          other.createdAt == this.createdAt);
}

class CalorieTrackingCompanion extends UpdateCompanion<CalorieTrackingData> {
  final Value<int> id;
  final Value<int> userProfileId;
  final Value<DateTime> date;
  final Value<int?> mealPlanningId;
  final Value<double> calories;
  final Value<double> proteins;
  final Value<double> fats;
  final Value<double> carbs;
  final Value<double> fibers;
  final Value<String> mealType;
  final Value<DateTime> createdAt;
  const CalorieTrackingCompanion({
    this.id = const Value.absent(),
    this.userProfileId = const Value.absent(),
    this.date = const Value.absent(),
    this.mealPlanningId = const Value.absent(),
    this.calories = const Value.absent(),
    this.proteins = const Value.absent(),
    this.fats = const Value.absent(),
    this.carbs = const Value.absent(),
    this.fibers = const Value.absent(),
    this.mealType = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  CalorieTrackingCompanion.insert({
    this.id = const Value.absent(),
    required int userProfileId,
    required DateTime date,
    this.mealPlanningId = const Value.absent(),
    this.calories = const Value.absent(),
    this.proteins = const Value.absent(),
    this.fats = const Value.absent(),
    this.carbs = const Value.absent(),
    this.fibers = const Value.absent(),
    required String mealType,
    this.createdAt = const Value.absent(),
  })  : userProfileId = Value(userProfileId),
        date = Value(date),
        mealType = Value(mealType);
  static Insertable<CalorieTrackingData> custom({
    Expression<int>? id,
    Expression<int>? userProfileId,
    Expression<DateTime>? date,
    Expression<int>? mealPlanningId,
    Expression<double>? calories,
    Expression<double>? proteins,
    Expression<double>? fats,
    Expression<double>? carbs,
    Expression<double>? fibers,
    Expression<String>? mealType,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userProfileId != null) 'user_profile_id': userProfileId,
      if (date != null) 'date': date,
      if (mealPlanningId != null) 'meal_planning_id': mealPlanningId,
      if (calories != null) 'calories': calories,
      if (proteins != null) 'proteins': proteins,
      if (fats != null) 'fats': fats,
      if (carbs != null) 'carbs': carbs,
      if (fibers != null) 'fibers': fibers,
      if (mealType != null) 'meal_type': mealType,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  CalorieTrackingCompanion copyWith(
      {Value<int>? id,
      Value<int>? userProfileId,
      Value<DateTime>? date,
      Value<int?>? mealPlanningId,
      Value<double>? calories,
      Value<double>? proteins,
      Value<double>? fats,
      Value<double>? carbs,
      Value<double>? fibers,
      Value<String>? mealType,
      Value<DateTime>? createdAt}) {
    return CalorieTrackingCompanion(
      id: id ?? this.id,
      userProfileId: userProfileId ?? this.userProfileId,
      date: date ?? this.date,
      mealPlanningId: mealPlanningId ?? this.mealPlanningId,
      calories: calories ?? this.calories,
      proteins: proteins ?? this.proteins,
      fats: fats ?? this.fats,
      carbs: carbs ?? this.carbs,
      fibers: fibers ?? this.fibers,
      mealType: mealType ?? this.mealType,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userProfileId.present) {
      map['user_profile_id'] = Variable<int>(userProfileId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (mealPlanningId.present) {
      map['meal_planning_id'] = Variable<int>(mealPlanningId.value);
    }
    if (calories.present) {
      map['calories'] = Variable<double>(calories.value);
    }
    if (proteins.present) {
      map['proteins'] = Variable<double>(proteins.value);
    }
    if (fats.present) {
      map['fats'] = Variable<double>(fats.value);
    }
    if (carbs.present) {
      map['carbs'] = Variable<double>(carbs.value);
    }
    if (fibers.present) {
      map['fibers'] = Variable<double>(fibers.value);
    }
    if (mealType.present) {
      map['meal_type'] = Variable<String>(mealType.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CalorieTrackingCompanion(')
          ..write('id: $id, ')
          ..write('userProfileId: $userProfileId, ')
          ..write('date: $date, ')
          ..write('mealPlanningId: $mealPlanningId, ')
          ..write('calories: $calories, ')
          ..write('proteins: $proteins, ')
          ..write('fats: $fats, ')
          ..write('carbs: $carbs, ')
          ..write('fibers: $fibers, ')
          ..write('mealType: $mealType, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $IngredientsTable ingredients = $IngredientsTable(this);
  late final $FrigoTable frigo = $FrigoTable(this);
  late final $RecettesTable recettes = $RecettesTable(this);
  late final $RecetteIngredientsTable recetteIngredients =
      $RecetteIngredientsTable(this);
  late final $UserProfilesTable userProfiles = $UserProfilesTable(this);
  late final $GroupsTable groups = $GroupsTable(this);
  late final $GroupMembersTable groupMembers = $GroupMembersTable(this);
  late final $MealPlanningTable mealPlanning = $MealPlanningTable(this);
  late final $ShoppingListTable shoppingList = $ShoppingListTable(this);
  late final $CalorieTrackingTable calorieTracking =
      $CalorieTrackingTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        ingredients,
        frigo,
        recettes,
        recetteIngredients,
        userProfiles,
        groups,
        groupMembers,
        mealPlanning,
        shoppingList,
        calorieTracking
      ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('ingredients',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('frigo', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('recettes',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('recette_ingredients', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('ingredients',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('recette_ingredients', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('groups',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('group_members', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('user_profiles',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('group_members', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('recettes',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('meal_planning', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('user_profiles',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('meal_planning', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('groups',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('meal_planning', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('ingredients',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('shopping_list', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('groups',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('shopping_list', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('user_profiles',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('calorie_tracking', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('meal_planning',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('calorie_tracking', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$IngredientsTableCreateCompanionBuilder = IngredientsCompanion
    Function({
  Value<int> id,
  required String name,
  Value<double> caloriesPer100g,
  Value<double> proteinsPer100g,
  Value<double> fatsPer100g,
  Value<double> carbsPer100g,
  Value<double> fibersPer100g,
  Value<double> saltPer100g,
  Value<double?> densityGPerMl,
  Value<double?> avgWeightPerUnitG,
  Value<String?> barcode,
  Value<String?> category,
  Value<String?> nutriscore,
  Value<bool> isCustom,
  Value<DateTime> createdAt,
});
typedef $$IngredientsTableUpdateCompanionBuilder = IngredientsCompanion
    Function({
  Value<int> id,
  Value<String> name,
  Value<double> caloriesPer100g,
  Value<double> proteinsPer100g,
  Value<double> fatsPer100g,
  Value<double> carbsPer100g,
  Value<double> fibersPer100g,
  Value<double> saltPer100g,
  Value<double?> densityGPerMl,
  Value<double?> avgWeightPerUnitG,
  Value<String?> barcode,
  Value<String?> category,
  Value<String?> nutriscore,
  Value<bool> isCustom,
  Value<DateTime> createdAt,
});

final class $$IngredientsTableReferences
    extends BaseReferences<_$AppDatabase, $IngredientsTable, Ingredient> {
  $$IngredientsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$FrigoTable, List<FrigoData>> _frigoRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.frigo,
          aliasName:
              $_aliasNameGenerator(db.ingredients.id, db.frigo.ingredientId));

  $$FrigoTableProcessedTableManager get frigoRefs {
    final manager = $$FrigoTableTableManager($_db, $_db.frigo)
        .filter((f) => f.ingredientId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_frigoRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$RecetteIngredientsTable, List<RecetteIngredient>>
      _recetteIngredientsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.recetteIngredients,
              aliasName: $_aliasNameGenerator(
                  db.ingredients.id, db.recetteIngredients.ingredientId));

  $$RecetteIngredientsTableProcessedTableManager get recetteIngredientsRefs {
    final manager = $$RecetteIngredientsTableTableManager(
            $_db, $_db.recetteIngredients)
        .filter((f) => f.ingredientId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_recetteIngredientsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ShoppingListTable, List<ShoppingListData>>
      _shoppingListRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.shoppingList,
              aliasName: $_aliasNameGenerator(
                  db.ingredients.id, db.shoppingList.ingredientId));

  $$ShoppingListTableProcessedTableManager get shoppingListRefs {
    final manager = $$ShoppingListTableTableManager($_db, $_db.shoppingList)
        .filter((f) => f.ingredientId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_shoppingListRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$IngredientsTableFilterComposer
    extends Composer<_$AppDatabase, $IngredientsTable> {
  $$IngredientsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get caloriesPer100g => $composableBuilder(
      column: $table.caloriesPer100g,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get proteinsPer100g => $composableBuilder(
      column: $table.proteinsPer100g,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get fatsPer100g => $composableBuilder(
      column: $table.fatsPer100g, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get carbsPer100g => $composableBuilder(
      column: $table.carbsPer100g, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get fibersPer100g => $composableBuilder(
      column: $table.fibersPer100g, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get saltPer100g => $composableBuilder(
      column: $table.saltPer100g, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get densityGPerMl => $composableBuilder(
      column: $table.densityGPerMl, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get avgWeightPerUnitG => $composableBuilder(
      column: $table.avgWeightPerUnitG,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get barcode => $composableBuilder(
      column: $table.barcode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nutriscore => $composableBuilder(
      column: $table.nutriscore, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCustom => $composableBuilder(
      column: $table.isCustom, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  Expression<bool> frigoRefs(
      Expression<bool> Function($$FrigoTableFilterComposer f) f) {
    final $$FrigoTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.frigo,
        getReferencedColumn: (t) => t.ingredientId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FrigoTableFilterComposer(
              $db: $db,
              $table: $db.frigo,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> recetteIngredientsRefs(
      Expression<bool> Function($$RecetteIngredientsTableFilterComposer f) f) {
    final $$RecetteIngredientsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.recetteIngredients,
        getReferencedColumn: (t) => t.ingredientId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RecetteIngredientsTableFilterComposer(
              $db: $db,
              $table: $db.recetteIngredients,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> shoppingListRefs(
      Expression<bool> Function($$ShoppingListTableFilterComposer f) f) {
    final $$ShoppingListTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.shoppingList,
        getReferencedColumn: (t) => t.ingredientId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ShoppingListTableFilterComposer(
              $db: $db,
              $table: $db.shoppingList,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$IngredientsTableOrderingComposer
    extends Composer<_$AppDatabase, $IngredientsTable> {
  $$IngredientsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get caloriesPer100g => $composableBuilder(
      column: $table.caloriesPer100g,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get proteinsPer100g => $composableBuilder(
      column: $table.proteinsPer100g,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get fatsPer100g => $composableBuilder(
      column: $table.fatsPer100g, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get carbsPer100g => $composableBuilder(
      column: $table.carbsPer100g,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get fibersPer100g => $composableBuilder(
      column: $table.fibersPer100g,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get saltPer100g => $composableBuilder(
      column: $table.saltPer100g, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get densityGPerMl => $composableBuilder(
      column: $table.densityGPerMl,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get avgWeightPerUnitG => $composableBuilder(
      column: $table.avgWeightPerUnitG,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get barcode => $composableBuilder(
      column: $table.barcode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nutriscore => $composableBuilder(
      column: $table.nutriscore, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCustom => $composableBuilder(
      column: $table.isCustom, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$IngredientsTableAnnotationComposer
    extends Composer<_$AppDatabase, $IngredientsTable> {
  $$IngredientsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get caloriesPer100g => $composableBuilder(
      column: $table.caloriesPer100g, builder: (column) => column);

  GeneratedColumn<double> get proteinsPer100g => $composableBuilder(
      column: $table.proteinsPer100g, builder: (column) => column);

  GeneratedColumn<double> get fatsPer100g => $composableBuilder(
      column: $table.fatsPer100g, builder: (column) => column);

  GeneratedColumn<double> get carbsPer100g => $composableBuilder(
      column: $table.carbsPer100g, builder: (column) => column);

  GeneratedColumn<double> get fibersPer100g => $composableBuilder(
      column: $table.fibersPer100g, builder: (column) => column);

  GeneratedColumn<double> get saltPer100g => $composableBuilder(
      column: $table.saltPer100g, builder: (column) => column);

  GeneratedColumn<double> get densityGPerMl => $composableBuilder(
      column: $table.densityGPerMl, builder: (column) => column);

  GeneratedColumn<double> get avgWeightPerUnitG => $composableBuilder(
      column: $table.avgWeightPerUnitG, builder: (column) => column);

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get nutriscore => $composableBuilder(
      column: $table.nutriscore, builder: (column) => column);

  GeneratedColumn<bool> get isCustom =>
      $composableBuilder(column: $table.isCustom, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> frigoRefs<T extends Object>(
      Expression<T> Function($$FrigoTableAnnotationComposer a) f) {
    final $$FrigoTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.frigo,
        getReferencedColumn: (t) => t.ingredientId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FrigoTableAnnotationComposer(
              $db: $db,
              $table: $db.frigo,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> recetteIngredientsRefs<T extends Object>(
      Expression<T> Function($$RecetteIngredientsTableAnnotationComposer a) f) {
    final $$RecetteIngredientsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.recetteIngredients,
            getReferencedColumn: (t) => t.ingredientId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$RecetteIngredientsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.recetteIngredients,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> shoppingListRefs<T extends Object>(
      Expression<T> Function($$ShoppingListTableAnnotationComposer a) f) {
    final $$ShoppingListTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.shoppingList,
        getReferencedColumn: (t) => t.ingredientId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ShoppingListTableAnnotationComposer(
              $db: $db,
              $table: $db.shoppingList,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$IngredientsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $IngredientsTable,
    Ingredient,
    $$IngredientsTableFilterComposer,
    $$IngredientsTableOrderingComposer,
    $$IngredientsTableAnnotationComposer,
    $$IngredientsTableCreateCompanionBuilder,
    $$IngredientsTableUpdateCompanionBuilder,
    (Ingredient, $$IngredientsTableReferences),
    Ingredient,
    PrefetchHooks Function(
        {bool frigoRefs, bool recetteIngredientsRefs, bool shoppingListRefs})> {
  $$IngredientsTableTableManager(_$AppDatabase db, $IngredientsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IngredientsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IngredientsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IngredientsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<double> caloriesPer100g = const Value.absent(),
            Value<double> proteinsPer100g = const Value.absent(),
            Value<double> fatsPer100g = const Value.absent(),
            Value<double> carbsPer100g = const Value.absent(),
            Value<double> fibersPer100g = const Value.absent(),
            Value<double> saltPer100g = const Value.absent(),
            Value<double?> densityGPerMl = const Value.absent(),
            Value<double?> avgWeightPerUnitG = const Value.absent(),
            Value<String?> barcode = const Value.absent(),
            Value<String?> category = const Value.absent(),
            Value<String?> nutriscore = const Value.absent(),
            Value<bool> isCustom = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              IngredientsCompanion(
            id: id,
            name: name,
            caloriesPer100g: caloriesPer100g,
            proteinsPer100g: proteinsPer100g,
            fatsPer100g: fatsPer100g,
            carbsPer100g: carbsPer100g,
            fibersPer100g: fibersPer100g,
            saltPer100g: saltPer100g,
            densityGPerMl: densityGPerMl,
            avgWeightPerUnitG: avgWeightPerUnitG,
            barcode: barcode,
            category: category,
            nutriscore: nutriscore,
            isCustom: isCustom,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<double> caloriesPer100g = const Value.absent(),
            Value<double> proteinsPer100g = const Value.absent(),
            Value<double> fatsPer100g = const Value.absent(),
            Value<double> carbsPer100g = const Value.absent(),
            Value<double> fibersPer100g = const Value.absent(),
            Value<double> saltPer100g = const Value.absent(),
            Value<double?> densityGPerMl = const Value.absent(),
            Value<double?> avgWeightPerUnitG = const Value.absent(),
            Value<String?> barcode = const Value.absent(),
            Value<String?> category = const Value.absent(),
            Value<String?> nutriscore = const Value.absent(),
            Value<bool> isCustom = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              IngredientsCompanion.insert(
            id: id,
            name: name,
            caloriesPer100g: caloriesPer100g,
            proteinsPer100g: proteinsPer100g,
            fatsPer100g: fatsPer100g,
            carbsPer100g: carbsPer100g,
            fibersPer100g: fibersPer100g,
            saltPer100g: saltPer100g,
            densityGPerMl: densityGPerMl,
            avgWeightPerUnitG: avgWeightPerUnitG,
            barcode: barcode,
            category: category,
            nutriscore: nutriscore,
            isCustom: isCustom,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$IngredientsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {frigoRefs = false,
              recetteIngredientsRefs = false,
              shoppingListRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (frigoRefs) db.frigo,
                if (recetteIngredientsRefs) db.recetteIngredients,
                if (shoppingListRefs) db.shoppingList
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (frigoRefs)
                    await $_getPrefetchedData<Ingredient, $IngredientsTable,
                            FrigoData>(
                        currentTable: table,
                        referencedTable:
                            $$IngredientsTableReferences._frigoRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$IngredientsTableReferences(db, table, p0)
                                .frigoRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.ingredientId == item.id),
                        typedResults: items),
                  if (recetteIngredientsRefs)
                    await $_getPrefetchedData<Ingredient, $IngredientsTable,
                            RecetteIngredient>(
                        currentTable: table,
                        referencedTable: $$IngredientsTableReferences
                            ._recetteIngredientsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$IngredientsTableReferences(db, table, p0)
                                .recetteIngredientsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.ingredientId == item.id),
                        typedResults: items),
                  if (shoppingListRefs)
                    await $_getPrefetchedData<Ingredient, $IngredientsTable,
                            ShoppingListData>(
                        currentTable: table,
                        referencedTable: $$IngredientsTableReferences
                            ._shoppingListRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$IngredientsTableReferences(db, table, p0)
                                .shoppingListRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.ingredientId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$IngredientsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $IngredientsTable,
    Ingredient,
    $$IngredientsTableFilterComposer,
    $$IngredientsTableOrderingComposer,
    $$IngredientsTableAnnotationComposer,
    $$IngredientsTableCreateCompanionBuilder,
    $$IngredientsTableUpdateCompanionBuilder,
    (Ingredient, $$IngredientsTableReferences),
    Ingredient,
    PrefetchHooks Function(
        {bool frigoRefs, bool recetteIngredientsRefs, bool shoppingListRefs})>;
typedef $$FrigoTableCreateCompanionBuilder = FrigoCompanion Function({
  Value<int> id,
  required int ingredientId,
  Value<double> quantity,
  Value<String> unit,
  Value<DateTime?> bestBefore,
  Value<String> location,
  Value<DateTime> addedAt,
});
typedef $$FrigoTableUpdateCompanionBuilder = FrigoCompanion Function({
  Value<int> id,
  Value<int> ingredientId,
  Value<double> quantity,
  Value<String> unit,
  Value<DateTime?> bestBefore,
  Value<String> location,
  Value<DateTime> addedAt,
});

final class $$FrigoTableReferences
    extends BaseReferences<_$AppDatabase, $FrigoTable, FrigoData> {
  $$FrigoTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $IngredientsTable _ingredientIdTable(_$AppDatabase db) =>
      db.ingredients.createAlias(
          $_aliasNameGenerator(db.frigo.ingredientId, db.ingredients.id));

  $$IngredientsTableProcessedTableManager get ingredientId {
    final $_column = $_itemColumn<int>('ingredient_id')!;

    final manager = $$IngredientsTableTableManager($_db, $_db.ingredients)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ingredientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$FrigoTableFilterComposer extends Composer<_$AppDatabase, $FrigoTable> {
  $$FrigoTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get bestBefore => $composableBuilder(
      column: $table.bestBefore, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
      column: $table.addedAt, builder: (column) => ColumnFilters(column));

  $$IngredientsTableFilterComposer get ingredientId {
    final $$IngredientsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ingredientId,
        referencedTable: $db.ingredients,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$IngredientsTableFilterComposer(
              $db: $db,
              $table: $db.ingredients,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$FrigoTableOrderingComposer
    extends Composer<_$AppDatabase, $FrigoTable> {
  $$FrigoTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get bestBefore => $composableBuilder(
      column: $table.bestBefore, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
      column: $table.addedAt, builder: (column) => ColumnOrderings(column));

  $$IngredientsTableOrderingComposer get ingredientId {
    final $$IngredientsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ingredientId,
        referencedTable: $db.ingredients,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$IngredientsTableOrderingComposer(
              $db: $db,
              $table: $db.ingredients,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$FrigoTableAnnotationComposer
    extends Composer<_$AppDatabase, $FrigoTable> {
  $$FrigoTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<DateTime> get bestBefore => $composableBuilder(
      column: $table.bestBefore, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  $$IngredientsTableAnnotationComposer get ingredientId {
    final $$IngredientsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ingredientId,
        referencedTable: $db.ingredients,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$IngredientsTableAnnotationComposer(
              $db: $db,
              $table: $db.ingredients,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$FrigoTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FrigoTable,
    FrigoData,
    $$FrigoTableFilterComposer,
    $$FrigoTableOrderingComposer,
    $$FrigoTableAnnotationComposer,
    $$FrigoTableCreateCompanionBuilder,
    $$FrigoTableUpdateCompanionBuilder,
    (FrigoData, $$FrigoTableReferences),
    FrigoData,
    PrefetchHooks Function({bool ingredientId})> {
  $$FrigoTableTableManager(_$AppDatabase db, $FrigoTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FrigoTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FrigoTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FrigoTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> ingredientId = const Value.absent(),
            Value<double> quantity = const Value.absent(),
            Value<String> unit = const Value.absent(),
            Value<DateTime?> bestBefore = const Value.absent(),
            Value<String> location = const Value.absent(),
            Value<DateTime> addedAt = const Value.absent(),
          }) =>
              FrigoCompanion(
            id: id,
            ingredientId: ingredientId,
            quantity: quantity,
            unit: unit,
            bestBefore: bestBefore,
            location: location,
            addedAt: addedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int ingredientId,
            Value<double> quantity = const Value.absent(),
            Value<String> unit = const Value.absent(),
            Value<DateTime?> bestBefore = const Value.absent(),
            Value<String> location = const Value.absent(),
            Value<DateTime> addedAt = const Value.absent(),
          }) =>
              FrigoCompanion.insert(
            id: id,
            ingredientId: ingredientId,
            quantity: quantity,
            unit: unit,
            bestBefore: bestBefore,
            location: location,
            addedAt: addedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$FrigoTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({ingredientId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (ingredientId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.ingredientId,
                    referencedTable:
                        $$FrigoTableReferences._ingredientIdTable(db),
                    referencedColumn:
                        $$FrigoTableReferences._ingredientIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$FrigoTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FrigoTable,
    FrigoData,
    $$FrigoTableFilterComposer,
    $$FrigoTableOrderingComposer,
    $$FrigoTableAnnotationComposer,
    $$FrigoTableCreateCompanionBuilder,
    $$FrigoTableUpdateCompanionBuilder,
    (FrigoData, $$FrigoTableReferences),
    FrigoData,
    PrefetchHooks Function({bool ingredientId})>;
typedef $$RecettesTableCreateCompanionBuilder = RecettesCompanion Function({
  Value<int> id,
  required String name,
  Value<String?> instructions,
  Value<int> servings,
  Value<String?> notes,
  Value<String?> imageUrl,
  Value<String?> category,
  Value<DateTime> createdAt,
});
typedef $$RecettesTableUpdateCompanionBuilder = RecettesCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String?> instructions,
  Value<int> servings,
  Value<String?> notes,
  Value<String?> imageUrl,
  Value<String?> category,
  Value<DateTime> createdAt,
});

final class $$RecettesTableReferences
    extends BaseReferences<_$AppDatabase, $RecettesTable, Recette> {
  $$RecettesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RecetteIngredientsTable, List<RecetteIngredient>>
      _recetteIngredientsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.recetteIngredients,
              aliasName: $_aliasNameGenerator(
                  db.recettes.id, db.recetteIngredients.recetteId));

  $$RecetteIngredientsTableProcessedTableManager get recetteIngredientsRefs {
    final manager =
        $$RecetteIngredientsTableTableManager($_db, $_db.recetteIngredients)
            .filter((f) => f.recetteId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_recetteIngredientsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$MealPlanningTable, List<MealPlanningData>>
      _mealPlanningRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.mealPlanning,
          aliasName:
              $_aliasNameGenerator(db.recettes.id, db.mealPlanning.recetteId));

  $$MealPlanningTableProcessedTableManager get mealPlanningRefs {
    final manager = $$MealPlanningTableTableManager($_db, $_db.mealPlanning)
        .filter((f) => f.recetteId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_mealPlanningRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$RecettesTableFilterComposer
    extends Composer<_$AppDatabase, $RecettesTable> {
  $$RecettesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get instructions => $composableBuilder(
      column: $table.instructions, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get servings => $composableBuilder(
      column: $table.servings, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imageUrl => $composableBuilder(
      column: $table.imageUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  Expression<bool> recetteIngredientsRefs(
      Expression<bool> Function($$RecetteIngredientsTableFilterComposer f) f) {
    final $$RecetteIngredientsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.recetteIngredients,
        getReferencedColumn: (t) => t.recetteId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RecetteIngredientsTableFilterComposer(
              $db: $db,
              $table: $db.recetteIngredients,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> mealPlanningRefs(
      Expression<bool> Function($$MealPlanningTableFilterComposer f) f) {
    final $$MealPlanningTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.mealPlanning,
        getReferencedColumn: (t) => t.recetteId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MealPlanningTableFilterComposer(
              $db: $db,
              $table: $db.mealPlanning,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$RecettesTableOrderingComposer
    extends Composer<_$AppDatabase, $RecettesTable> {
  $$RecettesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get instructions => $composableBuilder(
      column: $table.instructions,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get servings => $composableBuilder(
      column: $table.servings, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imageUrl => $composableBuilder(
      column: $table.imageUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$RecettesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecettesTable> {
  $$RecettesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get instructions => $composableBuilder(
      column: $table.instructions, builder: (column) => column);

  GeneratedColumn<int> get servings =>
      $composableBuilder(column: $table.servings, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> recetteIngredientsRefs<T extends Object>(
      Expression<T> Function($$RecetteIngredientsTableAnnotationComposer a) f) {
    final $$RecetteIngredientsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.recetteIngredients,
            getReferencedColumn: (t) => t.recetteId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$RecetteIngredientsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.recetteIngredients,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> mealPlanningRefs<T extends Object>(
      Expression<T> Function($$MealPlanningTableAnnotationComposer a) f) {
    final $$MealPlanningTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.mealPlanning,
        getReferencedColumn: (t) => t.recetteId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MealPlanningTableAnnotationComposer(
              $db: $db,
              $table: $db.mealPlanning,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$RecettesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RecettesTable,
    Recette,
    $$RecettesTableFilterComposer,
    $$RecettesTableOrderingComposer,
    $$RecettesTableAnnotationComposer,
    $$RecettesTableCreateCompanionBuilder,
    $$RecettesTableUpdateCompanionBuilder,
    (Recette, $$RecettesTableReferences),
    Recette,
    PrefetchHooks Function(
        {bool recetteIngredientsRefs, bool mealPlanningRefs})> {
  $$RecettesTableTableManager(_$AppDatabase db, $RecettesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecettesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecettesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecettesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> instructions = const Value.absent(),
            Value<int> servings = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String?> imageUrl = const Value.absent(),
            Value<String?> category = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              RecettesCompanion(
            id: id,
            name: name,
            instructions: instructions,
            servings: servings,
            notes: notes,
            imageUrl: imageUrl,
            category: category,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<String?> instructions = const Value.absent(),
            Value<int> servings = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String?> imageUrl = const Value.absent(),
            Value<String?> category = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              RecettesCompanion.insert(
            id: id,
            name: name,
            instructions: instructions,
            servings: servings,
            notes: notes,
            imageUrl: imageUrl,
            category: category,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$RecettesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {recetteIngredientsRefs = false, mealPlanningRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (recetteIngredientsRefs) db.recetteIngredients,
                if (mealPlanningRefs) db.mealPlanning
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (recetteIngredientsRefs)
                    await $_getPrefetchedData<Recette, $RecettesTable,
                            RecetteIngredient>(
                        currentTable: table,
                        referencedTable: $$RecettesTableReferences
                            ._recetteIngredientsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$RecettesTableReferences(db, table, p0)
                                .recetteIngredientsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.recetteId == item.id),
                        typedResults: items),
                  if (mealPlanningRefs)
                    await $_getPrefetchedData<Recette, $RecettesTable,
                            MealPlanningData>(
                        currentTable: table,
                        referencedTable: $$RecettesTableReferences
                            ._mealPlanningRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$RecettesTableReferences(db, table, p0)
                                .mealPlanningRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.recetteId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$RecettesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RecettesTable,
    Recette,
    $$RecettesTableFilterComposer,
    $$RecettesTableOrderingComposer,
    $$RecettesTableAnnotationComposer,
    $$RecettesTableCreateCompanionBuilder,
    $$RecettesTableUpdateCompanionBuilder,
    (Recette, $$RecettesTableReferences),
    Recette,
    PrefetchHooks Function(
        {bool recetteIngredientsRefs, bool mealPlanningRefs})>;
typedef $$RecetteIngredientsTableCreateCompanionBuilder
    = RecetteIngredientsCompanion Function({
  Value<int> id,
  required int recetteId,
  required int ingredientId,
  Value<double> quantity,
  Value<String> unit,
  Value<double?> densityGPerMl,
  Value<double?> weightPerUnitG,
});
typedef $$RecetteIngredientsTableUpdateCompanionBuilder
    = RecetteIngredientsCompanion Function({
  Value<int> id,
  Value<int> recetteId,
  Value<int> ingredientId,
  Value<double> quantity,
  Value<String> unit,
  Value<double?> densityGPerMl,
  Value<double?> weightPerUnitG,
});

final class $$RecetteIngredientsTableReferences extends BaseReferences<
    _$AppDatabase, $RecetteIngredientsTable, RecetteIngredient> {
  $$RecetteIngredientsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $RecettesTable _recetteIdTable(_$AppDatabase db) =>
      db.recettes.createAlias($_aliasNameGenerator(
          db.recetteIngredients.recetteId, db.recettes.id));

  $$RecettesTableProcessedTableManager get recetteId {
    final $_column = $_itemColumn<int>('recette_id')!;

    final manager = $$RecettesTableTableManager($_db, $_db.recettes)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_recetteIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $IngredientsTable _ingredientIdTable(_$AppDatabase db) =>
      db.ingredients.createAlias($_aliasNameGenerator(
          db.recetteIngredients.ingredientId, db.ingredients.id));

  $$IngredientsTableProcessedTableManager get ingredientId {
    final $_column = $_itemColumn<int>('ingredient_id')!;

    final manager = $$IngredientsTableTableManager($_db, $_db.ingredients)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ingredientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$RecetteIngredientsTableFilterComposer
    extends Composer<_$AppDatabase, $RecetteIngredientsTable> {
  $$RecetteIngredientsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get densityGPerMl => $composableBuilder(
      column: $table.densityGPerMl, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get weightPerUnitG => $composableBuilder(
      column: $table.weightPerUnitG,
      builder: (column) => ColumnFilters(column));

  $$RecettesTableFilterComposer get recetteId {
    final $$RecettesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.recetteId,
        referencedTable: $db.recettes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RecettesTableFilterComposer(
              $db: $db,
              $table: $db.recettes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$IngredientsTableFilterComposer get ingredientId {
    final $$IngredientsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ingredientId,
        referencedTable: $db.ingredients,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$IngredientsTableFilterComposer(
              $db: $db,
              $table: $db.ingredients,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RecetteIngredientsTableOrderingComposer
    extends Composer<_$AppDatabase, $RecetteIngredientsTable> {
  $$RecetteIngredientsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get densityGPerMl => $composableBuilder(
      column: $table.densityGPerMl,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get weightPerUnitG => $composableBuilder(
      column: $table.weightPerUnitG,
      builder: (column) => ColumnOrderings(column));

  $$RecettesTableOrderingComposer get recetteId {
    final $$RecettesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.recetteId,
        referencedTable: $db.recettes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RecettesTableOrderingComposer(
              $db: $db,
              $table: $db.recettes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$IngredientsTableOrderingComposer get ingredientId {
    final $$IngredientsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ingredientId,
        referencedTable: $db.ingredients,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$IngredientsTableOrderingComposer(
              $db: $db,
              $table: $db.ingredients,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RecetteIngredientsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecetteIngredientsTable> {
  $$RecetteIngredientsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<double> get densityGPerMl => $composableBuilder(
      column: $table.densityGPerMl, builder: (column) => column);

  GeneratedColumn<double> get weightPerUnitG => $composableBuilder(
      column: $table.weightPerUnitG, builder: (column) => column);

  $$RecettesTableAnnotationComposer get recetteId {
    final $$RecettesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.recetteId,
        referencedTable: $db.recettes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RecettesTableAnnotationComposer(
              $db: $db,
              $table: $db.recettes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$IngredientsTableAnnotationComposer get ingredientId {
    final $$IngredientsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ingredientId,
        referencedTable: $db.ingredients,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$IngredientsTableAnnotationComposer(
              $db: $db,
              $table: $db.ingredients,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RecetteIngredientsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RecetteIngredientsTable,
    RecetteIngredient,
    $$RecetteIngredientsTableFilterComposer,
    $$RecetteIngredientsTableOrderingComposer,
    $$RecetteIngredientsTableAnnotationComposer,
    $$RecetteIngredientsTableCreateCompanionBuilder,
    $$RecetteIngredientsTableUpdateCompanionBuilder,
    (RecetteIngredient, $$RecetteIngredientsTableReferences),
    RecetteIngredient,
    PrefetchHooks Function({bool recetteId, bool ingredientId})> {
  $$RecetteIngredientsTableTableManager(
      _$AppDatabase db, $RecetteIngredientsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecetteIngredientsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecetteIngredientsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecetteIngredientsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> recetteId = const Value.absent(),
            Value<int> ingredientId = const Value.absent(),
            Value<double> quantity = const Value.absent(),
            Value<String> unit = const Value.absent(),
            Value<double?> densityGPerMl = const Value.absent(),
            Value<double?> weightPerUnitG = const Value.absent(),
          }) =>
              RecetteIngredientsCompanion(
            id: id,
            recetteId: recetteId,
            ingredientId: ingredientId,
            quantity: quantity,
            unit: unit,
            densityGPerMl: densityGPerMl,
            weightPerUnitG: weightPerUnitG,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int recetteId,
            required int ingredientId,
            Value<double> quantity = const Value.absent(),
            Value<String> unit = const Value.absent(),
            Value<double?> densityGPerMl = const Value.absent(),
            Value<double?> weightPerUnitG = const Value.absent(),
          }) =>
              RecetteIngredientsCompanion.insert(
            id: id,
            recetteId: recetteId,
            ingredientId: ingredientId,
            quantity: quantity,
            unit: unit,
            densityGPerMl: densityGPerMl,
            weightPerUnitG: weightPerUnitG,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$RecetteIngredientsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({recetteId = false, ingredientId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (recetteId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.recetteId,
                    referencedTable:
                        $$RecetteIngredientsTableReferences._recetteIdTable(db),
                    referencedColumn: $$RecetteIngredientsTableReferences
                        ._recetteIdTable(db)
                        .id,
                  ) as T;
                }
                if (ingredientId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.ingredientId,
                    referencedTable: $$RecetteIngredientsTableReferences
                        ._ingredientIdTable(db),
                    referencedColumn: $$RecetteIngredientsTableReferences
                        ._ingredientIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$RecetteIngredientsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RecetteIngredientsTable,
    RecetteIngredient,
    $$RecetteIngredientsTableFilterComposer,
    $$RecetteIngredientsTableOrderingComposer,
    $$RecetteIngredientsTableAnnotationComposer,
    $$RecetteIngredientsTableCreateCompanionBuilder,
    $$RecetteIngredientsTableUpdateCompanionBuilder,
    (RecetteIngredient, $$RecetteIngredientsTableReferences),
    RecetteIngredient,
    PrefetchHooks Function({bool recetteId, bool ingredientId})>;
typedef $$UserProfilesTableCreateCompanionBuilder = UserProfilesCompanion
    Function({
  Value<int> id,
  required String name,
  required String userId,
  required String sex,
  required int age,
  required double heightCm,
  required double weightKg,
  Value<double> eaterMultiplier,
  Value<String> activityLevel,
  Value<double?> bmr,
  Value<double?> tdee,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$UserProfilesTableUpdateCompanionBuilder = UserProfilesCompanion
    Function({
  Value<int> id,
  Value<String> name,
  Value<String> userId,
  Value<String> sex,
  Value<int> age,
  Value<double> heightCm,
  Value<double> weightKg,
  Value<double> eaterMultiplier,
  Value<String> activityLevel,
  Value<double?> bmr,
  Value<double?> tdee,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

final class $$UserProfilesTableReferences
    extends BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfile> {
  $$UserProfilesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$GroupMembersTable, List<GroupMember>>
      _groupMembersRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.groupMembers,
              aliasName: $_aliasNameGenerator(
                  db.userProfiles.id, db.groupMembers.userProfileId));

  $$GroupMembersTableProcessedTableManager get groupMembersRefs {
    final manager = $$GroupMembersTableTableManager($_db, $_db.groupMembers)
        .filter((f) => f.userProfileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_groupMembersRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$MealPlanningTable, List<MealPlanningData>>
      _mealPlanningRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.mealPlanning,
              aliasName: $_aliasNameGenerator(
                  db.userProfiles.id, db.mealPlanning.userProfileId));

  $$MealPlanningTableProcessedTableManager get mealPlanningRefs {
    final manager = $$MealPlanningTableTableManager($_db, $_db.mealPlanning)
        .filter((f) => f.userProfileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_mealPlanningRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$CalorieTrackingTable, List<CalorieTrackingData>>
      _calorieTrackingRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.calorieTracking,
              aliasName: $_aliasNameGenerator(
                  db.userProfiles.id, db.calorieTracking.userProfileId));

  $$CalorieTrackingTableProcessedTableManager get calorieTrackingRefs {
    final manager = $$CalorieTrackingTableTableManager(
            $_db, $_db.calorieTracking)
        .filter((f) => f.userProfileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_calorieTrackingRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$UserProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sex => $composableBuilder(
      column: $table.sex, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get age => $composableBuilder(
      column: $table.age, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get heightCm => $composableBuilder(
      column: $table.heightCm, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get weightKg => $composableBuilder(
      column: $table.weightKg, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get eaterMultiplier => $composableBuilder(
      column: $table.eaterMultiplier,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get activityLevel => $composableBuilder(
      column: $table.activityLevel, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get bmr => $composableBuilder(
      column: $table.bmr, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get tdee => $composableBuilder(
      column: $table.tdee, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> groupMembersRefs(
      Expression<bool> Function($$GroupMembersTableFilterComposer f) f) {
    final $$GroupMembersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.groupMembers,
        getReferencedColumn: (t) => t.userProfileId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupMembersTableFilterComposer(
              $db: $db,
              $table: $db.groupMembers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> mealPlanningRefs(
      Expression<bool> Function($$MealPlanningTableFilterComposer f) f) {
    final $$MealPlanningTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.mealPlanning,
        getReferencedColumn: (t) => t.userProfileId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MealPlanningTableFilterComposer(
              $db: $db,
              $table: $db.mealPlanning,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> calorieTrackingRefs(
      Expression<bool> Function($$CalorieTrackingTableFilterComposer f) f) {
    final $$CalorieTrackingTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.calorieTracking,
        getReferencedColumn: (t) => t.userProfileId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CalorieTrackingTableFilterComposer(
              $db: $db,
              $table: $db.calorieTracking,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$UserProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sex => $composableBuilder(
      column: $table.sex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get age => $composableBuilder(
      column: $table.age, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get heightCm => $composableBuilder(
      column: $table.heightCm, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get weightKg => $composableBuilder(
      column: $table.weightKg, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get eaterMultiplier => $composableBuilder(
      column: $table.eaterMultiplier,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get activityLevel => $composableBuilder(
      column: $table.activityLevel,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get bmr => $composableBuilder(
      column: $table.bmr, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get tdee => $composableBuilder(
      column: $table.tdee, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$UserProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get sex =>
      $composableBuilder(column: $table.sex, builder: (column) => column);

  GeneratedColumn<int> get age =>
      $composableBuilder(column: $table.age, builder: (column) => column);

  GeneratedColumn<double> get heightCm =>
      $composableBuilder(column: $table.heightCm, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<double> get eaterMultiplier => $composableBuilder(
      column: $table.eaterMultiplier, builder: (column) => column);

  GeneratedColumn<String> get activityLevel => $composableBuilder(
      column: $table.activityLevel, builder: (column) => column);

  GeneratedColumn<double> get bmr =>
      $composableBuilder(column: $table.bmr, builder: (column) => column);

  GeneratedColumn<double> get tdee =>
      $composableBuilder(column: $table.tdee, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> groupMembersRefs<T extends Object>(
      Expression<T> Function($$GroupMembersTableAnnotationComposer a) f) {
    final $$GroupMembersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.groupMembers,
        getReferencedColumn: (t) => t.userProfileId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupMembersTableAnnotationComposer(
              $db: $db,
              $table: $db.groupMembers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> mealPlanningRefs<T extends Object>(
      Expression<T> Function($$MealPlanningTableAnnotationComposer a) f) {
    final $$MealPlanningTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.mealPlanning,
        getReferencedColumn: (t) => t.userProfileId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MealPlanningTableAnnotationComposer(
              $db: $db,
              $table: $db.mealPlanning,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> calorieTrackingRefs<T extends Object>(
      Expression<T> Function($$CalorieTrackingTableAnnotationComposer a) f) {
    final $$CalorieTrackingTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.calorieTracking,
        getReferencedColumn: (t) => t.userProfileId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CalorieTrackingTableAnnotationComposer(
              $db: $db,
              $table: $db.calorieTracking,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$UserProfilesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UserProfilesTable,
    UserProfile,
    $$UserProfilesTableFilterComposer,
    $$UserProfilesTableOrderingComposer,
    $$UserProfilesTableAnnotationComposer,
    $$UserProfilesTableCreateCompanionBuilder,
    $$UserProfilesTableUpdateCompanionBuilder,
    (UserProfile, $$UserProfilesTableReferences),
    UserProfile,
    PrefetchHooks Function(
        {bool groupMembersRefs,
        bool mealPlanningRefs,
        bool calorieTrackingRefs})> {
  $$UserProfilesTableTableManager(_$AppDatabase db, $UserProfilesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> sex = const Value.absent(),
            Value<int> age = const Value.absent(),
            Value<double> heightCm = const Value.absent(),
            Value<double> weightKg = const Value.absent(),
            Value<double> eaterMultiplier = const Value.absent(),
            Value<String> activityLevel = const Value.absent(),
            Value<double?> bmr = const Value.absent(),
            Value<double?> tdee = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              UserProfilesCompanion(
            id: id,
            name: name,
            userId: userId,
            sex: sex,
            age: age,
            heightCm: heightCm,
            weightKg: weightKg,
            eaterMultiplier: eaterMultiplier,
            activityLevel: activityLevel,
            bmr: bmr,
            tdee: tdee,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required String userId,
            required String sex,
            required int age,
            required double heightCm,
            required double weightKg,
            Value<double> eaterMultiplier = const Value.absent(),
            Value<String> activityLevel = const Value.absent(),
            Value<double?> bmr = const Value.absent(),
            Value<double?> tdee = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              UserProfilesCompanion.insert(
            id: id,
            name: name,
            userId: userId,
            sex: sex,
            age: age,
            heightCm: heightCm,
            weightKg: weightKg,
            eaterMultiplier: eaterMultiplier,
            activityLevel: activityLevel,
            bmr: bmr,
            tdee: tdee,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$UserProfilesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {groupMembersRefs = false,
              mealPlanningRefs = false,
              calorieTrackingRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (groupMembersRefs) db.groupMembers,
                if (mealPlanningRefs) db.mealPlanning,
                if (calorieTrackingRefs) db.calorieTracking
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (groupMembersRefs)
                    await $_getPrefetchedData<UserProfile, $UserProfilesTable,
                            GroupMember>(
                        currentTable: table,
                        referencedTable: $$UserProfilesTableReferences
                            ._groupMembersRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$UserProfilesTableReferences(db, table, p0)
                                .groupMembersRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.userProfileId == item.id),
                        typedResults: items),
                  if (mealPlanningRefs)
                    await $_getPrefetchedData<UserProfile, $UserProfilesTable, MealPlanningData>(
                        currentTable: table,
                        referencedTable: $$UserProfilesTableReferences
                            ._mealPlanningRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$UserProfilesTableReferences(db, table, p0)
                                .mealPlanningRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.userProfileId == item.id),
                        typedResults: items),
                  if (calorieTrackingRefs)
                    await $_getPrefetchedData<UserProfile, $UserProfilesTable,
                            CalorieTrackingData>(
                        currentTable: table,
                        referencedTable: $$UserProfilesTableReferences
                            ._calorieTrackingRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$UserProfilesTableReferences(db, table, p0)
                                .calorieTrackingRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.userProfileId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$UserProfilesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UserProfilesTable,
    UserProfile,
    $$UserProfilesTableFilterComposer,
    $$UserProfilesTableOrderingComposer,
    $$UserProfilesTableAnnotationComposer,
    $$UserProfilesTableCreateCompanionBuilder,
    $$UserProfilesTableUpdateCompanionBuilder,
    (UserProfile, $$UserProfilesTableReferences),
    UserProfile,
    PrefetchHooks Function(
        {bool groupMembersRefs,
        bool mealPlanningRefs,
        bool calorieTrackingRefs})>;
typedef $$GroupsTableCreateCompanionBuilder = GroupsCompanion Function({
  Value<int> id,
  required String groupId,
  required String name,
  Value<String?> description,
  Value<DateTime> createdAt,
});
typedef $$GroupsTableUpdateCompanionBuilder = GroupsCompanion Function({
  Value<int> id,
  Value<String> groupId,
  Value<String> name,
  Value<String?> description,
  Value<DateTime> createdAt,
});

final class $$GroupsTableReferences
    extends BaseReferences<_$AppDatabase, $GroupsTable, Group> {
  $$GroupsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$GroupMembersTable, List<GroupMember>>
      _groupMembersRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.groupMembers,
              aliasName:
                  $_aliasNameGenerator(db.groups.id, db.groupMembers.groupId));

  $$GroupMembersTableProcessedTableManager get groupMembersRefs {
    final manager = $$GroupMembersTableTableManager($_db, $_db.groupMembers)
        .filter((f) => f.groupId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_groupMembersRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$MealPlanningTable, List<MealPlanningData>>
      _mealPlanningRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.mealPlanning,
              aliasName:
                  $_aliasNameGenerator(db.groups.id, db.mealPlanning.groupId));

  $$MealPlanningTableProcessedTableManager get mealPlanningRefs {
    final manager = $$MealPlanningTableTableManager($_db, $_db.mealPlanning)
        .filter((f) => f.groupId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_mealPlanningRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ShoppingListTable, List<ShoppingListData>>
      _shoppingListRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.shoppingList,
              aliasName:
                  $_aliasNameGenerator(db.groups.id, db.shoppingList.groupId));

  $$ShoppingListTableProcessedTableManager get shoppingListRefs {
    final manager = $$ShoppingListTableTableManager($_db, $_db.shoppingList)
        .filter((f) => f.groupId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_shoppingListRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$GroupsTableFilterComposer
    extends Composer<_$AppDatabase, $GroupsTable> {
  $$GroupsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get groupId => $composableBuilder(
      column: $table.groupId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  Expression<bool> groupMembersRefs(
      Expression<bool> Function($$GroupMembersTableFilterComposer f) f) {
    final $$GroupMembersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.groupMembers,
        getReferencedColumn: (t) => t.groupId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupMembersTableFilterComposer(
              $db: $db,
              $table: $db.groupMembers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> mealPlanningRefs(
      Expression<bool> Function($$MealPlanningTableFilterComposer f) f) {
    final $$MealPlanningTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.mealPlanning,
        getReferencedColumn: (t) => t.groupId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MealPlanningTableFilterComposer(
              $db: $db,
              $table: $db.mealPlanning,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> shoppingListRefs(
      Expression<bool> Function($$ShoppingListTableFilterComposer f) f) {
    final $$ShoppingListTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.shoppingList,
        getReferencedColumn: (t) => t.groupId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ShoppingListTableFilterComposer(
              $db: $db,
              $table: $db.shoppingList,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$GroupsTableOrderingComposer
    extends Composer<_$AppDatabase, $GroupsTable> {
  $$GroupsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get groupId => $composableBuilder(
      column: $table.groupId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$GroupsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GroupsTable> {
  $$GroupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> groupMembersRefs<T extends Object>(
      Expression<T> Function($$GroupMembersTableAnnotationComposer a) f) {
    final $$GroupMembersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.groupMembers,
        getReferencedColumn: (t) => t.groupId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupMembersTableAnnotationComposer(
              $db: $db,
              $table: $db.groupMembers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> mealPlanningRefs<T extends Object>(
      Expression<T> Function($$MealPlanningTableAnnotationComposer a) f) {
    final $$MealPlanningTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.mealPlanning,
        getReferencedColumn: (t) => t.groupId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MealPlanningTableAnnotationComposer(
              $db: $db,
              $table: $db.mealPlanning,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> shoppingListRefs<T extends Object>(
      Expression<T> Function($$ShoppingListTableAnnotationComposer a) f) {
    final $$ShoppingListTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.shoppingList,
        getReferencedColumn: (t) => t.groupId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ShoppingListTableAnnotationComposer(
              $db: $db,
              $table: $db.shoppingList,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$GroupsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GroupsTable,
    Group,
    $$GroupsTableFilterComposer,
    $$GroupsTableOrderingComposer,
    $$GroupsTableAnnotationComposer,
    $$GroupsTableCreateCompanionBuilder,
    $$GroupsTableUpdateCompanionBuilder,
    (Group, $$GroupsTableReferences),
    Group,
    PrefetchHooks Function(
        {bool groupMembersRefs,
        bool mealPlanningRefs,
        bool shoppingListRefs})> {
  $$GroupsTableTableManager(_$AppDatabase db, $GroupsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GroupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GroupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GroupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> groupId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              GroupsCompanion(
            id: id,
            groupId: groupId,
            name: name,
            description: description,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String groupId,
            required String name,
            Value<String?> description = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              GroupsCompanion.insert(
            id: id,
            groupId: groupId,
            name: name,
            description: description,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$GroupsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {groupMembersRefs = false,
              mealPlanningRefs = false,
              shoppingListRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (groupMembersRefs) db.groupMembers,
                if (mealPlanningRefs) db.mealPlanning,
                if (shoppingListRefs) db.shoppingList
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (groupMembersRefs)
                    await $_getPrefetchedData<Group, $GroupsTable, GroupMember>(
                        currentTable: table,
                        referencedTable:
                            $$GroupsTableReferences._groupMembersRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$GroupsTableReferences(db, table, p0)
                                .groupMembersRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.groupId == item.id),
                        typedResults: items),
                  if (mealPlanningRefs)
                    await $_getPrefetchedData<Group, $GroupsTable,
                            MealPlanningData>(
                        currentTable: table,
                        referencedTable:
                            $$GroupsTableReferences._mealPlanningRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$GroupsTableReferences(db, table, p0)
                                .mealPlanningRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.groupId == item.id),
                        typedResults: items),
                  if (shoppingListRefs)
                    await $_getPrefetchedData<Group, $GroupsTable,
                            ShoppingListData>(
                        currentTable: table,
                        referencedTable:
                            $$GroupsTableReferences._shoppingListRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$GroupsTableReferences(db, table, p0)
                                .shoppingListRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.groupId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$GroupsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $GroupsTable,
    Group,
    $$GroupsTableFilterComposer,
    $$GroupsTableOrderingComposer,
    $$GroupsTableAnnotationComposer,
    $$GroupsTableCreateCompanionBuilder,
    $$GroupsTableUpdateCompanionBuilder,
    (Group, $$GroupsTableReferences),
    Group,
    PrefetchHooks Function(
        {bool groupMembersRefs, bool mealPlanningRefs, bool shoppingListRefs})>;
typedef $$GroupMembersTableCreateCompanionBuilder = GroupMembersCompanion
    Function({
  required int id,
  required int groupId,
  required int userProfileId,
  Value<String> role,
  Value<DateTime> joinedAt,
  Value<int> rowid,
});
typedef $$GroupMembersTableUpdateCompanionBuilder = GroupMembersCompanion
    Function({
  Value<int> id,
  Value<int> groupId,
  Value<int> userProfileId,
  Value<String> role,
  Value<DateTime> joinedAt,
  Value<int> rowid,
});

final class $$GroupMembersTableReferences
    extends BaseReferences<_$AppDatabase, $GroupMembersTable, GroupMember> {
  $$GroupMembersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GroupsTable _groupIdTable(_$AppDatabase db) => db.groups
      .createAlias($_aliasNameGenerator(db.groupMembers.groupId, db.groups.id));

  $$GroupsTableProcessedTableManager get groupId {
    final $_column = $_itemColumn<int>('group_id')!;

    final manager = $$GroupsTableTableManager($_db, $_db.groups)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_groupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $UserProfilesTable _userProfileIdTable(_$AppDatabase db) =>
      db.userProfiles.createAlias($_aliasNameGenerator(
          db.groupMembers.userProfileId, db.userProfiles.id));

  $$UserProfilesTableProcessedTableManager get userProfileId {
    final $_column = $_itemColumn<int>('user_profile_id')!;

    final manager = $$UserProfilesTableTableManager($_db, $_db.userProfiles)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userProfileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$GroupMembersTableFilterComposer
    extends Composer<_$AppDatabase, $GroupMembersTable> {
  $$GroupMembersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get joinedAt => $composableBuilder(
      column: $table.joinedAt, builder: (column) => ColumnFilters(column));

  $$GroupsTableFilterComposer get groupId {
    final $$GroupsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.groupId,
        referencedTable: $db.groups,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupsTableFilterComposer(
              $db: $db,
              $table: $db.groups,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$UserProfilesTableFilterComposer get userProfileId {
    final $$UserProfilesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userProfileId,
        referencedTable: $db.userProfiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UserProfilesTableFilterComposer(
              $db: $db,
              $table: $db.userProfiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$GroupMembersTableOrderingComposer
    extends Composer<_$AppDatabase, $GroupMembersTable> {
  $$GroupMembersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get joinedAt => $composableBuilder(
      column: $table.joinedAt, builder: (column) => ColumnOrderings(column));

  $$GroupsTableOrderingComposer get groupId {
    final $$GroupsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.groupId,
        referencedTable: $db.groups,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupsTableOrderingComposer(
              $db: $db,
              $table: $db.groups,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$UserProfilesTableOrderingComposer get userProfileId {
    final $$UserProfilesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userProfileId,
        referencedTable: $db.userProfiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UserProfilesTableOrderingComposer(
              $db: $db,
              $table: $db.userProfiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$GroupMembersTableAnnotationComposer
    extends Composer<_$AppDatabase, $GroupMembersTable> {
  $$GroupMembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<DateTime> get joinedAt =>
      $composableBuilder(column: $table.joinedAt, builder: (column) => column);

  $$GroupsTableAnnotationComposer get groupId {
    final $$GroupsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.groupId,
        referencedTable: $db.groups,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupsTableAnnotationComposer(
              $db: $db,
              $table: $db.groups,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$UserProfilesTableAnnotationComposer get userProfileId {
    final $$UserProfilesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userProfileId,
        referencedTable: $db.userProfiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UserProfilesTableAnnotationComposer(
              $db: $db,
              $table: $db.userProfiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$GroupMembersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GroupMembersTable,
    GroupMember,
    $$GroupMembersTableFilterComposer,
    $$GroupMembersTableOrderingComposer,
    $$GroupMembersTableAnnotationComposer,
    $$GroupMembersTableCreateCompanionBuilder,
    $$GroupMembersTableUpdateCompanionBuilder,
    (GroupMember, $$GroupMembersTableReferences),
    GroupMember,
    PrefetchHooks Function({bool groupId, bool userProfileId})> {
  $$GroupMembersTableTableManager(_$AppDatabase db, $GroupMembersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GroupMembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GroupMembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GroupMembersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> groupId = const Value.absent(),
            Value<int> userProfileId = const Value.absent(),
            Value<String> role = const Value.absent(),
            Value<DateTime> joinedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GroupMembersCompanion(
            id: id,
            groupId: groupId,
            userProfileId: userProfileId,
            role: role,
            joinedAt: joinedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required int id,
            required int groupId,
            required int userProfileId,
            Value<String> role = const Value.absent(),
            Value<DateTime> joinedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GroupMembersCompanion.insert(
            id: id,
            groupId: groupId,
            userProfileId: userProfileId,
            role: role,
            joinedAt: joinedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$GroupMembersTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({groupId = false, userProfileId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (groupId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.groupId,
                    referencedTable:
                        $$GroupMembersTableReferences._groupIdTable(db),
                    referencedColumn:
                        $$GroupMembersTableReferences._groupIdTable(db).id,
                  ) as T;
                }
                if (userProfileId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.userProfileId,
                    referencedTable:
                        $$GroupMembersTableReferences._userProfileIdTable(db),
                    referencedColumn: $$GroupMembersTableReferences
                        ._userProfileIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$GroupMembersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $GroupMembersTable,
    GroupMember,
    $$GroupMembersTableFilterComposer,
    $$GroupMembersTableOrderingComposer,
    $$GroupMembersTableAnnotationComposer,
    $$GroupMembersTableCreateCompanionBuilder,
    $$GroupMembersTableUpdateCompanionBuilder,
    (GroupMember, $$GroupMembersTableReferences),
    GroupMember,
    PrefetchHooks Function({bool groupId, bool userProfileId})>;
typedef $$MealPlanningTableCreateCompanionBuilder = MealPlanningCompanion
    Function({
  Value<int> id,
  required DateTime date,
  required String mealType,
  Value<int?> recetteId,
  Value<int> servings,
  Value<int?> userProfileId,
  Value<int?> groupId,
  Value<String?> eaters,
  Value<String?> modifiedIngredients,
  Value<double?> modifiedCalories,
  Value<double?> modifiedProteins,
  Value<double?> modifiedFats,
  Value<double?> modifiedCarbs,
  Value<double?> modifiedFibers,
  Value<String?> notes,
  Value<DateTime> createdAt,
});
typedef $$MealPlanningTableUpdateCompanionBuilder = MealPlanningCompanion
    Function({
  Value<int> id,
  Value<DateTime> date,
  Value<String> mealType,
  Value<int?> recetteId,
  Value<int> servings,
  Value<int?> userProfileId,
  Value<int?> groupId,
  Value<String?> eaters,
  Value<String?> modifiedIngredients,
  Value<double?> modifiedCalories,
  Value<double?> modifiedProteins,
  Value<double?> modifiedFats,
  Value<double?> modifiedCarbs,
  Value<double?> modifiedFibers,
  Value<String?> notes,
  Value<DateTime> createdAt,
});

final class $$MealPlanningTableReferences extends BaseReferences<_$AppDatabase,
    $MealPlanningTable, MealPlanningData> {
  $$MealPlanningTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RecettesTable _recetteIdTable(_$AppDatabase db) =>
      db.recettes.createAlias(
          $_aliasNameGenerator(db.mealPlanning.recetteId, db.recettes.id));

  $$RecettesTableProcessedTableManager? get recetteId {
    final $_column = $_itemColumn<int>('recette_id');
    if ($_column == null) return null;
    final manager = $$RecettesTableTableManager($_db, $_db.recettes)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_recetteIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $UserProfilesTable _userProfileIdTable(_$AppDatabase db) =>
      db.userProfiles.createAlias($_aliasNameGenerator(
          db.mealPlanning.userProfileId, db.userProfiles.id));

  $$UserProfilesTableProcessedTableManager? get userProfileId {
    final $_column = $_itemColumn<int>('user_profile_id');
    if ($_column == null) return null;
    final manager = $$UserProfilesTableTableManager($_db, $_db.userProfiles)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userProfileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $GroupsTable _groupIdTable(_$AppDatabase db) => db.groups
      .createAlias($_aliasNameGenerator(db.mealPlanning.groupId, db.groups.id));

  $$GroupsTableProcessedTableManager? get groupId {
    final $_column = $_itemColumn<int>('group_id');
    if ($_column == null) return null;
    final manager = $$GroupsTableTableManager($_db, $_db.groups)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_groupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$CalorieTrackingTable, List<CalorieTrackingData>>
      _calorieTrackingRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.calorieTracking,
              aliasName: $_aliasNameGenerator(
                  db.mealPlanning.id, db.calorieTracking.mealPlanningId));

  $$CalorieTrackingTableProcessedTableManager get calorieTrackingRefs {
    final manager = $$CalorieTrackingTableTableManager(
            $_db, $_db.calorieTracking)
        .filter((f) => f.mealPlanningId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_calorieTrackingRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$MealPlanningTableFilterComposer
    extends Composer<_$AppDatabase, $MealPlanningTable> {
  $$MealPlanningTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mealType => $composableBuilder(
      column: $table.mealType, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get servings => $composableBuilder(
      column: $table.servings, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get eaters => $composableBuilder(
      column: $table.eaters, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get modifiedIngredients => $composableBuilder(
      column: $table.modifiedIngredients,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get modifiedCalories => $composableBuilder(
      column: $table.modifiedCalories,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get modifiedProteins => $composableBuilder(
      column: $table.modifiedProteins,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get modifiedFats => $composableBuilder(
      column: $table.modifiedFats, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get modifiedCarbs => $composableBuilder(
      column: $table.modifiedCarbs, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get modifiedFibers => $composableBuilder(
      column: $table.modifiedFibers,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$RecettesTableFilterComposer get recetteId {
    final $$RecettesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.recetteId,
        referencedTable: $db.recettes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RecettesTableFilterComposer(
              $db: $db,
              $table: $db.recettes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$UserProfilesTableFilterComposer get userProfileId {
    final $$UserProfilesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userProfileId,
        referencedTable: $db.userProfiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UserProfilesTableFilterComposer(
              $db: $db,
              $table: $db.userProfiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$GroupsTableFilterComposer get groupId {
    final $$GroupsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.groupId,
        referencedTable: $db.groups,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupsTableFilterComposer(
              $db: $db,
              $table: $db.groups,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> calorieTrackingRefs(
      Expression<bool> Function($$CalorieTrackingTableFilterComposer f) f) {
    final $$CalorieTrackingTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.calorieTracking,
        getReferencedColumn: (t) => t.mealPlanningId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CalorieTrackingTableFilterComposer(
              $db: $db,
              $table: $db.calorieTracking,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$MealPlanningTableOrderingComposer
    extends Composer<_$AppDatabase, $MealPlanningTable> {
  $$MealPlanningTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mealType => $composableBuilder(
      column: $table.mealType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get servings => $composableBuilder(
      column: $table.servings, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get eaters => $composableBuilder(
      column: $table.eaters, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get modifiedIngredients => $composableBuilder(
      column: $table.modifiedIngredients,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get modifiedCalories => $composableBuilder(
      column: $table.modifiedCalories,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get modifiedProteins => $composableBuilder(
      column: $table.modifiedProteins,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get modifiedFats => $composableBuilder(
      column: $table.modifiedFats,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get modifiedCarbs => $composableBuilder(
      column: $table.modifiedCarbs,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get modifiedFibers => $composableBuilder(
      column: $table.modifiedFibers,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$RecettesTableOrderingComposer get recetteId {
    final $$RecettesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.recetteId,
        referencedTable: $db.recettes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RecettesTableOrderingComposer(
              $db: $db,
              $table: $db.recettes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$UserProfilesTableOrderingComposer get userProfileId {
    final $$UserProfilesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userProfileId,
        referencedTable: $db.userProfiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UserProfilesTableOrderingComposer(
              $db: $db,
              $table: $db.userProfiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$GroupsTableOrderingComposer get groupId {
    final $$GroupsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.groupId,
        referencedTable: $db.groups,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupsTableOrderingComposer(
              $db: $db,
              $table: $db.groups,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MealPlanningTableAnnotationComposer
    extends Composer<_$AppDatabase, $MealPlanningTable> {
  $$MealPlanningTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get mealType =>
      $composableBuilder(column: $table.mealType, builder: (column) => column);

  GeneratedColumn<int> get servings =>
      $composableBuilder(column: $table.servings, builder: (column) => column);

  GeneratedColumn<String> get eaters =>
      $composableBuilder(column: $table.eaters, builder: (column) => column);

  GeneratedColumn<String> get modifiedIngredients => $composableBuilder(
      column: $table.modifiedIngredients, builder: (column) => column);

  GeneratedColumn<double> get modifiedCalories => $composableBuilder(
      column: $table.modifiedCalories, builder: (column) => column);

  GeneratedColumn<double> get modifiedProteins => $composableBuilder(
      column: $table.modifiedProteins, builder: (column) => column);

  GeneratedColumn<double> get modifiedFats => $composableBuilder(
      column: $table.modifiedFats, builder: (column) => column);

  GeneratedColumn<double> get modifiedCarbs => $composableBuilder(
      column: $table.modifiedCarbs, builder: (column) => column);

  GeneratedColumn<double> get modifiedFibers => $composableBuilder(
      column: $table.modifiedFibers, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$RecettesTableAnnotationComposer get recetteId {
    final $$RecettesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.recetteId,
        referencedTable: $db.recettes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RecettesTableAnnotationComposer(
              $db: $db,
              $table: $db.recettes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$UserProfilesTableAnnotationComposer get userProfileId {
    final $$UserProfilesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userProfileId,
        referencedTable: $db.userProfiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UserProfilesTableAnnotationComposer(
              $db: $db,
              $table: $db.userProfiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$GroupsTableAnnotationComposer get groupId {
    final $$GroupsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.groupId,
        referencedTable: $db.groups,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupsTableAnnotationComposer(
              $db: $db,
              $table: $db.groups,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> calorieTrackingRefs<T extends Object>(
      Expression<T> Function($$CalorieTrackingTableAnnotationComposer a) f) {
    final $$CalorieTrackingTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.calorieTracking,
        getReferencedColumn: (t) => t.mealPlanningId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CalorieTrackingTableAnnotationComposer(
              $db: $db,
              $table: $db.calorieTracking,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$MealPlanningTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MealPlanningTable,
    MealPlanningData,
    $$MealPlanningTableFilterComposer,
    $$MealPlanningTableOrderingComposer,
    $$MealPlanningTableAnnotationComposer,
    $$MealPlanningTableCreateCompanionBuilder,
    $$MealPlanningTableUpdateCompanionBuilder,
    (MealPlanningData, $$MealPlanningTableReferences),
    MealPlanningData,
    PrefetchHooks Function(
        {bool recetteId,
        bool userProfileId,
        bool groupId,
        bool calorieTrackingRefs})> {
  $$MealPlanningTableTableManager(_$AppDatabase db, $MealPlanningTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MealPlanningTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MealPlanningTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MealPlanningTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<String> mealType = const Value.absent(),
            Value<int?> recetteId = const Value.absent(),
            Value<int> servings = const Value.absent(),
            Value<int?> userProfileId = const Value.absent(),
            Value<int?> groupId = const Value.absent(),
            Value<String?> eaters = const Value.absent(),
            Value<String?> modifiedIngredients = const Value.absent(),
            Value<double?> modifiedCalories = const Value.absent(),
            Value<double?> modifiedProteins = const Value.absent(),
            Value<double?> modifiedFats = const Value.absent(),
            Value<double?> modifiedCarbs = const Value.absent(),
            Value<double?> modifiedFibers = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              MealPlanningCompanion(
            id: id,
            date: date,
            mealType: mealType,
            recetteId: recetteId,
            servings: servings,
            userProfileId: userProfileId,
            groupId: groupId,
            eaters: eaters,
            modifiedIngredients: modifiedIngredients,
            modifiedCalories: modifiedCalories,
            modifiedProteins: modifiedProteins,
            modifiedFats: modifiedFats,
            modifiedCarbs: modifiedCarbs,
            modifiedFibers: modifiedFibers,
            notes: notes,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required DateTime date,
            required String mealType,
            Value<int?> recetteId = const Value.absent(),
            Value<int> servings = const Value.absent(),
            Value<int?> userProfileId = const Value.absent(),
            Value<int?> groupId = const Value.absent(),
            Value<String?> eaters = const Value.absent(),
            Value<String?> modifiedIngredients = const Value.absent(),
            Value<double?> modifiedCalories = const Value.absent(),
            Value<double?> modifiedProteins = const Value.absent(),
            Value<double?> modifiedFats = const Value.absent(),
            Value<double?> modifiedCarbs = const Value.absent(),
            Value<double?> modifiedFibers = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              MealPlanningCompanion.insert(
            id: id,
            date: date,
            mealType: mealType,
            recetteId: recetteId,
            servings: servings,
            userProfileId: userProfileId,
            groupId: groupId,
            eaters: eaters,
            modifiedIngredients: modifiedIngredients,
            modifiedCalories: modifiedCalories,
            modifiedProteins: modifiedProteins,
            modifiedFats: modifiedFats,
            modifiedCarbs: modifiedCarbs,
            modifiedFibers: modifiedFibers,
            notes: notes,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$MealPlanningTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {recetteId = false,
              userProfileId = false,
              groupId = false,
              calorieTrackingRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (calorieTrackingRefs) db.calorieTracking
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (recetteId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.recetteId,
                    referencedTable:
                        $$MealPlanningTableReferences._recetteIdTable(db),
                    referencedColumn:
                        $$MealPlanningTableReferences._recetteIdTable(db).id,
                  ) as T;
                }
                if (userProfileId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.userProfileId,
                    referencedTable:
                        $$MealPlanningTableReferences._userProfileIdTable(db),
                    referencedColumn: $$MealPlanningTableReferences
                        ._userProfileIdTable(db)
                        .id,
                  ) as T;
                }
                if (groupId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.groupId,
                    referencedTable:
                        $$MealPlanningTableReferences._groupIdTable(db),
                    referencedColumn:
                        $$MealPlanningTableReferences._groupIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (calorieTrackingRefs)
                    await $_getPrefetchedData<MealPlanningData,
                            $MealPlanningTable, CalorieTrackingData>(
                        currentTable: table,
                        referencedTable: $$MealPlanningTableReferences
                            ._calorieTrackingRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$MealPlanningTableReferences(db, table, p0)
                                .calorieTrackingRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.mealPlanningId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$MealPlanningTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MealPlanningTable,
    MealPlanningData,
    $$MealPlanningTableFilterComposer,
    $$MealPlanningTableOrderingComposer,
    $$MealPlanningTableAnnotationComposer,
    $$MealPlanningTableCreateCompanionBuilder,
    $$MealPlanningTableUpdateCompanionBuilder,
    (MealPlanningData, $$MealPlanningTableReferences),
    MealPlanningData,
    PrefetchHooks Function(
        {bool recetteId,
        bool userProfileId,
        bool groupId,
        bool calorieTrackingRefs})>;
typedef $$ShoppingListTableCreateCompanionBuilder = ShoppingListCompanion
    Function({
  Value<int> id,
  Value<int?> ingredientId,
  Value<String?> customName,
  Value<double> quantity,
  Value<String> unit,
  Value<bool> isChecked,
  Value<bool> isAutoGenerated,
  Value<int?> groupId,
  Value<DateTime> createdAt,
});
typedef $$ShoppingListTableUpdateCompanionBuilder = ShoppingListCompanion
    Function({
  Value<int> id,
  Value<int?> ingredientId,
  Value<String?> customName,
  Value<double> quantity,
  Value<String> unit,
  Value<bool> isChecked,
  Value<bool> isAutoGenerated,
  Value<int?> groupId,
  Value<DateTime> createdAt,
});

final class $$ShoppingListTableReferences extends BaseReferences<_$AppDatabase,
    $ShoppingListTable, ShoppingListData> {
  $$ShoppingListTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $IngredientsTable _ingredientIdTable(_$AppDatabase db) =>
      db.ingredients.createAlias($_aliasNameGenerator(
          db.shoppingList.ingredientId, db.ingredients.id));

  $$IngredientsTableProcessedTableManager? get ingredientId {
    final $_column = $_itemColumn<int>('ingredient_id');
    if ($_column == null) return null;
    final manager = $$IngredientsTableTableManager($_db, $_db.ingredients)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ingredientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $GroupsTable _groupIdTable(_$AppDatabase db) => db.groups
      .createAlias($_aliasNameGenerator(db.shoppingList.groupId, db.groups.id));

  $$GroupsTableProcessedTableManager? get groupId {
    final $_column = $_itemColumn<int>('group_id');
    if ($_column == null) return null;
    final manager = $$GroupsTableTableManager($_db, $_db.groups)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_groupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ShoppingListTableFilterComposer
    extends Composer<_$AppDatabase, $ShoppingListTable> {
  $$ShoppingListTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get customName => $composableBuilder(
      column: $table.customName, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isChecked => $composableBuilder(
      column: $table.isChecked, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isAutoGenerated => $composableBuilder(
      column: $table.isAutoGenerated,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$IngredientsTableFilterComposer get ingredientId {
    final $$IngredientsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ingredientId,
        referencedTable: $db.ingredients,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$IngredientsTableFilterComposer(
              $db: $db,
              $table: $db.ingredients,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$GroupsTableFilterComposer get groupId {
    final $$GroupsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.groupId,
        referencedTable: $db.groups,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupsTableFilterComposer(
              $db: $db,
              $table: $db.groups,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ShoppingListTableOrderingComposer
    extends Composer<_$AppDatabase, $ShoppingListTable> {
  $$ShoppingListTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get customName => $composableBuilder(
      column: $table.customName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isChecked => $composableBuilder(
      column: $table.isChecked, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isAutoGenerated => $composableBuilder(
      column: $table.isAutoGenerated,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$IngredientsTableOrderingComposer get ingredientId {
    final $$IngredientsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ingredientId,
        referencedTable: $db.ingredients,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$IngredientsTableOrderingComposer(
              $db: $db,
              $table: $db.ingredients,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$GroupsTableOrderingComposer get groupId {
    final $$GroupsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.groupId,
        referencedTable: $db.groups,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupsTableOrderingComposer(
              $db: $db,
              $table: $db.groups,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ShoppingListTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShoppingListTable> {
  $$ShoppingListTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get customName => $composableBuilder(
      column: $table.customName, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<bool> get isChecked =>
      $composableBuilder(column: $table.isChecked, builder: (column) => column);

  GeneratedColumn<bool> get isAutoGenerated => $composableBuilder(
      column: $table.isAutoGenerated, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$IngredientsTableAnnotationComposer get ingredientId {
    final $$IngredientsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ingredientId,
        referencedTable: $db.ingredients,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$IngredientsTableAnnotationComposer(
              $db: $db,
              $table: $db.ingredients,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$GroupsTableAnnotationComposer get groupId {
    final $$GroupsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.groupId,
        referencedTable: $db.groups,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupsTableAnnotationComposer(
              $db: $db,
              $table: $db.groups,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ShoppingListTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ShoppingListTable,
    ShoppingListData,
    $$ShoppingListTableFilterComposer,
    $$ShoppingListTableOrderingComposer,
    $$ShoppingListTableAnnotationComposer,
    $$ShoppingListTableCreateCompanionBuilder,
    $$ShoppingListTableUpdateCompanionBuilder,
    (ShoppingListData, $$ShoppingListTableReferences),
    ShoppingListData,
    PrefetchHooks Function({bool ingredientId, bool groupId})> {
  $$ShoppingListTableTableManager(_$AppDatabase db, $ShoppingListTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShoppingListTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShoppingListTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShoppingListTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> ingredientId = const Value.absent(),
            Value<String?> customName = const Value.absent(),
            Value<double> quantity = const Value.absent(),
            Value<String> unit = const Value.absent(),
            Value<bool> isChecked = const Value.absent(),
            Value<bool> isAutoGenerated = const Value.absent(),
            Value<int?> groupId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              ShoppingListCompanion(
            id: id,
            ingredientId: ingredientId,
            customName: customName,
            quantity: quantity,
            unit: unit,
            isChecked: isChecked,
            isAutoGenerated: isAutoGenerated,
            groupId: groupId,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> ingredientId = const Value.absent(),
            Value<String?> customName = const Value.absent(),
            Value<double> quantity = const Value.absent(),
            Value<String> unit = const Value.absent(),
            Value<bool> isChecked = const Value.absent(),
            Value<bool> isAutoGenerated = const Value.absent(),
            Value<int?> groupId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              ShoppingListCompanion.insert(
            id: id,
            ingredientId: ingredientId,
            customName: customName,
            quantity: quantity,
            unit: unit,
            isChecked: isChecked,
            isAutoGenerated: isAutoGenerated,
            groupId: groupId,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ShoppingListTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({ingredientId = false, groupId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (ingredientId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.ingredientId,
                    referencedTable:
                        $$ShoppingListTableReferences._ingredientIdTable(db),
                    referencedColumn:
                        $$ShoppingListTableReferences._ingredientIdTable(db).id,
                  ) as T;
                }
                if (groupId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.groupId,
                    referencedTable:
                        $$ShoppingListTableReferences._groupIdTable(db),
                    referencedColumn:
                        $$ShoppingListTableReferences._groupIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ShoppingListTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ShoppingListTable,
    ShoppingListData,
    $$ShoppingListTableFilterComposer,
    $$ShoppingListTableOrderingComposer,
    $$ShoppingListTableAnnotationComposer,
    $$ShoppingListTableCreateCompanionBuilder,
    $$ShoppingListTableUpdateCompanionBuilder,
    (ShoppingListData, $$ShoppingListTableReferences),
    ShoppingListData,
    PrefetchHooks Function({bool ingredientId, bool groupId})>;
typedef $$CalorieTrackingTableCreateCompanionBuilder = CalorieTrackingCompanion
    Function({
  Value<int> id,
  required int userProfileId,
  required DateTime date,
  Value<int?> mealPlanningId,
  Value<double> calories,
  Value<double> proteins,
  Value<double> fats,
  Value<double> carbs,
  Value<double> fibers,
  required String mealType,
  Value<DateTime> createdAt,
});
typedef $$CalorieTrackingTableUpdateCompanionBuilder = CalorieTrackingCompanion
    Function({
  Value<int> id,
  Value<int> userProfileId,
  Value<DateTime> date,
  Value<int?> mealPlanningId,
  Value<double> calories,
  Value<double> proteins,
  Value<double> fats,
  Value<double> carbs,
  Value<double> fibers,
  Value<String> mealType,
  Value<DateTime> createdAt,
});

final class $$CalorieTrackingTableReferences extends BaseReferences<
    _$AppDatabase, $CalorieTrackingTable, CalorieTrackingData> {
  $$CalorieTrackingTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $UserProfilesTable _userProfileIdTable(_$AppDatabase db) =>
      db.userProfiles.createAlias($_aliasNameGenerator(
          db.calorieTracking.userProfileId, db.userProfiles.id));

  $$UserProfilesTableProcessedTableManager get userProfileId {
    final $_column = $_itemColumn<int>('user_profile_id')!;

    final manager = $$UserProfilesTableTableManager($_db, $_db.userProfiles)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userProfileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $MealPlanningTable _mealPlanningIdTable(_$AppDatabase db) =>
      db.mealPlanning.createAlias($_aliasNameGenerator(
          db.calorieTracking.mealPlanningId, db.mealPlanning.id));

  $$MealPlanningTableProcessedTableManager? get mealPlanningId {
    final $_column = $_itemColumn<int>('meal_planning_id');
    if ($_column == null) return null;
    final manager = $$MealPlanningTableTableManager($_db, $_db.mealPlanning)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_mealPlanningIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$CalorieTrackingTableFilterComposer
    extends Composer<_$AppDatabase, $CalorieTrackingTable> {
  $$CalorieTrackingTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get calories => $composableBuilder(
      column: $table.calories, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get proteins => $composableBuilder(
      column: $table.proteins, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get fats => $composableBuilder(
      column: $table.fats, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get carbs => $composableBuilder(
      column: $table.carbs, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get fibers => $composableBuilder(
      column: $table.fibers, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mealType => $composableBuilder(
      column: $table.mealType, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$UserProfilesTableFilterComposer get userProfileId {
    final $$UserProfilesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userProfileId,
        referencedTable: $db.userProfiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UserProfilesTableFilterComposer(
              $db: $db,
              $table: $db.userProfiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$MealPlanningTableFilterComposer get mealPlanningId {
    final $$MealPlanningTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.mealPlanningId,
        referencedTable: $db.mealPlanning,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MealPlanningTableFilterComposer(
              $db: $db,
              $table: $db.mealPlanning,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CalorieTrackingTableOrderingComposer
    extends Composer<_$AppDatabase, $CalorieTrackingTable> {
  $$CalorieTrackingTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get calories => $composableBuilder(
      column: $table.calories, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get proteins => $composableBuilder(
      column: $table.proteins, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get fats => $composableBuilder(
      column: $table.fats, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get carbs => $composableBuilder(
      column: $table.carbs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get fibers => $composableBuilder(
      column: $table.fibers, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mealType => $composableBuilder(
      column: $table.mealType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$UserProfilesTableOrderingComposer get userProfileId {
    final $$UserProfilesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userProfileId,
        referencedTable: $db.userProfiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UserProfilesTableOrderingComposer(
              $db: $db,
              $table: $db.userProfiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$MealPlanningTableOrderingComposer get mealPlanningId {
    final $$MealPlanningTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.mealPlanningId,
        referencedTable: $db.mealPlanning,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MealPlanningTableOrderingComposer(
              $db: $db,
              $table: $db.mealPlanning,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CalorieTrackingTableAnnotationComposer
    extends Composer<_$AppDatabase, $CalorieTrackingTable> {
  $$CalorieTrackingTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<double> get calories =>
      $composableBuilder(column: $table.calories, builder: (column) => column);

  GeneratedColumn<double> get proteins =>
      $composableBuilder(column: $table.proteins, builder: (column) => column);

  GeneratedColumn<double> get fats =>
      $composableBuilder(column: $table.fats, builder: (column) => column);

  GeneratedColumn<double> get carbs =>
      $composableBuilder(column: $table.carbs, builder: (column) => column);

  GeneratedColumn<double> get fibers =>
      $composableBuilder(column: $table.fibers, builder: (column) => column);

  GeneratedColumn<String> get mealType =>
      $composableBuilder(column: $table.mealType, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$UserProfilesTableAnnotationComposer get userProfileId {
    final $$UserProfilesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userProfileId,
        referencedTable: $db.userProfiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UserProfilesTableAnnotationComposer(
              $db: $db,
              $table: $db.userProfiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$MealPlanningTableAnnotationComposer get mealPlanningId {
    final $$MealPlanningTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.mealPlanningId,
        referencedTable: $db.mealPlanning,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MealPlanningTableAnnotationComposer(
              $db: $db,
              $table: $db.mealPlanning,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CalorieTrackingTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CalorieTrackingTable,
    CalorieTrackingData,
    $$CalorieTrackingTableFilterComposer,
    $$CalorieTrackingTableOrderingComposer,
    $$CalorieTrackingTableAnnotationComposer,
    $$CalorieTrackingTableCreateCompanionBuilder,
    $$CalorieTrackingTableUpdateCompanionBuilder,
    (CalorieTrackingData, $$CalorieTrackingTableReferences),
    CalorieTrackingData,
    PrefetchHooks Function({bool userProfileId, bool mealPlanningId})> {
  $$CalorieTrackingTableTableManager(
      _$AppDatabase db, $CalorieTrackingTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CalorieTrackingTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CalorieTrackingTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CalorieTrackingTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> userProfileId = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<int?> mealPlanningId = const Value.absent(),
            Value<double> calories = const Value.absent(),
            Value<double> proteins = const Value.absent(),
            Value<double> fats = const Value.absent(),
            Value<double> carbs = const Value.absent(),
            Value<double> fibers = const Value.absent(),
            Value<String> mealType = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              CalorieTrackingCompanion(
            id: id,
            userProfileId: userProfileId,
            date: date,
            mealPlanningId: mealPlanningId,
            calories: calories,
            proteins: proteins,
            fats: fats,
            carbs: carbs,
            fibers: fibers,
            mealType: mealType,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int userProfileId,
            required DateTime date,
            Value<int?> mealPlanningId = const Value.absent(),
            Value<double> calories = const Value.absent(),
            Value<double> proteins = const Value.absent(),
            Value<double> fats = const Value.absent(),
            Value<double> carbs = const Value.absent(),
            Value<double> fibers = const Value.absent(),
            required String mealType,
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              CalorieTrackingCompanion.insert(
            id: id,
            userProfileId: userProfileId,
            date: date,
            mealPlanningId: mealPlanningId,
            calories: calories,
            proteins: proteins,
            fats: fats,
            carbs: carbs,
            fibers: fibers,
            mealType: mealType,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$CalorieTrackingTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {userProfileId = false, mealPlanningId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (userProfileId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.userProfileId,
                    referencedTable: $$CalorieTrackingTableReferences
                        ._userProfileIdTable(db),
                    referencedColumn: $$CalorieTrackingTableReferences
                        ._userProfileIdTable(db)
                        .id,
                  ) as T;
                }
                if (mealPlanningId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.mealPlanningId,
                    referencedTable: $$CalorieTrackingTableReferences
                        ._mealPlanningIdTable(db),
                    referencedColumn: $$CalorieTrackingTableReferences
                        ._mealPlanningIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$CalorieTrackingTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CalorieTrackingTable,
    CalorieTrackingData,
    $$CalorieTrackingTableFilterComposer,
    $$CalorieTrackingTableOrderingComposer,
    $$CalorieTrackingTableAnnotationComposer,
    $$CalorieTrackingTableCreateCompanionBuilder,
    $$CalorieTrackingTableUpdateCompanionBuilder,
    (CalorieTrackingData, $$CalorieTrackingTableReferences),
    CalorieTrackingData,
    PrefetchHooks Function({bool userProfileId, bool mealPlanningId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$IngredientsTableTableManager get ingredients =>
      $$IngredientsTableTableManager(_db, _db.ingredients);
  $$FrigoTableTableManager get frigo =>
      $$FrigoTableTableManager(_db, _db.frigo);
  $$RecettesTableTableManager get recettes =>
      $$RecettesTableTableManager(_db, _db.recettes);
  $$RecetteIngredientsTableTableManager get recetteIngredients =>
      $$RecetteIngredientsTableTableManager(_db, _db.recetteIngredients);
  $$UserProfilesTableTableManager get userProfiles =>
      $$UserProfilesTableTableManager(_db, _db.userProfiles);
  $$GroupsTableTableManager get groups =>
      $$GroupsTableTableManager(_db, _db.groups);
  $$GroupMembersTableTableManager get groupMembers =>
      $$GroupMembersTableTableManager(_db, _db.groupMembers);
  $$MealPlanningTableTableManager get mealPlanning =>
      $$MealPlanningTableTableManager(_db, _db.mealPlanning);
  $$ShoppingListTableTableManager get shoppingList =>
      $$ShoppingListTableTableManager(_db, _db.shoppingList);
  $$CalorieTrackingTableTableManager get calorieTracking =>
      $$CalorieTrackingTableTableManager(_db, _db.calorieTracking);
}
