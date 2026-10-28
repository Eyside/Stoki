// lib/services/profile_firestore_service.dart
// Un compte = un profil.
//   users/{uid}/private/profile        -> profil complet (privé)
//   groups/{gid}/profiles/{uid}        -> nom + coefficient (vu par le groupe)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/app_profile.dart';
import 'auth_service.dart';

class ProfileFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _auth = AuthService();

  String? get currentUid => _auth.currentUser?.uid;

  DocumentReference<Map<String, dynamic>> _profileRef(String uid) =>
      _firestore.collection('users').doc(uid).collection('private').doc('profile');

  // --------------------------------------------------------------------------
  // MON PROFIL
  // --------------------------------------------------------------------------

  Future<AppProfile?> getMyProfile() async {
    final uid = currentUid;
    if (uid == null) return null;
    final doc = await _profileRef(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return AppProfile.fromMap(uid, doc.data()!);
  }

  /// Enregistre mon profil et le propage dans tous mes groupes.
  Future<AppProfile> saveMyProfile({
    required String name,
    required String sex,
    required int age,
    required double heightCm,
    required double weightKg,
    required double eaterMultiplier,
    required String activityLevel,
  }) async {
    final uid = currentUid;
    if (uid == null) throw Exception('Utilisateur non connecté');

    final profile = AppProfile.create(
      uid: uid,
      name: name,
      sex: sex,
      age: age,
      heightCm: heightCm,
      weightKg: weightKg,
      eaterMultiplier: eaterMultiplier,
      activityLevel: activityLevel,
    );

    await _profileRef(uid).set(profile.toMap(), SetOptions(merge: true));

    // La propagation vers les groupes ne doit pas faire échouer la sauvegarde.
    try {
      await syncToAllGroups(profile);
    } catch (e) {
      debugPrint('⚠️ Synchronisation des groupes impossible: $e');
    }
    return profile;
  }

  // --------------------------------------------------------------------------
  // PROPAGATION DANS LES GROUPES
  // --------------------------------------------------------------------------

  Future<void> syncToAllGroups(AppProfile profile) async {
    final snapshot = await _firestore
        .collectionGroup('members')
        .where('userId', isEqualTo: profile.uid)
        .get();

    for (final memberDoc in snapshot.docs) {
      final groupRef = memberDoc.reference.parent.parent;
      if (groupRef == null) continue;
      await _writeGroupProfile(groupRef.id, profile);
    }
  }

  /// Ajoute (ou met à jour) mon profil dans un groupe. Sans effet si je n'ai
  /// pas encore de profil.
  Future<void> syncToGroup(String groupId) async {
    final profile = await getMyProfile();
    if (profile == null) return;
    await _writeGroupProfile(groupId, profile);
  }

  Future<void> _writeGroupProfile(String groupId, AppProfile profile) async {
    final profilesRef =
        _firestore.collection('groups').doc(groupId).collection('profiles');

    await profilesRef.doc(profile.uid).set({
      'userId': profile.uid,
      'name': profile.name,
      'eaterMultiplier': profile.eaterMultiplier,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Nettoyage des anciennes copies (ancien format, avec âge/poids).
    try {
      final old =
          await profilesRef.where('userId', isEqualTo: profile.uid).get();
      for (final doc in old.docs) {
        if (doc.id != profile.uid) {
          await doc.reference.delete();
        }
      }
    } catch (e) {
      debugPrint('⚠️ Nettoyage anciens profils: $e');
    }
  }

  Future<void> removeFromGroup(String groupId) async {
    final uid = currentUid;
    if (uid == null) return;
    try {
      await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('profiles')
          .doc(uid)
          .delete();
    } catch (e) {
      debugPrint('⚠️ Retrait du profil du groupe: $e');
    }
  }

  // --------------------------------------------------------------------------
  // MEMBRES D'UN GROUPE (nom + coefficient uniquement)
  // --------------------------------------------------------------------------

  List<GroupMember> _toMembers(QuerySnapshot<Map<String, dynamic>> snapshot) {
    return snapshot.docs
        .where((d) => d.id == (d.data()['userId'] ?? d.id))
        .map((d) => GroupMember.fromMap(d.id, d.data()))
        .toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  Future<List<GroupMember>> getGroupMembers(String groupId) async {
    final snapshot = await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('profiles')
        .get();
    return _toMembers(snapshot);
  }

  Stream<List<GroupMember>> watchGroupMembers(String groupId) {
    return _firestore
        .collection('groups')
        .doc(groupId)
        .collection('profiles')
        .snapshots()
        .map(_toMembers);
  }
}
