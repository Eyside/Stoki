// lib/services/recette_firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recette_firestore.dart';
import '../utils/unit_converter.dart';
import 'auth_service.dart';

class RecetteFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  // ============================================================================
  // CRÉER UNE RECETTE
  // ============================================================================

  Future<String> createRecette({
    required String name,
    String? instructions,
    required int servings,
    String? category,
    String? notes,
    String? imageUrl,
    required RecetteVisibility visibility,
    String? groupId,
    String? groupName, // ✅ AJOUTÉ
  }) async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) throw Exception('Utilisateur non connecté');

    if (visibility == RecetteVisibility.group && groupId == null) {
      throw Exception('groupId requis pour les recettes de groupe');
    }

    final recetteRef = _firestore.collection('recettes').doc();

    final recette = RecetteFirestore(
      id: recetteRef.id,
      name: name,
      instructions: instructions,
      servings: servings,
      category: category,
      notes: notes,
      imageUrl: imageUrl,
      ownerId: userId,
      visibility: visibility,
      groupId: groupId,
      groupName: groupName, // ✅ AJOUTÉ
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await recetteRef.set(recette.toFirestore());

    return recetteRef.id;
  }

  // ============================================================================
  // AJOUTER UN INGRÉDIENT À UNE RECETTE
  // ============================================================================

  Future<void> addIngredient({
    required String recetteId,
    required RecetteIngredientFirestore ingredient,
  }) async {
    await _firestore
        .collection('recettes')
        .doc(recetteId)
        .collection('ingredients')
        .doc(ingredient.ingredientId)
        .set(ingredient.toFirestore());

    // Recalculer la nutrition totale
    await _updateRecetteNutrition(recetteId);

    print('✅ Ingrédient ajouté à la recette $recetteId');
  }

  // ============================================================================
  // SUPPRIMER UN INGRÉDIENT
  // ============================================================================

  Future<void> removeIngredient({
    required String recetteId,
    required String ingredientId,
  }) async {
    await _firestore
        .collection('recettes')
        .doc(recetteId)
        .collection('ingredients')
        .doc(ingredientId)
        .delete();

    // Recalculer la nutrition
    await _updateRecetteNutrition(recetteId);

    print('✅ Ingrédient supprimé de la recette $recetteId');
  }

  // ============================================================================
  // RÉCUPÉRER LES INGRÉDIENTS D'UNE RECETTE
  // ============================================================================

  Future<List<RecetteIngredientFirestore>> getIngredients(String recetteId) async {
    final snapshot = await _firestore
        .collection('recettes')
        .doc(recetteId)
        .collection('ingredients')
        .get();

    return snapshot.docs
        .map((doc) => RecetteIngredientFirestore.fromFirestore(doc.data()))
        .toList();
  }

  // Stream des ingrédients (temps réel)
  Stream<List<RecetteIngredientFirestore>> watchIngredients(String recetteId) {
    return _firestore
        .collection('recettes')
        .doc(recetteId)
        .collection('ingredients')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => RecetteIngredientFirestore.fromFirestore(doc.data()))
        .toList());
  }

  // ============================================================================
  // CALCULER LA NUTRITION TOTALE
  // ============================================================================

  Future<void> _updateRecetteNutrition(String recetteId) async {
    final ingredients = await getIngredients(recetteId);

    double totalCalories = 0.0;
    double totalProteins = 0.0;
    double totalFats = 0.0;
    double totalCarbs = 0.0;
    double totalFibers = 0.0;

    for (final ingredient in ingredients) {
      // Convertir en grammes
      final gramsQuantity = UnitConverter.toGrams(
        quantity: ingredient.quantity,
        unit: ingredient.unit,
        weightPerPieceGrams: ingredient.avgWeightPerUnitG,
        densityGramsPerMl: ingredient.densityGPerMl ?? 1.0,
      );

      final factor = gramsQuantity / 100.0;
      totalCalories += ingredient.caloriesPer100g * factor;
      totalProteins += ingredient.proteinsPer100g * factor;
      totalFats += ingredient.fatsPer100g * factor;
      totalCarbs += ingredient.carbsPer100g * factor;
      totalFibers += ingredient.fibersPer100g * factor;
    }

    // Mettre à jour la recette avec les valeurs nutritionnelles
    await _firestore.collection('recettes').doc(recetteId).update({
      'nutrition': {
        'calories': totalCalories,
        'proteins': totalProteins,
        'fats': totalFats,
        'carbs': totalCarbs,
        'fibers': totalFibers,
      },
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ============================================================================
  // RÉCUPÉRER MES RECETTES (toutes celles accessibles)
  // ============================================================================

  Stream<List<RecetteFirestore>> getMyRecettes() {
    final userId = _authService.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    // On va combiner 3 queries :
    // 1. Mes recettes privées
    // 2. Recettes de groupe dont je suis membre
    // 3. Recettes partagées avec mes groupes

    // Pour simplifier, on récupère TOUTES les recettes où :
    // - Je suis le owner
    // - OU visibility = group (on filtrera côté client par groupId)
    // - OU mes groupes sont dans sharedWithGroups

    return _firestore
        .collection('recettes')
        .where('ownerId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => RecetteFirestore.fromFirestore(doc))
        .toList());
  }

  // Récupérer les recettes d'un groupe spécifique
  Stream<List<RecetteFirestore>> getGroupRecettes(String groupId) {
    return _firestore
        .collection('recettes')
        .where('groupId', isEqualTo: groupId)
        .where('visibility', isEqualTo: 'group')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => RecetteFirestore.fromFirestore(doc))
        .toList());
  }

  // Récupérer les recettes partagées avec un groupe
  Stream<List<RecetteFirestore>> getSharedRecettesForGroup(String groupId) {
    return _firestore
        .collection('recettes')
        .where('sharedWithGroups', arrayContains: groupId)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => RecetteFirestore.fromFirestore(doc))
        .toList());
  }

  // ============================================================================
  // METTRE À JOUR UNE RECETTE
  // ============================================================================

  Future<void> updateRecette({
    required String recetteId,
    String? name,
    String? instructions,
    int? servings,
    String? category,
    String? notes,
    String? imageUrl,
  }) async {
    final updates = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (name != null) updates['name'] = name;
    if (instructions != null) updates['instructions'] = instructions;
    if (servings != null) updates['servings'] = servings;
    if (category != null) updates['category'] = category;
    if (notes != null) updates['notes'] = notes;
    if (imageUrl != null) updates['imageUrl'] = imageUrl;

    await _firestore.collection('recettes').doc(recetteId).update(updates);

    print('✅ Recette mise à jour: $recetteId');
  }

  // ============================================================================
  // PARTAGER UNE RECETTE AVEC UN GROUPE
  // ============================================================================

  Future<void> shareWithGroup({
    required String recetteId,
    required String groupId,
  }) async {
    await _firestore.collection('recettes').doc(recetteId).update({
      'sharedWithGroups': FieldValue.arrayUnion([groupId]),
      'visibility': 'shared', // Change la visibilité en "shared"
      'updatedAt': FieldValue.serverTimestamp(),
    });

    print('✅ Recette partagée avec le groupe $groupId');
  }

  // Arrêter de partager avec un groupe
  Future<void> unshareWithGroup({
    required String recetteId,
    required String groupId,
  }) async {
    await _firestore.collection('recettes').doc(recetteId).update({
      'sharedWithGroups': FieldValue.arrayRemove([groupId]),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    print('✅ Partage annulé avec le groupe $groupId');
  }

  // ============================================================================
  // SUPPRIMER UNE RECETTE
  // ============================================================================

  Future<void> deleteRecette(String recetteId) async {
    // Supprimer d'abord tous les ingrédients
    final ingredientsSnapshot = await _firestore
        .collection('recettes')
        .doc(recetteId)
        .collection('ingredients')
        .get();

    for (final doc in ingredientsSnapshot.docs) {
      await doc.reference.delete();
    }

    // Supprimer la recette
    await _firestore.collection('recettes').doc(recetteId).delete();

    print('✅ Recette supprimée: $recetteId');
  }

  // ============================================================================
  // DUPLIQUER UNE RECETTE (copier dans mes recettes personnelles)
  // ============================================================================

  Future<String> duplicateRecette({
    required String sourceRecetteId,
    String? newName,
  }) async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) throw 'Non connecté';

    // Récupérer la recette source
    final sourceDoc = await _firestore.collection('recettes').doc(sourceRecetteId).get();
    if (!sourceDoc.exists) throw 'Recette introuvable';

    final sourceRecette = RecetteFirestore.fromFirestore(sourceDoc);

    // Créer une copie en privé
    final newRecetteId = await createRecette(
      name: newName ?? '${sourceRecette.name} (copie)',
      instructions: sourceRecette.instructions,
      servings: sourceRecette.servings,
      category: sourceRecette.category,
      notes: sourceRecette.notes,
      imageUrl: sourceRecette.imageUrl,
      visibility: RecetteVisibility.private, // Toujours en privé
    );

    // Copier les ingrédients
    final ingredients = await getIngredients(sourceRecetteId);
    for (final ingredient in ingredients) {
      await addIngredient(recetteId: newRecetteId, ingredient: ingredient);
    }

    print('✅ Recette dupliquée: $newRecetteId');
    return newRecetteId;
  }

  // ============================================================================
  // RÉCUPÉRER UNE RECETTE PAR ID
  // ============================================================================

  Future<RecetteFirestore?> getRecetteById(String recetteId) async {
    final doc = await _firestore.collection('recettes').doc(recetteId).get();
    if (!doc.exists) return null;
    return RecetteFirestore.fromFirestore(doc);
  }

  // Stream d'une recette (temps réel)
  Stream<RecetteFirestore?> watchRecette(String recetteId) {
    return _firestore
        .collection('recettes')
        .doc(recetteId)
        .snapshots()
        .map((doc) => doc.exists ? RecetteFirestore.fromFirestore(doc) : null);
  }
}