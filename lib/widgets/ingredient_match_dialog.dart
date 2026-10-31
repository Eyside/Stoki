// lib/widgets/ingredient_match_dialog.dart
// Anti-doublons : avant de créer un ingrédient, proposer ceux qui existent
// déjà ("Saumon" pour un "Saumon fumé Atlantique" scanné).

import 'package:flutter/material.dart';
import '../models/ingredient_firestore.dart';
import '../services/ingredient_firestore_service.dart';
import '../services/openfoodfacts_service.dart';

class IngredientMatchDialog {
  /// Retourne l'ingrédient choisi, ou null si l'utilisateur veut en créer un
  /// nouveau. Annuler revient à "créer un nouveau" (jamais de blocage).
  static Future<IngredientFirestore?> choose(
    BuildContext context, {
    required String newName,
    required List<IngredientFirestore> candidates,
    String? hint,
  }) {
    return showDialog<IngredientFirestore?>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Ingrédient déjà connu ?'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              Text(
                hint ?? '« $newName » ressemble à des ingrédients existants. '
                    'Choisissez-en un pour éviter les doublons.',
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 8),
              for (final ing in candidates.take(6))
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.link_rounded),
                  title: Text(ing.name),
                  subtitle: Text(
                    '${ing.caloriesPer100g.toStringAsFixed(0)} kcal/100g',
                  ),
                  onTap: () => Navigator.pop(c, ing),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, null),
            child: Text('Créer « $newName »'),
          ),
        ],
      ),
    );
  }

  /// Ingrédient correspondant à un produit scanné :
  ///  1. déjà relié à ce code-barres -> on le reprend ;
  ///  2. ingrédients proches -> l'utilisateur choisit (le code-barres est
  ///     alors relié, le prochain scan sera automatique) ;
  ///  3. sinon création d'un nouvel ingrédient relié au code-barres.
  static Future<IngredientFirestore> resolveScanned(
    BuildContext context,
    IngredientFirestoreService service,
    OpenFoodFactsProduct product,
  ) async {
    final known = await service.findByBarcode(product.barcode);
    if (known != null) return known;

    final candidates = await service.findSimilar(product.name);
    IngredientFirestore? chosen;
    if (candidates.isNotEmpty && context.mounted) {
      chosen = await choose(
        context,
        newName: product.name,
        candidates: candidates,
        hint: 'Le produit scanné « ${product.name} » ressemble à des '
            'ingrédients existants. Le relier à l\'un d\'eux évite les '
            'doublons : les recettes, le stock et les courses se '
            'retrouveront.',
      );
    }

    if (chosen != null) {
      // Compléter les valeurs nutritionnelles si l'ingrédient n'en avait pas.
      if (chosen.caloriesPer100g == 0 && product.kcal100g > 0) {
        await service.updateIngredient(
          id: chosen.id,
          caloriesPer100g: product.kcal100g,
          proteinsPer100g: product.proteins100g,
          fatsPer100g: product.fats100g,
          carbsPer100g: product.carbs100g,
          fibersPer100g: product.fibers100g,
          saltPer100g: product.salt100g,
        );
      }
      await service.linkBarcode(product.barcode, chosen.id);
      return chosen;
    }

    final id = await service.addIngredient(
      name: product.name,
      caloriesPer100g: product.kcal100g,
      proteinsPer100g: product.proteins100g,
      fatsPer100g: product.fats100g,
      carbsPer100g: product.carbs100g,
      fibersPer100g: product.fibers100g,
      saltPer100g: product.salt100g,
      barcode: product.barcode,
      category: product.category,
      nutriscore: product.nutriscore,
      imageUrl: product.imageUrl,
      brand: product.brand,
      visibility: IngredientVisibility.private,
    );
    await service.linkBarcode(product.barcode, id);
    final created = await service.getById(id);
    if (created == null) throw Exception('Création de l\'ingrédient impossible');
    return created;
  }

  /// Création manuelle : si un ingrédient de même nom (ou proche) existe,
  /// le proposer. Retourne l'ingrédient existant choisi, ou null pour créer.
  static Future<IngredientFirestore?> checkManualName(
    BuildContext context,
    IngredientFirestoreService service,
    String name,
  ) async {
    final candidates = await service.findSimilar(name);
    if (candidates.isEmpty || !context.mounted) return null;
    return choose(context, newName: name, candidates: candidates);
  }
}
