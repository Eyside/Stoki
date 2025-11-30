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

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _ingredientsFuture = widget.recetteRepository.getIngredientsForRecette(widget.recette.id);
      _nutritionFuture = widget.recetteRepository.calculateNutritionForRecette(widget.recette.id);
    });
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
                value: unite,
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
        // Supprimer l'ancien
        await widget.recetteRepository.removeIngredientFromRecette(
          recetteId: ri.recetteId,
          ingredientId: ri.ingredientId,
        );

        // Ajouter le nouveau
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
          recetteId: widget.recette.id,
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
        title: Text(widget.recette.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () async {
              await widget.recetteRepository.duplicateRecette(widget.recette.id);
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
                await widget.recetteRepository.deleteRecette(widget.recette.id);
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
                    Text(
                      widget.recette.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text("Portions: ${widget.recette.servings}"),
                    if (widget.recette.instructions != null && widget.recette.instructions!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Text(
                        "Instructions:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(widget.recette.instructions!),
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
                          "Par portion: ${(nutrition['calories']! / widget.recette.servings).toStringAsFixed(0)} kcal",
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
              "Ingrédients:",
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