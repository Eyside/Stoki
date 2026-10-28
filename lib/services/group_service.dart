// lib/services/group_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'profile_firestore_service.dart';

class GroupService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Ajoute mon profil (nom + coefficient) au groupe. Sans effet si je n'ai pas
  /// encore de profil, et sans jamais faire échouer la création / l'arrivée.
  Future<void> _addMyProfileToGroup(String groupId) async {
    try {
      await ProfileFirestoreService().syncToGroup(groupId);
    } catch (e) {
      debugPrint('⚠️ Ajout du profil au groupe impossible: $e');
    }
  }

  // Créer un groupe
  Future<String?> createGroup({
    required String name,
    required String userId,
    String? description,
  }) async {
    try {
      // Générer un code d'invitation unique
      final inviteCode = _generateInviteCode();

      final docRef = await _firestore.collection('groups').add({
        'name': name,
        'description': description ?? '',
        'createdBy': userId,
        'createdAt': FieldValue.serverTimestamp(),
        'inviteCode': inviteCode,
        'memberCount': 1,
      });

      print('✅ Groupe créé: ${docRef.id}');

      // Ajouter le créateur comme administrateur
      await docRef.collection('members').doc(userId).set({
        'userId': userId, // IMPORTANT: on stocke l'userId aussi ici
        'role': 'admin',
        'joinedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Membre admin ajouté: $userId');

      await _addMyProfileToGroup(docRef.id);

      return docRef.id;
    } catch (e) {
      print('❌ Erreur création groupe: $e');
      return null;
    }
  }

  // Rejoindre un groupe avec code d'invitation
  Future<bool> joinGroupWithCode({
    required String inviteCode,
    required String userId,
  }) async {
    try {
      // Chercher le groupe avec ce code
      final querySnapshot = await _firestore
          .collection('groups')
          .where('inviteCode', isEqualTo: inviteCode)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw 'Code d\'invitation invalide';
      }

      final groupDoc = querySnapshot.docs.first;

      // Vérifier si l'utilisateur est déjà membre
      final memberDoc = await groupDoc.reference
          .collection('members')
          .doc(userId)
          .get();

      if (memberDoc.exists) {
        throw 'Vous êtes déjà membre de ce groupe';
      }

      // Ajouter l'utilisateur comme membre
      await groupDoc.reference.collection('members').doc(userId).set({
        'userId': userId,
        'role': 'member',
        'joinedAt': FieldValue.serverTimestamp(),
      });

      // Incrémenter le compteur de membres
      await groupDoc.reference.update({
        'memberCount': FieldValue.increment(1),
      });

      await _addMyProfileToGroup(groupDoc.id);

      return true;
    } catch (e) {
      print('❌ Erreur rejoindre groupe: $e');
      rethrow;
    }
  }

  // Prévisualiser un groupe avec le code d'invitation (NOUVELLE MÉTHODE)
  Future<Map<String, dynamic>?> previewGroupByCode(String inviteCode) async {
    try {
      final querySnapshot = await _firestore
          .collection('groups')
          .where('inviteCode', isEqualTo: inviteCode)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      final groupDoc = querySnapshot.docs.first;
      final data = groupDoc.data();

      return {
        'id': groupDoc.id,
        'name': data['name'],
        'description': data['description'] ?? '',
        'memberCount': data['memberCount'] ?? 0,
        'inviteCode': data['inviteCode'],
      };
    } catch (e) {
      print('❌ Erreur preview groupe: $e');
      return null;
    }
  }

  // Récupérer les groupes d'un utilisateur - VERSION CORRIGÉE
  Stream<List<Map<String, dynamic>>> getUserGroups(String userId) {
    print('🔍 getUserGroups appelé avec userId: $userId');

    // On utilise collectionGroup pour chercher dans toutes les sous-collections 'members'
    return _firestore
        .collectionGroup('members')
        .where('userId', isEqualTo: userId) // CORRECTION: on cherche par userId dans les données
        .snapshots()
        .asyncMap((snapshot) async {
      print('🔍 Snapshot reçu avec ${snapshot.docs.length} documents');

      List<Map<String, dynamic>> groups = [];

      for (var memberDoc in snapshot.docs) {
        try {
          // Le parent.parent nous donne le document du groupe
          final groupRef = memberDoc.reference.parent.parent;

          if (groupRef == null) {
            print('⚠️ groupRef est null pour ${memberDoc.id}');
            continue;
          }

          print('🔍 Récupération du groupe: ${groupRef.id}');
          final groupDoc = await groupRef.get();

          if (groupDoc.exists) {
            final memberData = memberDoc.data();
            final groupData = groupDoc.data() as Map<String, dynamic>;

            groups.add({
              'id': groupRef.id,
              'role': memberData['role'] ?? 'member',
              'name': groupData['name'],
              'description': groupData['description'],
              'memberCount': groupData['memberCount'],
              'inviteCode': groupData['inviteCode'],
              'createdAt': groupData['createdAt'],
            });

            print('✅ Groupe ajouté: ${groupData['name']}');
          } else {
            print('⚠️ Le groupe ${groupRef.id} n\'existe pas');
          }
        } catch (e) {
          print('❌ Erreur traitement document: $e');
        }
      }

      print('✅ Total groupes trouvés: ${groups.length}');
      return groups;
    });
  }

  // Récupérer les détails d'un groupe
  Future<Map<String, dynamic>?> getGroupDetails(String groupId) async {
    try {
      final doc = await _firestore.collection('groups').doc(groupId).get();

      if (!doc.exists) return null;

      return {
        'id': doc.id,
        ...doc.data()!,
      };
    } catch (e) {
      print('❌ Erreur récupération groupe: $e');
      return null;
    }
  }

  // Récupérer les membres d'un groupe
  Stream<List<Map<String, dynamic>>> getGroupMembers(String groupId) {
    return _firestore
        .collection('groups')
        .doc(groupId)
        .collection('members')
        .snapshots()
        .asyncMap((snapshot) async {
      List<Map<String, dynamic>> members = [];

      for (var doc in snapshot.docs) {
        final userId = doc.data()['userId'] ?? doc.id;
        final memberData = doc.data();

        // Récupérer les infos utilisateur
        final userDoc = await _firestore.collection('users').doc(userId).get();

        if (userDoc.exists) {
          members.add({
            'userId': userId,
            'role': memberData['role'],
            'joinedAt': memberData['joinedAt'],
            ...userDoc.data()!,
          });
        }
      }

      return members;
    });
  }

  // Quitter un groupe
  Future<bool> leaveGroup({
    required String groupId,
    required String userId,
  }) async {
    try {
      final groupRef = _firestore.collection('groups').doc(groupId);
      final memberRef = groupRef.collection('members').doc(userId);

      // Vérifier si l'utilisateur est admin
      final memberDoc = await memberRef.get();
      if (memberDoc.exists && memberDoc.data()?['role'] == 'admin') {
        // Vérifier s'il y a d'autres membres
        final membersSnapshot = await groupRef.collection('members').get();

        if (membersSnapshot.docs.length == 1) {
          // Dernier membre : supprimer le groupe
          await groupRef.delete();
          return true;
        } else {
          // Transférer les droits d'admin à un autre membre
          final otherMember = membersSnapshot.docs.firstWhere(
                (doc) => doc.id != userId,
          );
          await groupRef.collection('members').doc(otherMember.id).update({
            'role': 'admin',
          });
        }
      }

      // Supprimer le membre
      await memberRef.delete();

      // Décrémenter le compteur
      await groupRef.update({
        'memberCount': FieldValue.increment(-1),
      });

      return true;
    } catch (e) {
      print('❌ Erreur quitter groupe: $e');
      return false;
    }
  }

  // Supprimer un groupe (admin uniquement)
  Future<bool> deleteGroup(String groupId, String userId) async {
    try {
      final groupRef = _firestore.collection('groups').doc(groupId);

      // Vérifier que l'utilisateur est admin
      final memberDoc = await groupRef.collection('members').doc(userId).get();

      if (!memberDoc.exists || memberDoc.data()?['role'] != 'admin') {
        throw 'Vous devez être administrateur pour supprimer ce groupe';
      }

      // Supprimer le groupe (cascade automatique des sous-collections)
      await groupRef.delete();

      return true;
    } catch (e) {
      print('❌ Erreur suppression groupe: $e');
      rethrow;
    }
  }

  // Mettre à jour un groupe
  Future<bool> updateGroup({
    required String groupId,
    String? name,
    String? description,
  }) async {
    try {
      final updates = <String, dynamic>{};

      if (name != null) updates['name'] = name;
      if (description != null) updates['description'] = description;

      if (updates.isEmpty) return false;

      await _firestore.collection('groups').doc(groupId).update(updates);

      return true;
    } catch (e) {
      print('❌ Erreur mise à jour groupe: $e');
      return false;
    }
  }

  // Générer un code d'invitation aléatoire
  String _generateInviteCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random();
    return List.generate(6, (index) => chars[random.nextInt(chars.length)]).join();
  }

  // Régénérer le code d'invitation
  Future<String?> regenerateInviteCode(String groupId) async {
    try {
      final newCode = _generateInviteCode();

      await _firestore.collection('groups').doc(groupId).update({
        'inviteCode': newCode,
      });

      return newCode;
    } catch (e) {
      print('❌ Erreur régénération code: $e');
      return null;
    }
  }
}