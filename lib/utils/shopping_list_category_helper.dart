// lib/utils/shopping_list_category_helper.dart
import 'package:flutter/material.dart';
import '../models/shopping_list_firestore.dart';

/// Helper pour organiser les articles par catégories
class ShoppingListCategoryHelper {
  /// Catégories prédéfinies avec icônes et couleurs
  static const Map<String, CategoryInfo> categories = {
    'Fruits': CategoryInfo(
      name: 'Fruits',
      icon: Icons.apple,
      color: Colors.red,
      emoji: '🍎',
    ),
    'Légumes': CategoryInfo(
      name: 'Légumes',
      icon: Icons.grass,
      color: Colors.green,
      emoji: '🥬',
    ),
    'Viandes': CategoryInfo(
      name: 'Viandes',
      icon: Icons.food_bank,
      color: Colors.brown,
      emoji: '🥩',
    ),
    'Poissons': CategoryInfo(
      name: 'Poissons',
      icon: Icons.set_meal,
      color: Colors.blue,
      emoji: '🐟',
    ),
    'Produits laitiers': CategoryInfo(
      name: 'Produits laitiers',
      icon: Icons.coffee,
      color: Colors.amber,
      emoji: '🥛',
    ),
    'Pains & Céréales': CategoryInfo(
      name: 'Pains & Céréales',
      icon: Icons.bakery_dining,
      color: Colors.orange,
      emoji: '🍞',
    ),
    'Épices': CategoryInfo(
      name: 'Épices',
      icon: Icons.spa,
      color: Colors.deepOrange,
      emoji: '🌶️',
    ),
    'Huiles': CategoryInfo(
      name: 'Huiles',
      icon: Icons.water_drop,
      color: Colors.yellow,
      emoji: '🫒',
    ),
    'Boissons': CategoryInfo(
      name: 'Boissons',
      icon: Icons.local_drink,
      color: Colors.lightBlue,
      emoji: '🥤',
    ),
    'Surgelés': CategoryInfo(
      name: 'Surgelés',
      icon: Icons.ac_unit,
      color: Colors.cyan,
      emoji: '❄️',
    ),
    'Conserves': CategoryInfo(
      name: 'Conserves',
      icon: Icons.inventory_2,
      color: Colors.grey,
      emoji: '🥫',
    ),
    'Autre': CategoryInfo(
      name: 'Autre',
      icon: Icons.more_horiz,
      color: Colors.blueGrey,
      emoji: '📦',
    ),
  };

  /// Organise les items par catégorie
  static Map<String, List<ShoppingListFirestore>> groupByCategory(
      List<ShoppingListFirestore> items) {
    final grouped = <String, List<ShoppingListFirestore>>{};

    // Initialiser toutes les catégories
    for (final categoryName in categories.keys) {
      grouped[categoryName] = [];
    }

    // Répartir les items
    for (final item in items) {
      final category = item.category ?? 'Autre';

      // Si la catégorie n'existe pas dans notre liste, mettre dans "Autre"
      if (!grouped.containsKey(category)) {
        grouped['Autre']!.add(item);
      } else {
        grouped[category]!.add(item);
      }
    }

    // Supprimer les catégories vides
    grouped.removeWhere((key, value) => value.isEmpty);

    return grouped;
  }

  /// Récupère les infos d'une catégorie
  static CategoryInfo getCategoryInfo(String categoryName) {
    return categories[categoryName] ?? categories['Autre']!;
  }

  /// Compte le nombre d'items par catégorie
  static Map<String, int> countByCategory(
      List<ShoppingListFirestore> items) {
    final counts = <String, int>{};

    for (final item in items) {
      final category = item.category ?? 'Autre';
      counts[category] = (counts[category] ?? 0) + 1;
    }

    return counts;
  }

  /// Calcule le pourcentage de complétion par catégorie
  static Map<String, double> completionByCategory(
      List<ShoppingListFirestore> items) {
    final grouped = groupByCategory(items);
    final completion = <String, double>{};

    for (final entry in grouped.entries) {
      final total = entry.value.length;
      final completed = entry.value.where((item) =>
      item.status == ShoppingStatus.completed ||
          item.status == ShoppingStatus.stored
      ).length;
      completion[entry.key] = total > 0 ? (completed / total * 100) : 0.0;
    }

    return completion;
  }

  /// Trie les catégories dans un ordre logique (pour un supermarché)
  static List<String> getSortedCategoryNames(Map<String, List<ShoppingListFirestore>> grouped) {
    // Ordre logique pour un parcours de supermarché
    const preferredOrder = [
      'Fruits',
      'Légumes',
      'Viandes',
      'Poissons',
      'Produits laitiers',
      'Pains & Céréales',
      'Surgelés',
      'Conserves',
      'Huiles',
      'Épices',
      'Boissons',
      'Autre',
    ];

    final sortedKeys = <String>[];

    // Ajouter dans l'ordre préféré si elles existent
    for (final category in preferredOrder) {
      if (grouped.containsKey(category)) {
        sortedKeys.add(category);
      }
    }

    // Ajouter les catégories restantes
    for (final key in grouped.keys) {
      if (!sortedKeys.contains(key)) {
        sortedKeys.add(key);
      }
    }

    return sortedKeys;
  }

  /// Génère un résumé textuel de la liste
  static String generateSummary(List<ShoppingListFirestore> items) {
    if (items.isEmpty) return 'Liste vide';

    final total = items.length;
    final completed = items.where((i) =>
    i.status == ShoppingStatus.completed ||
        i.status == ShoppingStatus.stored
    ).length;
    final remaining = total - completed;

    final grouped = groupByCategory(items);
    final categoryCount = grouped.length;

    return '$remaining article(s) restant(s) sur $total • $categoryCount catégorie(s)';
  }

  /// Détermine la catégorie d'un ingrédient depuis son nom (heuristique simple)
  static String inferCategory(String ingredientName) {
    final name = ingredientName.toLowerCase();

    // Fruits
    if (name.contains('pomme') || name.contains('poire') ||
        name.contains('banane') || name.contains('orange') ||
        name.contains('fraise') || name.contains('raisin') ||
        name.contains('cerise') || name.contains('abricot') ||
        name.contains('pêche') || name.contains('prune')) {
      return 'Fruits';
    }

    // Légumes
    if (name.contains('tomate') || name.contains('salade') ||
        name.contains('carotte') || name.contains('oignon') ||
        name.contains('ail') || name.contains('poivron') ||
        name.contains('courgette') || name.contains('aubergine') ||
        name.contains('haricot') || name.contains('chou') ||
        name.contains('épinard') || name.contains('brocoli')) {
      return 'Légumes';
    }

    // Viandes
    if (name.contains('poulet') || name.contains('boeuf') ||
        name.contains('porc') || name.contains('veau') ||
        name.contains('agneau') || name.contains('viande') ||
        name.contains('steak') || name.contains('escalope')) {
      return 'Viandes';
    }

    // Poissons
    if (name.contains('saumon') || name.contains('thon') ||
        name.contains('cabillaud') || name.contains('poisson') ||
        name.contains('crevette') || name.contains('moule')) {
      return 'Poissons';
    }

    // Produits laitiers
    if (name.contains('lait') || name.contains('yaourt') ||
        name.contains('fromage') || name.contains('beurre') ||
        name.contains('crème')) {
      return 'Produits laitiers';
    }

    // Pains & Céréales
    if (name.contains('pain') || name.contains('farine') ||
        name.contains('riz') || name.contains('pâtes') ||
        name.contains('céréales') || name.contains('semoule')) {
      return 'Pains & Céréales';
    }

    // Épices
    if (name.contains('sel') || name.contains('poivre') ||
        name.contains('épice') || name.contains('herbe') ||
        name.contains('basilic') || name.contains('thym') ||
        name.contains('persil') || name.contains('cumin')) {
      return 'Épices';
    }

    // Huiles
    if (name.contains('huile') || name.contains('vinaigre')) {
      return 'Huiles';
    }

    // Boissons
    if (name.contains('eau') || name.contains('jus') ||
        name.contains('soda') || name.contains('café') ||
        name.contains('thé')) {
      return 'Boissons';
    }

    // Surgelés
    if (name.contains('surgelé') || name.contains('congelé')) {
      return 'Surgelés';
    }

    // Conserves
    if (name.contains('conserve') || name.contains('boîte')) {
      return 'Conserves';
    }

    return 'Autre';
  }
}

/// Informations sur une catégorie
class CategoryInfo {
  final String name;
  final IconData icon;
  final Color color;
  final String emoji;

  const CategoryInfo({
    required this.name,
    required this.icon,
    required this.color,
    required this.emoji,
  });
}