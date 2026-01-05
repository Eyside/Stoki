// lib/services/shopping_list_generator_service.dart (CORRIGÉ)
import 'dart:convert';
import '../database.dart';
import '../models/shopping_list_firestore.dart';
import '../models/planning_firestore.dart';
import '../models/recette_firestore.dart';
import '../models/frigo_firestore.dart'; // ✅ AJOUTÉ
import '../repositories/planning_repository.dart';
import '../repositories/recette_repository.dart';
import '../repositories/frigo_repository.dart';
import '../repositories/ingredient_repository.dart';
import '../services/planning_firestore_service.dart';
import '../services/recette_firestore_service.dart';
import '../services/frigo_firestore_service.dart'; // ✅ AJOUTÉ
import '../utils/unit_converter.dart';
import 'shopping_list_cloud_service.dart';

enum ShoppingListSource {
  all,
  local,
  private,
  group,
}

class ShoppingListGeneratorService {
  final PlanningRepository planningRepo;
  final RecetteRepository recetteRepo;
  final FrigoRepository frigoRepo;
  final IngredientRepository ingredientRepo;
  final PlanningFirestoreService planningCloudService;
  final ShoppingListCloudService shoppingCloudService;
  final RecetteFirestoreService recetteCloudService;
  final FrigoFirestoreService frigoCloudService; // ✅ AJOUTÉ

  ShoppingListGeneratorService({
    required this.planningRepo,
    required this.recetteRepo,
    required this.frigoRepo,
    required this.ingredientRepo,
    required this.planningCloudService,
    required this.shoppingCloudService,
    required this.recetteCloudService,
    required this.frigoCloudService, // ✅ AJOUTÉ
  });

  // ============================================================================
  // GÉNÉRATION DEPUIS LE PLANNING
  // ============================================================================

  Future<List<Map<String, dynamic>>> generateFromPlanning({
    required DateTime startDate,
    required DateTime endDate,
    required ShoppingListSource source,
    String? groupId,
    bool subtractStock = true,
    bool runDiagnostic = false,
  }) async {
    print('🔄 Génération liste de courses...');
    print('   Source: ${source.name}');
    print('   Période: ${startDate.day}/${startDate.month} → ${endDate.day}/${endDate.month}');
    print('   Soustraire stock: $subtractStock');

    if (runDiagnostic) {
      await diagnosePlanningIssues(startDate: startDate, endDate: endDate);
    }

    // 1. Récupérer les plannings
    final allPlannings = await _fetchPlanningsBySource(
      startDate: startDate,
      endDate: endDate,
      source: source,
      groupId: groupId,
    );

    if (allPlannings.isEmpty) {
      print('⚠️ Aucun repas planifié sur cette période');
      return [];
    }

    print('✅ ${allPlannings.length} repas trouvés');

    // 2. Calculer les ingrédients nécessaires
    final neededIngredients = await _calculateNeededIngredients(allPlannings);
    print('✅ ${neededIngredients.length} ingrédients nécessaires');

    // 3. Soustraire le stock si demandé - AVEC SOURCE ET GROUPID
    if (subtractStock) {
      await _subtractStock(
        neededIngredients,
        source: source,
        groupId: groupId,
      );
      print('✅ Stock soustrait');
    }

    // 4. Retourner les ingrédients
    final items = <Map<String, dynamic>>[];
    for (final entry in neededIngredients.entries) {
      final need = entry.value;
      if (need.quantityGrams <= 0) continue;

      if (need.ingredient != null) {
        final ingredient = need.ingredient!;
        final displayQuantity = need.quantityGrams / 1000;
        final displayUnit = displayQuantity >= 1 ? 'kg' : 'g';
        final finalQuantity = displayQuantity >= 1 ? displayQuantity : need.quantityGrams;

        items.add({
          'ingredientId': ingredient.id.toString(),
          'ingredientName': ingredient.name,
          'quantity': finalQuantity,
          'unit': displayUnit,
          'category': ingredient.category,
          'caloriesPer100g': ingredient.caloriesPer100g,
          'proteinsPer100g': ingredient.proteinsPer100g,
          'fatsPer100g': ingredient.fatsPer100g,
          'carbsPer100g': ingredient.carbsPer100g,
          'fibersPer100g': ingredient.fibersPer100g,
          'densityGPerMl': ingredient.densityGPerMl,
          'avgWeightPerUnitG': ingredient.avgWeightPerUnitG,
        });
      } else if (need.cloudIngredient != null) {
        final ingredient = need.cloudIngredient!;
        final displayQuantity = need.quantityGrams / 1000;
        final displayUnit = displayQuantity >= 1 ? 'kg' : 'g';
        final finalQuantity = displayQuantity >= 1 ? displayQuantity : need.quantityGrams;

        items.add({
          'ingredientId': ingredient.ingredientId,
          'ingredientName': ingredient.ingredientName,
          'quantity': finalQuantity,
          'unit': displayUnit,
          'category': null,
          'caloriesPer100g': ingredient.caloriesPer100g,
          'proteinsPer100g': ingredient.proteinsPer100g,
          'fatsPer100g': ingredient.fatsPer100g,
          'carbsPer100g': ingredient.carbsPer100g,
          'fibersPer100g': ingredient.fibersPer100g,
          'densityGPerMl': ingredient.densityGPerMl,
          'avgWeightPerUnitG': ingredient.avgWeightPerUnitG,
        });
      }
    }

    items.sort((a, b) {
      final catA = a['category'] ?? 'Autre';
      final catB = b['category'] ?? 'Autre';
      return catA.compareTo(catB);
    });

    print('✅ ${items.length} articles générés');
    return items;
  }

  // ============================================================================
  // RÉCUPÉRATION DES PLANNINGS
  // ============================================================================

  Future<List<Map<String, dynamic>>> _fetchPlanningsBySource({
    required DateTime startDate,
    required DateTime endDate,
    required ShoppingListSource source,
    String? groupId,
  }) async {
    final List<Map<String, dynamic>> allPlannings = [];

    if (source == ShoppingListSource.all || source == ShoppingListSource.local) {
      final localPlannings = await _fetchLocalPlannings(startDate, endDate);
      allPlannings.addAll(localPlannings);
    }

    if (source == ShoppingListSource.all ||
        source == ShoppingListSource.private ||
        source == ShoppingListSource.group) {
      final cloudPlannings = await _fetchCloudPlannings(
        startDate: startDate,
        endDate: endDate,
        source: source,
        groupId: groupId,
      );
      allPlannings.addAll(cloudPlannings);
    }

    return allPlannings;
  }

  Future<List<Map<String, dynamic>>> _fetchLocalPlannings(
      DateTime startDate, DateTime endDate) async {
    final plannings = <Map<String, dynamic>>[];

    for (var date = startDate;
    date.isBefore(endDate.add(const Duration(days: 1)));
    date = date.add(const Duration(days: 1))) {

      final dayPlannings = await planningRepo.getPlanningForDate(date);

      for (final planning in dayPlannings) {
        if (planning.recetteId == null) continue;

        final recette = await recetteRepo.getRecetteById(planning.recetteId!);
        if (recette == null) continue;

        plannings.add({
          'type': 'local',
          'planning': planning,
          'recette': recette,
          'servings': planning.servings,
        });
      }
    }

    return plannings;
  }

  Future<List<Map<String, dynamic>>> _fetchCloudPlannings({
    required DateTime startDate,
    required DateTime endDate,
    required ShoppingListSource source,
    String? groupId,
  }) async {
    final plannings = <Map<String, dynamic>>[];

    try {
      final cloudPlannings = await planningCloudService
          .getPlanningForDateRange(startDate, endDate)
          .first;

      for (final planning in cloudPlannings) {
        if (source == ShoppingListSource.private &&
            planning.visibility != PlanningVisibility.private) {
          continue;
        }
        if (source == ShoppingListSource.group &&
            (planning.visibility != PlanningVisibility.group ||
                planning.groupId != groupId)) {
          continue;
        }

        plannings.add({
          'type': 'cloud',
          'planning': planning,
        });
      }
    } catch (e) {
      print('⚠️ Erreur récupération planning cloud: $e');
    }

    return plannings;
  }

  // ============================================================================
  // CALCUL DES INGRÉDIENTS NÉCESSAIRES
  // ============================================================================

  Future<Map<String, IngredientNeed>> _calculateNeededIngredients(
      List<Map<String, dynamic>> plannings) async {
    final neededIngredients = <String, IngredientNeed>{};

    for (final planningData in plannings) {
      final type = planningData['type'] as String;

      if (type == 'local') {
        await _processLocalPlanning(planningData, neededIngredients);
      } else if (type == 'cloud') {
        await _processCloudPlanning(planningData, neededIngredients);
      }
    }

    return neededIngredients;
  }

  Future<void> _processLocalPlanning(
      Map<String, dynamic> planningData,
      Map<String, IngredientNeed> neededIngredients,
      ) async {
    final planning = planningData['planning'] as MealPlanningData;
    final recette = planningData['recette'] as Recette;
    final servings = planningData['servings'] as int;

    final recetteIngredients = await recetteRepo.getIngredientsForRecette(recette.id);
    final portionFactor = servings / recette.servings;

    for (final item in recetteIngredients) {
      final ri = item['recetteIngredient'] as RecetteIngredient;
      final ingredient = item['ingredient'] as Ingredient?;

      if (ingredient == null) continue;

      final gramsQuantity = UnitConverter.toGrams(
        quantity: ri.quantity * portionFactor,
        unit: ri.unit,
        weightPerPieceGrams: ri.weightPerUnitG ?? ingredient.avgWeightPerUnitG,
        densityGramsPerMl: ri.densityGPerMl ?? ingredient.densityGPerMl ?? 1.0,
      );

      final key = 'local_${ingredient.id}';
      if (neededIngredients.containsKey(key)) {
        neededIngredients[key]!.addQuantity(gramsQuantity);
      } else {
        neededIngredients[key] = IngredientNeed(
          ingredient: ingredient,
          quantityGrams: gramsQuantity,
        );
      }
    }
  }

  Future<void> _processCloudPlanning(
      Map<String, dynamic> planningData,
      Map<String, IngredientNeed> neededIngredients,
      ) async {
    final planning = planningData['planning'] as PlanningFirestore;

    try {
      final recetteDoc = await recetteCloudService.getRecetteById(planning.recetteId);
      if (recetteDoc == null) return;

      final ingredients = await recetteCloudService.getIngredients(planning.recetteId);
      if (ingredients.isEmpty) return;

      double servings = 1.0;
      if (planning.eaters != null && planning.eaters!.isNotEmpty) {
        try {
          final eatersList = jsonDecode(planning.eaters!);
          servings = eatersList.length.toDouble();
        } catch (e) {
          print('⚠️ Impossible de parser eaters: ${planning.eaters}');
        }
      }

      for (final ingredient in ingredients) {
        final gramsQuantity = UnitConverter.toGrams(
          quantity: ingredient.quantity * servings,
          unit: ingredient.unit,
          weightPerPieceGrams: ingredient.avgWeightPerUnitG,
          densityGramsPerMl: ingredient.densityGPerMl ?? 1.0,
        );

        final key = 'cloud_${ingredient.ingredientId}';
        if (neededIngredients.containsKey(key)) {
          neededIngredients[key]!.addQuantity(gramsQuantity);
        } else {
          neededIngredients[key] = IngredientNeed(
            cloudIngredient: ingredient,
            quantityGrams: gramsQuantity,
          );
        }
      }
    } catch (e, stackTrace) {
      print('❌ Erreur processCloudPlanning: $e');
      print('Stack: $stackTrace');
    }
  }

  // ============================================================================
  // SOUSTRACTION DU STOCK - CORRIGÉ AVEC CLOUD
  // ============================================================================

  Future<void> _subtractStock(
      Map<String, IngredientNeed> neededIngredients, {
        ShoppingListSource? source,
        String? groupId,
      }) async {
    print('🔄 Soustraction du stock...');
    print('   Source: ${source?.name ?? "all"}');
    print('   GroupId: $groupId');

    int subtractedCount = 0;
    final stockItems = <Map<String, dynamic>>[];

    // 1. Récupérer le stock local
    final localFrigoItems = await frigoRepo.getAllFrigoWithIngredients();
    print('   → ${localFrigoItems.length} article(s) en stock local');

    for (final item in localFrigoItems) {
      final frigo = item['frigo'] as FrigoData;
      final ingredient = item['ingredient'] as Ingredient?;
      if (ingredient == null) continue;

      stockItems.add({
        'type': 'local',
        'ingredientId': ingredient.id.toString(),
        'ingredientName': ingredient.name,
        'quantity': frigo.quantity,
        'unit': frigo.unit,
        'densityGPerMl': ingredient.densityGPerMl,
        'avgWeightPerUnitG': ingredient.avgWeightPerUnitG,
      });
    }

    // 2. Récupérer le stock cloud si nécessaire
    try {
      if (source == null ||
          source == ShoppingListSource.all ||
          source == ShoppingListSource.private ||
          source == ShoppingListSource.group) {

        final cloudStocks = await frigoCloudService.getMyStock().first;
        print('   → ${cloudStocks.length} article(s) en stock cloud');

        for (final cloudFrigo in cloudStocks) {
          // Filtrer selon la source
          if (source == ShoppingListSource.group && cloudFrigo.groupId != groupId) {
            continue;
          }
          if (source == ShoppingListSource.private &&
              cloudFrigo.visibility != FrigoVisibility.private) {
            continue;
          }

          stockItems.add({
            'type': 'cloud',
            'ingredientId': cloudFrigo.ingredientId,
            'ingredientName': cloudFrigo.ingredientName,
            'quantity': cloudFrigo.quantity,
            'unit': cloudFrigo.unit,
            'densityGPerMl': cloudFrigo.densityGPerMl,
            'avgWeightPerUnitG': cloudFrigo.avgWeightPerUnitG,
          });
        }
      }
    } catch (e) {
      print('   ⚠️ Erreur récupération stock cloud: $e');
    }

    print('   → ${stockItems.length} article(s) en stock total');

    // 3. Soustraire chaque article du stock
    for (final stockItem in stockItems) {
      final type = stockItem['type'] as String;
      final ingredientId = stockItem['ingredientId'] as String;
      final ingredientName = stockItem['ingredientName'] as String;
      final quantity = stockItem['quantity'] as double;
      final unit = stockItem['unit'] as String;
      final densityGPerMl = stockItem['densityGPerMl'] as double?;
      final avgWeightPerUnitG = stockItem['avgWeightPerUnitG'] as double?;

      // Calculer la quantité en stock en grammes
      final stockGrams = UnitConverter.toGrams(
        quantity: quantity,
        unit: unit,
        weightPerPieceGrams: avgWeightPerUnitG,
        densityGramsPerMl: densityGPerMl ?? 1.0,
      );

      // Chercher dans les clés local ET cloud
      final localKey = 'local_$ingredientId';
      final cloudKey = 'cloud_$ingredientId';

      bool subtracted = false;

      // Essayer la clé locale
      if (neededIngredients.containsKey(localKey)) {
        final beforeQuantity = neededIngredients[localKey]!.quantityGrams;
        neededIngredients[localKey]!.subtractStock(stockGrams);
        final afterQuantity = neededIngredients[localKey]!.quantityGrams;

        print('   ✅ $ingredientName (local): ${beforeQuantity.toStringAsFixed(0)}g → ${afterQuantity.toStringAsFixed(0)}g (stock: ${stockGrams.toStringAsFixed(0)}g)');
        subtracted = true;
        subtractedCount++;
      }

      // Essayer la clé cloud
      if (neededIngredients.containsKey(cloudKey)) {
        final beforeQuantity = neededIngredients[cloudKey]!.quantityGrams;
        neededIngredients[cloudKey]!.subtractStock(stockGrams);
        final afterQuantity = neededIngredients[cloudKey]!.quantityGrams;

        print('   ✅ $ingredientName (cloud): ${beforeQuantity.toStringAsFixed(0)}g → ${afterQuantity.toStringAsFixed(0)}g (stock: ${stockGrams.toStringAsFixed(0)}g)');
        subtracted = true;
        subtractedCount++;
      }

      if (!subtracted) {
        print('   ⚠️ $ingredientName: en stock ($type) mais pas dans la liste planifiée');
      }
    }

    // Supprimer les ingrédients qui ne sont plus nécessaires
    final removedCount = neededIngredients.length;
    neededIngredients.removeWhere((key, value) => value.quantityGrams <= 0);
    final finalCount = neededIngredients.length;

    print('   → $subtractedCount ingrédient(s) traité(s)');
    print('   → ${removedCount - finalCount} ingrédient(s) supprimé(s) (stock suffisant)');
  }

  // ============================================================================
  // DIAGNOSTIC
  // ============================================================================

  Future<void> diagnosePlanningIssues({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    print('🔍 === DIAGNOSTIC DES PROBLÈMES DE PLANNING ===');

    print('\n📱 PLANNINGS LOCAUX:');
    final localPlannings = await _fetchLocalPlannings(startDate, endDate);
    print('   → ${localPlannings.length} planning(s) local(aux)');

    for (final planning in localPlannings) {
      final p = planning['planning'] as MealPlanningData;
      final r = planning['recette'] as Recette;
      print('   ✓ ${p.mealType}: ${r.name} (recetteId=${p.recetteId})');

      final ingredients = await recetteRepo.getIngredientsForRecette(r.id);
      print('     → ${ingredients.length} ingrédient(s)');
    }

    print('\n☁️ PLANNINGS CLOUD:');
    try {
      final cloudPlannings = await planningCloudService
          .getPlanningForDateRange(startDate, endDate)
          .first;
      print('   → ${cloudPlannings.length} planning(s) cloud');

      for (final planning in cloudPlannings) {
        print('   ✓ ${planning.mealType}: ${planning.recetteName} (recetteId=${planning.recetteId})');

        final recetteDoc = await recetteCloudService.getRecetteById(planning.recetteId);

        if (recetteDoc != null) {
          print('     ✅ Recette existe dans Firestore');

          final ingredients = await recetteCloudService.getIngredients(planning.recetteId);
          print('     → ${ingredients.length} ingrédient(s) dans Firestore');

          if (ingredients.isEmpty) {
            print('     ⚠️ PROBLÈME: Aucun ingrédient dans la sous-collection "ingredients"!');
          }
        } else {
          print('     ❌ PROBLÈME: Recette ${planning.recetteId} n\'existe PAS dans Firestore!');
        }
      }
    } catch (e) {
      print('   ❌ Erreur: $e');
    }

    print('\n=== FIN DU DIAGNOSTIC ===\n');
  }
}

// ============================================================================
// CLASSE HELPER
// ============================================================================

class IngredientNeed {
  final Ingredient? ingredient;
  final RecetteIngredientFirestore? cloudIngredient;
  double quantityGrams;

  IngredientNeed({
    this.ingredient,
    this.cloudIngredient,
    required this.quantityGrams,
  }) : assert(ingredient != null || cloudIngredient != null,
  'Au moins un type d\'ingrédient doit être fourni');

  void addQuantity(double grams) {
    quantityGrams += grams;
  }

  void subtractStock(double stockGrams) {
    quantityGrams = (quantityGrams - stockGrams).clamp(0, double.infinity);
  }
}