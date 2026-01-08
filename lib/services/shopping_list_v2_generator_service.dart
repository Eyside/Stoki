// lib/services/shopping_list_v2_generator_service.dart
// Service de génération de liste avec répartition intelligente par source
// VERSION CLOUD: Utilise IngredientFirestore au lieu d'Ingredient local

import 'dart:convert';
import '../models/recette_firestore.dart';
import '../services/planning_firestore_service.dart';
import '../services/recette_firestore_service.dart';
import '../services/frigo_firestore_service.dart';
import '../services/ingredient_firestore_service.dart';
import '../utils/unit_converter.dart';

/// Item de liste avec origine des besoins
class ShoppingItemWithOrigin {
  final String id;
  final String ingredientId;
  final String ingredientName;
  final double totalQuantity;
  final String unit;
  final String? category;

  /// Map sourceId -> quantité en grammes nécessaire
  final Map<String, double> needsBySource;

  final double? caloriesPer100g;
  final double? proteinsPer100g;
  final double? fatsPer100g;
  final double? carbsPer100g;
  final double? fibersPer100g;
  final double? densityGPerMl;
  final double? avgWeightPerUnitG;

  final bool isCompleted;

  ShoppingItemWithOrigin({
    required this.id,
    required this.ingredientId,
    required this.ingredientName,
    required this.totalQuantity,
    required this.unit,
    this.category,
    required this.needsBySource,
    this.caloriesPer100g,
    this.proteinsPer100g,
    this.fatsPer100g,
    this.carbsPer100g,
    this.fibersPer100g,
    this.densityGPerMl,
    this.avgWeightPerUnitG,
    this.isCompleted = false,
  });

  ShoppingItemWithOrigin copyWith({
    double? totalQuantity,
    bool? isCompleted,
  }) {
    return ShoppingItemWithOrigin(
      id: id,
      ingredientId: ingredientId,
      ingredientName: ingredientName,
      totalQuantity: totalQuantity ?? this.totalQuantity,
      unit: unit,
      category: category,
      needsBySource: needsBySource,
      caloriesPer100g: caloriesPer100g,
      proteinsPer100g: proteinsPer100g,
      fatsPer100g: fatsPer100g,
      carbsPer100g: carbsPer100g,
      fibersPer100g: fibersPer100g,
      densityGPerMl: densityGPerMl,
      avgWeightPerUnitG: avgWeightPerUnitG,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class ShoppingListV2GeneratorService {
  final PlanningFirestoreService planningService;
  final RecetteFirestoreService recetteService;
  final FrigoFirestoreService frigoService;
  final IngredientFirestoreService ingredientService;

  ShoppingListV2GeneratorService({
    required this.planningService,
    required this.recetteService,
    required this.frigoService,
    required this.ingredientService,
  });

  /// Génère une liste intelligente avec répartition par source
  Future<List<ShoppingItemWithOrigin>> generateSmartList({
    required List<String> sources,
    required DateTime startDate,
    required DateTime endDate,
    required bool subtractStock,
  }) async {
    print('🔄 Génération liste intelligente...');
    print('   Sources: ${sources.join(", ")}');
    print('   Période: ${startDate.day}/${startDate.month} → ${endDate.day}/${endDate.month}');
    print('   Soustraire stock: $subtractStock');

    // Map: ingredientId -> Map<sourceId, quantityGrams>
    final needsByIngredient = <String, Map<String, double>>{};
    final ingredientInfo = <String, RecetteIngredientFirestore>{};

    // 1. Parcourir chaque source
    for (final sourceId in sources) {
      print('\n📋 Traitement source: $sourceId');

      final plannings = await (sourceId == 'private'
          ? planningService.getPlanningForDateRange(startDate, endDate).first
          : planningService.getGroupPlanning(sourceId).first);

      final filteredPlannings = plannings.where((p) {
        return p.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
            p.date.isBefore(endDate.add(const Duration(days: 1)));
      }).toList();

      print('   → ${filteredPlannings.length} planning(s) trouvé(s)');

      // 2. Pour chaque planning, récupérer les ingrédients
      for (final planning in filteredPlannings) {
        try {
          final recetteDoc = await recetteService.getRecetteById(planning.recetteId);
          if (recetteDoc == null) {
            print('   ⚠️ Recette ${planning.recetteId} introuvable');
            continue;
          }

          final ingredients = await recetteService.getIngredients(planning.recetteId);

          double servings = 1.0;
          if (planning.eaters != null && planning.eaters!.isNotEmpty) {
            try {
              final eatersList = jsonDecode(planning.eaters!);
              servings = eatersList.length.toDouble();
            } catch (e) {
              print('   ⚠️ Erreur parsing eaters: $e');
            }
          }

          for (final ingredient in ingredients) {
            final gramsQuantity = UnitConverter.toGrams(
              quantity: ingredient.quantity * servings,
              unit: ingredient.unit,
              weightPerPieceGrams: ingredient.avgWeightPerUnitG,
              densityGramsPerMl: ingredient.densityGPerMl ?? 1.0,
            );

            final key = ingredient.ingredientId;

            // Ajouter à la map des besoins
            needsByIngredient.putIfAbsent(key, () => {});
            needsByIngredient[key]!.update(
              sourceId,
                  (value) => value + gramsQuantity,
              ifAbsent: () => gramsQuantity,
            );

            // Garder les infos de l'ingrédient
            if (!ingredientInfo.containsKey(key)) {
              ingredientInfo[key] = ingredient;
            }
          }
        } catch (e) {
          print('   ❌ Erreur traitement planning ${planning.id}: $e');
        }
      }
    }

    print('\n✅ ${needsByIngredient.length} ingrédients uniques trouvés');

    // 3. Soustraire le stock si demandé
    if (subtractStock) {
      await _subtractStockSmart(needsByIngredient, sources);
    }

    // 4. Convertir en ShoppingItemWithOrigin
    final items = <ShoppingItemWithOrigin>[];
    for (final entry in needsByIngredient.entries) {
      final ingredientId = entry.key;
      final needsBySource = entry.value;

      // Calculer la quantité totale
      final totalGrams = needsBySource.values.fold<double>(0.0, (sum, q) => sum + q);

      if (totalGrams <= 0) continue;

      final info = ingredientInfo[ingredientId];
      if (info == null) continue;

      // Convertir en unité appropriée
      final displayQuantity = totalGrams / 1000.0;
      final displayUnit = displayQuantity >= 1 ? 'kg' : 'g';
      final finalQuantity = displayQuantity >= 1 ? displayQuantity : totalGrams;

      items.add(ShoppingItemWithOrigin(
        id: ingredientId,
        ingredientId: ingredientId,
        ingredientName: info.ingredientName,
        totalQuantity: finalQuantity,
        unit: displayUnit,
        category: null, // La catégorie sera récupérée depuis IngredientFirestore
        needsBySource: needsBySource,
        caloriesPer100g: info.caloriesPer100g,
        proteinsPer100g: info.proteinsPer100g,
        fatsPer100g: info.fatsPer100g,
        carbsPer100g: info.carbsPer100g,
        fibersPer100g: info.fibersPer100g,
        densityGPerMl: info.densityGPerMl,
        avgWeightPerUnitG: info.avgWeightPerUnitG,
      ));
    }

    // Enrichir avec les catégories depuis IngredientFirestore
    for (var i = 0; i < items.length; i++) {
      try {
        final ingredient = await ingredientService.getById(items[i].ingredientId);
        if (ingredient != null && ingredient.category != null) {
          items[i] = ShoppingItemWithOrigin(
            id: items[i].id,
            ingredientId: items[i].ingredientId,
            ingredientName: items[i].ingredientName,
            totalQuantity: items[i].totalQuantity,
            unit: items[i].unit,
            category: ingredient.category,
            needsBySource: items[i].needsBySource,
            caloriesPer100g: items[i].caloriesPer100g,
            proteinsPer100g: items[i].proteinsPer100g,
            fatsPer100g: items[i].fatsPer100g,
            carbsPer100g: items[i].carbsPer100g,
            fibersPer100g: items[i].fibersPer100g,
            densityGPerMl: items[i].densityGPerMl,
            avgWeightPerUnitG: items[i].avgWeightPerUnitG,
          );
        }
      } catch (e) {
        print('⚠️ Impossible de récupérer la catégorie pour ${items[i].ingredientName}');
      }
    }

    // Trier par catégorie puis nom
    items.sort((a, b) {
      final catCompare = (a.category ?? 'Autre').compareTo(b.category ?? 'Autre');
      if (catCompare != 0) return catCompare;
      return a.ingredientName.compareTo(b.ingredientName);
    });

    print('✅ ${items.length} articles dans la liste finale');
    return items;
  }

  /// Soustrait le stock de manière intelligente par source
  Future<void> _subtractStockSmart(
      Map<String, Map<String, double>> needsByIngredient,
      List<String> sources,
      ) async {
    print('\n🔄 Soustraction du stock...');

    // Récupérer tout le stock
    final allStock = await frigoService.getMyStock().first;
    print('   → ${allStock.length} article(s) en stock');

    for (final stockItem in allStock) {
      final ingredientId = stockItem.ingredientId;

      // Vérifier si cet ingrédient est nécessaire
      if (!needsByIngredient.containsKey(ingredientId)) continue;

      // Calculer la quantité en stock en grammes
      final stockGrams = UnitConverter.toGrams(
        quantity: stockItem.quantity,
        unit: stockItem.unit,
        weightPerPieceGrams: stockItem.avgWeightPerUnitG,
        densityGramsPerMl: stockItem.densityGPerMl ?? 1.0,
      );

      // Déterminer à quelle(s) source(s) ce stock correspond
      final stockSource = stockItem.visibility.name == 'private'
          ? 'private'
          : stockItem.groupId;

      if (stockSource == null) continue;

      // Soustraire du besoin correspondant
      if (needsByIngredient[ingredientId]!.containsKey(stockSource)) {
        final before = needsByIngredient[ingredientId]![stockSource]!;
        final afterValue = before - stockGrams;
        final after = afterValue < 0 ? 0.0 : afterValue;
        needsByIngredient[ingredientId]![stockSource] = after;

        print('   ✅ ${stockItem.ingredientName} ($stockSource): ${before.toStringAsFixed(0)}g → ${after.toStringAsFixed(0)}g');
      }
    }

    // Supprimer les sources avec besoin à 0
    needsByIngredient.removeWhere((key, sources) {
      sources.removeWhere((_, qty) => qty <= 0);
      return sources.isEmpty;
    });

    print('   ✅ Soustraction terminée');
  }
}