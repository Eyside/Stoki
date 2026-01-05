// lib/database.dart - REMPLACER ENTIÈREMENT LE CONTENU
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/foundation.dart'; // Pour debugPrint

part 'database.g.dart';

// ============================================================================
// TABLE: INGREDIENTS (base de données d'aliments)
// ============================================================================
class Ingredients extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();

  // Valeurs nutritionnelles pour 100g
  RealColumn get caloriesPer100g => real().withDefault(const Constant(0.0))();
  RealColumn get proteinsPer100g => real().withDefault(const Constant(0.0))();
  RealColumn get fatsPer100g => real().withDefault(const Constant(0.0))();
  RealColumn get carbsPer100g => real().withDefault(const Constant(0.0))();
  RealColumn get fibersPer100g => real().withDefault(const Constant(0.0))();
  RealColumn get saltPer100g => real().withDefault(const Constant(0.0))();

  // Informations de conversion
  RealColumn get densityGPerMl => real().nullable()();
  RealColumn get avgWeightPerUnitG => real().nullable()();

  // Métadonnées
  TextColumn get barcode => text().nullable()();
  TextColumn get category => text().nullable()();
  TextColumn get nutriscore => text().nullable()();
  BoolColumn get isCustom => boolean().withDefault(const Constant(false))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// ============================================================================
// TABLE: FRIGO (stocks actuels - frigo + placard)
// ============================================================================
class Frigo extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get ingredientId => integer().references(Ingredients, #id, onDelete: KeyAction.cascade)();

  RealColumn get quantity => real().withDefault(const Constant(0.0))();
  TextColumn get unit => text().withDefault(const Constant('g'))();

  DateTimeColumn get bestBefore => dateTime().nullable()();
  TextColumn get location => text().withDefault(const Constant('frigo'))();

  DateTimeColumn get addedAt => dateTime().withDefault(currentDateAndTime)();
}

// ============================================================================
// TABLE: RECETTES
// ============================================================================
class Recettes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get instructions => text().nullable()();
  IntColumn get servings => integer().withDefault(const Constant(1))();
  TextColumn get notes => text().nullable()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get category => text().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// ============================================================================
// TABLE: RECETTE_INGREDIENTS (liaison recette <-> ingrédients)
// ============================================================================
class RecetteIngredients extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get recetteId => integer().references(Recettes, #id, onDelete: KeyAction.cascade)();
  IntColumn get ingredientId => integer().references(Ingredients, #id, onDelete: KeyAction.cascade)();

  RealColumn get quantity => real().withDefault(const Constant(0.0))();
  TextColumn get unit => text().withDefault(const Constant('g'))();

  RealColumn get densityGPerMl => real().nullable()();
  RealColumn get weightPerUnitG => real().nullable()();
}

// ============================================================================
// TABLE: PROFILS UTILISATEURS (pour calcul BMR/TDEE)
// ============================================================================
class UserProfiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get userId => text().unique()();

  TextColumn get sex => text()();
  IntColumn get age => integer()();
  RealColumn get heightCm => real()();
  RealColumn get weightKg => real()();

  RealColumn get eaterMultiplier => real().withDefault(const Constant(1.0))();

  TextColumn get activityLevel => text().withDefault(const Constant('sedentary'))();

  RealColumn get bmr => real().nullable()();
  RealColumn get tdee => real().nullable()();

  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

// ============================================================================
// TABLE: GROUPES (pour partage entre amis)
// ============================================================================
class Groups extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get groupId => text().unique()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// ============================================================================
// TABLE: GROUP_MEMBERS (membres d'un groupe)
// ============================================================================
class GroupMembers extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get groupId => integer().references(Groups, #id, onDelete: KeyAction.cascade)();
  IntColumn get userProfileId => integer().references(UserProfiles, #id, onDelete: KeyAction.cascade)();

  TextColumn get role => text().withDefault(const Constant('member'))();
  DateTimeColumn get joinedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {groupId, userProfileId};
}

// ============================================================================
// TABLE: PLANNING (calendrier des repas) - VERSION MODIFIÉE
// ============================================================================
class MealPlanning extends Table {
  IntColumn get id => integer().autoIncrement()();

  DateTimeColumn get date => dateTime()();
  TextColumn get mealType => text()();

  IntColumn get recetteId => integer().references(Recettes, #id, onDelete: KeyAction.cascade).nullable()();
  IntColumn get servings => integer().withDefault(const Constant(1))();

  IntColumn get userProfileId => integer().references(UserProfiles, #id, onDelete: KeyAction.cascade).nullable()();
  IntColumn get groupId => integer().references(Groups, #id, onDelete: KeyAction.cascade).nullable()();

  TextColumn get eaters => text().nullable()();

  // NOUVELLES COLONNES pour les modifications
  TextColumn get modifiedIngredients => text().nullable()();
  RealColumn get modifiedCalories => real().nullable()();
  RealColumn get modifiedProteins => real().nullable()();
  RealColumn get modifiedFats => real().nullable()();
  RealColumn get modifiedCarbs => real().nullable()();
  RealColumn get modifiedFibers => real().nullable()();

  TextColumn get notes => text().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// ============================================================================
// TABLE: LISTE DE COURSES
// ============================================================================
class ShoppingList extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get ingredientId => integer().references(Ingredients, #id, onDelete: KeyAction.cascade).nullable()();
  TextColumn get customName => text().nullable()();

  RealColumn get quantity => real().withDefault(const Constant(0.0))();
  TextColumn get unit => text().withDefault(const Constant('g'))();

  BoolColumn get isChecked => boolean().withDefault(const Constant(false))();
  BoolColumn get isAutoGenerated => boolean().withDefault(const Constant(false))();

  IntColumn get groupId => integer().references(Groups, #id, onDelete: KeyAction.cascade).nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// ============================================================================
// TABLE: SUIVI CALORIQUE (historique de consommation)
// ============================================================================
class CalorieTracking extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get userProfileId => integer().references(UserProfiles, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get date => dateTime()();

  IntColumn get mealPlanningId => integer().references(MealPlanning, #id, onDelete: KeyAction.cascade).nullable()();

  RealColumn get calories => real().withDefault(const Constant(0.0))();
  RealColumn get proteins => real().withDefault(const Constant(0.0))();
  RealColumn get fats => real().withDefault(const Constant(0.0))();
  RealColumn get carbs => real().withDefault(const Constant(0.0))();
  RealColumn get fibers => real().withDefault(const Constant(0.0))();

  TextColumn get mealType => text()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// ============================================================================
// DATABASE CLASS
// ============================================================================
@DriftDatabase(tables: [
  Ingredients,
  Frigo,
  Recettes,
  RecetteIngredients,
  UserProfiles,
  Groups,
  GroupMembers,
  MealPlanning,
  ShoppingList,
  CalorieTracking,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 5; // Version 5

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      // Migration de la version 1 vers 2
      if (from == 1) {
        try {
          await m.addColumn(ingredients, ingredients.densityGPerMl);
          await m.addColumn(ingredients, ingredients.avgWeightPerUnitG);
          await m.addColumn(ingredients, ingredients.barcode);
        } catch (_) {}
      }

      // Migration de la version 2 vers 3
      if (from <= 2) {
        try {
          await m.addColumn(ingredients, ingredients.proteinsPer100g);
          await m.addColumn(ingredients, ingredients.fatsPer100g);
          await m.addColumn(ingredients, ingredients.carbsPer100g);
          await m.addColumn(ingredients, ingredients.fibersPer100g);
          await m.addColumn(ingredients, ingredients.saltPer100g);
          await m.addColumn(ingredients, ingredients.isCustom);
          await m.addColumn(ingredients, ingredients.createdAt);

          await m.createTable(userProfiles);
          await m.createTable(groups);
          await m.createTable(groupMembers);
          await m.createTable(mealPlanning);
          await m.createTable(shoppingList);
          await m.createTable(calorieTracking);
        } catch (e) {
          debugPrint('Migration error v3: $e');
        }
      }

      // Migration de la version 3 vers 4
      if (from <= 3) {
        try {
          await m.addColumn(recettes, recettes.category);
        } catch (e) {
          debugPrint('Migration error v4: $e');
        }
      }

      // Migration de la version 4 vers 5
      if (from <= 4) {
        try {
          await m.addColumn(mealPlanning, mealPlanning.modifiedIngredients);
          await m.addColumn(mealPlanning, mealPlanning.modifiedCalories);
          await m.addColumn(mealPlanning, mealPlanning.modifiedProteins);
          await m.addColumn(mealPlanning, mealPlanning.modifiedFats);
          await m.addColumn(mealPlanning, mealPlanning.modifiedCarbs);
          await m.addColumn(mealPlanning, mealPlanning.modifiedFibers);
          debugPrint('✅ Migration v5 réussie: colonnes de modification ajoutées');
        } catch (e) {
          debugPrint('❌ Migration error v5: $e');
        }
      }
    },
  );

  // ============================================================================
  // QUERIES DE CONVENIENCE
  // ============================================================================

  Future<List<Ingredient>> getAllIngredients() => select(ingredients).get();
  Future<Ingredient?> getIngredientById(int id) =>
      (select(ingredients)..where((i) => i.id.equals(id))).getSingleOrNull();

  Future<List<FrigoData>> getAllFrigo() => select(frigo).get();

  Future<List<Recette>> getAllRecettes() => select(recettes).get();

  Future<List<UserProfile>> getAllProfiles() => select(userProfiles).get();
  Future<UserProfile?> getActiveProfile() =>
      (select(userProfiles)..where((p) => p.isActive.equals(true))).getSingleOrNull();

  Future<List<MealPlanningData>> getPlanningForDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return (select(mealPlanning)
      ..where((p) => p.date.isBiggerOrEqualValue(startOfDay))
      ..where((p) => p.date.isSmallerThanValue(endOfDay))
    ).get();
  }

  Future<List<ShoppingListData>> getShoppingList() =>
      (select(shoppingList)..where((s) => s.isChecked.equals(false))).get();

  Future<List<CalorieTrackingData>> getCalorieTrackingForDateRange(
      int userProfileId,
      DateTime startDate,
      DateTime endDate
      ) {
    return (select(calorieTracking)
      ..where((c) => c.userProfileId.equals(userProfileId))
      ..where((c) => c.date.isBiggerOrEqualValue(startDate))
      ..where((c) => c.date.isSmallerOrEqualValue(endDate))
      ..orderBy([(c) => OrderingTerm.desc(c.date)])
    ).get();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final folder = await getApplicationDocumentsDirectory();
    final file = File(p.join(folder.path, 'stoki.sqlite'));
    return NativeDatabase(file);
  });
}