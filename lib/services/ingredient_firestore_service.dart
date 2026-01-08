// lib/services/ingredient_firestore_service.dart
// Service cloud pour gérer les ingrédients dans Firestore

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ingredient_firestore.dart';
import 'auth_service.dart';

class IngredientFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  CollectionReference get _ingredientsCollection => _firestore.collection('ingredients');

  // ============================================================================
  // AJOUTER UN INGRÉDIENT
  // ============================================================================
  Future<String> addIngredient({
    required String name,
    required double caloriesPer100g,
    double proteinsPer100g = 0.0,
    double fatsPer100g = 0.0,
    double carbsPer100g = 0.0,
    double fibersPer100g = 0.0,
    double saltPer100g = 0.0,
    String? barcode,
    double? densityGPerMl,
    double? avgWeightPerUnitG,
    String? category,
    String? nutriscore,
    String? imageUrl,
    String? brand,
    IngredientVisibility visibility = IngredientVisibility.private,
    String? groupId,
  }) async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final now = DateTime.now();

    final data = {
      'ownerId': userId,
      'name': name,
      'caloriesPer100g': caloriesPer100g,
      'proteinsPer100g': proteinsPer100g,
      'fatsPer100g': fatsPer100g,
      'carbsPer100g': carbsPer100g,
      'fibersPer100g': fibersPer100g,
      'saltPer100g': saltPer100g,
      'barcode': barcode,
      'densityGPerMl': densityGPerMl,
      'avgWeightPerUnitG': avgWeightPerUnitG,
      'category': category,
      'nutriscore': nutriscore,
      'imageUrl': imageUrl,
      'brand': brand,
      'visibility': _visibilityToString(visibility),
      'groupId': groupId,
      'isCustom': visibility == IngredientVisibility.private,
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
    };

    final docRef = await _ingredientsCollection.add(data);
    print('✅ Ingrédient ajouté: ${docRef.id}');
    return docRef.id;
  }

  // ============================================================================
  // RECHERCHER PAR CODE-BARRES
  // ============================================================================
  Future<IngredientFirestore?> findByBarcode(String barcode) async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) return null;

    // Chercher d'abord dans les ingrédients personnels
    final privateQuery = await _ingredientsCollection
        .where('barcode', isEqualTo: barcode)
        .where('ownerId', isEqualTo: userId)
        .limit(1)
        .get();

    if (privateQuery.docs.isNotEmpty) {
      return IngredientFirestore.fromFirestore(privateQuery.docs.first);
    }

    // Sinon chercher dans les ingrédients publics
    final publicQuery = await _ingredientsCollection
        .where('barcode', isEqualTo: barcode)
        .where('visibility', isEqualTo: 'public')
        .limit(1)
        .get();

    if (publicQuery.docs.isNotEmpty) {
      return IngredientFirestore.fromFirestore(publicQuery.docs.first);
    }

    return null;
  }

  // ============================================================================
  // RECHERCHER PAR ID
  // ============================================================================
  Future<IngredientFirestore?> getById(String id) async {
    final doc = await _ingredientsCollection.doc(id).get();
    if (!doc.exists) return null;
    return IngredientFirestore.fromFirestore(doc);
  }

  // ============================================================================
  // RECHERCHER PAR NOM
  // ============================================================================
  Future<List<IngredientFirestore>> searchByName(String query) async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) return [];

    final lowerQuery = query.toLowerCase();

    // Récupérer les ingrédients personnels + publics
    final myIngredients = await _ingredientsCollection
        .where('ownerId', isEqualTo: userId)
        .get();

    final publicIngredients = await _ingredientsCollection
        .where('visibility', isEqualTo: 'public')
        .get();

    final allDocs = [...myIngredients.docs, ...publicIngredients.docs];

    // Filtrer par nom (côté client car Firestore ne supporte pas LIKE)
    final filtered = allDocs
        .map((doc) => IngredientFirestore.fromFirestore(doc))
        .where((ing) => ing.name.toLowerCase().contains(lowerQuery))
        .toList();

    // Supprimer les doublons par ID
    final uniqueMap = <String, IngredientFirestore>{};
    for (final ing in filtered) {
      uniqueMap[ing.id] = ing;
    }

    final result = uniqueMap.values.toList();
    result.sort((a, b) => a.name.compareTo(b.name));

    return result;
  }

  // ============================================================================
  // RÉCUPÉRER MES INGRÉDIENTS
  // ============================================================================
  Stream<List<IngredientFirestore>> getMyIngredients() {
    final userId = _authService.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _ingredientsCollection
        .where('ownerId', isEqualTo: userId)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => IngredientFirestore.fromFirestore(doc))
          .toList();
    });
  }

  // ============================================================================
  // RÉCUPÉRER TOUS LES INGRÉDIENTS ACCESSIBLES
  // ============================================================================
  Future<List<IngredientFirestore>> getAllAccessibleIngredients() async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) return [];

    // Ingrédients personnels
    final myIngredients = await _ingredientsCollection
        .where('ownerId', isEqualTo: userId)
        .orderBy('name')
        .get();

    // Ingrédients publics
    final publicIngredients = await _ingredientsCollection
        .where('visibility', isEqualTo: 'public')
        .orderBy('name')
        .get();

    final allDocs = [...myIngredients.docs, ...publicIngredients.docs];

    // Supprimer doublons et trier
    final uniqueMap = <String, IngredientFirestore>{};
    for (final doc in allDocs) {
      final ing = IngredientFirestore.fromFirestore(doc);
      uniqueMap[ing.id] = ing;
    }

    final result = uniqueMap.values.toList();
    result.sort((a, b) => a.name.compareTo(b.name));

    return result;
  }

  // ============================================================================
  // METTRE À JOUR UN INGRÉDIENT
  // ============================================================================
  Future<void> updateIngredient({
    required String id,
    String? name,
    double? caloriesPer100g,
    double? proteinsPer100g,
    double? fatsPer100g,
    double? carbsPer100g,
    double? fibersPer100g,
    double? saltPer100g,
    double? densityGPerMl,
    double? avgWeightPerUnitG,
    String? category,
    String? nutriscore,
    String? imageUrl,
  }) async {
    final updates = <String, dynamic>{
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    };

    if (name != null) updates['name'] = name;
    if (caloriesPer100g != null) updates['caloriesPer100g'] = caloriesPer100g;
    if (proteinsPer100g != null) updates['proteinsPer100g'] = proteinsPer100g;
    if (fatsPer100g != null) updates['fatsPer100g'] = fatsPer100g;
    if (carbsPer100g != null) updates['carbsPer100g'] = carbsPer100g;
    if (fibersPer100g != null) updates['fibersPer100g'] = fibersPer100g;
    if (saltPer100g != null) updates['saltPer100g'] = saltPer100g;
    if (densityGPerMl != null) updates['densityGPerMl'] = densityGPerMl;
    if (avgWeightPerUnitG != null) updates['avgWeightPerUnitG'] = avgWeightPerUnitG;
    if (category != null) updates['category'] = category;
    if (nutriscore != null) updates['nutriscore'] = nutriscore;
    if (imageUrl != null) updates['imageUrl'] = imageUrl;

    await _ingredientsCollection.doc(id).update(updates);
  }

  // ============================================================================
  // SUPPRIMER UN INGRÉDIENT
  // ============================================================================
  Future<void> deleteIngredient(String id) async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final doc = await _ingredientsCollection.doc(id).get();
    if (!doc.exists) throw Exception('Ingredient not found');

    final data = doc.data() as Map<String, dynamic>;
    if (data['ownerId'] != userId) {
      throw Exception('Not authorized to delete this ingredient');
    }

    await _ingredientsCollection.doc(id).delete();
    print('✅ Ingrédient supprimé: $id');
  }

  // ============================================================================
  // HELPERS
  // ============================================================================
  String _visibilityToString(IngredientVisibility visibility) {
    switch (visibility) {
      case IngredientVisibility.public:
        return 'public';
      case IngredientVisibility.group:
        return 'group';
      case IngredientVisibility.private:
      default:
        return 'private';
    }
  }

  IngredientVisibility _visibilityFromString(String? visibility) {
    switch (visibility) {
      case 'public':
        return IngredientVisibility.public;
      case 'group':
        return IngredientVisibility.group;
      default:
        return IngredientVisibility.private;
    }
  }
}