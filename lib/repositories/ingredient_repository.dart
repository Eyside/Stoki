// lib/repositories/ingredient_repository.dart
import 'package:drift/drift.dart';
import '../database.dart';

class IngredientRepository extends DatabaseAccessor<AppDatabase> {
  final AppDatabase db;
  IngredientRepository(this.db) : super(db);

  @override
  AppDatabase get attachedDatabase => db;

  Future<int> insertIngredient({
    required String name,
    required double caloriesPer100g,
    double proteinsPer100g = 0.0,
    double fatsPer100g = 0.0,
    double carbsPer100g = 0.0,
    double fibersPer100g = 0.0,
    double saltPer100g = 0.0,
    String? barcode,
    double? densityGPerMl,
    double? avgWeightPerUnitG,
    String? category,
    String? nutriscore,
    bool isCustom = false,
  }) {
    final companion = IngredientsCompanion(
      name: Value(name),
      caloriesPer100g: Value(caloriesPer100g),
      proteinsPer100g: Value(proteinsPer100g),
      fatsPer100g: Value(fatsPer100g),
      carbsPer100g: Value(carbsPer100g),
      fibersPer100g: Value(fibersPer100g),
      saltPer100g: Value(saltPer100g),
      barcode: Value(barcode),
      densityGPerMl: Value(densityGPerMl),
      avgWeightPerUnitG: Value(avgWeightPerUnitG),
      category: Value(category),
      nutriscore: Value(nutriscore),
      isCustom: Value(isCustom),
    );
    return into(db.ingredients).insert(companion);
  }

  Future<int> insertScannedIngredient({
    required String name,
    required double caloriesPer100g,
    double proteinsPer100g = 0.0,
    double fatsPer100g = 0.0,
    double carbsPer100g = 0.0,
    double fibersPer100g = 0.0,
    double saltPer100g = 0.0,
    String? barcode,
    double? densityGPerMl,
    double? avgWeightPerUnitG,
    String? category,
    String? nutriscore,
  }) {
    return insertIngredient(
      name: name,
      caloriesPer100g: caloriesPer100g,
      proteinsPer100g: proteinsPer100g,
      fatsPer100g: fatsPer100g,
      carbsPer100g: carbsPer100g,
      fibersPer100g: fibersPer100g,
      saltPer100g: saltPer100g,
      barcode: barcode,
      densityGPerMl: densityGPerMl,
      avgWeightPerUnitG: avgWeightPerUnitG,
      category: category,
      nutriscore: nutriscore,
      isCustom: false,
    );
  }

  Future<List<Ingredient>> getAllIngredients() => db.getAllIngredients();

  Future<Ingredient?> findByBarcode(String barcode) async {
    final q = (select(db.ingredients)..where((t) => t.barcode.equals(barcode)));
    final list = await q.get();
    return list.isNotEmpty ? list.first : null;
  }

  Future<Ingredient?> findById(int id) =>
      (select(db.ingredients)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> updateIngredient({
    required int id,
    String? name,
    double? caloriesPer100g,
    double? proteinsPer100g,
    double? fatsPer100g,
    double? carbsPer100g,
    double? fibersPer100g,
    double? saltPer100g,
    double? densityGPerMl,
    double? avgWeightPerUnitG,
    String? category,
    String? nutriscore,
  }) {
    return (update(db.ingredients)..where((t) => t.id.equals(id))).write(
      IngredientsCompanion(
        name: name != null ? Value(name) : const Value.absent(),
        caloriesPer100g: caloriesPer100g != null ? Value(caloriesPer100g) : const Value.absent(),
        proteinsPer100g: proteinsPer100g != null ? Value(proteinsPer100g) : const Value.absent(),
        fatsPer100g: fatsPer100g != null ? Value(fatsPer100g) : const Value.absent(),
        carbsPer100g: carbsPer100g != null ? Value(carbsPer100g) : const Value.absent(),
        fibersPer100g: fibersPer100g != null ? Value(fibersPer100g) : const Value.absent(),
        saltPer100g: saltPer100g != null ? Value(saltPer100g) : const Value.absent(),
        densityGPerMl: densityGPerMl != null ? Value(densityGPerMl) : const Value.absent(),
        avgWeightPerUnitG: avgWeightPerUnitG != null ? Value(avgWeightPerUnitG) : const Value.absent(),
        category: category != null ? Value(category) : const Value.absent(),
        nutriscore: nutriscore != null ? Value(nutriscore) : const Value.absent(),
      ),
    );
  }

  Future<int> deleteIngredient(int id) =>
      (delete(db.ingredients)..where((t) => t.id.equals(id))).go();
}