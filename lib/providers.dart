// lib/providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database.dart';
import 'repositories/ingredient_repository.dart';
import 'repositories/frigo_repository.dart';
import 'repositories/recette_repository.dart';

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
