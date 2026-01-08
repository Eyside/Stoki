// lib/repositories/frigo_repository.dart - VERSION CLOUD
// Ce repository est maintenant un simple wrapper du service cloud
// Il est conservé pour la compatibilité mais toutes les opérations passent par le cloud

import '../services/frigo_firestore_service.dart';
import '../services/auth_service.dart';
import '../models/frigo_firestore.dart';

class FrigoRepository {
  final _frigoService = FrigoFirestoreService();
  final _authService = AuthService();

  // ⚠️ DEPRECATED: Utilisez directement FrigoFirestoreService
  @Deprecated('Utilisez FrigoFirestoreService.addToFrigo')
  Future<void> addToFrigo({
    required int ingredientId,
    required double quantity,
    required String unit,
    DateTime? bestBefore,
    String? location,
  }) async {
    // Cette méthode ne devrait plus être utilisée
    // Si elle est appelée, on lève une exception pour forcer la migration
    throw UnsupportedError(
      'addToFrigo() local est deprecated. Utilisez FrigoFirestoreService.addToFrigo() pour ajouter au cloud.',
    );
  }

  // ⚠️ DEPRECATED: Utilisez directement FrigoFirestoreService.getMyStock()
  @Deprecated('Utilisez FrigoFirestoreService.getMyStock()')
  Future<List<Map<String, dynamic>>> getAllFrigoWithIngredients() async {
    // Retourne une liste vide pour indiquer qu'il n'y a plus de stock local
    // Les appelants devront migrer vers le service cloud
    return [];
  }

  // ⚠️ DEPRECATED: Utilisez directement FrigoFirestoreService
  @Deprecated('Utilisez FrigoFirestoreService.updateFrigoItem()')
  Future<void> updateFrigoQuantity({
    required int id,
    required double quantity,
  }) async {
    throw UnsupportedError(
      'updateFrigoQuantity() local est deprecated. Utilisez FrigoFirestoreService.updateFrigoItem().',
    );
  }

  // ⚠️ DEPRECATED: Utilisez directement FrigoFirestoreService
  @Deprecated('Utilisez FrigoFirestoreService.deleteFrigoItem()')
  Future<void> deleteFrigoItem(int id) async {
    throw UnsupportedError(
      'deleteFrigoItem() local est deprecated. Utilisez FrigoFirestoreService.deleteFrigoItem().',
    );
  }

  // NOUVELLE MÉTHODE: Wrapper vers le service cloud pour compatibilité temporaire
  Stream<List<FrigoFirestore>> getAllFrigoStream() {
    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      return Stream.value([]);
    }
    return _frigoService.getMyStock();
  }

  // NOUVELLE MÉTHODE: Conversion pour compatibilité avec l'ancien format
  Future<List<Map<String, dynamic>>> getAllFrigoWithIngredientsFromCloud() async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) return [];

    try {
      final cloudItems = await _frigoService.getMyStock().first;

      // Conversion du format cloud vers l'ancien format pour compatibilité
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
      print('❌ Erreur récupération stock cloud: $e');
      return [];
    }
  }
}