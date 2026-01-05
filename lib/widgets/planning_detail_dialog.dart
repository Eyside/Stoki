// lib/widgets/planning_detail_dialog.dart
import 'package:flutter/material.dart';
import '../database.dart';
import '../models/recette_firestore.dart';

/// Dialogue détaillé pour afficher les informations nutritionnelles
/// d'une recette planifiée
class PlanningDetailDialog extends StatelessWidget {
  final String recetteName;
  final int servings;
  final Map<String, double> nutrition;
  final List<dynamic> ingredients; // RecetteIngredient ou RecetteIngredientFirestore
  final UserProfile? userProfile;
  final VoidCallback? onEdit;

  const PlanningDetailDialog({
    super.key,
    required this.recetteName,
    required this.servings,
    required this.nutrition,
    required this.ingredients,
    this.userProfile,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final calories = nutrition['calories'] ?? 0;
    final proteins = nutrition['proteins'] ?? 0;
    final fats = nutrition['fats'] ?? 0;
    final carbs = nutrition['carbs'] ?? 0;
    final fibers = nutrition['fibers'] ?? 0;

    // Calculer les pourcentages si profil disponible
    final tdee = userProfile?.tdee;
    final caloriesPercent = (tdee != null && tdee > 0)
        ? (calories / tdee * 100).clamp(0, 100).toDouble()
        : null;

    // Calories par macro
    final proteinCals = proteins * 4;
    final carbsCals = carbs * 4;
    final fatsCals = fats * 9;
    final totalMacroCals = proteinCals + carbsCals + fatsCals;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      recetteName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Portions
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.people, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      '$servings portion(s)',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Calories principales
              _buildCaloriesSection(
                calories: calories,
                caloriesPercent: caloriesPercent,
                tdee: tdee,
              ),
              const SizedBox(height: 20),

              // Macronutriments
              const Text(
                'Macronutriments',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              _buildMacroBar(
                label: 'Protéines',
                grams: proteins,
                color: Colors.red,
                percentage: totalMacroCals > 0 ? proteinCals / totalMacroCals : 0,
                calories: proteinCals,
              ),
              const SizedBox(height: 8),

              _buildMacroBar(
                label: 'Glucides',
                grams: carbs,
                color: Colors.blue,
                percentage: totalMacroCals > 0 ? carbsCals / totalMacroCals : 0,
                calories: carbsCals,
              ),
              const SizedBox(height: 8),

              _buildMacroBar(
                label: 'Lipides',
                grams: fats,
                color: Colors.purple,
                percentage: totalMacroCals > 0 ? fatsCals / totalMacroCals : 0,
                calories: fatsCals,
              ),
              const SizedBox(height: 8),

              _buildMacroBar(
                label: 'Fibres',
                grams: fibers,
                color: Colors.brown,
                percentage: null, // Pas de calories
                calories: null,
              ),
              const SizedBox(height: 20),

              // Ingrédients
              const Text(
                'Ingrédients',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              if (ingredients.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Aucun ingrédient disponible',
                    style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                  ),
                )
              else
                ...ingredients.map((ing) {
                  String name;
                  double quantity;
                  String unit;

                  if (ing is RecetteIngredient) {
                    name = 'Ingrédient #${ing.ingredientId}'; // Sera résolu dans planning_screen
                    quantity = ing.quantity;
                    unit = ing.unit;
                  } else if (ing is RecetteIngredientFirestore) {
                    name = ing.ingredientName;
                    quantity = ing.quantity;
                    unit = ing.unit;
                  } else {
                    return const SizedBox.shrink();
                  }

                  return _buildIngredientRow(
                    name: name,
                    quantity: quantity,
                    unit: unit,
                  );
                }),

              const SizedBox(height: 20),

              // Boutons d'action
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onEdit != null)
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        onEdit!();
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Modifier'),
                    ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Fermer'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCaloriesSection({
    required double calories,
    double? caloriesPercent,
    double? tdee,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade400, Colors.orange.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_fire_department, color: Colors.white, size: 32),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Calories totales',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '${calories.toStringAsFixed(0)} kcal',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (tdee != null && tdee > 0 && caloriesPercent != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: caloriesPercent / 100,
                backgroundColor: Colors.white30,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${caloriesPercent.toStringAsFixed(0)}% de vos besoins journaliers (${tdee.toStringAsFixed(0)} kcal)',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMacroBar({
    required String label,
    required double grams,
    required Color color,
    double? percentage,
    double? calories,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  '${grams.toStringAsFixed(1)}g',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                if (calories != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    '(${calories.toStringAsFixed(0)} kcal)',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        if (percentage != null) ...[
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${(percentage * 100).toStringAsFixed(0)}% des calories',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildIngredientRow({
    required String name,
    required double quantity,
    required String unit,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 8, color: Colors.green),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontSize: 15),
            ),
          ),
          Text(
            '${quantity.toStringAsFixed(0)} $unit',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}