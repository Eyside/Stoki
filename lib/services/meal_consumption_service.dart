// lib/services/meal_consumption_service.dart
// Deux actions distinctes sur un repas planifié :
//   • CUISINER   = déduire les ingrédients du stock
//   • CONSOMMER  = ajouter MA part de calories à MON suivi calorique
//
// Règle de portions (voir PortionCalculator) : la recette représente une
// personne normale (x1) ; chaque convive reçoit la recette multipliée par son
// coefficient, divisée par les portions de la recette.

import 'package:flutter/foundation.dart';
import '../models/frigo_firestore.dart';
import '../models/planning_firestore.dart';
import '../models/recette_firestore.dart';
import 'calorie_tracking_firestore_service.dart';
import '../utils/portion_calculator.dart';
import '../utils/unit_converter.dart';
import 'planning_firestore_service.dart';
import 'recette_firestore_service.dart';
import 'frigo_firestore_service.dart';

class MealConsumptionResult {
  final bool success;
  final String message;
  final List<String> warnings;
  final List<IngredientStockAdjustment> stockAdjustments;

  MealConsumptionResult({
    required this.success,
    required this.message,
    this.warnings = const [],
    this.stockAdjustments = const [],
  });
}

class IngredientStockAdjustment {
  final String ingredientName;
  final double quantityNeeded;
  final double quantityAvailable;
  final String unit;
  final bool sufficient;

  IngredientStockAdjustment({
    required this.ingredientName,
    required this.quantityNeeded,
    required this.quantityAvailable,
    required this.unit,
    required this.sufficient,
  });
}

class MealConsumptionService {
  final PlanningFirestoreService _planningService;
  final RecetteFirestoreService _recetteService;
  final FrigoFirestoreService _frigoService;
  final CalorieTrackingFirestoreService _calorieTrackingService;

  /// Tolérance (en grammes) pour éviter les erreurs d'arrondi.
  static const double _epsilonGrams = 0.001;

  MealConsumptionService({
    required PlanningFirestoreService planningService,
    required RecetteFirestoreService recetteService,
    required FrigoFirestoreService frigoService,
    required CalorieTrackingFirestoreService calorieTrackingService,
  })  : _planningService = planningService,
        _recetteService = recetteService,
        _frigoService = frigoService,
        _calorieTrackingService = calorieTrackingService;

  // ==========================================================================
  // OUTILS
  // ==========================================================================

  /// Nombre de portions prévues par la recette (1 si introuvable).
  Future<int> getRecipeServings(String recetteId) async {
    final recette = await _recetteService.getRecetteById(recetteId);
    return recette?.servings ?? 1;
  }

  /// Part totale du repas : somme des coefficients des convives / portions de la recette.
  Future<double> computeScale(String recetteId, List<EaterPortion> eaters) async {
    return PortionCalculator.mealFactor(
      multipliers: eaters.map((e) => e.multiplier),
      recipeServings: await getRecipeServings(recetteId),
    );
  }

  /// Convertit une quantité en grammes (les unités inconnues sont traitées comme des grammes).
  double _toGrams(
      double quantity,
      String unit, {
        double? weightPerPieceGrams,
        double? densityGPerMl,
      }) {
    return UnitConverter.toGrams(
      quantity: quantity,
      unit: unit,
      weightPerPieceGrams: weightPerPieceGrams,
      densityGramsPerMl: densityGPerMl ?? 1.0,
    );
  }

  /// Quantité d'un article de stock en grammes.
  /// On utilise les infos de conversion du stock, sinon celles de la recette.
  double _stockItemGrams(FrigoFirestore item, RecetteIngredientFirestore ingredient) {
    return _toGrams(
      item.quantity,
      item.unit,
      weightPerPieceGrams: item.avgWeightPerUnitG ?? ingredient.avgWeightPerUnitG,
      densityGPerMl: item.densityGPerMl ?? ingredient.densityGPerMl,
    );
  }

  /// Articles du stock qui correspondent à un ingrédient de recette.
  List<FrigoFirestore> _matchingStock(
      List<FrigoFirestore> stock,
      RecetteIngredientFirestore ingredient,
      ) {
    return stock.where((item) => item.ingredientId == ingredient.ingredientId).toList();
  }

  // ==========================================================================
  // VÉRIFICATION DU STOCK (avec conversion des unités)
  // ==========================================================================

  /// [scale] = part du repas par rapport à la recette de base.
  /// Stock concerné par un repas : repas de groupe = stock du groupe (tous les
  /// membres) ; repas privé = mon stock privé.
  Future<List<FrigoFirestore>> _stockFor(String? groupId) async {
    if (groupId != null) {
      return _frigoService.getGroupStock(groupId).first;
    }
    final mine = await _frigoService.getAllMyStocks().first;
    return mine.where((i) => i.visibility == FrigoVisibility.private).toList();
  }

  Future<List<IngredientStockAdjustment>> checkStockAvailability(
      String recetteId, {
        double scale = 1.0,
        String? groupId,
      }) async {
    final adjustments = <IngredientStockAdjustment>[];

    try {
      final ingredients = await _recetteService.getIngredients(recetteId);
      final stock = await _stockFor(groupId);

      for (final ingredient in ingredients) {
        final neededQuantity = ingredient.quantity * scale;
        final neededGrams = _toGrams(
          neededQuantity,
          ingredient.unit,
          weightPerPieceGrams: ingredient.avgWeightPerUnitG,
          densityGPerMl: ingredient.densityGPerMl,
        );

        var availableGrams = 0.0;
        for (final item in _matchingStock(stock, ingredient)) {
          availableGrams += _stockItemGrams(item, ingredient);
        }

        // Affichage dans l'unité de la recette
        final gramsPerRecipeUnit = _toGrams(
          1,
          ingredient.unit,
          weightPerPieceGrams: ingredient.avgWeightPerUnitG,
          densityGPerMl: ingredient.densityGPerMl,
        );
        final availableQuantity =
        gramsPerRecipeUnit > 0 ? availableGrams / gramsPerRecipeUnit : 0.0;

        adjustments.add(IngredientStockAdjustment(
          ingredientName: ingredient.ingredientName,
          quantityNeeded: neededQuantity,
          quantityAvailable: availableQuantity,
          unit: ingredient.unit,
          sufficient: availableGrams + _epsilonGrams >= neededGrams,
        ));
      }
    } catch (e) {
      debugPrint('❌ Erreur lors de la vérification du stock: $e');
    }

    return adjustments;
  }

  // ==========================================================================
  // CUISINER = déduction du stock
  // ==========================================================================

  /// Déduit du stock les ingrédients du repas (pour tous les convives).
  /// Si le stock est insuffisant, on déduit ce qui existe et on le signale
  /// par un message d'information (jamais bloquant).
  Future<MealConsumptionResult> cookMeal({
    required PlanningFirestore planning,
    required List<EaterPortion> eaters,
  }) async {
    if (planning.cooked) {
      return MealConsumptionResult(
        success: false,
        message: 'ℹ️ Ce repas est déjà marqué comme cuisiné.',
      );
    }

    final infos = <String>[];

    try {
      debugPrint('🍳 Cuisson du repas: ${planning.recetteName}');

      final scale = await computeScale(planning.recetteId, eaters);

      final unknownCount = eaters.where((e) => !e.known).length;
      if (unknownCount > 0) {
        infos.add(
          'ℹ️ $unknownCount convive(s) sans profil : comptés comme une personne normale.',
        );
      }

      final ingredients = await _recetteService.getIngredients(planning.recetteId);
      final stock = await _stockFor(
        planning.visibility == PlanningVisibility.group ? planning.groupId : null,
      );

      for (final ingredient in ingredients) {
        final missing = await _deductIngredientFromStock(
          ingredient: ingredient,
          scale: scale,
          stock: stock,
        );
        if (missing > 0.001) {
          infos.add(
            'ℹ️ ${ingredient.ingredientName} : ${missing.toStringAsFixed(missing < 10 ? 1 : 0)} ${ingredient.unit} '
                'non déduit(s) (pas assez en stock).',
          );
        }
      }

      await _planningService.markCooked(planning.id);

      return MealConsumptionResult(
        success: true,
        message: '🍳 Repas cuisiné : stock mis à jour.',
        warnings: infos,
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Erreur lors de la cuisson du repas: $e');
      debugPrint('Stack: $stackTrace');
      return MealConsumptionResult(
        success: false,
        message: '❌ Erreur: $e',
        warnings: infos,
      );
    }
  }

  /// Déduit un ingrédient du stock (FIFO : on commence par ce qui périme en premier).
  /// Retourne la quantité manquante, exprimée dans l'unité de la recette (0 si tout est couvert).
  Future<double> _deductIngredientFromStock({
    required RecetteIngredientFirestore ingredient,
    required double scale,
    required List<FrigoFirestore> stock,
  }) async {
    final items = _matchingStock(stock, ingredient);

    var remainingGrams = _toGrams(
      ingredient.quantity * scale,
      ingredient.unit,
      weightPerPieceGrams: ingredient.avgWeightPerUnitG,
      densityGPerMl: ingredient.densityGPerMl,
    );

    items.sort((a, b) {
      if (a.bestBefore == null && b.bestBefore == null) return 0;
      if (a.bestBefore == null) return 1;
      if (b.bestBefore == null) return -1;
      return a.bestBefore!.compareTo(b.bestBefore!);
    });

    for (final item in items) {
      if (remainingGrams <= _epsilonGrams) break;

      final itemGrams = _stockItemGrams(item, ingredient);
      if (itemGrams <= _epsilonGrams) continue;

      if (itemGrams <= remainingGrams + _epsilonGrams) {
        // Tout l'article est consommé
        await _frigoService.deleteFrigoItem(item.id);
        remainingGrams -= itemGrams;
        debugPrint('🗑️ Article supprimé: ${item.quantity} ${item.unit} de ${item.ingredientName}');
      } else {
        // On retire seulement une partie : la quantité restante garde l'unité de l'article
        final leftGrams = itemGrams - remainingGrams;
        final newQuantity = item.quantity * (leftGrams / itemGrams);
        await _frigoService.updateFrigoItem(
          frigoId: item.id,
          quantity: newQuantity,
          unit: item.unit,
          location: item.location,
          bestBefore: item.bestBefore,
        );
        remainingGrams = 0;
        debugPrint('📉 ${item.ingredientName}: ${item.quantity} → $newQuantity ${item.unit}');
      }
    }

    if (remainingGrams <= _epsilonGrams) return 0;

    final gramsPerRecipeUnit = _toGrams(
      1,
      ingredient.unit,
      weightPerPieceGrams: ingredient.avgWeightPerUnitG,
      densityGPerMl: ingredient.densityGPerMl,
    );
    return gramsPerRecipeUnit > 0 ? remainingGrams / gramsPerRecipeUnit : remainingGrams;
  }

  // ==========================================================================
  // CONSOMMER = calcul calorique
  // ==========================================================================

  /// Calories (et macros) de chaque convive pour ce repas, sans rien enregistrer.
  Future<Map<EaterPortion, double>> previewCalories({
    required PlanningFirestore planning,
    required List<EaterPortion> eaters,
  }) async {
    final servings = await getRecipeServings(planning.recetteId);
    final base = planning.modifiedCalories ?? planning.totalCalories;
    return {
      for (final e in eaters)
        e: base *
            PortionCalculator.eaterFactor(
              multiplier: e.multiplier,
              recipeServings: servings,
            ),
    };
  }

  /// Ajoute MA part du repas à MON suivi calorique. [eaters] contient ma
  /// ligne (coefficient de mon profil) ; chacun consomme pour soi seul.
  Future<MealConsumptionResult> consumeMeal({
    required PlanningFirestore planning,
    required List<EaterPortion> eaters,
  }) async {
    final myUid = _calorieTrackingService.currentUid;
    if (myUid == null) {
      return MealConsumptionResult(
        success: false,
        message: '❌ Vous devez être connecté pour suivre vos calories.',
      );
    }

    try {
      if (await _calorieTrackingService.hasConsumed(planning.id)) {
        return MealConsumptionResult(
          success: false,
          message: 'ℹ️ Vous avez déjà consommé ce repas.',
        );
      }

      final me = eaters.where((e) => e.uid == myUid).isNotEmpty
          ? eaters.firstWhere((e) => e.uid == myUid)
          : (eaters.isNotEmpty ? eaters.first : null);
      if (me == null) {
        return MealConsumptionResult(
          success: false,
          message: '❌ Créez votre profil pour calculer vos calories.',
        );
      }

      final recipeServings = await getRecipeServings(planning.recetteId);
      final factor = PortionCalculator.eaterFactor(
        multiplier: me.multiplier,
        recipeServings: recipeServings,
      );

      final calories = (planning.modifiedCalories ?? planning.totalCalories) * factor;
      await _calorieTrackingService.addEntry(
        planningId: planning.id,
        date: planning.date,
        mealType: planning.mealType,
        calories: calories,
        proteins: (planning.modifiedProteins ?? planning.totalProteins) * factor,
        fats: (planning.modifiedFats ?? planning.totalFats) * factor,
        carbs: (planning.modifiedCarbs ?? planning.totalCarbs) * factor,
        fibers: (planning.modifiedFibers ?? planning.totalFibers) * factor,
        recipeName: planning.recetteName,
      );

      // Repas privé : une seule personne, on peut marquer le repas lui-même.
      if (planning.visibility == PlanningVisibility.private) {
        await _planningService.markConsumed(planning.id);
      }

      return MealConsumptionResult(
        success: true,
        message: '🍽️ Repas consommé ! ${calories.round()} kcal ajoutées à votre suivi.',
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Erreur lors de la consommation du repas: $e');
      debugPrint('Stack: $stackTrace');
      return MealConsumptionResult(
        success: false,
        message: '❌ Erreur: $e',
      );
    }
  }

  /// Résumé du stock pour un repas (utilisé par la fenêtre « Cuisiné »).
  Future<Map<String, dynamic>> getMealConsumptionSummary(
      PlanningFirestore planning, {
        double scale = 1.0,
      }) async {
    final adjustments = await checkStockAvailability(
      planning.recetteId,
      scale: scale,
      groupId: planning.visibility == PlanningVisibility.group ? planning.groupId : null,
    );

    final totalIngredientsCount = adjustments.length;
    final availableCount = adjustments.where((a) => a.sufficient).length;
    final missingCount = totalIngredientsCount - availableCount;

    return {
      'totalIngredients': totalIngredientsCount,
      'availableIngredients': availableCount,
      'missingIngredients': missingCount,
      'canConsume': missingCount == 0,
      'adjustments': adjustments,
    };
  }
}
