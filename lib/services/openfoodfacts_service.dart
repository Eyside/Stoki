// lib/services/openfoodfacts_service.dart
// VERSION ÉTENDUE avec toutes les valeurs nutritionnelles

import 'dart:convert';
import 'package:http/http.dart' as http;

/// Produit complet renvoyé par OpenFoodFacts
class OpenFoodFactsProduct {
  final String name;
  final String barcode;

  // Valeurs nutritionnelles
  final double kcal100g;
  final double proteins100g;
  final double fats100g;
  final double carbs100g;
  final double fibers100g;
  final double salt100g;

  // Métadonnées
  final String? nutriscore;
  final String? imageUrl;
  final String? brand;
  final String? category;

  OpenFoodFactsProduct({
    required this.name,
    required this.barcode,
    required this.kcal100g,
    this.proteins100g = 0.0,
    this.fats100g = 0.0,
    this.carbs100g = 0.0,
    this.fibers100g = 0.0,
    this.salt100g = 0.0,
    this.nutriscore,
    this.imageUrl,
    this.brand,
    this.category,
  });

  /// Vérifie si le produit a des valeurs nutritionnelles complètes
  bool get hasCompleteNutrition {
    return kcal100g > 0 || proteins100g > 0 || fats100g > 0 || carbs100g > 0;
  }

  /// Retourne un résumé textuel
  String get nutritionSummary {
    final parts = <String>[];
    if (kcal100g > 0) parts.add('${kcal100g.toStringAsFixed(0)} kcal');
    if (proteins100g > 0) parts.add('${proteins100g.toStringAsFixed(1)}g prot.');
    if (carbs100g > 0) parts.add('${carbs100g.toStringAsFixed(1)}g gluc.');
    if (fats100g > 0) parts.add('${fats100g.toStringAsFixed(1)}g lip.');
    return parts.isEmpty ? 'Valeurs non disponibles' : parts.join(' • ');
  }
}

/// Service pour récupérer un produit par code-barres depuis OpenFoodFacts
class OpenFoodFactsService {
  static Future<OpenFoodFactsProduct?> fetchProduct(String barcode) async {
    final url = Uri.parse('https://world.openfoodfacts.org/api/v0/product/$barcode.json');
    try {
      final resp = await http.get(url).timeout(const Duration(seconds: 8));
      if (resp.statusCode != 200) return null;

      final data = json.decode(resp.body) as Map<String, dynamic>;
      if (data['status'] != 1) return null;

      final p = data['product'] as Map<String, dynamic>? ?? {};
      final nutr = p['nutriments'] as Map<String, dynamic>? ?? {};

      // Extraction des valeurs nutritionnelles
      final kcal = _parseNutriment(nutr, ['energy-kcal_100g', 'energy_100g']);
      final proteins = _parseNutriment(nutr, ['proteins_100g', 'proteins']);
      final fats = _parseNutriment(nutr, ['fat_100g', 'fat']);
      final carbs = _parseNutriment(nutr, ['carbohydrates_100g', 'carbohydrates']);
      final fibers = _parseNutriment(nutr, ['fiber_100g', 'fiber']);
      final salt = _parseNutriment(nutr, ['salt_100g', 'salt']);

      // Métadonnées
      final name = (p['product_name'] ?? p['brands'] ?? 'Produit inconnu').toString().trim();
      final brand = p['brands']?.toString().trim();
      final nutriscore = p['nutriscore_grade']?.toString().toUpperCase();
      final imageUrl = p['image_url']?.toString();
      final category = p['categories']?.toString().split(',').first.trim();

      return OpenFoodFactsProduct(
        name: name,
        barcode: barcode,
        kcal100g: kcal,
        proteins100g: proteins,
        fats100g: fats,
        carbs100g: carbs,
        fibers100g: fibers,
        salt100g: salt,
        nutriscore: nutriscore,
        imageUrl: imageUrl,
        brand: brand,
        category: category,
      );
    } catch (e) {
      print('❌ Erreur OpenFoodFacts: $e');
      return null;
    }
  }

  /// Essaie de parser un nutriment depuis plusieurs clés possibles
  static double _parseNutriment(Map<String, dynamic> nutr, List<String> keys) {
    for (final key in keys) {
      final value = nutr[key];
      if (value != null) {
        try {
          return (value as num).toDouble();
        } catch (_) {
          final parsed = double.tryParse(value.toString());
          if (parsed != null) return parsed;
        }
      }
    }
    return 0.0;
  }
}