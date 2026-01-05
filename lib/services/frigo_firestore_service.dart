// lib/services/frigo_firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/frigo_firestore.dart';
import 'auth_service.dart';

class FrigoFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  // Référence à la collection frigo
  CollectionReference get _frigoCollection => _firestore.collection('frigo');

  // ============================================================================
  // AJOUTER UN PRODUIT AU FRIGO CLOUD
  // ============================================================================
  Future<String> addToFrigo({
    required String ingredientId,
    required String ingredientName,
    required double quantity,
    required String unit,
    required String location,
    DateTime? bestBefore,
    required FrigoVisibility visibility,
    String? groupId,
    required double caloriesPer100g,
    double proteinsPer100g = 0.0,
    double fatsPer100g = 0.0,
    double carbsPer100g = 0.0,
    double fibersPer100g = 0.0,
    double? densityGPerMl,
    double? avgWeightPerUnitG,
  }) async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    if (visibility == FrigoVisibility.group && groupId == null) {
      throw Exception('Group ID required for group frigo items');
    }

    final now = DateTime.now();

    final data = {
      'ownerId': userId,
      'ingredientId': ingredientId,
      'ingredientName': ingredientName,
      'quantity': quantity,
      'unit': unit,
      'location': location,
      'bestBefore': bestBefore != null ? Timestamp.fromDate(bestBefore) : null,
      'visibility': visibility == FrigoVisibility.group ? 'group' : 'private',
      'groupId': groupId,
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
      'caloriesPer100g': caloriesPer100g,
      'proteinsPer100g': proteinsPer100g,
      'fatsPer100g': fatsPer100g,
      'carbsPer100g': carbsPer100g,
      'fibersPer100g': fibersPer100g,
      'densityGPerMl': densityGPerMl,
      'avgWeightPerUnitG': avgWeightPerUnitG,
    };

    final docRef = await _frigoCollection.add(data);
    return docRef.id;
  }

  // ============================================================================
  // RÉCUPÉRER MON STOCK (PRIVÉ + GROUPES)
  // ============================================================================
  Stream<List<FrigoFirestore>> getMyStock() {
    final userId = _authService.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _frigoCollection
        .where('ownerId', isEqualTo: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => FrigoFirestore.fromFirestore(doc))
          .toList();
    });
  }

  // ============================================================================
  // RÉCUPÉRER LE STOCK D'UN GROUPE
  // ============================================================================
  Stream<List<FrigoFirestore>> getGroupStock(String groupId) {
    return _frigoCollection
        .where('groupId', isEqualTo: groupId)
        .where('visibility', isEqualTo: 'group')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => FrigoFirestore.fromFirestore(doc))
          .toList();
    });
  }

  // ============================================================================
  // RÉCUPÉRER UN PRODUIT SPÉCIFIQUE
  // ============================================================================
  Stream<FrigoFirestore?> watchFrigoItem(String frigoId) {
    return _frigoCollection.doc(frigoId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return FrigoFirestore.fromFirestore(doc);
    });
  }

  Future<FrigoFirestore?> getFrigoItem(String frigoId) async {
    final doc = await _frigoCollection.doc(frigoId).get();
    if (!doc.exists) return null;
    return FrigoFirestore.fromFirestore(doc);
  }

  // ============================================================================
  // MODIFIER UN PRODUIT
  // ============================================================================
  Future<void> updateFrigoItem({
    required String frigoId,
    double? quantity,
    String? unit,
    String? location,
    DateTime? bestBefore,
    bool clearBestBefore = false,
  }) async {
    final updates = <String, dynamic>{
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    };

    if (quantity != null) updates['quantity'] = quantity;
    if (unit != null) updates['unit'] = unit;
    if (location != null) updates['location'] = location;

    if (clearBestBefore) {
      updates['bestBefore'] = null;
    } else if (bestBefore != null) {
      updates['bestBefore'] = Timestamp.fromDate(bestBefore);
    }

    await _frigoCollection.doc(frigoId).update(updates);
  }

  // ============================================================================
  // SUPPRIMER UN PRODUIT
  // ============================================================================
  Future<void> deleteFrigoItem(String frigoId) async {
    await _frigoCollection.doc(frigoId).delete();
  }

  // ============================================================================
  // DUPLIQUER VERS MON STOCK PRIVÉ
  // ============================================================================
  Future<String> duplicateToPrivate({required String sourceFrigoId}) async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final sourceFrigo = await getFrigoItem(sourceFrigoId);
    if (sourceFrigo == null) throw Exception('Source frigo item not found');

    final now = DateTime.now();

    final data = {
      'ownerId': userId,
      'ingredientId': sourceFrigo.ingredientId,
      'ingredientName': sourceFrigo.ingredientName,
      'quantity': sourceFrigo.quantity,
      'unit': sourceFrigo.unit,
      'location': sourceFrigo.location,
      'bestBefore': sourceFrigo.bestBefore != null
          ? Timestamp.fromDate(sourceFrigo.bestBefore!)
          : null,
      'visibility': 'private',
      'groupId': null,
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
      'caloriesPer100g': sourceFrigo.caloriesPer100g,
      'proteinsPer100g': sourceFrigo.proteinsPer100g,
      'fatsPer100g': sourceFrigo.fatsPer100g,
      'carbsPer100g': sourceFrigo.carbsPer100g,
      'fibersPer100g': sourceFrigo.fibersPer100g,
      'densityGPerMl': sourceFrigo.densityGPerMl,
      'avgWeightPerUnitG': sourceFrigo.avgWeightPerUnitG,
    };

    final docRef = await _frigoCollection.add(data);
    return docRef.id;
  }

  // ============================================================================
  // MIGRER VERS UN GROUPE
  // ============================================================================
  Future<void> migrateToGroup({
    required String frigoId,
    required String groupId,
  }) async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final frigo = await getFrigoItem(frigoId);
    if (frigo == null) throw Exception('Frigo item not found');
    if (frigo.ownerId != userId) throw Exception('Not authorized');

    await _frigoCollection.doc(frigoId).update({
      'visibility': 'group',
      'groupId': groupId,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  // ============================================================================
  // RÉCUPÉRER TOUS LES STOCKS (POUR "TOUT LE STOCK")
  // ============================================================================
  Stream<List<FrigoFirestore>> getAllMyStocks() async* {
    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      yield [];
      return;
    }

    // Écouter les changements sur les stocks privés
    await for (final privateSnapshot in _frigoCollection
        .where('ownerId', isEqualTo: userId)
        .snapshots()) {

      final privateItems = privateSnapshot.docs
          .map((doc) => FrigoFirestore.fromFirestore(doc))
          .toList();

      yield privateItems;
    }
  }

  // ============================================================================
  // RECHERCHE PAR NOM D'INGRÉDIENT
  // ============================================================================
  Future<List<FrigoFirestore>> searchByIngredientName(String query) async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) return [];

    final snapshot = await _frigoCollection
        .where('ownerId', isEqualTo: userId)
        .get();

    return snapshot.docs
        .map((doc) => FrigoFirestore.fromFirestore(doc))
        .where((item) => item.ingredientName.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // ============================================================================
  // STATISTIQUES
  // ============================================================================
  Future<Map<String, int>> getStockStats() async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) return {'total': 0, 'frigo': 0, 'placard': 0, 'congélateur': 0};

    final snapshot = await _frigoCollection
        .where('ownerId', isEqualTo: userId)
        .get();

    final items = snapshot.docs.map((doc) => FrigoFirestore.fromFirestore(doc)).toList();

    return {
      'total': items.length,
      'frigo': items.where((i) => i.location == 'frigo').length,
      'placard': items.where((i) => i.location == 'placard').length,
      'congélateur': items.where((i) => i.location == 'congélateur').length,
    };
  }

  // ============================================================================
  // PRODUITS PÉRIMÉS OU BIENTÔT PÉRIMÉS
  // ============================================================================
  Stream<List<FrigoFirestore>> getExpiringItems({int daysThreshold = 3}) {
    final userId = _authService.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    final threshold = DateTime.now().add(Duration(days: daysThreshold));

    return _frigoCollection
        .where('ownerId', isEqualTo: userId)
        .where('bestBefore', isLessThanOrEqualTo: Timestamp.fromDate(threshold))
        .orderBy('bestBefore')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => FrigoFirestore.fromFirestore(doc))
          .toList();
    });
  }
}