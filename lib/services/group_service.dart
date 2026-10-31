// lib/services/group_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'profile_firestore_service.dart';

class GroupService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Nom affiché dans le groupe tant que le membre n'a pas de profil
  /// (jamais l'adresse e-mail complète).
  String _myDisplayName() {
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName?.trim();
    if (name != null && name.isNotEmpty) return name;
    final email = user?.email;
    if (email != null && email.contains('@')) return email.split('@').first;
    return 'Membre';
  }

  /// Fiche publique d'un code d'invitation : invites/{code}.
  /// Elle permet de rejoindre un groupe sans que les groupes soient lisibles
  /// par tout le monde.
  Future<void> _writeInvite({
    required String code,
    required String groupId,
    required String groupName,
    required String description,
    required String createdBy,
  }) {
    return _firestore.collection('invites').doc(code).set({
      'groupId': groupId,
      'groupName': groupName,
      'description': description,
      'createdBy': createdBy,
    });
  }

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

      debugPrint('✅ Groupe créé: ${docRef.id}');

      // Ajouter le créateur comme administrateur
      await docRef.collection('members').doc(userId).set({
        'userId': userId, // IMPORTANT: on stocke l'userId aussi ici
        'role': 'admin',
        'displayName': _myDisplayName(),
        'joinedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('✅ Membre admin ajouté: $userId');

      await _writeInvite(
        code: inviteCode,
        groupId: docRef.id,
        groupName: name,
        description: description ?? '',
        createdBy: userId,
      );

      await _addMyProfileToGroup(docRef.id);

      return docRef.id;
    } catch (e) {
      debugPrint('❌ Erreur création groupe: $e');
      return null;
    }
  }

  // Rejoindre un groupe avec code d'invitation
  Future<bool> joinGroupWithCode({
    required String inviteCode,
    required String userId,
  }) async {
    try {
      final code = inviteCode.trim().toUpperCase();

      // Le code mène au groupe via sa fiche d'invitation
      final invite = await _firestore.collection('invites').doc(code).get();
      if (!invite.exists || invite.data()?['groupId'] == null) {
        throw 'Code d\'invitation invalide';
      }

      final groupRef =
          _firestore.collection('groups').doc(invite.data()!['groupId'] as String);

      // Vérifier si l'utilisateur est déjà membre
      final memberDoc = await groupRef.collection('members').doc(userId).get();
      if (memberDoc.exists) {
        throw 'Vous êtes déjà membre de ce groupe';
      }

      // Ajouter l'utilisateur comme membre (le code prouve l'invitation)
      await groupRef.collection('members').doc(userId).set({
        'userId': userId,
        'role': 'member',
        'displayName': _myDisplayName(),
        'inviteCode': code,
        'joinedAt': FieldValue.serverTimestamp(),
      });

      // Incrémenter le compteur de membres
      await groupRef.update({
        'memberCount': FieldValue.increment(1),
      });

      await _addMyProfileToGroup(groupRef.id);

      return true;
    } catch (e) {
      debugPrint('❌ Erreur rejoindre groupe: $e');
      rethrow;
    }
  }

  // Prévisualiser un groupe avec le code d'invitation (NOUVELLE MÉTHODE)
  Future<Map<String, dynamic>?> previewGroupByCode(String inviteCode) async {
    try {
      final invite = await _firestore
          .collection('invites')
          .doc(inviteCode.trim().toUpperCase())
          .get();
      if (!invite.exists) return null;

      final data = invite.data()!;
      return {
        'id': data['groupId'],
        'name': data['groupName'],
        'description': data['description'] ?? '',
        'memberCount': null, // non communiqué avant d'avoir rejoint
        'inviteCode': invite.id,
      };
    } catch (e) {
      debugPrint('❌ Erreur preview groupe: $e');
      return null;
    }
  }

  // Récupérer les groupes d'un utilisateur - VERSION CORRIGÉE
  Stream<List<Map<String, dynamic>>> getUserGroups(String userId) {
    debugPrint('🔍 getUserGroups appelé avec userId: $userId');

    // On utilise collectionGroup pour chercher dans toutes les sous-collections 'members'
    return _firestore
        .collectionGroup('members')
        .where('userId', isEqualTo: userId) // CORRECTION: on cherche par userId dans les données
        .snapshots()
        .asyncMap((snapshot) async {
      debugPrint('🔍 Snapshot reçu avec ${snapshot.docs.length} documents');

      List<Map<String, dynamic>> groups = [];

      for (var memberDoc in snapshot.docs) {
        try {
          // Le parent.parent nous donne le document du groupe
          final groupRef = memberDoc.reference.parent.parent;

          if (groupRef == null) {
            debugPrint('⚠️ groupRef est null pour ${memberDoc.id}');
            continue;
          }

          debugPrint('🔍 Récupération du groupe: ${groupRef.id}');
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

            debugPrint('✅ Groupe ajouté: ${groupData['name']}');
          } else {
            debugPrint('⚠️ Le groupe ${groupRef.id} n\'existe pas');
          }
        } catch (e) {
          debugPrint('❌ Erreur traitement document: $e');
        }
      }

      debugPrint('✅ Total groupes trouvés: ${groups.length}');
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
      debugPrint('❌ Erreur récupération groupe: $e');
      return null;
    }
  }

  // Récupérer les membres d'un groupe (fiches de membre uniquement : aucun
  // autre compte n'est lu)
  Stream<List<Map<String, dynamic>>> getGroupMembers(String groupId) {
    return _firestore
        .collection('groups')
        .doc(groupId)
        .collection('members')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return <String, dynamic>{
          'userId': data['userId'] ?? doc.id,
          'role': data['role'],
          'joinedAt': data['joinedAt'],
          'displayName': data['displayName'] ?? 'Membre',
        };
      }).toList();
    });
  }

  /// Remet ma fiche de membre à jour (nom affiché) et, si je suis
  /// administrateur, crée la fiche d'invitation d'un groupe plus ancien.
  /// Sans effet bloquant : toute erreur est ignorée.
  Future<void> syncMembership(String groupId, String userId) async {
    try {
      final groupRef = _firestore.collection('groups').doc(groupId);
      final memberRef = groupRef.collection('members').doc(userId);
      final member = await memberRef.get();
      if (!member.exists) return;

      if (member.data()?['displayName'] == null) {
        await memberRef.update({'displayName': _myDisplayName()});
      }

      if (member.data()?['role'] == 'admin') {
        final group = await groupRef.get();
        final data = group.data();
        final code = data?['inviteCode'] as String?;
        if (data != null && code != null) {
          final invite = await _firestore.collection('invites').doc(code).get();
          if (!invite.exists) {
            await _writeInvite(
              code: code,
              groupId: groupId,
              groupName: (data['name'] ?? '') as String,
              description: (data['description'] ?? '') as String,
              createdBy: userId,
            );
          }
        }
      }
    } catch (e) {
      debugPrint('⚠️ Synchronisation de la fiche de membre: $e');
    }
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
          // Dernier membre : supprimer le groupe et sa fiche d'invitation
          await _deleteInviteOf(groupRef);
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

      // Décrémenter le compteur (tant que je suis encore membre)
      await groupRef.update({
        'memberCount': FieldValue.increment(-1),
      });

      // Supprimer le membre
      await memberRef.delete();

      return true;
    } catch (e) {
      debugPrint('❌ Erreur quitter groupe: $e');
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

      // Supprimer la fiche d'invitation puis le groupe
      await _deleteInviteOf(groupRef);
      await groupRef.delete();

      return true;
    } catch (e) {
      debugPrint('❌ Erreur suppression groupe: $e');
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
      debugPrint('❌ Erreur mise à jour groupe: $e');
      return false;
    }
  }

  // Générer un code d'invitation aléatoire
  String _generateInviteCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random();
    return List.generate(6, (index) => chars[random.nextInt(chars.length)]).join();
  }

  /// Supprime la fiche d'invitation du groupe (si elle existe).
  Future<void> _deleteInviteOf(DocumentReference<Map<String, dynamic>> groupRef) async {
    try {
      final group = await groupRef.get();
      final code = group.data()?['inviteCode'] as String?;
      if (code != null) {
        await _firestore.collection('invites').doc(code).delete();
      }
    } catch (e) {
      debugPrint('⚠️ Suppression de la fiche d\'invitation: $e');
    }
  }

  // Régénérer le code d'invitation
  Future<String?> regenerateInviteCode(String groupId) async {
    try {
      final groupRef = _firestore.collection('groups').doc(groupId);
      final group = await groupRef.get();
      final data = group.data();
      if (data == null) return null;

      final newCode = _generateInviteCode();

      await groupRef.update({'inviteCode': newCode});

      // L'ancien code cesse de fonctionner
      final oldCode = data['inviteCode'] as String?;
      if (oldCode != null) {
        try {
          await _firestore.collection('invites').doc(oldCode).delete();
        } catch (_) {}
      }

      await _writeInvite(
        code: newCode,
        groupId: groupId,
        groupName: (data['name'] ?? '') as String,
        description: (data['description'] ?? '') as String,
        createdBy: (data['createdBy'] ?? '') as String,
      );

      return newCode;
    } catch (e) {
      debugPrint('❌ Erreur régénération code: $e');
      return null;
    }
  }
}
