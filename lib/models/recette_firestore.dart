// lib/models/recette_firestore.dart (VERSION AVEC groupName)
import 'package:cloud_firestore/cloud_firestore.dart';

enum RecetteVisibility {
  private,  // Visible uniquement par moi
  group,    // Recette de groupe (collaborative)
}

class RecetteFirestore {
  final String id;
  final String name;
  final String? instructions;
  final int servings;
  final String? category;
  final String? notes;
  final String? imageUrl;

  // Propriétés cloud
  final String ownerId;
  final RecetteVisibility visibility;
  final String? groupId; // Si visibility = group
  final String? groupName; // ✅ AJOUTÉ - Nom du groupe pour affichage

  final DateTime createdAt;
  final DateTime updatedAt;

  // Nutrition totale (calculée)
  final Map<String, double>? nutrition;

  RecetteFirestore({
    required this.id,
    required this.name,
    this.instructions,
    required this.servings,
    this.category,
    this.notes,
    this.imageUrl,
    required this.ownerId,
    required this.visibility,
    this.groupId,
    this.groupName, // ✅ AJOUTÉ
    required this.createdAt,
    required this.updatedAt,
    this.nutrition,
  });

  // Convertir depuis Firestore
  factory RecetteFirestore.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return RecetteFirestore(
      id: doc.id,
      name: data['name'] ?? '',
      instructions: data['instructions'],
      servings: data['servings'] ?? 1,
      category: data['category'],
      notes: data['notes'],
      imageUrl: data['imageUrl'],
      ownerId: data['ownerId'] ?? '',
      visibility: _parseVisibility(data['visibility']),
      groupId: data['groupId'],
      groupName: data['groupName'], // ✅ AJOUTÉ
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      nutrition: data['nutrition'] != null
          ? Map<String, double>.from(data['nutrition'])
          : null,
    );
  }

  // Convertir vers Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'instructions': instructions,
      'servings': servings,
      'category': category,
      'notes': notes,
      'imageUrl': imageUrl,
      'ownerId': ownerId,
      'visibility': visibility.name,
      'groupId': groupId,
      'groupName': groupName, // ✅ AJOUTÉ
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'nutrition': nutrition,
    };
  }

  // Helper pour parser la visibilité
  static RecetteVisibility _parseVisibility(String? value) {
    switch (value) {
      case 'group':
        return RecetteVisibility.group;
      default:
        return RecetteVisibility.private;
    }
  }

  // Copie avec modifications
  RecetteFirestore copyWith({
    String? name,
    String? instructions,
    int? servings,
    String? category,
    String? notes,
    String? imageUrl,
    RecetteVisibility? visibility,
    String? groupId,
    String? groupName, // ✅ AJOUTÉ
    Map<String, double>? nutrition,
  }) {
    return RecetteFirestore(
      id: id,
      name: name ?? this.name,
      instructions: instructions ?? this.instructions,
      servings: servings ?? this.servings,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      imageUrl: imageUrl ?? this.imageUrl,
      ownerId: ownerId,
      visibility: visibility ?? this.visibility,
      groupId: groupId ?? this.groupId,
      groupName: groupName ?? this.groupName, // ✅ AJOUTÉ
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      nutrition: nutrition ?? this.nutrition,
    );
  }

  // Vérifier si l'utilisateur peut modifier
  bool canEdit(String userId, {bool isGroupAdmin = false}) {
    // Le propriétaire peut toujours modifier
    if (ownerId == userId) return true;

    // Pour les recettes de groupe, tous les membres peuvent modifier
    if (visibility == RecetteVisibility.group) return true;

    // Pour les recettes privées, seul le propriétaire peut modifier
    return false;
  }

  // Obtenir le badge de visibilité
  String get visibilityLabel {
    switch (visibility) {
      case RecetteVisibility.private:
        return 'Privée';
      case RecetteVisibility.group:
      // ✅ AMÉLIORÉ - Affiche le nom du groupe si disponible
        return groupName != null ? 'Groupe: $groupName' : 'Groupe';
    }
  }
}

// Modèle pour un ingrédient dans une recette Firestore
class RecetteIngredientFirestore {
  final String ingredientId;
  final String ingredientName;
  final double quantity;
  final String unit;

  // Copie des valeurs nutritionnelles (pour 100g)
  final double caloriesPer100g;
  final double proteinsPer100g;
  final double fatsPer100g;
  final double carbsPer100g;
  final double fibersPer100g;

  // Infos de conversion
  final double? densityGPerMl;
  final double? avgWeightPerUnitG;

  RecetteIngredientFirestore({
    required this.ingredientId,
    required this.ingredientName,
    required this.quantity,
    required this.unit,
    required this.caloriesPer100g,
    required this.proteinsPer100g,
    required this.fatsPer100g,
    required this.carbsPer100g,
    required this.fibersPer100g,
    this.densityGPerMl,
    this.avgWeightPerUnitG,
  });

  factory RecetteIngredientFirestore.fromFirestore(Map<String, dynamic> data) {
    return RecetteIngredientFirestore(
      ingredientId: data['ingredientId'] ?? '',
      ingredientName: data['ingredientName'] ?? '',
      quantity: (data['quantity'] ?? 0.0).toDouble(),
      unit: data['unit'] ?? 'g',
      caloriesPer100g: (data['caloriesPer100g'] ?? 0.0).toDouble(),
      proteinsPer100g: (data['proteinsPer100g'] ?? 0.0).toDouble(),
      fatsPer100g: (data['fatsPer100g'] ?? 0.0).toDouble(),
      carbsPer100g: (data['carbsPer100g'] ?? 0.0).toDouble(),
      fibersPer100g: (data['fibersPer100g'] ?? 0.0).toDouble(),
      densityGPerMl: data['densityGPerMl']?.toDouble(),
      avgWeightPerUnitG: data['avgWeightPerUnitG']?.toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'ingredientId': ingredientId,
      'ingredientName': ingredientName,
      'quantity': quantity,
      'unit': unit,
      'caloriesPer100g': caloriesPer100g,
      'proteinsPer100g': proteinsPer100g,
      'fatsPer100g': fatsPer100g,
      'carbsPer100g': carbsPer100g,
      'fibersPer100g': fibersPer100g,
      'densityGPerMl': densityGPerMl,
      'avgWeightPerUnitG': avgWeightPerUnitG,
    };
  }
}