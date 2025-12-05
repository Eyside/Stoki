// lib/repositories/recette_repository.dart
import 'package:drift/drift.dart';
import '../database.dart';
import '../utils/unit_converter.dart';

class RecetteRepository extends DatabaseAccessor<AppDatabase> {
  final AppDatabase db;
  RecetteRepository(this.db) : super(db);

  @override
  AppDatabase get attachedDatabase => db;

  Future<int> insertRecette({
    required String name,
    String? notes,
    int servings = 1,
    String? instructions,
    String? imageUrl,
    String? category, // NOUVEAU
  }) {
    final companion = RecettesCompanion(
      name: Value(name),
      notes: Value(notes),
      servings: Value(servings),
      instructions: Value(instructions),
      imageUrl: Value(imageUrl),
      category: Value(category), // NOUVEAU
    );
    return into(db.recettes).insert(companion);
  }

  Future<int> addIngredientToRecette({
    required int recetteId,
    required int ingredientId,
    required double quantity,
    required String unit,
    double? densityGPerMl,
    double? weightPerUnitG,
  }) {
    final comp = RecetteIngredientsCompanion(
      recetteId: Value(recetteId),
      ingredientId: Value(ingredientId),
      quantity: Value(quantity),
      unit: Value(unit),
      densityGPerMl: Value(densityGPerMl),
      weightPerUnitG: Value(weightPerUnitG),
    );
    return into(db.recetteIngredients).insert(comp);
  }

  Future<List<Recette>> getAllRecettes() => db.getAllRecettes();

  Future<Recette?> getRecetteById(int id) =>
      (select(db.recettes)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<List<Map<String, dynamic>>> getIngredientsForRecette(int recetteId) async {
    final q = select(db.recetteIngredients).join([
      leftOuterJoin(db.ingredients, db.ingredients.id.equalsExp(db.recetteIngredients.ingredientId)),
    ])..where(db.recetteIngredients.recetteId.equals(recetteId));

    final rows = await q.get();
    return rows.map((r) {
      final ri = r.readTable(db.recetteIngredients);
      final ing = r.readTableOrNull(db.ingredients);
      return {'recetteIngredient': ri, 'ingredient': ing};
    }).toList();
  }

  // Calcul des valeurs nutritionnelles complètes d'une recette
  Future<Map<String, double>> calculateNutritionForRecette(int recetteId) async {
    final list = await getIngredientsForRecette(recetteId);
    double totalCalories = 0.0;
    double totalProteins = 0.0;
    double totalFats = 0.0;
    double totalCarbs = 0.0;
    double totalFibers = 0.0;

    for (final item in list) {
      final ri = item['recetteIngredient'] as RecetteIngredient;
      final ing = item['ingredient'] as Ingredient?;
      if (ing == null) continue;

      // Convertir la quantité en grammes
      final gramsQuantity = UnitConverter.toGrams(
        quantity: ri.quantity,
        unit: ri.unit,
        weightPerPieceGrams: ri.weightPerUnitG ?? ing.avgWeightPerUnitG,
        densityGramsPerMl: ri.densityGPerMl ?? ing.densityGPerMl ?? 1.0,
      );

      // Calculer les valeurs pour cette quantité
      final factor = gramsQuantity / 100.0;
      totalCalories += ing.caloriesPer100g * factor;
      totalProteins += ing.proteinsPer100g * factor;
      totalFats += ing.fatsPer100g * factor;
      totalCarbs += ing.carbsPer100g * factor;
      totalFibers += ing.fibersPer100g * factor;
    }

    return {
      'calories': totalCalories,
      'proteins': totalProteins,
      'fats': totalFats,
      'carbs': totalCarbs,
      'fibers': totalFibers,
    };
  }

  // Calcul des calories (rétrocompatibilité)
  Future<double> calculateCaloriesForRecette(int recetteId) async {
    final nutrition = await calculateNutritionForRecette(recetteId);
    return nutrition['calories'] ?? 0.0;
  }

  Future<int> removeIngredientFromRecette({
    required int recetteId,
    required int ingredientId,
  }) async {
    return (delete(db.recetteIngredients)
      ..where((t) =>
      t.recetteId.equals(recetteId) & t.ingredientId.equals(ingredientId)))
        .go();
  }

  Future<int> duplicateRecette(int recetteId) async {
    final original = await (select(db.recettes)..where((t) => t.id.equals(recetteId))).getSingleOrNull();
    if (original == null) throw StateError('Recette not found');

    final newId = await insertRecette(
      name: '${original.name} (copie)',
      notes: original.notes,
      servings: original.servings,
      instructions: original.instructions,
      imageUrl: original.imageUrl,
      category: original.category, // NOUVEAU
    );

    final ingredients = await getIngredientsForRecette(recetteId);
    for (final item in ingredients) {
      final ri = item['recetteIngredient'] as RecetteIngredient;
      await addIngredientToRecette(
        recetteId: newId,
        ingredientId: ri.ingredientId,
        quantity: ri.quantity,
        unit: ri.unit,
        densityGPerMl: ri.densityGPerMl,
        weightPerUnitG: ri.weightPerUnitG,
      );
    }
    return newId;
  }

  Future<int> updateRecette({
    required int id,
    String? name,
    String? notes,
    int? servings,
    String? instructions,
    String? imageUrl,
    String? category, // NOUVEAU
  }) {
    return (update(db.recettes)..where((t) => t.id.equals(id))).write(
      RecettesCompanion(
        name: name != null ? Value(name) : const Value.absent(),
        notes: notes != null ? Value(notes) : const Value.absent(),
        servings: servings != null ? Value(servings) : const Value.absent(),
        instructions: instructions != null ? Value(instructions) : const Value.absent(),
        imageUrl: imageUrl != null ? Value(imageUrl) : const Value.absent(),
        category: category != null ? Value(category) : const Value.absent(), // NOUVEAU
      ),
    );
  }

  Future<int> deleteRecette(int id) async {
    await (delete(db.recetteIngredients)..where((t) => t.recetteId.equals(id))).go();
    return (delete(db.recettes)..where((t) => t.id.equals(id))).go();
  }
}
