// lib/services/meal_consumption_service.dart
// Service pour gérer la consommation des repas planifiés

import 'package:flutter/foundation.dart';
import '../models/planning_firestore.dart';
import '../repositories/calorie_tracking_repository.dart';
import '../utils/portion_calculator.dart';
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
  final CalorieTrackingRepository _calorieTrackingRepo;

  MealConsumptionService({
    required PlanningFirestoreService planningService,
    required RecetteFirestoreService recetteService,
    required FrigoFirestoreService frigoService,
    required CalorieTrackingRepository calorieTrackingRepo,
  })  : _planningService = planningService,
        _recetteService = recetteService,
        _frigoService = frigoService,
        _calorieTrackingRepo = calorieTrackingRepo;

  /// Vérifie la disponibilité des ingrédients dans le stock
  /// [scale] = part du repas par rapport à la recette de base (voir PortionCalculator).
  Future<List<IngredientStockAdjustment>> checkStockAvailability(
      String recetteId, {
      double scale = 1.0,
      }) async {
    final adjustments = <IngredientStockAdjustment>[];

    try {
      // Récupérer les ingrédients de la recette
      final ingredients = await _recetteService.getIngredients(recetteId);

      // Récupérer tout le stock disponible
      final stock = await _frigoService.getAllMyStocks().first;

      for (final ingredient in ingredients) {
        // Chercher l'ingrédient dans le stock
        final stockItem = stock.where(
              (item) => item.ingredientId == ingredient.ingredientId,
        ).toList();

        double availableQuantity = 0;
        for (final item in stockItem) {
          // Convertir les unités si nécessaire
          if (item.unit == ingredient.unit) {
            availableQuantity += item.quantity;
          }
          // TODO: Gérer les conversions d'unités complexes si nécessaire
        }

        final needed = ingredient.quantity * scale;
        adjustments.add(IngredientStockAdjustment(
          ingredientName: ingredient.ingredientName,
          quantityNeeded: needed,
          quantityAvailable: availableQuantity,
          unit: ingredient.unit,
          sufficient: availableQuantity >= needed,
        ));
      }
    } catch (e) {
      debugPrint('❌ Erreur lors de la vérification du stock: $e');
    }

    return adjustments;
  }

  /// Part totale du repas : somme des coefficients des convives / portions de la recette.
  Future<double> computeScale(String recetteId, List<EaterPortion> eaters) async {
    final recette = await _recetteService.getRecetteById(recetteId);
    return PortionCalculator.mealFactor(
      multipliers: eaters.map((e) => e.multiplier),
      recipeServings: recette?.servings ?? 1,
    );
  }

  /// Marque un repas comme consommé.
  /// Règle : la recette = 1 personne normale (x1). Chaque convive reçoit la
  /// recette multipliée par son coefficient (0,5 / 1 / 1,5), divisée par les
  /// portions de la recette. Le stock est déduit une seule fois pour tout le repas.
  Future<MealConsumptionResult> consumeMeal({
    required PlanningFirestore planning,
    required List<EaterPortion> eaters,
    bool deductFromStock = true,
  }) async {
    final warnings = <String>[];

    try {
      debugPrint('🍽️ Consommation du repas: ${planning.recetteName}');

      final recette = await _recetteService.getRecetteById(planning.recetteId);
      final recipeServings = recette?.servings ?? 1;
      final scale = PortionCalculator.mealFactor(
        multipliers: eaters.map((e) => e.multiplier),
        recipeServings: recipeServings,
      );

      // Seuls les profils retrouvés sur cet appareil peuvent recevoir des calories
      final trackable = eaters.where((e) => e.known && e.profileId != null).toList();
      if (trackable.isEmpty) {
        return MealConsumptionResult(
          success: false,
          message: '❌ Aucun profil à qui attribuer les calories. Créez un profil d\'abord.',
        );
      }
      final unknownCount = eaters.length - trackable.length;
      if (unknownCount > 0) {
        warnings.add(
          '⚠️ $unknownCount convive(s) introuvable(s) sur cet appareil : '
              'leurs calories ne sont pas enregistrées (stock compté x1 pour eux).',
        );
      }

      // 1. Vérifier la disponibilité du stock si nécessaire
      List<IngredientStockAdjustment>? stockAdjustments;
      if (deductFromStock) {
        stockAdjustments = await checkStockAvailability(planning.recetteId, scale: scale);

        // Vérifier s'il y a des ingrédients insuffisants
        final insufficient = stockAdjustments.where((a) => !a.sufficient).toList();
        if (insufficient.isNotEmpty) {
          for (final adj in insufficient) {
            warnings.add(
              '⚠️ ${adj.ingredientName}: seulement ${adj.quantityAvailable} ${adj.unit} '
                  'disponible(s) (${adj.quantityNeeded} ${adj.unit} nécessaire(s))',
            );
          }
        }
      }

      // 2. Ajouter l'entrée dans le suivi calorique de chaque convive
      final baseCalories = planning.modifiedCalories ?? planning.totalCalories;
      final baseProteins = planning.modifiedProteins ?? planning.totalProteins;
      final baseFats = planning.modifiedFats ?? planning.totalFats;
      final baseCarbs = planning.modifiedCarbs ?? planning.totalCarbs;
      final baseFibers = planning.modifiedFibers ?? planning.totalFibers;

      final perEaterLines = <String>[];
      for (final eater in trackable) {
        final factor = PortionCalculator.eaterFactor(
          multiplier: eater.multiplier,
          recipeServings: recipeServings,
        );
        await _calorieTrackingRepo.addTracking(
          userProfileId: eater.profileId!,
          date: planning.date,
          mealType: planning.mealType,
          calories: baseCalories * factor,
          proteins: baseProteins * factor,
          fats: baseFats * factor,
          carbs: baseCarbs * factor,
          fibers: baseFibers * factor,
        );
        perEaterLines.add('${eater.name} : ${(baseCalories * factor).round()} kcal');
      }

      debugPrint('✅ Calories ajoutées au suivi');

      // 3. Déduire les quantités du stock
      if (deductFromStock && stockAdjustments != null) {
        final ingredients = await _recetteService.getIngredients(planning.recetteId);

        for (final ingredient in ingredients) {
          await _deductIngredientFromStock(
            ingredientId: ingredient.ingredientId,
            ingredientName: ingredient.ingredientName,
            quantityNeeded: ingredient.quantity * scale,
            unit: ingredient.unit,
          );
        }

        debugPrint('✅ Stock mis à jour');
      }

      // 4. Marquer le planning comme consommé (on pourrait ajouter un champ)
      await _planningService.updatePlanning(
        planningId: planning.id,
        notes: '✅ Consommé le ${DateTime.now().day}/${DateTime.now().month}',
      );

      return MealConsumptionResult(
        success: true,
        message: warnings.isEmpty
            ? '✅ Repas consommé ! ${perEaterLines.join(' • ')}'
            : '✅ Repas consommé (avec avertissements) ${perEaterLines.join(' • ')}',
        warnings: warnings,
        stockAdjustments: stockAdjustments ?? [],
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Erreur lors de la consommation du repas: $e');
      debugPrint('Stack: $stackTrace');

      return MealConsumptionResult(
        success: false,
        message: '❌ Erreur: $e',
        warnings: warnings,
      );
    }
  }

  /// Déduit un ingrédient du stock
  Future<void> _deductIngredientFromStock({
    required String ingredientId,
    required String ingredientName,
    required double quantityNeeded,
    required String unit,
  }) async {
    // Récupérer tous les items de cet ingrédient dans le stock
    final stock = await _frigoService.getAllMyStocks().first;
    final items = stock
        .where((item) => item.ingredientId == ingredientId)
        .toList();

    if (items.isEmpty) {
      debugPrint('⚠️ Ingrédient non trouvé dans le stock: $ingredientName');
      return;
    }

    double remainingNeeded = quantityNeeded;

    // Déduire des items existants (FIFO - First In, First Out)
    items.sort((a, b) {
      if (a.bestBefore == null && b.bestBefore == null) return 0;
      if (a.bestBefore == null) return 1;
      if (b.bestBefore == null) return -1;
      return a.bestBefore!.compareTo(b.bestBefore!);
    });

    for (final item in items) {
      if (remainingNeeded <= 0) break;

      if (item.unit != unit) {
        // TODO: Gérer les conversions d'unités
        debugPrint('⚠️ Unité différente pour ${item.ingredientName}: ${item.unit} vs $unit');
        continue;
      }

      if (item.quantity <= remainingNeeded) {
        // Supprimer l'item entièrement
        await _frigoService.deleteFrigoItem(item.id);
        remainingNeeded -= item.quantity;
        debugPrint('🗑️ Item supprimé: ${item.quantity} ${item.unit} de ${item.ingredientName}');
      } else {
        // Réduire la quantité
        final newQuantity = item.quantity - remainingNeeded;
        await _frigoService.updateFrigoItem(
          frigoId: item.id,
          quantity: newQuantity,
          unit: item.unit,
          location: item.location,
          bestBefore: item.bestBefore,
        );
        remainingNeeded = 0;
        debugPrint('📉 Quantité réduite: ${item.quantity} → $newQuantity ${item.unit} de ${item.ingredientName}');
      }
    }

    if (remainingNeeded > 0) {
      debugPrint('⚠️ Stock insuffisant: il manque encore $remainingNeeded $unit de $ingredientName');
    }
  }

  /// Obtient un résumé de consommation pour un repas
  Future<Map<String, dynamic>> getMealConsumptionSummary(
      PlanningFirestore planning, {
      double scale = 1.0,
      }) async {
    final ingredients = await _recetteService.getIngredients(planning.recetteId);
    final adjustments = await checkStockAvailability(planning.recetteId, scale: scale);

    final totalIngredientsCount = ingredients.length;
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