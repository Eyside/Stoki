// lib/models/planning_firestore.dart
// REMPLACEZ la classe PlanningFirestore par celle-ci

import 'package:cloud_firestore/cloud_firestore.dart';

enum PlanningVisibility {
  private,
  group,
}

class PlanningFirestore {
  final String id;
  final String ownerId;
  final DateTime date;
  final String mealType;

  final String recetteId;
  final String recetteName;

  final String? eaters;

  final PlanningVisibility visibility;
  final String? groupId;

  final double totalCalories;
  final double totalProteins;
  final double totalFats;
  final double totalCarbs;
  final double totalFibers;

  // NOUVEAUX CHAMPS pour les modifications
  final String? modifiedIngredients;
  final double? modifiedCalories;
  final double? modifiedProteins;
  final double? modifiedFats;
  final double? modifiedCarbs;
  final double? modifiedFibers;

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
    this.modifiedIngredients,
    this.modifiedCalories,
    this.modifiedProteins,
    this.modifiedFats,
    this.modifiedCarbs,
    this.modifiedFibers,
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
      modifiedIngredients: data['modifiedIngredients'],
      modifiedCalories: data['modifiedCalories'] != null
          ? (data['modifiedCalories'] as num).toDouble()
          : null,
      modifiedProteins: data['modifiedProteins'] != null
          ? (data['modifiedProteins'] as num).toDouble()
          : null,
      modifiedFats: data['modifiedFats'] != null
          ? (data['modifiedFats'] as num).toDouble()
          : null,
      modifiedCarbs: data['modifiedCarbs'] != null
          ? (data['modifiedCarbs'] as num).toDouble()
          : null,
      modifiedFibers: data['modifiedFibers'] != null
          ? (data['modifiedFibers'] as num).toDouble()
          : null,
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
      'modifiedIngredients': modifiedIngredients,
      'modifiedCalories': modifiedCalories,
      'modifiedProteins': modifiedProteins,
      'modifiedFats': modifiedFats,
      'modifiedCarbs': modifiedCarbs,
      'modifiedFibers': modifiedFibers,
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
    String? modifiedIngredients,
    double? modifiedCalories,
    double? modifiedProteins,
    double? modifiedFats,
    double? modifiedCarbs,
    double? modifiedFibers,
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
      modifiedIngredients: modifiedIngredients ?? this.modifiedIngredients,
      modifiedCalories: modifiedCalories ?? this.modifiedCalories,
      modifiedProteins: modifiedProteins ?? this.modifiedProteins,
      modifiedFats: modifiedFats ?? this.modifiedFats,
      modifiedCarbs: modifiedCarbs ?? this.modifiedCarbs,
      modifiedFibers: modifiedFibers ?? this.modifiedFibers,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}