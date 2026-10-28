// lib/services/calorie_tracking_firestore_service.dart
// Suivi calorique privé : users/{uid}/calorie_tracking/{planningId}
// L'identifiant du document est celui du repas planifié : consommer deux fois
// le même repas écrase la ligne au lieu de la dupliquer.

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_profile.dart';
import 'auth_service.dart';

class CalorieTrackingFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _auth = AuthService();

  String? get currentUid => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _firestore.collection('users').doc(uid).collection('calorie_tracking');

  /// Lignes entre [start] et [end] (inclus), de la plus ancienne à la
  /// plus récente.
  Future<List<CalorieEntry>> getRange(DateTime start, DateTime end) async {
    final uid = currentUid;
    if (uid == null) return [];

    final snapshot = await _col(uid)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .orderBy('date')
        .get();

    return snapshot.docs
        .map((d) => CalorieEntry.fromMap(d.id, d.data()))
        .toList();
  }

  Future<void> addEntry({
    required String planningId,
    required DateTime date,
    required String mealType,
    required double calories,
    double proteins = 0,
    double fats = 0,
    double carbs = 0,
    double fibers = 0,
    String? recipeName,
  }) async {
    final uid = currentUid;
    if (uid == null) throw Exception('Utilisateur non connecté');

    await _col(uid).doc(planningId).set({
      'planningId': planningId,
      'date': Timestamp.fromDate(date),
      'mealType': mealType,
      'calories': calories,
      'proteins': proteins,
      'fats': fats,
      'carbs': carbs,
      'fibers': fibers,
      'recipeName': recipeName,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Ai-je déjà consommé ce repas ?
  Future<bool> hasConsumed(String planningId) async {
    final uid = currentUid;
    if (uid == null) return false;
    final doc = await _col(uid).doc(planningId).get();
    return doc.exists;
  }
}
