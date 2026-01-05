// lib/utils/firestore_structure_checker.dart
// Script de diagnostic pour vérifier la structure Firestore

import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreStructureChecker {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Vérifie toute la structure Firestore de l'application
  Future<Map<String, dynamic>> checkCompleteStructure() async {
    print('🔍 === VÉRIFICATION STRUCTURE FIRESTORE ===\n');

    final report = <String, dynamic>{};

    // 1. Vérifier les recettes
    report['recettes'] = await _checkRecettes();

    // 2. Vérifier les plannings
    report['plannings'] = await _checkPlannings();

    // 3. Vérifier les listes de courses
    report['shopping_lists'] = await _checkShoppingLists();

    // 4. Vérifier les groupes
    report['groups'] = await _checkGroups();

    print('\n=== FIN DE LA VÉRIFICATION ===');
    return report;
  }

  /// Vérifie les recettes et leurs ingrédients
  Future<Map<String, dynamic>> _checkRecettes() async {
    print('📋 RECETTES:');

    try {
      final recettesSnapshot = await _firestore.collection('recettes').get();
      print('   → ${recettesSnapshot.docs.length} recette(s) trouvée(s)');

      int recettesWithIngredients = 0;
      int recettesWithoutIngredients = 0;
      int totalIngredients = 0;

      for (final recetteDoc in recettesSnapshot.docs) {
        final recetteData = recetteDoc.data();
        final recetteName = recetteData['name'] ?? 'Sans nom';

        // Vérifier la sous-collection ingredients
        final ingredientsSnapshot = await recetteDoc.reference
            .collection('ingredients')
            .get();

        if (ingredientsSnapshot.docs.isEmpty) {
          print('   ⚠️ "${recetteName}" (${recetteDoc.id}) : 0 ingrédients');
          recettesWithoutIngredients++;
        } else {
          print('   ✅ "${recetteName}" (${recetteDoc.id}) : ${ingredientsSnapshot.docs.length} ingrédients');
          recettesWithIngredients++;
          totalIngredients += ingredientsSnapshot.docs.length;

          // Afficher les ingrédients
          for (final ingDoc in ingredientsSnapshot.docs) {
            final ingData = ingDoc.data();
            print('      - ${ingData['ingredientName']}: ${ingData['quantity']} ${ingData['unit']}');
          }
        }
      }

      return {
        'total': recettesSnapshot.docs.length,
        'withIngredients': recettesWithIngredients,
        'withoutIngredients': recettesWithoutIngredients,
        'totalIngredients': totalIngredients,
      };
    } catch (e) {
      print('   ❌ Erreur: $e');
      return {'error': e.toString()};
    }
  }

  /// Vérifie les plannings
  Future<Map<String, dynamic>> _checkPlannings() async {
    print('\n📅 PLANNINGS:');

    try {
      final planningsSnapshot = await _firestore.collection('planning').get();
      print('   → ${planningsSnapshot.docs.length} planning(s) trouvé(s)');

      int withValidRecette = 0;
      int withInvalidRecette = 0;

      for (final planningDoc in planningsSnapshot.docs) {
        final planningData = planningDoc.data();
        final recetteId = planningData['recetteId'];
        final recetteName = planningData['recetteName'] ?? 'Sans nom';
        final mealType = planningData['mealType'] ?? 'inconnu';
        final date = (planningData['date'] as Timestamp).toDate();

        // Vérifier si la recette existe
        final recetteDoc = await _firestore
            .collection('recettes')
            .doc(recetteId)
            .get();

        if (recetteDoc.exists) {
          // Vérifier les ingrédients
          final ingredientsSnapshot = await recetteDoc.reference
              .collection('ingredients')
              .get();

          if (ingredientsSnapshot.docs.isEmpty) {
            print('   ⚠️ ${date.day}/${date.month} $mealType: "$recetteName" existe mais SANS ingrédients');
          } else {
            print('   ✅ ${date.day}/${date.month} $mealType: "$recetteName" (${ingredientsSnapshot.docs.length} ingrédients)');
            withValidRecette++;
          }
        } else {
          print('   ❌ ${date.day}/${date.month} $mealType: Recette "$recetteName" ($recetteId) INTROUVABLE');
          withInvalidRecette++;
        }
      }

      return {
        'total': planningsSnapshot.docs.length,
        'withValidRecette': withValidRecette,
        'withInvalidRecette': withInvalidRecette,
      };
    } catch (e) {
      print('   ❌ Erreur: $e');
      return {'error': e.toString()};
    }
  }

  /// Vérifie les listes de courses
  Future<Map<String, dynamic>> _checkShoppingLists() async {
    print('\n🛒 LISTES DE COURSES:');

    try {
      final shoppingSnapshot = await _firestore.collection('shopping_list').get();
      print('   → ${shoppingSnapshot.docs.length} article(s) trouvé(s)');

      int pending = 0;
      int completed = 0;
      int stored = 0;

      for (final doc in shoppingSnapshot.docs) {
        final data = doc.data();
        final status = data['status'] ?? 'pending';

        if (status == 'pending') pending++;
        else if (status == 'completed') completed++;
        else if (status == 'stored') stored++;

        print('   - ${data['ingredientName'] ?? data['customName']}: ${data['quantity']} ${data['unit']} [$status]');
      }

      return {
        'total': shoppingSnapshot.docs.length,
        'pending': pending,
        'completed': completed,
        'stored': stored,
      };
    } catch (e) {
      print('   ❌ Erreur: $e');
      return {'error': e.toString()};
    }
  }

  /// Vérifie les groupes
  Future<Map<String, dynamic>> _checkGroups() async {
    print('\n👥 GROUPES:');

    try {
      final groupsSnapshot = await _firestore.collection('groups').get();
      print('   → ${groupsSnapshot.docs.length} groupe(s) trouvé(s)');

      for (final groupDoc in groupsSnapshot.docs) {
        final groupData = groupDoc.data();
        final groupName = groupData['name'] ?? 'Sans nom';

        // Vérifier les membres
        final membersSnapshot = await groupDoc.reference
            .collection('members')
            .get();

        print('   ✅ "$groupName" (${groupDoc.id}) : ${membersSnapshot.docs.length} membre(s)');
      }

      return {
        'total': groupsSnapshot.docs.length,
      };
    } catch (e) {
      print('   ❌ Erreur: $e');
      return {'error': e.toString()};
    }
  }

  /// Vérifie un planning spécifique et toutes ses dépendances
  Future<void> checkSpecificPlanning(String planningId) async {
    print('🔍 === VÉRIFICATION PLANNING SPÉCIFIQUE ===\n');
    print('Planning ID: $planningId\n');

    try {
      final planningDoc = await _firestore
          .collection('planning')
          .doc(planningId)
          .get();

      if (!planningDoc.exists) {
        print('❌ Planning introuvable!');
        return;
      }

      final planningData = planningDoc.data()!;
      print('📅 PLANNING:');
      print('   Recette: ${planningData['recetteName']}');
      print('   Type: ${planningData['mealType']}');
      print('   Date: ${(planningData['date'] as Timestamp).toDate()}');
      print('   RecetteId: ${planningData['recetteId']}');

      final recetteId = planningData['recetteId'];

      // Vérifier la recette
      print('\n📋 RECETTE LIÉE:');
      final recetteDoc = await _firestore
          .collection('recettes')
          .doc(recetteId)
          .get();

      if (!recetteDoc.exists) {
        print('   ❌ Recette introuvable dans Firestore!');
        print('   💡 Le planning référence une recette qui n\'existe pas');
        return;
      }

      final recetteData = recetteDoc.data()!;
      print('   ✅ Recette trouvée: ${recetteData['name']}');
      print('   Portions: ${recetteData['servings']}');

      // Vérifier les ingrédients
      print('\n🥗 INGRÉDIENTS:');
      final ingredientsSnapshot = await recetteDoc.reference
          .collection('ingredients')
          .get();

      if (ingredientsSnapshot.docs.isEmpty) {
        print('   ❌ Aucun ingrédient trouvé!');
        print('   💡 La sous-collection "ingredients" est vide');
        print('   💡 Vous devez ajouter des ingrédients à cette recette dans Firestore');
      } else {
        print('   ✅ ${ingredientsSnapshot.docs.length} ingrédient(s) trouvé(s):');
        for (final ingDoc in ingredientsSnapshot.docs) {
          final ingData = ingDoc.data();
          print('      - ${ingData['ingredientName']}: ${ingData['quantity']} ${ingData['unit']}');
        }
      }

    } catch (e) {
      print('❌ Erreur: $e');
    }
  }
}

// ============================================================================
// EXEMPLE D'UTILISATION
// ============================================================================

/*
// Dans votre code UI ou dans un bouton de debug:

final checker = FirestoreStructureChecker();

// Vérification complète
await checker.checkCompleteStructure();

// Vérification d'un planning spécifique
await checker.checkSpecificPlanning('votre_planning_id');
*/