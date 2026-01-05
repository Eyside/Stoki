class IngredientModel {
  final String name;
  final double caloriesPer100g;
  final double? densityGPerMl; // facultatif, ex: huile ~0.92
  final double? avgWeightPerUnitG; // facultatif, ex: oeuf ~50g
  final String? barcode; // code barre si connu

  IngredientModel({
    required this.name,
    required this.caloriesPer100g,
    this.densityGPerMl,
    this.avgWeightPerUnitG,
    this.barcode,
  });

  factory IngredientModel.fromOpenFoodFacts(Map<String, dynamic> json, String barcode) {
    // mapping basique: on tente de récupérer nom et nutriments
    final product = json['product'] ?? {};
    final productName = product['product_name'] ?? product['brands'] ?? 'Ingrédient';
    final nutriments = product['nutriments'] ?? {};
    final energyKcal100g = (nutriments['energy-kcal_100g'] ?? nutriments['energy_100g'])?.toDouble() ?? 0.0;
    return IngredientModel(
      name: productName,
      caloriesPer100g: energyKcal100g,
      densityGPerMl: null,
      avgWeightPerUnitG: null,
      barcode: barcode,
    );
  }
}
