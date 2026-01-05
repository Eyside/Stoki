// lib/models/frigo_firestore.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum FrigoVisibility {
  private,
  group,
}

class FrigoFirestore {
  final String id;
  final String ownerId;
  final String ingredientId; // Référence à l'ingrédient local ou ID string
  final String ingredientName;
  final double quantity;
  final String unit;
  final String location; // frigo, placard, congélateur
  final DateTime? bestBefore;
  final FrigoVisibility visibility;
  final String? groupId;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Valeurs nutritionnelles copiées de l'ingrédient
  final double caloriesPer100g;
  final double proteinsPer100g;
  final double fatsPer100g;
  final double carbsPer100g;
  final double fibersPer100g;
  final double? densityGPerMl;
  final double? avgWeightPerUnitG;

  FrigoFirestore({
    required this.id,
    required this.ownerId,
    required this.ingredientId,
    required this.ingredientName,
    required this.quantity,
    required this.unit,
    required this.location,
    this.bestBefore,
    required this.visibility,
    this.groupId,
    required this.createdAt,
    required this.updatedAt,
    required this.caloriesPer100g,
    this.proteinsPer100g = 0.0,
    this.fatsPer100g = 0.0,
    this.carbsPer100g = 0.0,
    this.fibersPer100g = 0.0,
    this.densityGPerMl,
    this.avgWeightPerUnitG,
  });

  factory FrigoFirestore.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return FrigoFirestore(
      id: doc.id,
      ownerId: data['ownerId'] ?? '',
      ingredientId: data['ingredientId'] ?? '',
      ingredientName: data['ingredientName'] ?? 'Inconnu',
      quantity: (data['quantity'] ?? 0).toDouble(),
      unit: data['unit'] ?? 'g',
      location: data['location'] ?? 'frigo',
      bestBefore: data['bestBefore'] != null
          ? (data['bestBefore'] as Timestamp).toDate()
          : null,
      visibility: data['visibility'] == 'group'
          ? FrigoVisibility.group
          : FrigoVisibility.private,
      groupId: data['groupId'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      caloriesPer100g: (data['caloriesPer100g'] ?? 0).toDouble(),
      proteinsPer100g: (data['proteinsPer100g'] ?? 0).toDouble(),
      fatsPer100g: (data['fatsPer100g'] ?? 0).toDouble(),
      carbsPer100g: (data['carbsPer100g'] ?? 0).toDouble(),
      fibersPer100g: (data['fibersPer100g'] ?? 0).toDouble(),
      densityGPerMl: data['densityGPerMl']?.toDouble(),
      avgWeightPerUnitG: data['avgWeightPerUnitG']?.toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'ownerId': ownerId,
      'ingredientId': ingredientId,
      'ingredientName': ingredientName,
      'quantity': quantity,
      'unit': unit,
      'location': location,
      'bestBefore': bestBefore != null ? Timestamp.fromDate(bestBefore!) : null,
      'visibility': visibility == FrigoVisibility.group ? 'group' : 'private',
      'groupId': groupId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'caloriesPer100g': caloriesPer100g,
      'proteinsPer100g': proteinsPer100g,
      'fatsPer100g': fatsPer100g,
      'carbsPer100g': carbsPer100g,
      'fibersPer100g': fibersPer100g,
      'densityGPerMl': densityGPerMl,
      'avgWeightPerUnitG': avgWeightPerUnitG,
    };
  }

  String get visibilityLabel {
    switch (visibility) {
      case FrigoVisibility.private:
        return 'Privé';
      case FrigoVisibility.group:
        return 'Groupe';
    }
  }

  bool canEdit(String userId) {
    if (ownerId == userId) return true;
    if (visibility == FrigoVisibility.group) return true;
    return false;
  }

  FrigoFirestore copyWith({
    String? id,
    String? ownerId,
    String? ingredientId,
    String? ingredientName,
    double? quantity,
    String? unit,
    String? location,
    DateTime? bestBefore,
    FrigoVisibility? visibility,
    String? groupId,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? caloriesPer100g,
    double? proteinsPer100g,
    double? fatsPer100g,
    double? carbsPer100g,
    double? fibersPer100g,
    double? densityGPerMl,
    double? avgWeightPerUnitG,
  }) {
    return FrigoFirestore(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      ingredientId: ingredientId ?? this.ingredientId,
      ingredientName: ingredientName ?? this.ingredientName,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      location: location ?? this.location,
      bestBefore: bestBefore ?? this.bestBefore,
      visibility: visibility ?? this.visibility,
      groupId: groupId ?? this.groupId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      caloriesPer100g: caloriesPer100g ?? this.caloriesPer100g,
      proteinsPer100g: proteinsPer100g ?? this.proteinsPer100g,
      fatsPer100g: fatsPer100g ?? this.fatsPer100g,
      carbsPer100g: carbsPer100g ?? this.carbsPer100g,
      fibersPer100g: fibersPer100g ?? this.fibersPer100g,
      densityGPerMl: densityGPerMl ?? this.densityGPerMl,
      avgWeightPerUnitG: avgWeightPerUnitG ?? this.avgWeightPerUnitG,
    );
  }
}