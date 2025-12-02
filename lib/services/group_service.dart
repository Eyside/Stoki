// lib/services/group_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class GroupService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

      // Ajouter le créateur comme administrateur
      await docRef.collection('members').doc(userId).set({
        'role': 'admin',
        'joinedAt': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      print('Erreur création groupe: $e');
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
      final groupId = groupDoc.id;

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
        'role': 'member',
        'joinedAt': FieldValue.serverTimestamp(),
      });

      // Incrémenter le compteur de membres
      await groupDoc.reference.update({
        'memberCount': FieldValue.increment(1),
      });

      return true;
    } catch (e) {
      print('Erreur rejoindre groupe: $e');
      rethrow;
    }
  }

  // Récupérer les groupes d'un utilisateur
  Stream<List<Map<String, dynamic>>> getUserGroups(String userId) {
    return _firestore
        .collectionGroup('members')
        .where(FieldPath.documentId, isEqualTo: userId)
        .snapshots()
        .asyncMap((snapshot) async {
      List<Map<String, dynamic>> groups = [];

      for (var doc in snapshot.docs) {
        final groupRef = doc.reference.parent.parent!;
        final groupDoc = await groupRef.get();

        if (groupDoc.exists) {
          final memberData = doc.data();
          groups.add({
            'id': groupRef.id,
            'role': memberData['role'],
            ...groupDoc.data() as Map<String, dynamic>,
          });
        }
      }

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
      print('Erreur récupération groupe: $e');
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
        final userId = doc.id;
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
      print('Erreur quitter groupe: $e');
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
      print('Erreur suppression groupe: $e');
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
      print('Erreur mise à jour groupe: $e');
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
      print('Erreur régénération code: $e');
      return null;
    }
  }
}