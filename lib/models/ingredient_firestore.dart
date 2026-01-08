// lib/models/ingredient_firestore.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum IngredientVisibility {
  private,
  public,
  group,
}

class IngredientFirestore {
  final String id;
  final String ownerId;
  final String name;

  // Valeurs nutritionnelles pour 100g
  final double caloriesPer100g;
  final double proteinsPer100g;
  final double fatsPer100g;
  final double carbsPer100g;
  final double fibersPer100g;
  final double saltPer100g;

  // Informations de conversion
  final double? densityGPerMl;
  final double? avgWeightPerUnitG;

  // Métadonnées
  final String? barcode;
  final String? category;
  final String? nutriscore;
  final String? imageUrl;
  final String? brand;

  final IngredientVisibility visibility;
  final String? groupId;
  final bool isCustom;

  final DateTime createdAt;
  final DateTime updatedAt;

  IngredientFirestore({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.caloriesPer100g,
    this.proteinsPer100g = 0.0,
    this.fatsPer100g = 0.0,
    this.carbsPer100g = 0.0,
    this.fibersPer100g = 0.0,
    this.saltPer100g = 0.0,
    this.densityGPerMl,
    this.avgWeightPerUnitG,
    this.barcode,
    this.category,
    this.nutriscore,
    this.imageUrl,
    this.brand,
    required this.visibility,
    this.groupId,
    required this.isCustom,
    required this.createdAt,
    required this.updatedAt,
  });

  factory IngredientFirestore.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return IngredientFirestore(
      id: doc.id,
      ownerId: data['ownerId'] ?? '',
      name: data['name'] ?? 'Ingrédient inconnu',
      caloriesPer100g: (data['caloriesPer100g'] ?? 0).toDouble(),
      proteinsPer100g: (data['proteinsPer100g'] ?? 0).toDouble(),
      fatsPer100g: (data['fatsPer100g'] ?? 0).toDouble(),
      carbsPer100g: (data['carbsPer100g'] ?? 0).toDouble(),
      fibersPer100g: (data['fibersPer100g'] ?? 0).toDouble(),
      saltPer100g: (data['saltPer100g'] ?? 0).toDouble(),
      densityGPerMl: data['densityGPerMl']?.toDouble(),
      avgWeightPerUnitG: data['avgWeightPerUnitG']?.toDouble(),
      barcode: data['barcode'],
      category: data['category'],
      nutriscore: data['nutriscore'],
      imageUrl: data['imageUrl'],
      brand: data['brand'],
      visibility: _visibilityFromString(data['visibility']),
      groupId: data['groupId'],
      isCustom: data['isCustom'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'ownerId': ownerId,
      'name': name,
      'caloriesPer100g': caloriesPer100g,
      'proteinsPer100g': proteinsPer100g,
      'fatsPer100g': fatsPer100g,
      'carbsPer100g': carbsPer100g,
      'fibersPer100g': fibersPer100g,
      'saltPer100g': saltPer100g,
      'densityGPerMl': densityGPerMl,
      'avgWeightPerUnitG': avgWeightPerUnitG,
      'barcode': barcode,
      'category': category,
      'nutriscore': nutriscore,
      'imageUrl': imageUrl,
      'brand': brand,
      'visibility': _visibilityToString(visibility),
      'groupId': groupId,
      'isCustom': isCustom,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  static IngredientVisibility _visibilityFromString(String? visibility) {
    switch (visibility) {
      case 'public':
        return IngredientVisibility.public;
      case 'group':
        return IngredientVisibility.group;
      default:
        return IngredientVisibility.private;
    }
  }

  static String _visibilityToString(IngredientVisibility visibility) {
    switch (visibility) {
      case IngredientVisibility.public:
        return 'public';
      case IngredientVisibility.group:
        return 'group';
      case IngredientVisibility.private:
        return 'private';
    }
  }

  String get visibilityLabel {
    switch (visibility) {
      case IngredientVisibility.private:
        return 'Privé';
      case IngredientVisibility.public:
        return 'Public';
      case IngredientVisibility.group:
        return 'Groupe';
    }
  }

  bool canEdit(String userId) {
    return ownerId == userId;
  }

  IngredientFirestore copyWith({
    String? name,
    double? caloriesPer100g,
    double? proteinsPer100g,
    double? fatsPer100g,
    double? carbsPer100g,
    double? fibersPer100g,
    double? saltPer100g,
    double? densityGPerMl,
    double? avgWeightPerUnitG,
    String? category,
    String? nutriscore,
    String? imageUrl,
  }) {
    return IngredientFirestore(
      id: id,
      ownerId: ownerId,
      name: name ?? this.name,
      caloriesPer100g: caloriesPer100g ?? this.caloriesPer100g,
      proteinsPer100g: proteinsPer100g ?? this.proteinsPer100g,
      fatsPer100g: fatsPer100g ?? this.fatsPer100g,
      carbsPer100g: carbsPer100g ?? this.carbsPer100g,
      fibersPer100g: fibersPer100g ?? this.fibersPer100g,
      saltPer100g: saltPer100g ?? this.saltPer100g,
      densityGPerMl: densityGPerMl ?? this.densityGPerMl,
      avgWeightPerUnitG: avgWeightPerUnitG ?? this.avgWeightPerUnitG,
      barcode: barcode,
      category: category ?? this.category,
      nutriscore: nutriscore ?? this.nutriscore,
      imageUrl: imageUrl ?? this.imageUrl,
      brand: brand,
      visibility: visibility,
      groupId: groupId,
      isCustom: isCustom,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}