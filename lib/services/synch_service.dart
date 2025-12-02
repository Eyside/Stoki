import 'package:cloud_firestore/cloud_firestore.dart';

class GroupService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Créer un groupe
  Future<String?> createGroup(String name, String userId) async {
    try {
      final docRef = await _firestore.collection('groups').add({
        'name': name,
        'createdBy': userId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Ajouter le créateur comme membre
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
  Future<bool> joinGroup(String groupId, String userId) async {
    try {
      await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('members')
          .doc(userId)
          .set({
        'role': 'member',
        'joinedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Erreur rejoindre groupe: $e');
      return false;
    }
  }

  // Récupérer les groupes d'un utilisateur
  Stream<List<Map<String, dynamic>>> getUserGroups(String userId) {
    return _firestore
        .collectionGroup('members')
        .where('__name__', isEqualTo: userId)
        .snapshots()
        .asyncMap((snapshot) async {
      List<Map<String, dynamic>> groups = [];
      for (var doc in snapshot.docs) {
        final groupId = doc.reference.parent.parent!.id;
        final groupDoc = await _firestore.collection('groups').doc(groupId).get();
        if (groupDoc.exists) {
          groups.add({
            'id': groupId,
            ...groupDoc.data()!,
          });
        }
      }
      return groups;
    });
  }

  // Générer un code d'invitation
  Future<String> generateInviteCode(String groupId) async {
    // Utiliser un service comme Firebase Dynamic Links
    // ou simplement retourner le groupId
    return groupId;
  }
}