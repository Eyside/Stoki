// lib/widgets/consume_meal_dialog.dart
// Dialog pour confirmer la consommation d'un repas

import 'package:flutter/material.dart';
import '../models/planning_firestore.dart';
import '../services/meal_consumption_service.dart';

class ConsumeMealDialog extends StatefulWidget {
  final PlanningFirestore planning;
  final MealConsumptionService consumptionService;
  final int userProfileId;

  const ConsumeMealDialog({
    super.key,
    required this.planning,
    required this.consumptionService,
    required this.userProfileId,
  });

  @override
  State<ConsumeMealDialog> createState() => _ConsumeMealDialogState();
}

class _ConsumeMealDialogState extends State<ConsumeMealDialog> {
  bool _loading = true;
  bool _deductFromStock = true;
  Map<String, dynamic>? _summary;
  List<IngredientStockAdjustment>? _adjustments;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    setState(() => _loading = true);

    try {
      final summary = await widget.consumptionService
          .getMealConsumptionSummary(widget.planning);

      setState(() {
        _summary = summary;
        _adjustments = summary['adjustments'] as List<IngredientStockAdjustment>;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
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

  Future<void> _confirmConsumption() async {
    setState(() => _loading = true);

    try {
      final result = await widget.consumptionService.consumeMeal(
        planning: widget.planning,
        userProfileId: widget.userProfileId,
        deductFromStock: _deductFromStock,
      );

      if (mounted) {
        Navigator.pop(context, result);
      }
    } catch (e) {
      setState(() => _loading = false);
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.restaurant, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Marquer comme consommé',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.planning.recetteName,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Contenu
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildContent(),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Annuler'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _loading ? null : _confirmConsumption,
                      icon: _loading
                          ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : const Icon(Icons.check),
                      label: const Text('Confirmer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_summary == null) {
      return const Center(child: Text('Erreur de chargement'));
    }

    final missingCount = _summary!['missingIngredients'] as int;
    final canConsume = _summary!['canConsume'] as bool;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Résumé nutritionnel
        _buildNutritionCard(),
        const SizedBox(height: 20),

        // Option de déduction du stock
        Card(
          child: SwitchListTile(
            value: _deductFromStock,
            onChanged: (v) => setState(() => _deductFromStock = v),
            title: const Text(
              'Déduire du stock',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: const Text(
              'Retirer automatiquement les ingrédients du frigo',
              style: TextStyle(fontSize: 12),
            ),
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.inventory_2, color: Colors.blue),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // État du stock
        if (_deductFromStock) ...[
          _buildStockStatusCard(canConsume, missingCount),
          const SizedBox(height: 16),

          // Liste des ingrédients
          if (_adjustments != null && _adjustments!.isNotEmpty) ...[
            const Text(
              'Ingrédients requis:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),
            ..._adjustments!.map((adj) => _buildIngredientTile(adj)),
          ],
        ],
      ],
    );
  }

  Widget _buildNutritionCard() {
    final calories = widget.planning.modifiedCalories ?? widget.planning.totalCalories;
    final proteins = widget.planning.modifiedProteins ?? widget.planning.totalProteins;
    final carbs = widget.planning.modifiedCarbs ?? widget.planning.totalCarbs;
    final fats = widget.planning.modifiedFats ?? widget.planning.totalFats;

    return Card(
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.local_fire_department,
                    color: Colors.orange,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Valeurs nutritionnelles',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMacroColumn('Calories', '${calories.toStringAsFixed(0)} kcal', Colors.orange),
                _buildMacroColumn('Protéines', '${proteins.toStringAsFixed(1)}g', Colors.red),
                _buildMacroColumn('Glucides', '${carbs.toStringAsFixed(1)}g', Colors.blue),
                _buildMacroColumn('Lipides', '${fats.toStringAsFixed(1)}g', Colors.purple),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildStockStatusCard(bool canConsume, int missingCount) {
    return Card(
      color: canConsume ? Colors.green.shade50 : Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              canConsume ? Icons.check_circle : Icons.warning,
              color: canConsume ? Colors.green : Colors.orange,
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    canConsume ? 'Stock suffisant' : 'Stock insuffisant',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: canConsume ? Colors.green.shade900 : Colors.orange.shade900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    canConsume
                        ? 'Tous les ingrédients sont disponibles'
                        : '$missingCount ingrédient(s) manquant(s)',
                    style: TextStyle(
                      fontSize: 12,
                      color: canConsume ? Colors.green.shade700 : Colors.orange.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientTile(IngredientStockAdjustment adj) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: adj.sufficient ? null : Colors.red.shade50,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: adj.sufficient ? Colors.green.shade100 : Colors.red.shade100,
          child: Icon(
            adj.sufficient ? Icons.check : Icons.close,
            color: adj.sufficient ? Colors.green : Colors.red,
            size: 20,
          ),
        ),
        title: Text(
          adj.ingredientName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          adj.sufficient
              ? 'Disponible: ${adj.quantityAvailable.toStringAsFixed(1)} ${adj.unit}'
              : 'Nécessaire: ${adj.quantityNeeded.toStringAsFixed(1)} ${adj.unit} '
              '(disponible: ${adj.quantityAvailable.toStringAsFixed(1)} ${adj.unit})',
          style: TextStyle(
            fontSize: 12,
            color: adj.sufficient ? Colors.green.shade700 : Colors.red.shade700,
          ),
        ),
        trailing: adj.sufficient
            ? null
            : const Icon(Icons.warning, color: Colors.orange, size: 20),
      ),
    );
  }
}