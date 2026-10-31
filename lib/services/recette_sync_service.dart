// lib/services/recette_sync_service.dart
import 'package:flutter/foundation.dart';
import '../database.dart';
import '../models/recette_firestore.dart';
import '../repositories/recette_repository.dart';
import 'recette_firestore_service.dart';
import 'auth_service.dart';

/// Service pour synchroniser les recettes SQLite vers Firestore
/// Architecture "Cloud-First" : Firestore est la source de vérité
class RecetteSyncService {
  final RecetteRepository _recetteRepo;
  final RecetteFirestoreService _recetteCloudService;
  final AuthService _authService;

  // Cache pour éviter les syncs multiples
  final Map<int, String> _syncedRecettes = {};

  RecetteSyncService({
    required RecetteRepository recetteRepo,
    required RecetteFirestoreService recetteCloudService,
    required AuthService authService,
  })  : _recetteRepo = recetteRepo,
        _recetteCloudService = recetteCloudService,
        _authService = authService;

  /// Vérifie si l'utilisateur est connecté
  bool get isUserAuthenticated => _authService.currentUser != null;

  /// Synchronise une recette locale vers Firestore (privée)
  /// Retourne l'ID Firestore de la recette synchronisée
  Future<String> syncRecetteToCloud({
    required int localRecetteId,
    bool forceSync = false,
  }) async {
    if (!isUserAuthenticated) {
      throw Exception('Utilisateur non connecté');
    }

    debugPrint('🔄 Synchronisation de la recette locale $localRecetteId vers le cloud...');

    // Vérifier si déjà synchronisée (cache)
    if (!forceSync && _syncedRecettes.containsKey(localRecetteId)) {
      final cloudId = _syncedRecettes[localRecetteId]!;
      debugPrint('✅ Recette déjà synchronisée : $cloudId (depuis le cache)');
      return cloudId;
    }

    // 1. Récupérer la recette locale
    final recette = await _recetteRepo.getRecetteById(localRecetteId);
    if (recette == null) {
      throw Exception('Recette locale $localRecetteId introuvable');
    }

    debugPrint('   📖 Recette trouvée : ${recette.name}');

    // 2. Récupérer les ingrédients locaux
    final ingredients = await _recetteRepo.getIngredientsForRecette(localRecetteId);
    debugPrint('   🥗 ${ingredients.length} ingrédients à synchroniser');

    // 3. Créer la recette dans Firestore (toujours en privé pour les recettes locales)
    final cloudRecetteId = await _recetteCloudService.createRecette(
      name: recette.name,
      instructions: recette.instructions,
      servings: recette.servings,
      category: recette.category,
      notes: recette.notes,
      imageUrl: recette.imageUrl,
      visibility: RecetteVisibility.private,
      groupId: null,
    );

    debugPrint('   ✅ Recette créée dans Firestore : $cloudRecetteId');

    // 4. Synchroniser les ingrédients
    for (final item in ingredients) {
      final ri = item['recetteIngredient'] as RecetteIngredient;
      final ingredient = item['ingredient'] as Ingredient?;

      if (ingredient == null) {
        debugPrint('   ⚠️ Ingrédient ${ri.ingredientId} introuvable, ignoré');
        continue;
      }

      final cloudIngredient = RecetteIngredientFirestore(
        ingredientId: ingredient.id.toString(),
        ingredientName: ingredient.name,
        quantity: ri.quantity,
        unit: ri.unit,
        caloriesPer100g: ingredient.caloriesPer100g,
        proteinsPer100g: ingredient.proteinsPer100g,
        fatsPer100g: ingredient.fatsPer100g,
        carbsPer100g: ingredient.carbsPer100g,
        fibersPer100g: ingredient.fibersPer100g,
        densityGPerMl: ri.densityGPerMl ?? ingredient.densityGPerMl,
        avgWeightPerUnitG: ri.weightPerUnitG ?? ingredient.avgWeightPerUnitG,
      );

      await _recetteCloudService.addIngredient(
        recetteId: cloudRecetteId,
        ingredient: cloudIngredient,
      );

      debugPrint('   ✅ Ingrédient synchronisé : ${ingredient.name}');
    }

    // 5. Mettre en cache
    _syncedRecettes[localRecetteId] = cloudRecetteId;

    debugPrint('🎉 Synchronisation terminée ! Local ID: $localRecetteId → Cloud ID: $cloudRecetteId');

    return cloudRecetteId;
  }

  /// Synchronise une recette locale vers un groupe Firestore
  /// Retourne l'ID Firestore de la recette synchronisée
  Future<String> syncRecetteToGroup({
    required int localRecetteId,
    required String groupId,
    bool forceSync = false,
  }) async {
    if (!isUserAuthenticated) {
      throw Exception('Utilisateur non connecté');
    }

    debugPrint('🔄 Synchronisation de la recette locale $localRecetteId vers le groupe $groupId...');

    // 1. Récupérer la recette locale
    final recette = await _recetteRepo.getRecetteById(localRecetteId);
    if (recette == null) {
      throw Exception('Recette locale $localRecetteId introuvable');
    }

    debugPrint('   📖 Recette trouvée : ${recette.name}');

    // 2. Récupérer les ingrédients locaux
    final ingredients = await _recetteRepo.getIngredientsForRecette(localRecetteId);
    debugPrint('   🥗 ${ingredients.length} ingrédients à synchroniser');

    // 3. Créer la recette dans Firestore (mode groupe)
    final cloudRecetteId = await _recetteCloudService.createRecette(
      name: recette.name,
      instructions: recette.instructions,
      servings: recette.servings,
      category: recette.category,
      notes: recette.notes,
      imageUrl: recette.imageUrl,
      visibility: RecetteVisibility.group,
      groupId: groupId,
    );

    debugPrint('   ✅ Recette créée dans Firestore pour le groupe : $cloudRecetteId');

    // 4. Synchroniser les ingrédients
    for (final item in ingredients) {
      final ri = item['recetteIngredient'] as RecetteIngredient;
      final ingredient = item['ingredient'] as Ingredient?;

      if (ingredient == null) {
        debugPrint('   ⚠️ Ingrédient ${ri.ingredientId} introuvable, ignoré');
        continue;
      }

      final cloudIngredient = RecetteIngredientFirestore(
        ingredientId: ingredient.id.toString(),
        ingredientName: ingredient.name,
        quantity: ri.quantity,
        unit: ri.unit,
        caloriesPer100g: ingredient.caloriesPer100g,
        proteinsPer100g: ingredient.proteinsPer100g,
        fatsPer100g: ingredient.fatsPer100g,
        carbsPer100g: ingredient.carbsPer100g,
        fibersPer100g: ingredient.fibersPer100g,
        densityGPerMl: ri.densityGPerMl ?? ingredient.densityGPerMl,
        avgWeightPerUnitG: ri.weightPerUnitG ?? ingredient.avgWeightPerUnitG,
      );

      await _recetteCloudService.addIngredient(
        recetteId: cloudRecetteId,
        ingredient: cloudIngredient,
      );

      debugPrint('   ✅ Ingrédient synchronisé : ${ingredient.name}');
    }

    debugPrint('🎉 Synchronisation groupe terminée ! Local ID: $localRecetteId → Cloud ID: $cloudRecetteId');

    return cloudRecetteId;
  }

  /// Vérifie si une recette locale est déjà synchronisée
  bool isRecetteSynced(int localRecetteId) {
    return _syncedRecettes.containsKey(localRecetteId);
  }

  /// Récupère l'ID cloud d'une recette locale synchronisée
  String? getCloudId(int localRecetteId) {
    return _syncedRecettes[localRecetteId];
  }

  /// Vide le cache de synchronisation
  void clearCache() {
    _syncedRecettes.clear();
    debugPrint('🧹 Cache de synchronisation vidé');
  }

  /// Synchronise toutes les recettes locales vers le cloud (mode privé)
  /// Utile pour une migration complète
  Future<Map<int, String>> syncAllRecettesToCloud() async {
    if (!isUserAuthenticated) {
      throw Exception('Utilisateur non connecté');
    }

    debugPrint('🔄 Synchronisation de TOUTES les recettes locales...');

    final allRecettes = await _recetteRepo.getAllRecettes();
    final results = <int, String>{};

    for (final recette in allRecettes) {
      try {
        final cloudId = await syncRecetteToCloud(
          localRecetteId: recette.id,
          forceSync: false,
        );
        results[recette.id] = cloudId;
      } catch (e) {
        debugPrint('❌ Erreur lors de la sync de ${recette.name}: $e');
      }
    }

    debugPrint('🎉 Synchronisation globale terminée : ${results.length}/${allRecettes.length} recettes');

    return results;
  }

  /// Récupère les statistiques de synchronisation
  Map<String, dynamic> getSyncStats() {
    return {
      'cached_syncs': _syncedRecettes.length,
      'is_authenticated': isUserAuthenticated,
    };
  }
}