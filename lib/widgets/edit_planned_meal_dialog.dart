// lib/widgets/edit_planned_meal_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../database.dart';
import '../models/recette_firestore.dart';
import 'dart:convert';

/// Classe pour stocker les ingrédients modifiés
class ModifiedIngredientData {
  final String ingredientId;
  final String ingredientName;
  final double originalQuantity;
  final double newQuantity;
  final String unit;

  ModifiedIngredientData({
    required this.ingredientId,
    required this.ingredientName,
    required this.originalQuantity,
    required this.newQuantity,
    required this.unit,
  });

  Map<String, dynamic> toJson() => {
    'ingredientId': ingredientId,
    'ingredientName': ingredientName,
    'originalQuantity': originalQuantity,
    'newQuantity': newQuantity,
    'unit': unit,
  };

  factory ModifiedIngredientData.fromJson(Map<String, dynamic> json) {
    return ModifiedIngredientData(
      ingredientId: json['ingredientId'] as String,
      ingredientName: json['ingredientName'] as String,
      originalQuantity: (json['originalQuantity'] as num).toDouble(),
      newQuantity: (json['newQuantity'] as num).toDouble(),
      unit: json['unit'] as String,
    );
  }
}

/// Résultat de l'édition d'un repas planifié
class EditedMealResult {
  final List<ModifiedIngredientData> modifiedIngredients;
  final Map<String, double> newNutrition;

  EditedMealResult({
    required this.modifiedIngredients,
    required this.newNutrition,
  });

  String toJson() => json.encode({
    'modifiedIngredients': modifiedIngredients.map((i) => i.toJson()).toList(),
    'newNutrition': newNutrition,
  });

  static EditedMealResult fromJson(String jsonString) {
    final data = json.decode(jsonString) as Map<String, dynamic>;
    return EditedMealResult(
      modifiedIngredients: (data['modifiedIngredients'] as List)
          .map((i) => ModifiedIngredientData.fromJson(i as Map<String, dynamic>))
          .toList(),
      newNutrition: (data['newNutrition'] as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, (v as num).toDouble())),
    );
  }
}

/// Dialogue pour modifier les quantités d'ingrédients d'un repas planifié
class EditPlannedMealDialog extends StatefulWidget {
  final String recetteName;
  final int servings;
  final List<RecetteIngredientFirestore> ingredients;

  const EditPlannedMealDialog({
    super.key,
    required this.recetteName,
    required this.servings,
    required this.ingredients,
  });

  @override
  State<EditPlannedMealDialog> createState() => _EditPlannedMealDialogState();
}

class _EditPlannedMealDialogState extends State<EditPlannedMealDialog> {
  late List<RecetteIngredientFirestore> _editableIngredients;
  late Map<String, TextEditingController> _controllers;
  late Map<String, double> _originalQuantities;
  Map<String, double> _currentNutrition = {};

  @override
  void initState() {
    super.initState();
    _initializeIngredients();
    _calculateNutrition();
  }

  void _initializeIngredients() {
    _editableIngredients = List.from(widget.ingredients);
    _controllers = {};
    _originalQuantities = {};

    for (final ing in _editableIngredients) {
      _controllers[ing.ingredientId] = TextEditingController(
        text: ing.quantity.toStringAsFixed(0),
      );
      _originalQuantities[ing.ingredientId] = ing.quantity;
    }
  }

  void _calculateNutrition() {
    double totalCalories = 0;
    double totalProteins = 0;
    double totalFats = 0;
    double totalCarbs = 0;
    double totalFibers = 0;

    for (final ing in _editableIngredients) {
      final controller = _controllers[ing.ingredientId];
      final quantity = double.tryParse(controller?.text ?? '0') ?? 0;

      // Convertir en grammes si nécessaire
      final gramsQuantity = _toGrams(
          quantity,
          ing.unit,
          ing.avgWeightPerUnitG,
          ing.densityGPerMl
      );
      final factor = gramsQuantity / 100.0;

      totalCalories += ing.caloriesPer100g * factor;
      totalProteins += ing.proteinsPer100g * factor;
      totalFats += ing.fatsPer100g * factor;
      totalCarbs += ing.carbsPer100g * factor;
      totalFibers += ing.fibersPer100g * factor;
    }

    setState(() {
      _currentNutrition = {
        'calories': totalCalories,
        'proteins': totalProteins,
        'fats': totalFats,
        'carbs': totalCarbs,
        'fibers': totalFibers,
      };
    });
  }

  double _toGrams(double quantity, String unit, double? weightPerPiece, double? density) {
    if (unit == 'g') return quantity;
    if (unit == 'kg') return quantity * 1000;
    if (unit == 'ml') return quantity * (density ?? 1.0);
    if (unit == 'L') return quantity * 1000 * (density ?? 1.0);
    if (unit == 'unité' || unit == 'pièce') return quantity * (weightPerPiece ?? 50);
    return quantity; // Fallback
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasChanges = _controllers.entries.any((entry) {
      final currentValue = double.tryParse(entry.value.text) ?? 0;
      final originalValue = _originalQuantities[entry.key] ?? 0;
      return currentValue != originalValue;
    });

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
                  const Icon(Icons.edit, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Modifier les quantités',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.recetteName,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.amber.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Les modifications ne changeront pas la recette originale',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.amber.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Nutrition actuelle
              _buildNutritionSummary(),
              const SizedBox(height: 20),

              // Liste des ingrédients modifiables
              const Text(
                'Ajuster les quantités',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              ..._editableIngredients.map((ing) {
                final controller = _controllers[ing.ingredientId]!;
                final hasChanged = double.tryParse(controller.text) !=
                    _originalQuantities[ing.ingredientId];

                return _buildIngredientEditor(
                  ingredient: ing,
                  controller: controller,
                  hasChanged: hasChanged,
                );
              }),

              const SizedBox(height: 20),

              // Boutons d'action
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: hasChanges ? _resetAll : null,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Réinitialiser'),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Annuler'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: hasChanges ? _saveChanges : null,
                        icon: const Icon(Icons.save),
                        label: const Text('Enregistrer'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNutritionSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade400, Colors.green.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Calories',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    '${_currentNutrition['calories']?.toStringAsFixed(0) ?? 0} kcal',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  _buildMiniNutrient('P', _currentNutrition['proteins'] ?? 0, Colors.red.shade100),
                  const SizedBox(width: 8),
                  _buildMiniNutrient('G', _currentNutrition['carbs'] ?? 0, Colors.blue.shade100),
                  const SizedBox(width: 8),
                  _buildMiniNutrient('L', _currentNutrition['fats'] ?? 0, Colors.purple.shade100),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniNutrient(String label, double grams, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
          Text(
            '${grams.toStringAsFixed(0)}g',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientEditor({
    required RecetteIngredientFirestore ingredient,
    required TextEditingController controller,
    required bool hasChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: hasChanged ? Colors.blue.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: hasChanged ? Border.all(color: Colors.blue.shade300, width: 2) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  ingredient.ingredientName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (hasChanged)
                Icon(Icons.edit, size: 16, color: Colors.blue.shade700),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Quantité',
                    suffixText: ingredient.unit,
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onChanged: (_) => _calculateNutrition(),
                ),
              ),
              const SizedBox(width: 12),
              if (hasChanged)
                IconButton(
                  icon: const Icon(Icons.undo, color: Colors.orange),
                  tooltip: 'Réinitialiser',
                  onPressed: () {
                    controller.text = _originalQuantities[ingredient.ingredientId]!
                        .toStringAsFixed(0);
                    _calculateNutrition();
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _resetAll() {
    for (final entry in _controllers.entries) {
      entry.value.text = _originalQuantities[entry.key]!.toStringAsFixed(0);
    }
    _calculateNutrition();
  }

  void _saveChanges() {
    // Créer la liste des ingrédients modifiés
    final modifiedIngredients = <ModifiedIngredientData>[];

    for (final ing in _editableIngredients) {
      final newQuantity = double.tryParse(_controllers[ing.ingredientId]!.text)
          ?? ing.quantity;

      modifiedIngredients.add(ModifiedIngredientData(
        ingredientId: ing.ingredientId,
        ingredientName: ing.ingredientName,
        originalQuantity: _originalQuantities[ing.ingredientId]!,
        newQuantity: newQuantity,
        unit: ing.unit,
      ));
    }

    final result = EditedMealResult(
      modifiedIngredients: modifiedIngredients,
      newNutrition: _currentNutrition,
    );

    Navigator.pop(context, result);
  }
}