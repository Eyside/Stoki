// lib/screens/ingredient_cloud_screen.dart
// Écran de gestion des ingrédients dans le cloud

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ingredient_firestore.dart';
import '../services/ingredient_firestore_service.dart';
import '../services/auth_service.dart';
import '../providers.dart';
import 'scan/scan_screen.dart';

class IngredientCloudScreen extends ConsumerStatefulWidget {
  const IngredientCloudScreen({super.key});

  @override
  ConsumerState<IngredientCloudScreen> createState() => _IngredientCloudScreenState();
}

class _IngredientCloudScreenState extends ConsumerState<IngredientCloudScreen> {
  String _searchQuery = '';
  String _filterCategory = 'all';
  bool _showOnlyCustom = false;
  List<IngredientFirestore> _allIngredients = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadIngredients();
  }

  Future<void> _loadIngredients() async {
    setState(() => _isLoading = true);
    try {
      final service = ref.read(ingredientFirestoreServiceProvider);
      final ingredients = await service.getAllAccessibleIngredients();
      setState(() {
        _allIngredients = ingredients;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<IngredientFirestore> _filterIngredients() {
    var filtered = _allIngredients;

    // Filtrage par recherche
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((ing) => ing.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Filtrage par catégorie
    if (_filterCategory != 'all') {
      filtered = filtered
          .where((ing) => ing.category == _filterCategory)
          .toList();
    }

    // Filtrage custom uniquement
    if (_showOnlyCustom) {
      filtered = filtered.where((ing) => ing.isCustom).toList();
    }

    return filtered;
  }

  Set<String> _getCategories() {
    return _allIngredients
        .where((ing) => ing.category != null && ing.category!.isNotEmpty)
        .map((ing) => ing.category!)
        .toSet();
  }

  Future<void> _confirmDeleteIngredient(IngredientFirestore ingredient) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Confirmation"),
        content: Text(
          "Supprimer « ${ingredient.name} » ?\n\n"
              "Cette action est irréversible.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(c, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Supprimer"),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        final service = ref.read(ingredientFirestoreServiceProvider);
        await service.deleteIngredient(ingredient.id);
        await _loadIngredients();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("${ingredient.name} supprimé")),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _addIngredientDialog() async {
    final nameCtrl = TextEditingController();
    final categoryCtrl = TextEditingController();
    final caloriesCtrl = TextEditingController();
    final proteinsCtrl = TextEditingController();
    final fatsCtrl = TextEditingController();
    final carbsCtrl = TextEditingController();
    final fibersCtrl = TextEditingController();
    final barcodeCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Nouvel ingrédient"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: "Nom *",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: categoryCtrl,
                decoration: const InputDecoration(
                  labelText: "Catégorie",
                  border: OutlineInputBorder(),
                  hintText: "Ex: Légumes, Viandes, Céréales...",
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: barcodeCtrl,
                decoration: const InputDecoration(
                  labelText: "Code-barres (optionnel)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Valeurs nutritionnelles (pour 100g)",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: caloriesCtrl,
                decoration: const InputDecoration(
                  labelText: "Calories (kcal) *",
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: proteinsCtrl,
                decoration: const InputDecoration(
                  labelText: "Protéines (g)",
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: fatsCtrl,
                decoration: const InputDecoration(
                  labelText: "Lipides (g)",
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: carbsCtrl,
                decoration: const InputDecoration(
                  labelText: "Glucides (g)",
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: fibersCtrl,
                decoration: const InputDecoration(
                  labelText: "Fibres (g)",
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text("Ajouter"),
          ),
        ],
      ),
    );

    if (ok == true) {
      final name = nameCtrl.text.trim();
      final category = categoryCtrl.text.trim();
      final barcode = barcodeCtrl.text.trim();
      final calories = double.tryParse(caloriesCtrl.text.trim()) ?? 0.0;
      final proteins = double.tryParse(proteinsCtrl.text.trim()) ?? 0.0;
      final fats = double.tryParse(fatsCtrl.text.trim()) ?? 0.0;
      final carbs = double.tryParse(carbsCtrl.text.trim()) ?? 0.0;
      final fibers = double.tryParse(fibersCtrl.text.trim()) ?? 0.0;

      if (name.isNotEmpty) {
        try {
          final service = ref.read(ingredientFirestoreServiceProvider);
          await service.addIngredient(
            name: name,
            caloriesPer100g: calories,
            proteinsPer100g: proteins,
            fatsPer100g: fats,
            carbsPer100g: carbs,
            fibersPer100g: fibers,
            category: category.isEmpty ? null : category,
            barcode: barcode.isEmpty ? null : barcode,
            visibility: IngredientVisibility.private,
          );
          await _loadIngredients();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Ingrédient ajouté !")),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erreur: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    }
  }

  Future<void> _editIngredientDialog(IngredientFirestore ingredient) async {
    final nameCtrl = TextEditingController(text: ingredient.name);
    final categoryCtrl = TextEditingController(text: ingredient.category ?? '');
    final caloriesCtrl = TextEditingController(text: ingredient.caloriesPer100g.toString());
    final proteinsCtrl = TextEditingController(text: ingredient.proteinsPer100g.toString());
    final fatsCtrl = TextEditingController(text: ingredient.fatsPer100g.toString());
    final carbsCtrl = TextEditingController(text: ingredient.carbsPer100g.toString());
    final fibersCtrl = TextEditingController(text: ingredient.fibersPer100g.toString());

    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Modifier l'ingrédient"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: "Nom",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: categoryCtrl,
                decoration: const InputDecoration(
                  labelText: "Catégorie",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Valeurs nutritionnelles (pour 100g)",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: caloriesCtrl,
                decoration: const InputDecoration(
                  labelText: "Calories (kcal)",
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: proteinsCtrl,
                decoration: const InputDecoration(
                  labelText: "Protéines (g)",
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: fatsCtrl,
                decoration: const InputDecoration(
                  labelText: "Lipides (g)",
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: carbsCtrl,
                decoration: const InputDecoration(
                  labelText: "Glucides (g)",
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: fibersCtrl,
                decoration: const InputDecoration(
                  labelText: "Fibres (g)",
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text("Modifier"),
          ),
        ],
      ),
    );

    if (ok == true) {
      final name = nameCtrl.text.trim();
      final category = categoryCtrl.text.trim();

      if (name.isNotEmpty) {
        try {
          final service = ref.read(ingredientFirestoreServiceProvider);
          await service.updateIngredient(
            id: ingredient.id,
            name: name,
            caloriesPer100g: double.tryParse(caloriesCtrl.text.trim()),
            proteinsPer100g: double.tryParse(proteinsCtrl.text.trim()),
            fatsPer100g: double.tryParse(fatsCtrl.text.trim()),
            carbsPer100g: double.tryParse(carbsCtrl.text.trim()),
            fibersPer100g: double.tryParse(fibersCtrl.text.trim()),
            category: category.isEmpty ? null : category,
          );
          await _loadIngredients();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Ingrédient modifié !")),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erreur: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    }
  }

  void _showFilterMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.filter_list),
                  const SizedBox(width: 12),
                  const Text(
                    'Filtres',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            SwitchListTile(
              title: const Text('Mes ingrédients uniquement'),
              subtitle: const Text('Masquer les ingrédients publics'),
              value: _showOnlyCustom,
              onChanged: (value) {
                setState(() => _showOnlyCustom = value);
                Navigator.pop(context);
              },
            ),
            const Divider(height: 1),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Catégories',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            ..._getCategories().map((cat) {
              return ListTile(
                title: Text(cat),
                trailing: _filterCategory == cat
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () {
                  setState(() => _filterCategory = cat);
                  Navigator.pop(context);
                },
              );
            }),
            ListTile(
              title: const Text('Toutes les catégories'),
              trailing: _filterCategory == 'all'
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                setState(() => _filterCategory = 'all');
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredIngredients = _filterIngredients();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes ingrédients"),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterMenu,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadIngredients,
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Rechercher un ingrédient...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => setState(() => _searchQuery = ''),
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),

          // Filtres actifs
          if (_filterCategory != 'all' || _showOnlyCustom)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Wrap(
                spacing: 8,
                children: [
                  if (_filterCategory != 'all')
                    Chip(
                      label: Text(_filterCategory),
                      onDeleted: () => setState(() => _filterCategory = 'all'),
                    ),
                  if (_showOnlyCustom)
                    Chip(
                      label: const Text('Mes ingrédients'),
                      onDeleted: () => setState(() => _showOnlyCustom = false),
                    ),
                ],
              ),
            ),

          // Liste des ingrédients
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildIngredientsList(filteredIngredients),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'scan',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ScanScreen()),
              );
              _loadIngredients();
            },
            child: const Icon(Icons.qr_code_scanner),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'add',
            onPressed: _addIngredientDialog,
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsList(List<IngredientFirestore> ingredients) {
    if (_allIngredients.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.eco, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              "Aucun ingrédient",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              "Ajoutez vos premiers ingrédients\nou scannez des produits",
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _addIngredientDialog,
              icon: const Icon(Icons.add),
              label: const Text("Ajouter un ingrédient"),
            ),
          ],
        ),
      );
    }

    if (ingredients.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              "Aucun résultat",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _filterCategory = 'all';
                  _showOnlyCustom = false;
                });
              },
              child: const Text("Réinitialiser les filtres"),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: ingredients.length,
      itemBuilder: (c, i) {
        final ing = ingredients[i];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: ing.isCustom ? Colors.blue : Colors.green,
              child: Text(
                ing.name[0].toUpperCase(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    ing.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                if (ing.barcode != null)
                  const Icon(Icons.qr_code, size: 16, color: Colors.grey),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (ing.category != null && ing.category!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.folder, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(ing.category!, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  "${ing.caloriesPer100g.toStringAsFixed(0)} kcal/100g",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  "P: ${ing.proteinsPer100g.toStringAsFixed(1)}g • "
                      "G: ${ing.carbsPer100g.toStringAsFixed(1)}g • "
                      "L: ${ing.fatsPer100g.toStringAsFixed(1)}g",
                  style: const TextStyle(fontSize: 11),
                ),
                if (ing.nutriscore != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Text('Nutri-Score: ', style: TextStyle(fontSize: 11)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getNutriscoreColor(ing.nutriscore!),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          ing.nutriscore!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            trailing: ing.canEdit(ref.read(authServiceProvider).currentUser?.uid ?? '')
                ? PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('Modifier'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Supprimer', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'edit') _editIngredientDialog(ing);
                if (value == 'delete') _confirmDeleteIngredient(ing);
              },
            )
                : const Icon(Icons.lock, color: Colors.grey),
            onTap: () => _editIngredientDialog(ing),
          ),
        );
      },
    );
  }

  Color _getNutriscoreColor(String score) {
    switch (score.toLowerCase()) {
      case 'a':
        return Colors.green;
      case 'b':
        return Colors.lightGreen;
      case 'c':
        return Colors.yellow;
      case 'd':
        return Colors.orange;
      case 'e':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}