class UnitConverter {
  static const Map<String, double> weightToGram = {
    'mg': 0.001,
    'g': 1.0,
    'kg': 1000.0,
    'oz': 28.3495,
    'lb': 453.592,
  };

  static const Map<String, double> volumeToMl = {
    'ml': 1.0,
    'l': 1000.0,
    'tsp': 4.92892,
    'tbsp': 14.7868,
    'cup': 240.0,
  };

  /// Noms d'unité qui désignent une pièce (l'application propose « unité »).
  static const Set<String> pieceUnits = {
    'unité', 'unite', 'unités', 'unites',
    'pièce', 'piece', 'pièces', 'pieces',
    'pcs', 'pc', 'unit', 'u',
  };

  /// Poids utilisé quand l'ingrédient n'a pas de poids par pièce renseigné.
  static const double defaultPieceWeightGrams = 100.0;

  static double toGrams({
    required double quantity,
    required String unit,
    double? weightPerPieceGrams,
    double densityGramsPerMl = 1.0,
  }) {
    final u = unit.trim().toLowerCase();
    if (weightToGram.containsKey(u)) {
      return quantity * weightToGram[u]!;
    } else if (volumeToMl.containsKey(u)) {
      final ml = quantity * volumeToMl[u]!;
      return ml * densityGramsPerMl;
    } else if (pieceUnits.contains(u)) {
      // Si le poids d'une pièce n'est pas renseigné, on prend 100 g par défaut
      // au lieu de faire planter l'application.
      final perPiece = (weightPerPieceGrams != null && weightPerPieceGrams > 0)
          ? weightPerPieceGrams
          : defaultPieceWeightGrams;
      return quantity * perPiece;
    } else {
      // Unité inconnue : on évite le crash, on considère des grammes.
      return quantity;
    }
  }

  static double caloriesForIngredient({
    required double caloriesPer100g,
    required double quantity,
    required String unit,
    double? weightPerPieceGrams,
    double densityGramsPerMl = 1.0,
  }) {
    final grams = toGrams(
      quantity: quantity,
      unit: unit,
      weightPerPieceGrams: weightPerPieceGrams,
      densityGramsPerMl: densityGramsPerMl,
    );
    final kcalPerGram = caloriesPer100g / 100.0;
    return grams * kcalPerGram;
  }
}
