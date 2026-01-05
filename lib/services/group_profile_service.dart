// lib/services/group_profile_service.dart (VERSION SIMPLIFIÉE)
import 'package:cloud_firestore/cloud_firestore.dart';
import '../database.dart';
import 'auth_service.dart';

/// Service simplifié : Le profil actif local est automatiquement
/// synchronisé dans tous les groupes de l'utilisateur
class GroupProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  // ============================================================================
  // SYNCHRONISATION AUTOMATIQUE DE TOUS LES PROFILS
  // ============================================================================

  /// Synchronise UN profil vers TOUS les groupes de l'utilisateur
  /// À appeler quand l'utilisateur crée/modifie un profil
  Future<void> syncProfileToAllGroups(UserProfile profile) async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    print('🔄 Synchronisation du profil ${profile.name} vers tous les groupes...');

    try {
      // Récupérer tous les groupes de l'utilisateur
      final groupsSnapshot = await _firestore
          .collectionGroup('members')
          .where('userId', isEqualTo: userId)
          .get();

      print('   → ${groupsSnapshot.docs.length} groupe(s) trouvé(s)');

      // Pour chaque groupe, mettre à jour le profil
      for (final memberDoc in groupsSnapshot.docs) {
        final groupRef = memberDoc.reference.parent.parent;
        if (groupRef == null) continue;

        final groupId = groupRef.id;

        await _updateProfileInGroup(
          groupId: groupId,
          userId: userId,
          profile: profile,
        );

        print('   ✅ Profil synchronisé dans le groupe $groupId');
      }

      print('✅ Synchronisation terminée !');
    } catch (e) {
      print('❌ Erreur synchronisation profils: $e');
      rethrow;
    }
  }

  /// Synchronise TOUS les profils de l'utilisateur vers un groupe
  /// À appeler quand l'utilisateur rejoint un nouveau groupe
  Future<void> syncAllProfilesToGroup({
    required String groupId,
    required List<UserProfile> profiles,
  }) async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    print('🔄 Synchronisation de ${profiles.length} profil(s) vers le groupe $groupId...');

    for (final profile in profiles) {
      await _updateProfileInGroup(
        groupId: groupId,
        userId: userId,
        profile: profile,
      );
      print('   ✅ ${profile.name} synchronisé');
    }

    print('✅ Tous les profils synchronisés dans le groupe');
  }

  /// Met à jour un profil dans un groupe spécifique
  Future<void> _updateProfileInGroup({
    required String groupId,
    required String userId,
    required UserProfile profile,
  }) async {
    // Utiliser l'ID du profil local comme identifiant dans le groupe
    final profileDocId = '${userId}_${profile.id}';

    await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('profiles')
        .doc(profileDocId)
        .set({
      'userId': userId,
      'localProfileId': profile.id,
      'name': profile.name,
      'eaterMultiplier': profile.eaterMultiplier,
      'sex': profile.sex,
      'age': profile.age,
      'heightCm': profile.heightCm,
      'weightKg': profile.weightKg,
      'activityLevel': profile.activityLevel,
      'bmr': profile.bmr,
      'tdee': profile.tdee,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // ============================================================================
  // RÉCUPÉRATION DES PROFILS (LECTURE SEULE)
  // ============================================================================

  /// Récupère tous les profils des membres d'un groupe
  Future<List<Map<String, dynamic>>> getGroupProfiles(String groupId) async {
    try {
      final snapshot = await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('profiles')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'userId': data['userId'] ?? doc.id,
          'localProfileId': data['localProfileId'] ?? 0,
          'name': data['name'] ?? 'Profil inconnu',
          'eaterMultiplier': (data['eaterMultiplier'] ?? 1.0).toDouble(),
          'sex': data['sex'] ?? 'other',
          'age': data['age'] ?? 30,
          'heightCm': (data['heightCm'] ?? 170.0).toDouble(),
          'weightKg': (data['weightKg'] ?? 70.0).toDouble(),
          'activityLevel': data['activityLevel'] ?? 'moderate',
          'bmr': data['bmr']?.toDouble(),
          'tdee': data['tdee']?.toDouble(),
          'createdAt': data['createdAt'],
          'updatedAt': data['updatedAt'],
        };
      }).toList();
    } catch (e) {
      print('❌ Erreur récupération profils groupe: $e');
      return [];
    }
  }

  /// Stream des profils d'un groupe (temps réel)
  Stream<List<Map<String, dynamic>>> watchGroupProfiles(String groupId) {
    return _firestore
        .collection('groups')
        .doc(groupId)
        .collection('profiles')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'userId': data['userId'] ?? doc.id,
          'localProfileId': data['localProfileId'] ?? 0,
          'name': data['name'] ?? 'Profil inconnu',
          'eaterMultiplier': (data['eaterMultiplier'] ?? 1.0).toDouble(),
          'sex': data['sex'] ?? 'other',
          'age': data['age'] ?? 30,
          'heightCm': (data['heightCm'] ?? 170.0).toDouble(),
          'weightKg': (data['weightKg'] ?? 70.0).toDouble(),
          'activityLevel': data['activityLevel'] ?? 'moderate',
          'bmr': data['bmr']?.toDouble(),
          'tdee': data['tdee']?.toDouble(),
          'createdAt': data['createdAt'],
          'updatedAt': data['updatedAt'],
        };
      }).toList();
    });
  }

  /// Récupère le profil de l'utilisateur actuel dans un groupe spécifique
  Future<Map<String, dynamic>?> getMyProfileInGroup(String groupId) async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) return null;

    try {
      final doc = await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('profiles')
          .doc(userId)
          .get();

      if (!doc.exists) return null;

      final data = doc.data()!;
      return {
        'userId': userId,
        'localProfileId': data['localProfileId'] ?? 0,
        'name': data['name'] ?? 'Mon profil',
        'eaterMultiplier': (data['eaterMultiplier'] ?? 1.0).toDouble(),
        'sex': data['sex'] ?? 'other',
        'age': data['age'] ?? 30,
        'heightCm': (data['heightCm'] ?? 170.0).toDouble(),
        'weightKg': (data['weightKg'] ?? 70.0).toDouble(),
        'activityLevel': data['activityLevel'] ?? 'moderate',
        'bmr': data['bmr']?.toDouble(),
        'tdee': data['tdee']?.toDouble(),
        'createdAt': data['createdAt'],
        'updatedAt': data['updatedAt'],
      };
    } catch (e) {
      print('❌ Erreur récupération profil: $e');
      return null;
    }
  }

  // ============================================================================
  // VÉRIFICATIONS
  // ============================================================================

  /// Vérifie si l'utilisateur a déjà un profil dans ce groupe
  Future<bool> hasProfileInGroup(String groupId) async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) return false;

    final doc = await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('profiles')
        .doc(userId)
        .get();

    return doc.exists;
  }

  // ============================================================================
  // GESTION MANUELLE DES PROFILS PAR GROUPE
  // ============================================================================

  /// Ajoute un profil spécifique à un groupe
  Future<void> addProfileToGroup({
    required String groupId,
    required UserProfile profile,
  }) async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    await _updateProfileInGroup(
      groupId: groupId,
      userId: userId,
      profile: profile,
    );

    print('✅ Profil ${profile.name} ajouté au groupe $groupId');
  }

  /// Supprime un profil spécifique d'un groupe
  Future<void> removeSpecificProfile(
      String groupId,
      String userId,
      int localProfileId,
      ) async {
    final profileDocId = '${userId}_$localProfileId';

    await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('profiles')
        .doc(profileDocId)
        .delete();

    print('✅ Profil retiré du groupe');
  }

  // ============================================================================
  // CONVERSION POUR COMPATIBILITÉ
  // ============================================================================

  /// Convertit les profils de groupe en objets UserProfile temporaires
  List<UserProfile> convertToUserProfiles(List<Map<String, dynamic>> groupProfiles) {
    return groupProfiles.map((profile) {
      final tempId = -(profile['userId'].hashCode.abs());

      return UserProfile(
        id: tempId,
        name: profile['name'] ?? 'Profil inconnu',
        userId: profile['userId'] ?? '',
        sex: profile['sex'] ?? 'other',
        age: profile['age'] ?? 30,
        heightCm: (profile['heightCm'] ?? 170.0).toDouble(),
        weightKg: (profile['weightKg'] ?? 70.0).toDouble(),
        eaterMultiplier: (profile['eaterMultiplier'] ?? 1.0).toDouble(),
        activityLevel: profile['activityLevel'] ?? 'moderate',
        bmr: profile['bmr']?.toDouble(),
        tdee: profile['tdee']?.toDouble(),
        isActive: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }).toList();
  }
}