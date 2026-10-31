// lib/services/ingredient_firestore_service.dart
// Service cloud pour gérer les ingrédients dans Firestore

import 'package:flutter/foundation.dart';
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
    debugPrint('✅ Ingrédient ajouté: ${docRef.id}');
    return docRef.id;
  }

  // ============================================================================
  // RECHERCHER PAR CODE-BARRES
  // ============================================================================
  Future<IngredientFirestore?> findByBarcode(String barcode) async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) return null;

    // 0. Lien code-barres -> ingrédient (un ingrédient générique peut avoir
    // plusieurs codes-barres : toutes les marques de "saumon fumé", etc.)
    final linked = await getLinkedIngredient(barcode);
    if (linked != null) return linked;

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
    debugPrint('✅ Ingrédient supprimé: $id');
  }

  // ============================================================================
  // LIENS CODE-BARRES -> INGRÉDIENT  (users/{uid}/barcode_links/{code})
  // ============================================================================
  DocumentReference<Map<String, dynamic>>? _linkRef(String barcode) {
    final userId = _authService.currentUser?.uid;
    if (userId == null || barcode.isEmpty) return null;
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('barcode_links')
        .doc(barcode);
  }

  Future<IngredientFirestore?> getLinkedIngredient(String barcode) async {
    try {
      final ref = _linkRef(barcode);
      if (ref == null) return null;
      final doc = await ref.get();
      final ingredientId = doc.data()?['ingredientId'] as String?;
      if (ingredientId == null) return null;
      final ingredient = await getById(ingredientId);
      if (ingredient == null) {
        await ref.delete(); // l'ingrédient a été supprimé : lien périmé
      }
      return ingredient;
    } catch (e) {
      debugPrint('⚠️ Lien code-barres: $e');
      return null;
    }
  }

  Future<void> linkBarcode(String barcode, String ingredientId) async {
    final ref = _linkRef(barcode);
    if (ref == null) return;
    await ref.set({
      'barcode': barcode,
      'ingredientId': ingredientId,
      'createdAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  // ============================================================================
  // INGRÉDIENTS SIMILAIRES (anti-doublons)
  // ============================================================================
  static const _stopWords = {
    'de', 'du', 'des', 'la', 'le', 'les', 'l', 'd', 'au', 'aux', 'a', 'en',
    'et', 'un', 'une', 'bio',
  };

  static const _accents = {
    'à': 'a', 'â': 'a', 'ä': 'a', 'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
    'î': 'i', 'ï': 'i', 'ô': 'o', 'ö': 'o', 'ù': 'u', 'û': 'u', 'ü': 'u',
    'ç': 'c', 'œ': 'oe', 'æ': 'ae', 'ÿ': 'y',
  };

  /// Mots significatifs d'un nom : sans accent, minuscules, sans pluriel
  /// ni mots vides. "Saumon fumé en tranches" -> {saumon, fume, tranche}.
  static Set<String> nameTokens(String name) {
    var text = name.toLowerCase();
    _accents.forEach((k, v) => text = text.replaceAll(k, v));
    final words = text.split(RegExp(r'[^a-z0-9]+'));
    final tokens = <String>{};
    for (var w in words) {
      if (w.isEmpty || _stopWords.contains(w)) continue;
      if (w.length > 3 && (w.endsWith('s') || w.endsWith('x'))) {
        w = w.substring(0, w.length - 1);
      }
      tokens.add(w);
    }
    return tokens;
  }

  /// Ingrédients déjà connus qui ressemblent à [name], du plus proche au
  /// moins proche. Un ingrédient générique ("Saumon") correspond à un produit
  /// plus précis ("Saumon fumé Atlantique") et inversement.
  Future<List<IngredientFirestore>> findSimilar(String name,
      {String? excludeId}) async {
    final wanted = nameTokens(name);
    if (wanted.isEmpty) return [];

    final all = await getAllAccessibleIngredients();
    final scored = <MapEntry<IngredientFirestore, int>>[];

    for (final ing in all) {
      if (ing.id == excludeId) continue;
      final tokens = nameTokens(ing.name);
      if (tokens.isEmpty) continue;

      int score;
      if (tokens.length == wanted.length && tokens.containsAll(wanted)) {
        score = 3; // même nom
      } else if (wanted.containsAll(tokens)) {
        score = 2; // l'ingrédient connu est plus générique
      } else if (tokens.containsAll(wanted)) {
        score = 1; // l'ingrédient connu est plus précis
      } else {
        continue;
      }
      scored.add(MapEntry(ing, score));
    }

    scored.sort((a, b) {
      final byScore = b.value.compareTo(a.value);
      return byScore != 0 ? byScore : a.key.name.compareTo(b.key.name);
    });
    return scored.map((e) => e.key).toList();
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
        return 'private';
    }
  }

}