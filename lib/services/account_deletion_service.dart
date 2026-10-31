// lib/services/account_deletion_service.dart
// Suppression complète d'un compte (obligatoire pour les boutiques d'applications).
//
// Efface : mon profil, mon suivi calorique, mes repas planifiés, mon stock
// privé, ma liste de courses, mes recettes privées et mes ingrédients privés.
// Je quitte mes groupes (le dernier membre supprime le groupe). Ce qui
// appartient au groupe (recettes de groupe, stock de groupe) reste au groupe.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'group_service.dart';
import 'profile_firestore_service.dart';
import 'recette_firestore_service.dart';

class AccountDeletionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Ancienneté maximale de la dernière connexion : au-delà, Firebase refuse
  /// de supprimer le compte (opération sensible).
  static const Duration _maxSignInAge = Duration(minutes: 5);

  Future<void> deleteEverything() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw 'Vous n\'êtes pas connecté.';

    // Vérifier AVANT d'effacer quoi que ce soit, sinon on pourrait effacer les
    // données puis échouer à supprimer le compte.
    final lastSignIn = user.metadata.lastSignInTime;
    if (lastSignIn == null || DateTime.now().difference(lastSignIn) > _maxSignInAge) {
      throw 'Pour votre sécurité, déconnectez-vous puis reconnectez-vous, '
          'et relancez la suppression aussitôt.';
    }

    final uid = user.uid;

    // 1. Données personnelles
    await _deleteWhereOwner('planning', uid);
    await _deleteWhereOwner('shopping_list', uid, onlyPrivate: true);
    await _deleteWhereOwner('frigo', uid, onlyPrivate: true);
    await _deleteWhereOwner('ingredients', uid, onlyPrivate: true);
    await _deletePrivateRecipes(uid);
    await _deleteSubcollection(
        _firestore.collection('users').doc(uid).collection('calorie_tracking'));
    await _deleteSubcollection(
        _firestore.collection('users').doc(uid).collection('private'));

    // 2. Quitter les groupes (mon profil de groupe est retiré au passage)
    final groupService = GroupService();
    final profileService = ProfileFirestoreService();
    final groups = await groupService.getUserGroups(uid).first;
    for (final g in groups) {
      final groupId = g['id'] as String;
      await profileService.removeFromGroup(groupId);
      final left = await groupService.leaveGroup(groupId: groupId, userId: uid);
      if (!left) {
        throw 'Impossible de quitter le groupe "${g['name'] ?? groupId}". '
            'Réessayez.';
      }
    }

    // 3. Compte
    await _firestore.collection('users').doc(uid).delete();
    await user.delete();
    debugPrint('✅ Compte supprimé');
  }

  Future<void> _deleteWhereOwner(String collection, String uid,
      {bool onlyPrivate = false}) async {
    final snapshot =
        await _firestore.collection(collection).where('ownerId', isEqualTo: uid).get();
    for (final doc in snapshot.docs) {
      if (onlyPrivate && doc.data()['visibility'] != 'private') continue;
      await doc.reference.delete();
    }
  }

  Future<void> _deletePrivateRecipes(String uid) async {
    final recipeService = RecetteFirestoreService();
    final snapshot = await _firestore
        .collection('recettes')
        .where('ownerId', isEqualTo: uid)
        .get();
    for (final doc in snapshot.docs) {
      if (doc.data()['visibility'] == 'private') {
        await recipeService.deleteRecette(doc.id);
      }
    }
  }

  Future<void> _deleteSubcollection(CollectionReference<Map<String, dynamic>> col) async {
    final snapshot = await col.get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}
