// lib/screens/shopping_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database.dart';
import '../providers.dart';
import '../repositories/shopping_list_repository.dart';
import '../repositories/planning_repository.dart';
import '../repositories/recette_repository.dart';
import '../repositories/frigo_repository.dart';

class ShoppingListScreen extends ConsumerStatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  ConsumerState<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends ConsumerState<ShoppingListScreen> {
  bool _showCompleted = false;
  late ShoppingListRepository _shoppingRepo;
  late PlanningRepository _planningRepo;
  late RecetteRepository _recetteRepo;
  late FrigoRepository _frigoRepo;

  @override
  void initState() {
    super.initState();
    final db = ref.read(databaseProvider);
    _shoppingRepo = ShoppingListRepository(db);
    _planningRepo = PlanningRepository(db);
    _recetteRepo = ref.read(recetteRepositoryProvider);
    _frigoRepo = ref.read(frigoRepositoryProvider);
  }

  void _refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<ShoppingListData>>(
        future: _shoppingRepo.getAllShoppingList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final allItems = snapshot.data ?? [];
          final activeItems = allItems.where((item) => !item.isChecked).toList();
          final completedItems = allItems.where((item) => item.isChecked).toList();

          if (allItems.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: [
              // Stats en-tête
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.green.shade50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatChip(
                      label: 'À acheter',
                      value: activeItems.length.toString(),
                      color: Colors.orange,
                    ),
                    _StatChip(
                      label: 'Complétés',
                      value: completedItems.length.toString(),
                      color: Colors.green,
                    ),
                    _StatChip(
                      label: 'Total',
                      value: allItems.length.toString(),
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),

              // Bouton afficher/masquer complétés
              if (completedItems.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          setState(() => _showCompleted = !_showCompleted);
                        },
                        icon: Icon(_showCompleted ? Icons.visibility_off : Icons.visibility),
                        label: Text(
                          _showCompleted ? 'Masquer complétés' : 'Afficher complétés',
                        ),
                      ),
                    ],
                  ),
                ),

              // Liste des courses
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Items actifs
                    if (activeItems.isNotEmpty) ...[
                      const Text(
                        'À acheter',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...activeItems.map((item) => _buildShoppingItem(item)),
                    ],

                    // Items complétés
                    if (_showCompleted && completedItems.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Complétés',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...completedItems.map((item) => _buildShoppingItem(item)),
                    ],
                  ],
                ),
              ),

              // Boutons actions
              if (allItems.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      if (completedItems.isNotEmpty)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _addCompletedToFrigo,
                            icon: const Icon(Icons.kitchen),
                            label: const Text('Ajouter les complétés au frigo'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      if (completedItems.isNotEmpty) const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: completedItems.isEmpty ? null : _clearCompleted,
                              icon: const Icon(Icons.delete_sweep),
                              label: const Text('Supprimer complétés'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _clearAll,
                              icon: const Icon(Icons.clear_all),
                              label: const Text('Tout supprimer'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'generate',
            onPressed: _generateFromPlanning,
            backgroundColor: Colors.green,
            child: const Icon(Icons.auto_awesome),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'add',
            onPressed: _addManualItem,
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            'Liste de courses vide',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Générez depuis le planning\nou ajoutez manuellement',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _generateFromPlanning,
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Générer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: _addManualItem,
                icon: const Icon(Icons.add),
                label: const Text('Ajouter'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShoppingItem(ShoppingListData item) {
    return FutureBuilder<Ingredient?>(
      future: item.ingredientId != null
          ? ref.read(ingredientRepositoryProvider).findById(item.ingredientId!)
          : Future.value(null),
      builder: (context, snapshot) {
        final ingredient = snapshot.data;
        final displayName = ingredient?.name ?? item.customName ?? 'Article';

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Checkbox(
              value: item.isChecked,
              onChanged: (value) async {
                await _shoppingRepo.toggleChecked(item.id, value ?? false);
                _refresh();
              },
            ),
            title: Text(
              displayName,
              style: TextStyle(
                decoration: item.isChecked ? TextDecoration.lineThrough : null,
                color: item.isChecked ? Colors.grey : null,
              ),
            ),
            subtitle: Row(
              children: [
                Text(
                  '${item.quantity} ${item.unit}',
                  style: TextStyle(
                    color: item.isChecked ? Colors.grey : Colors.black54,
                  ),
                ),
                const SizedBox(width: 8),
                if (item.isAutoGenerated)
                  const Tooltip(
                    message: 'Généré automatiquement',
                    child: Icon(Icons.auto_awesome, color: Colors.blue, size: 14),
                  )
                else
                  const Tooltip(
                    message: 'Ajouté manuellement',
                    child: Icon(Icons.edit, color: Colors.grey, size: 14),
                  ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  onPressed: () => _deleteItem(item),
                  tooltip: 'Supprimer',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _generateFromPlanning() async {
    // Demander la période
    final startDate = DateTime.now();
    final endDate = await showDialog<DateTime>(
      context: context,
      builder: (c) => _DateRangePickerDialog(startDate: startDate),
    );

    if (endDate == null) return;

    if (!mounted) return;

    // Afficher le chargement
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Génération de la liste...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // 1. Récupérer tous les plannings de la période
      final allPlannings = <MealPlanningData>[];
      for (var date = startDate; date.isBefore(endDate.add(const Duration(days: 1))); date = date.add(const Duration(days: 1))) {
        final dayPlannings = await _planningRepo.getPlanningForDate(date);
        allPlannings.addAll(dayPlannings);
      }

      if (allPlannings.isEmpty) {
        if (!mounted) return;
        Navigator.pop(context); // Fermer le dialog de chargement
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aucun repas planifié sur cette période')),
        );
        return;
      }

      // 2. Calculer les ingrédients nécessaires
      final neededIngredients = <int, double>{}; // ingredientId -> quantité en grammes

      for (final planning in allPlannings) {
        if (planning.recetteId == null) continue;

        final recetteIngredients = await _recetteRepo.getIngredientsForRecette(planning.recetteId!);
        final recette = await _recetteRepo.getRecetteById(planning.recetteId!);

        if (recette == null) continue;

        final portionFactor = planning.servings / recette.servings;

        for (final item in recetteIngredients) {
          final ri = item['recetteIngredient'] as RecetteIngredient;
          final ingredient = item['ingredient'] as Ingredient?;

          if (ingredient == null) continue;

          // Convertir en grammes
          double quantityInGrams = ri.quantity * portionFactor;
          if (ri.unit == 'ml') {
            quantityInGrams *= (ri.densityGPerMl ?? ingredient.densityGPerMl ?? 1.0);
          } else if (ri.unit == 'unité') {
            quantityInGrams *= (ri.weightPerUnitG ?? ingredient.avgWeightPerUnitG ?? 100);
          }

          neededIngredients[ingredient.id] = (neededIngredients[ingredient.id] ?? 0) + quantityInGrams;
        }
      }

      // 3. Soustraire ce qui est en stock
      final frigoItems = await _frigoRepo.getAllFrigoWithIngredients();

      for (final frigoItem in frigoItems) {
        final frigo = frigoItem['frigo'] as FrigoData;
        final ingredient = frigoItem['ingredient'] as Ingredient?;

        if (ingredient == null || !neededIngredients.containsKey(ingredient.id)) continue;

        // Convertir stock en grammes
        double stockInGrams = frigo.quantity;
        if (frigo.unit == 'ml') {
          stockInGrams *= (ingredient.densityGPerMl ?? 1.0);
        } else if (frigo.unit == 'unité') {
          stockInGrams *= (ingredient.avgWeightPerUnitG ?? 100);
        }

        neededIngredients[ingredient.id] = (neededIngredients[ingredient.id]! - stockInGrams).clamp(0, double.infinity);
      }

      // 4. Supprimer les articles auto-générés précédents
      await _shoppingRepo.clearAutoGenerated();

      // 5. Ajouter à la liste de courses
      int addedCount = 0;
      for (final entry in neededIngredients.entries) {
        if (entry.value <= 0) continue; // Déjà assez en stock

        await _shoppingRepo.addToShoppingList(
          ingredientId: entry.key,
          quantity: entry.value,
          unit: 'g',
          isAutoGenerated: true,
        );
        addedCount++;
      }

      if (!mounted) return;
      Navigator.pop(context); // Fermer le dialog de chargement

      _refresh();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$addedCount article(s) ajouté(s) à la liste !')),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Fermer le dialog de chargement

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  Future<void> _addManualItem() async {
    final nameCtrl = TextEditingController();
    final quantityCtrl = TextEditingController(text: '1');
    String unit = 'unité';

    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c2, setDialogState) => AlertDialog(
          title: const Text('Ajouter un article'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nom de l\'article',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: quantityCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Quantité',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: unit,
                      decoration: const InputDecoration(
                        labelText: 'Unité',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'g', child: Text('g')),
                        DropdownMenuItem(value: 'kg', child: Text('kg')),
                        DropdownMenuItem(value: 'ml', child: Text('ml')),
                        DropdownMenuItem(value: 'L', child: Text('L')),
                        DropdownMenuItem(value: 'unité', child: Text('unité')),
                      ],
                      onChanged: (v) => setDialogState(() => unit = v ?? 'unité'),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Ajouter'),
            ),
          ],
        ),
      ),
    );

    if (ok == true) {
      final name = nameCtrl.text.trim();
      final quantity = double.tryParse(quantityCtrl.text.trim()) ?? 1.0;

      if (name.isNotEmpty) {
        await _shoppingRepo.addToShoppingList(
          customName: name,
          quantity: quantity,
          unit: unit,
          isAutoGenerated: false,
        );
        _refresh();
      }
    }
  }

  void _clearCompleted() async {
    await _shoppingRepo.clearChecked();
    _refresh();
  }

  void _clearAll() {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Tout supprimer ?'),
        content: const Text('Êtes-vous sûr de vouloir supprimer tous les articles ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _shoppingRepo.clearAll();
              Navigator.pop(c);
              _refresh();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Tout supprimer'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteItem(ShoppingListData item) async {
    final ingredient = item.ingredientId != null
        ? await ref.read(ingredientRepositoryProvider).findById(item.ingredientId!)
        : null;
    final displayName = ingredient?.name ?? item.customName ?? 'Article';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Supprimer cet article ?'),
        content: Text('Voulez-vous supprimer "$displayName" de la liste ?'),
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
      await _shoppingRepo.deleteItem(item.id);
      _refresh();
    }
  }

  Future<void> _addCompletedToFrigo() async {
    final allItems = await _shoppingRepo.getAllShoppingList();
    final completedItems = allItems.where((item) => item.isChecked).toList();

    if (completedItems.isEmpty) return;

    // Dialog de confirmation avec choix d'emplacement
    String location = 'frigo';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c2, setDialogState) => AlertDialog(
          title: const Text('Ajouter au stock'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${completedItems.length} article(s) complété(s) seront ajoutés au stock.'),
              const SizedBox(height: 16),
              const Text('Emplacement:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'frigo', label: Text('🧊 Frigo')),
                  ButtonSegment(value: 'placard', label: Text('📦 Placard')),
                  ButtonSegment(value: 'congélateur', label: Text('❄️ Congélateur')),
                ],
                selected: {location},
                onSelectionChanged: (Set<String> newSelection) {
                  setDialogState(() => location = newSelection.first);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Ajouter'),
            ),
          ],
        ),
      ),
    );

    if (confirm != true) return;

    // Afficher chargement
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Ajout au stock...'),
              ],
            ),
          ),
        ),
      ),
    );

    int addedCount = 0;

    for (final item in completedItems) {
      if (item.ingredientId != null) {
        // Article avec ingrédient connu
        await _frigoRepo.addToFrigo(
          ingredientId: item.ingredientId!,
          quantity: item.quantity,
          unit: item.unit,
          location: location,
        );
        addedCount++;
      } else if (item.customName != null) {
        // Article custom : créer l'ingrédient d'abord
        final ingredientId = await ref.read(ingredientRepositoryProvider).insertIngredient(
          name: item.customName!,
          caloriesPer100g: 0, // Valeur par défaut
          isCustom: true,
        );

        await _frigoRepo.addToFrigo(
          ingredientId: ingredientId,
          quantity: item.quantity,
          unit: item.unit,
          location: location,
        );
        addedCount++;
      }
    }

    // Supprimer les articles complétés de la liste
    await _shoppingRepo.clearChecked();

    if (!mounted) return;
    Navigator.pop(context); // Fermer le dialog de chargement

    _refresh();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$addedCount article(s) ajouté(s) au $location !')),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}

class _DateRangePickerDialog extends StatefulWidget {
  final DateTime startDate;

  const _DateRangePickerDialog({required this.startDate});

  @override
  State<_DateRangePickerDialog> createState() => _DateRangePickerDialogState();
}

class _DateRangePickerDialogState extends State<_DateRangePickerDialog> {
  int _selectedDays = 7;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Période de planification'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Générer la liste de courses pour :'),
          const SizedBox(height: 16),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 1, label: Text('1 jour')),
              ButtonSegment(value: 3, label: Text('3 jours')),
              ButtonSegment(value: 7, label: Text('1 semaine')),
              ButtonSegment(value: 14, label: Text('2 semaines')),
            ],
            selected: {_selectedDays},
            onSelectionChanged: (Set<int> newSelection) {
              setState(() => _selectedDays = newSelection.first);
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Du ${_formatDate(widget.startDate)} au ${_formatDate(widget.startDate.add(Duration(days: _selectedDays - 1)))}',
            style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, widget.startDate.add(Duration(days: _selectedDays - 1)));
          },
          child: const Text('Générer'),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}