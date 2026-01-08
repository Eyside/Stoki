// lib/providers.dart (VERSION MISE À JOUR POUR LE CLOUD)
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database.dart';
import 'repositories/ingredient_repository.dart';
import 'repositories/frigo_repository.dart';
import 'repositories/recette_repository.dart';
import 'repositories/planning_repository.dart';
import 'repositories/user_profile_repository.dart';
import 'services/shopping_list_generator_service.dart';
import 'services/shopping_list_cloud_service.dart';
import 'services/planning_firestore_service.dart';
import 'services/recette_firestore_service.dart';
import 'services/frigo_firestore_service.dart';
import 'services/recette_sync_service.dart';
import 'services/auth_service.dart';
import 'services/group_profile_service.dart';
import 'models/frigo_firestore.dart';
import '../services/shopping_list_v2_generator_service.dart';
import '../services/ingredient_firestore_service.dart';
import '../services/meal_consumption_service.dart';
import '../repositories/calorie_tracking_repository.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

final ingredientRepositoryProvider = Provider<IngredientRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return IngredientRepository(db);
});

// ⚠️ CONSERVÉ pour compatibilité mais ne devrait plus être utilisé
final frigoRepositoryProvider = Provider<FrigoRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return FrigoRepository();
});

final recetteRepositoryProvider = Provider<RecetteRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return RecetteRepository(db);
});

final planningRepositoryProvider = Provider<PlanningRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return PlanningRepository(db);
});

final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final groupProfileService = ref.watch(groupProfileServiceProvider);
  return UserProfileRepository(db, groupProfileService: groupProfileService);
});

// ============================================================================
// SERVICES CLOUD
// ============================================================================

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final shoppingListCloudServiceProvider = Provider<ShoppingListCloudService>((ref) {
  return ShoppingListCloudService();
});

final planningFirestoreServiceProvider = Provider<PlanningFirestoreService>((ref) {
  return PlanningFirestoreService();
});

final recetteFirestoreServiceProvider = Provider<RecetteFirestoreService>((ref) {
  return RecetteFirestoreService();
});

final frigoFirestoreServiceProvider = Provider<FrigoFirestoreService>((ref) {
  return FrigoFirestoreService();
});

final groupProfileServiceProvider = Provider<GroupProfileService>((ref) {
  return GroupProfileService();
});

// Service de synchronisation des recettes
final recetteSyncServiceProvider = Provider<RecetteSyncService>((ref) {
  return RecetteSyncService(
    recetteRepo: ref.watch(recetteRepositoryProvider),
    recetteCloudService: ref.watch(recetteFirestoreServiceProvider),
    authService: ref.watch(authServiceProvider),
  );
});

// Service de génération de listes de courses (mis à jour pour le cloud)
final shoppingListGeneratorServiceProvider = Provider<ShoppingListGeneratorService>((ref) {
  return ShoppingListGeneratorService(
    planningRepo: ref.watch(planningRepositoryProvider),
    recetteRepo: ref.watch(recetteRepositoryProvider),
    frigoRepo: ref.watch(frigoRepositoryProvider), // Conservé mais deprecated
    ingredientRepo: ref.watch(ingredientRepositoryProvider),
    planningCloudService: ref.watch(planningFirestoreServiceProvider),
    shoppingCloudService: ref.watch(shoppingListCloudServiceProvider),
    recetteCloudService: ref.watch(recetteFirestoreServiceProvider),
    frigoCloudService: ref.watch(frigoFirestoreServiceProvider),
  );
});

// ============================================================================
// PROVIDERS ASYNCHRONES
// ============================================================================

final ingredientsProvider = FutureProvider((ref) async {
  final repo = ref.watch(ingredientRepositoryProvider);
  return repo.getAllIngredients();
});

// ⚠️ NOUVEAU: Provider basé sur le cloud (remplace l'ancien frigoProvider)
final frigoCloudProvider = StreamProvider<List<FrigoFirestore>>((ref) {
  final authService = ref.watch(authServiceProvider);
  final frigoService = ref.watch(frigoFirestoreServiceProvider);

  final userId = authService.currentUser?.uid;
  if (userId == null) {
    return Stream.value([]);
  }

  return frigoService.getMyStock();
});

// ⚠️ DEPRECATED: Ancien provider local, conservé temporairement pour compatibilité
@Deprecated('Utilisez frigoCloudProvider à la place')
final frigoProvider = FutureProvider((ref) async {
  final repo = ref.watch(frigoRepositoryProvider);

  // Retourne les données du cloud au format compatible
  try {
    return await repo.getAllFrigoWithIngredientsFromCloud();
  } catch (e) {
    print('⚠️ frigoProvider deprecated utilisé - migrez vers frigoCloudProvider');
    return <Map<String, dynamic>>[];
  }
});

// ⚠️ NOUVEAU: Provider pour le stock avec format compatible (migration facilitée)
final frigoCloudCompatProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final authService = ref.watch(authServiceProvider);
  final frigoService = ref.watch(frigoFirestoreServiceProvider);

  final userId = authService.currentUser?.uid;
  if (userId == null) return [];

  try {
    final cloudItems = await frigoService.getMyStock().first;

    // Conversion vers format compatible avec l'ancien code
    return cloudItems.map((item) {
      return {
        'frigo': {
          'id': item.id,
          'quantity': item.quantity,
          'unit': item.unit,
          'location': item.location,
          'bestBefore': item.bestBefore,
          'addedAt': item.createdAt,
        },
        'ingredient': {
          'id': int.tryParse(item.ingredientId) ?? 0,
          'name': item.ingredientName,
          'caloriesPer100g': item.caloriesPer100g,
          'proteinsPer100g': item.proteinsPer100g,
          'fatsPer100g': item.fatsPer100g,
          'carbsPer100g': item.carbsPer100g,
          'fibersPer100g': item.fibersPer100g,
        },
      };
    }).toList();
  } catch (e) {
    print('❌ Erreur frigoCloudCompatProvider: $e');
    return [];
  }
});

final recettesProvider = FutureProvider((ref) async {
  final repo = ref.watch(recetteRepositoryProvider);
  return repo.getAllRecettes();
});

// ============================================================================
// PROVIDERS POUR STATISTIQUES (UTILES POUR LA HOME)
// ============================================================================

// Nombre total de produits en stock
final stockCountProvider = StreamProvider<int>((ref) {
  final frigoCloud = ref.watch(frigoCloudProvider);
  return frigoCloud.when(
    data: (items) => Stream.value(items.length),
    loading: () => Stream.value(0),
    error: (_, __) => Stream.value(0),
  );
});

// ============================================================================
// SERVICE CLOUD POUR LES INGRÉDIENTS
// ============================================================================

final ingredientFirestoreServiceProvider = Provider<IngredientFirestoreService>((ref) {
  return IngredientFirestoreService();
});

// ============================================================================
// NOUVEAU SERVICE V2 DE GÉNÉRATION DE LISTE (AVEC INGREDIENT SERVICE)
// ============================================================================

final shoppingListV2GeneratorServiceProvider = Provider<ShoppingListV2GeneratorService>((ref) {
  return ShoppingListV2GeneratorService(
    planningService: ref.watch(planningFirestoreServiceProvider),
    recetteService: ref.watch(recetteFirestoreServiceProvider),
    frigoService: ref.watch(frigoFirestoreServiceProvider),
    ingredientService: ref.watch(ingredientFirestoreServiceProvider), // ✅ AJOUTÉ
  );
});

// Nombre de produits périmés ou bientôt périmés
final expiringStockCountProvider = StreamProvider<int>((ref) {
  final frigoCloud = ref.watch(frigoCloudProvider);
  return frigoCloud.when(
    data: (items) {
      final now = DateTime.now();
      final count = items.where((item) {
        if (item.bestBefore == null) return false;
        final daysUntil = item.bestBefore!.difference(now).inDays;
        return daysUntil <= 3;
      }).length;
      return Stream.value(count);
    },
    loading: () => Stream.value(0),
    error: (_, __) => Stream.value(0),
  );
});

// ============================================================================
// CALORIE TRACKING REPOSITORY
// ============================================================================

final calorieTrackingRepositoryProvider = Provider<CalorieTrackingRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return CalorieTrackingRepository(db);
});

// ============================================================================
// MEAL CONSUMPTION SERVICE
// ============================================================================

final mealConsumptionServiceProvider = Provider<MealConsumptionService>((ref) {
  return MealConsumptionService(
    planningService: ref.watch(planningFirestoreServiceProvider),
    recetteService: ref.watch(recetteFirestoreServiceProvider),
    frigoService: ref.watch(frigoFirestoreServiceProvider),
    calorieTrackingRepo: ref.watch(calorieTrackingRepositoryProvider),
  );
});

// Produits urgents à consommer
final urgentStockProvider = StreamProvider<List<FrigoFirestore>>((ref) {
  final frigoCloud = ref.watch(frigoCloudProvider);
  return frigoCloud.when(
    data: (items) {
      final now = DateTime.now();
      final urgentItems = items.where((item) {
        if (item.bestBefore == null) return false;
        final daysUntil = item.bestBefore!.difference(now).inDays;
        return daysUntil <= 3;
      }).toList();

      // Trier par date de péremption (les plus urgents en premier)
      urgentItems.sort((a, b) {
        if (a.bestBefore == null) return 1;
        if (b.bestBefore == null) return -1;
        return a.bestBefore!.compareTo(b.bestBefore!);
      });

      return Stream.value(urgentItems);
    },
    loading: () => Stream.value(<FrigoFirestore>[]),
    error: (_, __) => Stream.value(<FrigoFirestore>[]),
  );
});