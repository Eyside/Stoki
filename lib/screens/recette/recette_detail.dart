// lib/screens/recette/recette_detail.dart
import 'package:flutter/material.dart';
import '../../repositories/recette_repository.dart';
import '../../repositories/ingredient_repository.dart';
import '../../database.dart';
import '../../utils/snackbar_helper.dart';
import '../../utils/unit_converter.dart';

class RecetteDetailScreen extends StatefulWidget {
  final RecetteRepository recetteRepository;
  final Recette recette;

  const RecetteDetailScreen({
    super.key,
    required this.recetteRepository,
    required this.recette,
  });

  @override
  State<RecetteDetailScreen> createState() => _RecetteDetailScreenState();
}

class _RecetteDetailScreenState extends State<RecetteDetailScreen> {
  late Future<List<Map<String, dynamic>>> _ingredientsFuture;
  late Future<Map<String, double>> _nutritionFuture;
  late Recette _currentRecette;

  @override
  void initState() {
    super.initState();
    _currentRecette = widget.recette;
    _refresh();
  }

  void _refresh() {
    setState(() {
      _ingredientsFuture = widget.recetteRepository.getIngredientsForRecette(_currentRecette.id);
      _nutritionFuture = widget.recetteRepository.calculateNutritionForRecette(_currentRecette.id);
    });
  }

  // Rafraîchir les données de la recette depuis la BDD
  Future<void> _refreshRecetteData() async {
    final updated = await widget.recetteRepository.getRecetteById(_currentRecette.id);
    if (updated != null) {
      setState(() {
        _currentRecette = updated;
      });
    }
  }

  // Modifier le nom de la recette
  Future<void> _editRecetteName() async {
    final nameCtrl = TextEditingController(text: _currentRecette.name);

    final newName = await showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Modifier le nom"),
        content: TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(
            labelText: "Nom de la recette",
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(c, nameCtrl.text.trim()),
            child: const Text("Modifier"),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty && newName != _currentRecette.name) {
      await widget.recetteRepository.updateRecette(
        id: _currentRecette.id,
        name: newName,
      );

      await _refreshRecetteData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Nom modifié !")),
        );
      }
    }
  }

  // Modifier la catégorie de la recette
  Future<void> _editRecetteCategory() async {
    final categories = [
      'Petit déjeuner',
      'Déjeuner',
      'Dîner',
      'Collation',
      'Dessert',
      'Entrée',
      'Plat principal',
      'Accompagnement',
      'Boisson',
      'Autre',
    ];

    final selected = await showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Choisir une catégorie"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = _currentRecette.category == category;

              return ListTile(
                title: Text(category),
                leading: Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: isSelected ? Colors.green : Colors.grey,
                ),
                selected: isSelected,
                onTap: () => Navigator.pop(c, category),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text("Annuler"),
          ),
        ],
      ),
    );

    if (selected != null && selected != _currentRecette.category) {
      await widget.recetteRepository.updateRecette(
        id: _currentRecette.id,
        category: selected,
      );

      await _refreshRecetteData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Catégorie modifiée !")),
        );
      }
    }
  }

  // Afficher les détails d'un ingrédient
  void _showIngredientDetails(Ingredient ingredient, RecetteIngredient ri) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.green.shade100,
              child: Text(
                ingredient.name[0].toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                ingredient.name,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quantité dans la recette
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Dans cette recette:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "${ri.quantity} ${ri.unit}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),

              // Valeurs nutritionnelles pour 100g
              const Text(
                "Valeurs nutritionnelles (pour 100g)",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),

              _DetailRow(
                icon: Icons.local_fire_department,
                label: "Calories",
                value: "${ingredient.caloriesPer100g.toStringAsFixed(0)} kcal",
                color: Colors.orange,
              ),
              _DetailRow(
                icon: Icons.fitness_center,
                label: "Protéines",
                value: "${ingredient.proteinsPer100g.toStringAsFixed(1)} g",
                color: Colors.red,
              ),
              _DetailRow(
                icon: Icons.grain,
                label: "Glucides",
                value: "${ingredient.carbsPer100g.toStringAsFixed(1)} g",
                color: Colors.blue,
              ),
              _DetailRow(
                icon: Icons.water_drop,
                label: "Lipides",
                value: "${ingredient.fatsPer100g.toStringAsFixed(1)} g",
                color: Colors.purple,
              ),

              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),

              // Informations supplémentaires
              const Text(
                "Informations",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),

              if (ingredient.category != null) ...[
                _InfoRow(
                  label: "Catégorie",
                  value: ingredient.category!,
                  icon: Icons.category,
                ),
              ],

              if (ingredient.densityGPerMl != null) ...[
                _InfoRow(
                  label: "Densité",
                  value: "${ingredient.densityGPerMl!.toStringAsFixed(2)} g/ml",
                  icon: Icons.science,
                ),
              ],

              if (ingredient.avgWeightPerUnitG != null) ...[
                _InfoRow(
                  label: "Poids moyen",
                  value: "${ingredient.avgWeightPerUnitG!.toStringAsFixed(0)} g/unité",
                  icon: Icons.scale,
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text("Fermer"),
          ),
        ],
      ),
    );
  }

  Future<void> _editIngredientQuantity(RecetteIngredient ri, Ingredient ingredient) async {
    final quantCtrl = TextEditingController(text: ri.quantity.toString());
    String unite = ri.unit;

    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c2, setDialogState) => AlertDialog(
          title: Text("Modifier ${ingredient.name}"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: quantCtrl,
                decoration: const InputDecoration(
                  labelText: "Nouvelle quantité",
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: unite,
                decoration: const InputDecoration(
                  labelText: "Unité",
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'g', child: Text('g (grammes)')),
                  DropdownMenuItem(value: 'ml', child: Text('ml (millilitres)')),
                  DropdownMenuItem(value: 'unité', child: Text('unité (pièce)')),
                ],
                onChanged: (v) => setDialogState(() => unite = v ?? 'g'),
              ),
            ],
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
      ),
    );

    if (ok == true) {
      final newQuantity = double.tryParse(quantCtrl.text.trim()) ?? 0.0;
      if (newQuantity > 0) {
        await widget.recetteRepository.removeIngredientFromRecette(
          recetteId: ri.recetteId,
          ingredientId: ri.ingredientId,
        );

        await widget.recetteRepository.addIngredientToRecette(
          recetteId: ri.recetteId,
          ingredientId: ri.ingredientId,
          quantity: newQuantity,
          unit: unite,
          densityGPerMl: ri.densityGPerMl,
          weightPerUnitG: ri.weightPerUnitG,
        );

        _refresh();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Quantité modifiée !")),
          );
        }
      }
    }
  }

  Future<void> _removeIngredient(RecetteIngredient ri, Ingredient? ingredient) async {
    if (ingredient == null) return;

    final recetteId = ri.recetteId;
    final ingredientId = ri.ingredientId;
    final quantity = ri.quantity;
    final unit = ri.unit;
    final densityGPerMl = ri.densityGPerMl;
    final weightPerUnitG = ri.weightPerUnitG;

    await widget.recetteRepository.removeIngredientFromRecette(
      recetteId: recetteId,
      ingredientId: ingredientId,
    );

    if (!mounted) return;

    SnackBarHelper.showUndoSnackBar(
      context: context,
      message: "Ingrédient supprimé",
      onUndo: () async {
        await widget.recetteRepository.addIngredientToRecette(
          recetteId: recetteId,
          ingredientId: ingredientId,
          quantity: quantity,
          unit: unit,
          densityGPerMl: densityGPerMl,
          weightPerUnitG: weightPerUnitG,
        );
        _refresh();
      },
    );

    _refresh();
  }

  Future<void> _addIngredientDialog() async {
    final ingredientRepo = IngredientRepository(widget.recetteRepository.attachedDatabase);
    final ingredients = await ingredientRepo.getAllIngredients();

    if (!mounted) return;

    Ingredient? selected;
    final quantCtrl = TextEditingController();
    String unite = 'g';

    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c2, setDialogState) => AlertDialog(
          title: const Text("Ajouter ingrédient"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<Ingredient>(
                value: selected,
                hint: const Text("Choisir un ingrédient"),
                isExpanded: true,
                items: ingredients
                    .map((i) => DropdownMenuItem(
                  value: i,
                  child: Text(i.name),
                ))
                    .toList(),
                onChanged: (v) => setDialogState(() => selected = v),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: quantCtrl,
                decoration: const InputDecoration(
                  labelText: "Quantité",
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              DropdownButton<String>(
                value: unite,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 'g', child: Text('g (grammes)')),
                  DropdownMenuItem(value: 'ml', child: Text('ml (millilitres)')),
                  DropdownMenuItem(value: 'unité', child: Text('unité (pièce)')),
                ],
                onChanged: (v) => setDialogState(() => unite = v ?? 'g'),
              ),
            ],
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
      ),
    );

    if (ok == true && selected != null) {
      final q = double.tryParse(quantCtrl.text.trim()) ?? 0.0;
      if (q > 0) {
        await widget.recetteRepository.addIngredientToRecette(
          recetteId: _currentRecette.id,
          ingredientId: selected!.id,
          quantity: q,
          unit: unite,
        );
        _refresh();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentRecette.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () async {
              await widget.recetteRepository.duplicateRecette(_currentRecette.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Recette dupliquée !")),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final should = await showDialog<bool>(
                context: context,
                builder: (c) => AlertDialog(
                  title: const Text("Supprimer la recette"),
                  content: const Text("Confirmez-vous la suppression de cette recette ?"),
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
              if (should == true) {
                await widget.recetteRepository.deleteRecette(_currentRecette.id);
                if (mounted) Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nom avec bouton d'édition
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _currentRecette.name,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: _editRecetteName,
                          tooltip: "Modifier le nom",
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Catégorie
                    InkWell(
                      onTap: _editRecetteCategory,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.category, size: 16, color: Colors.green.shade700),
                            const SizedBox(width: 4),
                            Text(
                              _currentRecette.category ?? "Sans catégorie",
                              style: TextStyle(
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.edit, size: 14, color: Colors.green.shade700),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),
                    Text("Portions: ${_currentRecette.servings}"),

                    if (_currentRecette.instructions != null && _currentRecette.instructions!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Text(
                        "Instructions:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(_currentRecette.instructions!),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            FutureBuilder<Map<String, double>>(
              future: _nutritionFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox.shrink();
                final nutrition = snapshot.data!;
                return Card(
                  color: Colors.green.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Valeurs nutritionnelles totales:",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _NutritionBadge(
                              label: "Calories",
                              value: "${nutrition['calories']!.toStringAsFixed(0)} kcal",
                              color: Colors.orange,
                            ),
                            _NutritionBadge(
                              label: "Protéines",
                              value: "${nutrition['proteins']!.toStringAsFixed(1)}g",
                              color: Colors.red,
                            ),
                            _NutritionBadge(
                              label: "Glucides",
                              value: "${nutrition['carbs']!.toStringAsFixed(1)}g",
                              color: Colors.blue,
                            ),
                            _NutritionBadge(
                              label: "Lipides",
                              value: "${nutrition['fats']!.toStringAsFixed(1)}g",
                              color: Colors.purple,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Par portion: ${(nutrition['calories']! / _currentRecette.servings).toStringAsFixed(0)} kcal",
                          style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),
            const Text(
              "Ingrédients (cliquez pour voir les détails):",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _ingredientsFuture,
                builder: (c, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final list = snap.data ?? [];
                  if (list.isEmpty) {
                    return const Center(
                      child: Text("Aucun ingrédient\nAppuyez sur + pour ajouter"),
                    );
                  }

                  return ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (c, i) {
                      final item = list[i];
                      final ri = item['recetteIngredient'] as RecetteIngredient;
                      final ingredient = item['ingredient'] as Ingredient?;

                      if (ingredient == null) return const SizedBox.shrink();

                      final calories = UnitConverter.caloriesForIngredient(
                        caloriesPer100g: ingredient.caloriesPer100g,
                        quantity: ri.quantity,
                        unit: ri.unit,
                        weightPerPieceGrams: ri.weightPerUnitG ?? ingredient.avgWeightPerUnitG,
                        densityGramsPerMl: ri.densityGPerMl ?? ingredient.densityGPerMl ?? 1.0,
                      );

                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(ingredient.name[0].toUpperCase()),
                          ),
                          title: Text(ingredient.name),
                          subtitle: Text("${ri.quantity} ${ri.unit}"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "${calories.toStringAsFixed(0)} kcal",
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _editIngredientQuantity(ri, ingredient),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removeIngredient(ri, ingredient),
                              ),
                            ],
                          ),
                          // Clic sur la carte pour voir les détails
                          onTap: () => _showIngredientDetails(ingredient, ri),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addIngredientDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Widget pour afficher une ligne de détail nutritionnel
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget pour afficher une ligne d'information
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _NutritionBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _NutritionBadge({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 10, color: color),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}