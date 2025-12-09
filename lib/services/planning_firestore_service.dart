// lib/services/planning_firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/planning_firestore.dart';
import 'auth_service.dart';

class PlanningFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  CollectionReference get _planningCollection => _firestore.collection('planning');

  // ============================================================================
  // AJOUTER UN REPAS AU PLANNING CLOUD
  // ============================================================================
  Future<String> addToPlanning({
    required DateTime date,
    required String mealType,
    required String recetteId,
    required String recetteName,
    String? eaters,
    required PlanningVisibility visibility,
    String? groupId,
    required double totalCalories,
    double totalProteins = 0.0,
    double totalFats = 0.0,
    double totalCarbs = 0.0,
    double totalFibers = 0.0,
    String? notes,
  }) async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    if (visibility == PlanningVisibility.group && groupId == null) {
      throw Exception('Group ID required for group planning');
    }

    final now = DateTime.now();

    final data = {
      'ownerId': userId,
      'date': Timestamp.fromDate(date),
      'mealType': mealType,
      'recetteId': recetteId,
      'recetteName': recetteName,
      'eaters': eaters,
      'visibility': visibility == PlanningVisibility.group ? 'group' : 'private',
      'groupId': groupId,
      'totalCalories': totalCalories,
      'totalProteins': totalProteins,
      'totalFats': totalFats,
      'totalCarbs': totalCarbs,
      'totalFibers': totalFibers,
      'notes': notes,
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
    };

    final docRef = await _planningCollection.add(data);
    return docRef.id;
  }

  // ============================================================================
  // RÉCUPÉRER MON PLANNING
  // ============================================================================
  Stream<List<PlanningFirestore>> getMyPlanning() {
    final userId = _authService.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _planningCollection
        .where('ownerId', isEqualTo: userId)
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PlanningFirestore.fromFirestore(doc))
          .toList();
    });
  }

  // ============================================================================
  // RÉCUPÉRER LE PLANNING D'UN GROUPE
  // ============================================================================
  Stream<List<PlanningFirestore>> getGroupPlanning(String groupId) {
    return _planningCollection
        .where('groupId', isEqualTo: groupId)
        .where('visibility', isEqualTo: 'group')
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PlanningFirestore.fromFirestore(doc))
          .toList();
    });
  }

  // ============================================================================
  // RÉCUPÉRER LE PLANNING POUR UNE DATE
  // ============================================================================
  Stream<List<PlanningFirestore>> getPlanningForDate(DateTime date) {
    final userId = _authService.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _planningCollection
        .where('ownerId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay))
        .orderBy('date')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PlanningFirestore.fromFirestore(doc))
          .toList();
    });
  }

  // ============================================================================
  // RÉCUPÉRER LE PLANNING POUR UNE PLAGE DE DATES
  // ============================================================================
  Stream<List<PlanningFirestore>> getPlanningForDateRange(
      DateTime startDate,
      DateTime endDate,
      ) {
    final userId = _authService.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _planningCollection
        .where('ownerId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('date')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PlanningFirestore.fromFirestore(doc))
          .toList();
    });
  }

  // ============================================================================
  // MODIFIER UN REPAS
  // ============================================================================
  Future<void> updatePlanning({
    required String planningId,
    DateTime? date,
    String? mealType,
    String? recetteId,
    String? recetteName,
    String? eaters,
    double? totalCalories,
    double? totalProteins,
    double? totalFats,
    double? totalCarbs,
    double? totalFibers,
    String? notes,
  }) async {
    final updates = <String, dynamic>{
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    };

    if (date != null) updates['date'] = Timestamp.fromDate(date);
    if (mealType != null) updates['mealType'] = mealType;
    if (recetteId != null) updates['recetteId'] = recetteId;
    if (recetteName != null) updates['recetteName'] = recetteName;
    if (eaters != null) updates['eaters'] = eaters;
    if (totalCalories != null) updates['totalCalories'] = totalCalories;
    if (totalProteins != null) updates['totalProteins'] = totalProteins;
    if (totalFats != null) updates['totalFats'] = totalFats;
    if (totalCarbs != null) updates['totalCarbs'] = totalCarbs;
    if (totalFibers != null) updates['totalFibers'] = totalFibers;
    if (notes != null) updates['notes'] = notes;

    await _planningCollection.doc(planningId).update(updates);
  }

  // ============================================================================
  // SUPPRIMER UN REPAS
  // ============================================================================
  Future<void> deletePlanning(String planningId) async {
    await _planningCollection.doc(planningId).delete();
  }

  // ============================================================================
  // RÉCUPÉRER UN PLANNING SPÉCIFIQUE
  // ============================================================================
  Future<PlanningFirestore?> getPlanningById(String planningId) async {
    final doc = await _planningCollection.doc(planningId).get();
    if (!doc.exists) return null;
    return PlanningFirestore.fromFirestore(doc);
  }

  // ============================================================================
  // DUPLIQUER UN PLANNING
  // ============================================================================
  Future<String> duplicatePlanning({
    required String sourcePlanningId,
    required DateTime newDate,
  }) async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final source = await getPlanningById(sourcePlanningId);
    if (source == null) throw Exception('Source planning not found');

    return await addToPlanning(
      date: newDate,
      mealType: source.mealType,
      recetteId: source.recetteId,
      recetteName: source.recetteName,
      eaters: source.eaters,
      visibility: source.visibility,
      groupId: source.groupId,
      totalCalories: source.totalCalories,
      totalProteins: source.totalProteins,
      totalFats: source.totalFats,
      totalCarbs: source.totalCarbs,
      totalFibers: source.totalFibers,
      notes: source.notes,
    );
  }

  // ============================================================================
  // STATISTIQUES NUTRITIONNELLES POUR UNE DATE
  // ============================================================================
  Future<Map<String, double>> getDailyNutritionStats(DateTime date) async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) return {};

    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final snapshot = await _planningCollection
        .where('ownerId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay))
        .get();

    double totalCalories = 0;
    double totalProteins = 0;
    double totalFats = 0;
    double totalCarbs = 0;
    double totalFibers = 0;

    for (final doc in snapshot.docs) {
      final planning = PlanningFirestore.fromFirestore(doc);
      totalCalories += planning.totalCalories;
      totalProteins += planning.totalProteins;
      totalFats += planning.totalFats;
      totalCarbs += planning.totalCarbs;
      totalFibers += planning.totalFibers;
    }

    return {
      'calories': totalCalories,
      'proteins': totalProteins,
      'fats': totalFats,
      'carbs': totalCarbs,
      'fibers': totalFibers,
    };
  }

  // ============================================================================
  // COPIER LE PLANNING D'UN JOUR VERS UN AUTRE
  // ============================================================================
  Future<void> copyDayPlanning(DateTime sourceDate, DateTime targetDate) async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final startOfDay = DateTime(sourceDate.year, sourceDate.month, sourceDate.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final snapshot = await _planningCollection
        .where('ownerId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay))
        .get();

    for (final doc in snapshot.docs) {
      final planning = PlanningFirestore.fromFirestore(doc);

      final newDate = DateTime(
        targetDate.year,
        targetDate.month,
        targetDate.day,
        planning.date.hour,
        planning.date.minute,
      );

      await addToPlanning(
        date: newDate,
        mealType: planning.mealType,
        recetteId: planning.recetteId,
        recetteName: planning.recetteName,
        eaters: planning.eaters,
        visibility: planning.visibility,
        groupId: planning.groupId,
        totalCalories: planning.totalCalories,
        totalProteins: planning.totalProteins,
        totalFats: planning.totalFats,
        totalCarbs: planning.totalCarbs,
        totalFibers: planning.totalFibers,
        notes: planning.notes,
      );
    }
  }
}