// lib/screens/ingredient_list_screen.dart
import 'package:flutter/material.dart';
import '../database.dart';
import '../repositories/ingredient_repository.dart';

class IngredientListScreen extends StatefulWidget {
  final IngredientRepository repository;

  const IngredientListScreen({
    super.key,
    required this.repository,
  });

  @override
  State<IngredientListScreen> createState() => _IngredientListScreenState();
}

class _IngredientListScreenState extends State<IngredientListScreen> {
  late Future<List<Ingredient>> _ingredientsFuture;
  String _searchQuery = '';
  String _filterCategory = 'all';

  @override
  void initState() {
    super.initState();
    _refreshIngredients();
  }

  void _refreshIngredients() {
    setState(() {
      _ingredientsFuture = widget.repository.getAllIngredients();
    });
  }

  List<Ingredient> _filterIngredients(List<Ingredient> ingredients) {
    var filtered = ingredients;

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

    return filtered;
  }

  Set<String> _getCategories(List<Ingredient> ingredients) {
    return ingredients
        .where((ing) => ing.category != null && ing.category!.isNotEmpty)
        .map((ing) => ing.category!)
        .toSet();
  }

  Future<void> _confirmDeleteIngredient(Ingredient ingredient) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Confirmation"),
        content: Text("Supprimer « ${ingredient.name} » ?\n\nCette action est irréversible."),
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
      await widget.repository.deleteIngredient(ingredient.id);
      _refreshIngredients();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${ingredient.name} supprimé")),
        );
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
      final calories = double.tryParse(caloriesCtrl.text.trim()) ?? 0.0;
      final proteins = double.tryParse(proteinsCtrl.text.trim()) ?? 0.0;
      final fats = double.tryParse(fatsCtrl.text.trim()) ?? 0.0;
      final carbs = double.tryParse(carbsCtrl.text.trim()) ?? 0.0;
      final fibers = double.tryParse(fibersCtrl.text.trim()) ?? 0.0;

      if (name.isNotEmpty) {
        await widget.repository.insertIngredient(
          name: name,
          caloriesPer100g: calories,
          proteinsPer100g: proteins,
          fatsPer100g: fats,
          carbsPer100g: carbs,
          fibersPer100g: fibers,
          category: category.isEmpty ? null : category,
          isCustom: true,
        );
        _refreshIngredients();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Ingrédient ajouté !")),
          );
        }
      }
    }
  }

  Future<void> _editIngredientDialog(Ingredient ingredient) async {
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
        await widget.repository.updateIngredient(
          id: ingredient.id,
          name: name,
          caloriesPer100g: double.tryParse(caloriesCtrl.text.trim()),
          proteinsPer100g: double.tryParse(proteinsCtrl.text.trim()),
          fatsPer100g: double.tryParse(fatsCtrl.text.trim()),
          carbsPer100g: double.tryParse(carbsCtrl.text.trim()),
          fibersPer100g: double.tryParse(fibersCtrl.text.trim()),
          category: category.isEmpty ? null : category,
        );
        _refreshIngredients();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Ingrédient modifié !")),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ingrédients"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshIngredients,
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

          // Liste des ingrédients
          Expanded(
            child: FutureBuilder<List<Ingredient>>(
              future: _ingredientsFuture,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snap.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text("Erreur: ${snap.error}"),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _refreshIngredients,
                          child: const Text("Réessayer"),
                        ),
                      ],
                    ),
                  );
                }

                final allIngredients = snap.data ?? [];
                final filteredIngredients = _filterIngredients(allIngredients);
                final categories = _getCategories(allIngredients);

                if (allIngredients.isEmpty) {
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

                if (filteredIngredients.isEmpty) {
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
                  itemCount: filteredIngredients.length,
                  itemBuilder: (c, i) {
                    final ing = filteredIngredients[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: Dismissible(
                        key: Key(ing.id.toString()),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (_) async {
                          await _confirmDeleteIngredient(ing);
                          return false;
                        },
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: ing.isCustom ? Colors.blue : Colors.green,
                            child: Text(
                              ing.name[0].toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(
                            ing.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (ing.category != null && ing.category!.isNotEmpty)
                                Text("📂 ${ing.category}"),
                              const SizedBox(height: 2),
                              Text(
                                "${ing.caloriesPer100g.toStringAsFixed(0)} kcal/100g",
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "P: ${ing.proteinsPer100g.toStringAsFixed(1)}g • "
                                    "G: ${ing.carbsPer100g.toStringAsFixed(1)}g • "
                                    "L: ${ing.fatsPer100g.toStringAsFixed(1)}g",
                                style: const TextStyle(fontSize: 11),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editIngredientDialog(ing),
                          ),
                          onTap: () => _editIngredientDialog(ing),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addIngredientDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}