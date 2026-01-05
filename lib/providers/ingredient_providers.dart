import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/ingredient_repository.dart';
import '../database.dart';

// Repository provider (accès DB)
final ingredientRepositoryProvider = Provider<IngredientRepository>((ref) {
  throw UnimplementedError("Repository non initialisé");
});

// Liste des ingrédients
final ingredientListProvider = FutureProvider<List<Ingredient>>((ref) async {
  final repo = ref.watch(ingredientRepositoryProvider);
  return repo.getAllIngredients();
});
