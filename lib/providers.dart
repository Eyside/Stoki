// lib/providers.dart (PARTIE MODIFIÉE)
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
import 'services/frigo_firestore_service.dart'; // ✅ AJOUTÉ
import 'services/recette_sync_service.dart';
import 'services/auth_service.dart';
import 'services/group_profile_service.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

final ingredientRepositoryProvider = Provider<IngredientRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return IngredientRepository(db);
});

final frigoRepositoryProvider = Provider<FrigoRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return FrigoRepository(db);
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

// Services
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

// ✅ NOUVEAU: Provider pour FrigoFirestoreService
final frigoFirestoreServiceProvider = Provider<FrigoFirestoreService>((ref) {
  return FrigoFirestoreService();
});

// Provider pour le service de synchronisation
final recetteSyncServiceProvider = Provider<RecetteSyncService>((ref) {
  return RecetteSyncService(
    recetteRepo: ref.watch(recetteRepositoryProvider),
    recetteCloudService: ref.watch(recetteFirestoreServiceProvider),
    authService: ref.watch(authServiceProvider),
  );
});

// ✅ MODIFIÉ: Provider pour le service de génération de listes de courses
final shoppingListGeneratorServiceProvider = Provider<ShoppingListGeneratorService>((ref) {
  return ShoppingListGeneratorService(
    planningRepo: ref.watch(planningRepositoryProvider),
    recetteRepo: ref.watch(recetteRepositoryProvider),
    frigoRepo: ref.watch(frigoRepositoryProvider),
    ingredientRepo: ref.watch(ingredientRepositoryProvider),
    planningCloudService: ref.watch(planningFirestoreServiceProvider),
    shoppingCloudService: ref.watch(shoppingListCloudServiceProvider),
    recetteCloudService: ref.watch(recetteFirestoreServiceProvider),
    frigoCloudService: ref.watch(frigoFirestoreServiceProvider), // ✅ AJOUTÉ
  );
});

// Providers asynchrones existants
final ingredientsProvider = FutureProvider((ref) async {
  final repo = ref.watch(ingredientRepositoryProvider);
  return repo.getAllIngredients();
});

final frigoProvider = FutureProvider((ref) async {
  final repo = ref.watch(frigoRepositoryProvider);
  return repo.getAllFrigoWithIngredients();
});

final recettesProvider = FutureProvider((ref) async {
  final repo = ref.watch(recetteRepositoryProvider);
  return repo.getAllRecettes();
});

final groupProfileServiceProvider = Provider<GroupProfileService>((ref) {
  return GroupProfileService();
});