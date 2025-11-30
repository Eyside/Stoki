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

  static double toGrams({
    required double quantity,
    required String unit,
    double? weightPerPieceGrams,
    double densityGramsPerMl = 1.0,
  }) {
    final u = unit.toLowerCase();
    if (weightToGram.containsKey(u)) {
      return quantity * weightToGram[u]!;
    } else if (volumeToMl.containsKey(u)) {
      final ml = quantity * volumeToMl[u]!;
      return ml * densityGramsPerMl;
    } else if (u == 'piece' || u == 'pcs' || u == 'unit') {
      if (weightPerPieceGrams != null) {
        return quantity * weightPerPieceGrams;
      } else {
        throw ArgumentError('weightPerPieceGrams required for unit "piece".');
      }
    } else {
      throw ArgumentError('Unknown unit: $unit');
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
