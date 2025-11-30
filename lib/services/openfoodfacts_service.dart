// lib/services/openfoodfacts_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Produit minimal renvoyé par OpenFoodFacts
class OpenFoodFactsProduct {
  final String name;
  final double kcal100g;
  final String barcode;

  OpenFoodFactsProduct({
    required this.name,
    required this.kcal100g,
    required this.barcode,
  });
}

/// Service simple pour récupérer un produit par code-barres.
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

      // On tente d'obtenir les kcal; si absent on met 0
      final dynamic energyKcal = nutr['energy-kcal_100g'] ?? nutr['energy_100g'];
      double kcal = 0.0;
      if (energyKcal != null) {
        try {
          kcal = (energyKcal as num).toDouble();
        } catch (_) {
          kcal = double.tryParse(energyKcal.toString()) ?? 0.0;
        }
      }

      final name = (p['product_name'] ?? p['brands'] ?? 'Produit inconnu').toString();

      return OpenFoodFactsProduct(name: name, kcal100g: kcal, barcode: barcode);
    } catch (e) {
      // ignore network/parsing errors for now
      return null;
    }
  }
}
