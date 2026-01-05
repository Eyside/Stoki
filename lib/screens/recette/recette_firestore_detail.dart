// lib/screens/recette/recette_firestore_detail.dart
import 'package:flutter/material.dart';
import '../../models/recette_firestore.dart';
import '../../services/recette_firestore_service.dart';
import '../../services/auth_service.dart';
import '../../database.dart';
import '../../providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RecetteFirestoreDetail extends ConsumerStatefulWidget {
  final String recetteId;

  const RecetteFirestoreDetail({
    super.key,
    required this.recetteId,
  });

  @override
  ConsumerState<RecetteFirestoreDetail> createState() => _RecetteFirestoreDetailState();
}

class _RecetteFirestoreDetailState extends ConsumerState<RecetteFirestoreDetail> {
  final _recetteService = RecetteFirestoreService();
  final _authService = AuthService();

  Future<void> _addIngredient(RecetteFirestore recette) async {
    final ingredientRepo = ref.read(ingredientRepositoryProvider);
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
        // Créer l'ingrédient Firestore avec copie des infos
        final ingredient = RecetteIngredientFirestore(
          ingredientId: selected!.id.toString(),
          ingredientName: selected!.name,
          quantity: q,
          unit: unite,
          caloriesPer100g: selected!.caloriesPer100g,
          proteinsPer100g: selected!.proteinsPer100g,
          fatsPer100g: selected!.fatsPer100g,
          carbsPer100g: selected!.carbsPer100g,
          fibersPer100g: selected!.fibersPer100g,
          densityGPerMl: selected!.densityGPerMl,
          avgWeightPerUnitG: selected!.avgWeightPerUnitG,
        );

        await _recetteService.addIngredient(
          recetteId: widget.recetteId,
          ingredient: ingredient,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ingrédient ajouté !')),
          );
        }
      }
    }
  }

  Future<void> _removeIngredient(RecetteIngredientFirestore ingredient) async {
    await _recetteService.removeIngredient(
      recetteId: widget.recetteId,
      ingredientId: ingredient.ingredientId,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingrédient supprimé')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = _authService.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de la recette'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (c) => AlertDialog(
                  title: const Text('Supprimer'),
                  content: const Text('Supprimer cette recette ?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(c, false),
                      child: const Text('Annuler'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(c, true),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Supprimer'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await _recetteService.deleteRecette(widget.recetteId);
                if (mounted) Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<RecetteFirestore?>(
        stream: _recetteService.watchRecette(widget.recetteId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final recette = snapshot.data;
          if (recette == null) {
            return const Center(child: Text('Recette introuvable'));
          }

          final canEdit = recette.canEdit(userId);

          return Column(
            children: [
              // En-tête
              Card(
                margin: const EdgeInsets.all(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              recette.name,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ),
                          _buildVisibilityBadge(recette),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (recette.category != null)
                        Container(
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
                                recette.category!,
                                style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 8),
                      Text('Portions: ${recette.servings}'),
                      if (recette.instructions != null && recette.instructions!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        const Text(
                          'Instructions:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(recette.instructions!),
                      ],
                    ],
                  ),
                ),
              ),

              // Nutrition
              if (recette.nutrition != null)
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  color: Colors.green.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Valeurs nutritionnelles totales:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _NutritionBadge(
                              label: 'Calories',
                              value: '${recette.nutrition!['calories']?.toStringAsFixed(0)} kcal',
                              color: Colors.orange,
                            ),
                            _NutritionBadge(
                              label: 'Protéines',
                              value: '${recette.nutrition!['proteins']?.toStringAsFixed(1)}g',
                              color: Colors.red,
                            ),
                            _NutritionBadge(
                              label: 'Glucides',
                              value: '${recette.nutrition!['carbs']?.toStringAsFixed(1)}g',
                              color: Colors.blue,
                            ),
                            _NutritionBadge(
                              label: 'Lipides',
                              value: '${recette.nutrition!['fats']?.toStringAsFixed(1)}g',
                              color: Colors.purple,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 12),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'Ingrédients:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),

              // Liste des ingrédients
              Expanded(
                child: StreamBuilder<List<RecetteIngredientFirestore>>(
                  stream: _recetteService.watchIngredients(widget.recetteId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final ingredients = snapshot.data ?? [];

                    if (ingredients.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Aucun ingrédient'),
                            if (canEdit) ...[
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () => _addIngredient(recette),
                                icon: const Icon(Icons.add),
                                label: const Text('Ajouter un ingrédient'),
                              ),
                            ],
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: ingredients.length,
                      itemBuilder: (context, index) {
                        final ingredient = ingredients[index];

                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text(ingredient.ingredientName[0].toUpperCase()),
                            ),
                            title: Text(ingredient.ingredientName),
                            subtitle: Text('${ingredient.quantity} ${ingredient.unit}'),
                            trailing: canEdit
                                ? IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeIngredient(ingredient),
                            )
                                : null,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: StreamBuilder<RecetteFirestore?>(
        stream: _recetteService.watchRecette(widget.recetteId),
        builder: (context, snapshot) {
          final recette = snapshot.data;
          if (recette == null) return const SizedBox.shrink();

          final canEdit = recette.canEdit(userId);
          if (!canEdit) return const SizedBox.shrink();

          return FloatingActionButton(
            onPressed: () => _addIngredient(recette),
            child: const Icon(Icons.add),
          );
        },
      ),
    );
  }

  Widget _buildVisibilityBadge(RecetteFirestore recette) {
    final color = _getVisibilityColor(recette.visibility);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getVisibilityIcon(recette.visibility), size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            recette.visibilityLabel,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getVisibilityIcon(RecetteVisibility visibility) {
    switch (visibility) {
      case RecetteVisibility.private:
        return Icons.lock;
      case RecetteVisibility.group:
        return Icons.group;
    }
  }

  Color _getVisibilityColor(RecetteVisibility visibility) {
    switch (visibility) {
      case RecetteVisibility.private:
        return Colors.grey;
      case RecetteVisibility.group:
        return Colors.green;
    }
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