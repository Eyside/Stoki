// lib/widgets/consume_meal_dialog.dart
// Fenêtre de confirmation pour un repas planifié :
//   • MealAction.cook    -> « Cuisiné »  : déduction du stock
//   • MealAction.consume -> « Consommé » : calcul calorique par convive

import 'package:flutter/material.dart';
import '../models/planning_firestore.dart';
import '../services/meal_consumption_service.dart';
import '../utils/portion_calculator.dart';

enum MealAction { cook, consume }

class ConsumeMealDialog extends StatefulWidget {
  final PlanningFirestore planning;
  final MealConsumptionService consumptionService;
  final List<EaterPortion> eaters;
  final MealAction action;

  const ConsumeMealDialog({
    super.key,
    required this.planning,
    required this.consumptionService,
    required this.eaters,
    required this.action,
  });

  @override
  State<ConsumeMealDialog> createState() => _ConsumeMealDialogState();
}

class _ConsumeMealDialogState extends State<ConsumeMealDialog> {
  bool _loading = true;
  bool _confirming = false;
  Map<String, dynamic>? _summary;
  List<IngredientStockAdjustment>? _adjustments;
  Map<EaterPortion, double>? _caloriesByEater;

  bool get _isCook => widget.action == MealAction.cook;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    try {
      if (_isCook) {
        final scale = await widget.consumptionService
            .computeScale(widget.planning.recetteId, widget.eaters);
        final summary = await widget.consumptionService
            .getMealConsumptionSummary(widget.planning, scale: scale);
        _summary = summary;
        _adjustments = summary['adjustments'] as List<IngredientStockAdjustment>;
      } else {
        _caloriesByEater = await widget.consumptionService.previewCalories(
          planning: widget.planning,
          eaters: widget.eaters,
        );
      }
      if (mounted) setState(() => _loading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _confirm() async {
    setState(() => _confirming = true);

    try {
      final result = _isCook
          ? await widget.consumptionService.cookMeal(
        planning: widget.planning,
        eaters: widget.eaters,
      )
          : await widget.consumptionService.consumeMeal(
        planning: widget.planning,
        eaters: widget.eaters,
      );

      if (mounted) {
        Navigator.pop(context, result);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _confirming = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _isCook ? const Color(0xFFF59E0B) : const Color(0xFF10B981);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // En-tête
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isCook ? Icons.soup_kitchen : Icons.restaurant,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isCook ? 'Marquer comme cuisiné' : 'Marquer comme consommé',
                          style: const TextStyle(
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
            Flexible(
              child: _loading
                  ? const Padding(
                padding: EdgeInsets.all(40),
                child: Center(child: CircularProgressIndicator()),
              )
                  : _isCook
                  ? _buildCookContent()
                  : _buildConsumeContent(),
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
                      onPressed: (_loading || _confirming) ? null : _confirm,
                      icon: _confirming
                          ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : const Icon(Icons.check),
                      label: Text(_isCook ? 'Déduire du stock' : 'Enregistrer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
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

  // ==========================================================================
  // CUISINÉ : stock
  // ==========================================================================

  Widget _buildCookContent() {
    if (_summary == null) {
      return const Center(child: Text('Erreur de chargement'));
    }

    final missingCount = _summary!['missingIngredients'] as int;
    final canConsume = _summary!['canConsume'] as bool;

    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Les ingrédients de ce repas (pour ${_eatersLabel()}) seront retirés de votre stock.',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
        ),
        const SizedBox(height: 16),
        _buildStockStatusCard(canConsume, missingCount),
        const SizedBox(height: 16),
        if (_adjustments != null && _adjustments!.isNotEmpty) ...[
          const Text(
            'Ingrédients :',
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
    );
  }

  String _eatersLabel() {
    final total = widget.eaters.length;
    if (total == 0) return '1 personne';
    return total == 1 ? '1 personne' : '$total personnes';
  }

  Widget _buildStockStatusCard(bool canConsume, int missingCount) {
    // Un stock partiel n'est pas une erreur : on déduit ce qui existe.
    final bg = canConsume ? Colors.green.shade50 : Colors.blue.shade50;
    final fg = canConsume ? Colors.green : Colors.blue;

    return Card(
      color: bg,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              canConsume ? Icons.check_circle : Icons.info,
              color: fg,
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    canConsume ? 'Stock suffisant' : 'Stock partiel',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: canConsume ? Colors.green.shade900 : Colors.blue.shade900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    canConsume
                        ? 'Tous les ingrédients sont en stock'
                        : '$missingCount ingrédient(s) en quantité insuffisante : '
                        'seule la quantité disponible sera déduite',
                    style: TextStyle(
                      fontSize: 12,
                      color: canConsume ? Colors.green.shade700 : Colors.blue.shade700,
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
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: adj.sufficient ? Colors.green.shade100 : Colors.blue.shade100,
          child: Icon(
            adj.sufficient ? Icons.check : Icons.info_outline,
            color: adj.sufficient ? Colors.green : Colors.blue,
            size: 20,
          ),
        ),
        title: Text(
          adj.ingredientName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          'Besoin : ${adj.quantityNeeded.toStringAsFixed(1)} ${adj.unit} '
          '(en stock : ${adj.quantityAvailable.toStringAsFixed(1)} ${adj.unit})',
          style: TextStyle(
            fontSize: 12,
            color: adj.sufficient ? Colors.green.shade700 : Colors.blue.shade700,
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // CONSOMMÉ : calories
  // ==========================================================================

  Widget _buildConsumeContent() {
    final calories = _caloriesByEater ?? {};

    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Les calories de ce repas seront ajoutées au suivi calorique de chaque convive '
              '(recette x coefficient d\'appétit).',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
        ),
        const SizedBox(height: 16),
        ...calories.entries.map((entry) {
          final eater = entry.key;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: eater.known ? Colors.green.shade100 : Colors.grey.shade200,
                child: Icon(
                  eater.known ? Icons.person : Icons.help_outline,
                  color: eater.known ? Colors.green : Colors.grey,
                  size: 20,
                ),
              ),
              title: Text(
                eater.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                eater.known
                    ? 'Coefficient x${eater.multiplier.toStringAsFixed(eater.multiplier % 1 == 0 ? 0 : 1)}'
                    : 'Profil introuvable sur cet appareil (calories non enregistrées)',
                style: const TextStyle(fontSize: 12),
              ),
              trailing: Text(
                '${entry.value.round()} kcal',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
