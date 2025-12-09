// lib/models/planning_firestore.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum PlanningVisibility {
  private,
  group,
}

class PlanningFirestore {
  final String id;
  final String ownerId;
  final DateTime date;
  final String mealType; // breakfast, lunch, dinner, snack

  // Référence à la recette (local ou cloud)
  final String recetteId;
  final String recetteName;

  // Liste des profils qui mangent (JSON array d'IDs)
  final String? eaters;

  // Visibilité
  final PlanningVisibility visibility;
  final String? groupId;

  // Valeurs nutritionnelles copiées pour historique
  final double totalCalories;
  final double totalProteins;
  final double totalFats;
  final double totalCarbs;
  final double totalFibers;

  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  PlanningFirestore({
    required this.id,
    required this.ownerId,
    required this.date,
    required this.mealType,
    required this.recetteId,
    required this.recetteName,
    this.eaters,
    required this.visibility,
    this.groupId,
    required this.totalCalories,
    this.totalProteins = 0.0,
    this.totalFats = 0.0,
    this.totalCarbs = 0.0,
    this.totalFibers = 0.0,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PlanningFirestore.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return PlanningFirestore(
      id: doc.id,
      ownerId: data['ownerId'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      mealType: data['mealType'] ?? 'lunch',
      recetteId: data['recetteId'] ?? '',
      recetteName: data['recetteName'] ?? 'Recette inconnue',
      eaters: data['eaters'],
      visibility: data['visibility'] == 'group'
          ? PlanningVisibility.group
          : PlanningVisibility.private,
      groupId: data['groupId'],
      totalCalories: (data['totalCalories'] ?? 0).toDouble(),
      totalProteins: (data['totalProteins'] ?? 0).toDouble(),
      totalFats: (data['totalFats'] ?? 0).toDouble(),
      totalCarbs: (data['totalCarbs'] ?? 0).toDouble(),
      totalFibers: (data['totalFibers'] ?? 0).toDouble(),
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'ownerId': ownerId,
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
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  String get visibilityLabel {
    switch (visibility) {
      case PlanningVisibility.private:
        return 'Privé';
      case PlanningVisibility.group:
        return 'Groupe';
    }
  }

  bool canEdit(String userId) {
    if (ownerId == userId) return true;
    if (visibility == PlanningVisibility.group) return true;
    return false;
  }

  PlanningFirestore copyWith({
    String? id,
    String? ownerId,
    DateTime? date,
    String? mealType,
    String? recetteId,
    String? recetteName,
    String? eaters,
    PlanningVisibility? visibility,
    String? groupId,
    double? totalCalories,
    double? totalProteins,
    double? totalFats,
    double? totalCarbs,
    double? totalFibers,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PlanningFirestore(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      date: date ?? this.date,
      mealType: mealType ?? this.mealType,
      recetteId: recetteId ?? this.recetteId,
      recetteName: recetteName ?? this.recetteName,
      eaters: eaters ?? this.eaters,
      visibility: visibility ?? this.visibility,
      groupId: groupId ?? this.groupId,
      totalCalories: totalCalories ?? this.totalCalories,
      totalProteins: totalProteins ?? this.totalProteins,
      totalFats: totalFats ?? this.totalFats,
      totalCarbs: totalCarbs ?? this.totalCarbs,
      totalFibers: totalFibers ?? this.totalFibers,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}