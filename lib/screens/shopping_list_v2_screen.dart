// lib/screens/shopping_list_v2_screen.dart (PARTIE 1/3)
// Écran de liste de courses refait avec répartition intelligente du stock

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/shopping_list_firestore.dart';
import '../services/shopping_list_v2_generator_service.dart';
import '../services/shopping_list_cloud_service.dart';
import '../services/frigo_firestore_service.dart';
import '../providers.dart';
import '../utils/shopping_list_category_helper.dart';
import '../utils/unit_converter.dart';
import '../models/ingredient_firestore.dart';
import '../models/frigo_firestore.dart';
import 'scan/scan_for_shopping_screen.dart';

class ShoppingListV2Screen extends ConsumerStatefulWidget {
  final List<String> selectedSources;
  final DateTime startDate;
  final DateTime endDate;
  final bool subtractStock;

  const ShoppingListV2Screen({
    super.key,
    required this.selectedSources,
    required this.startDate,
    required this.endDate,
    required this.subtractStock,
  });

  @override
  ConsumerState<ShoppingListV2Screen> createState() => _ShoppingListV2ScreenState();
}

class _ShoppingListV2ScreenState extends ConsumerState<ShoppingListV2Screen> {
  late ShoppingListV2GeneratorService _generatorService;
  late ShoppingListCloudService _cloudService;
  late FrigoFirestoreService _frigoService;

  List<ShoppingItemWithOrigin> _items = [];
  Set<String> _selectedItemIds = {};
  bool _isLoading = true;
  bool _showCompleted = false;
  bool _viewByCategory = true;

  // Destinations pour chaque item
  Map<String, String> _itemDestinations = {}; // itemId -> destination

  @override
  void initState() {
    super.initState();
    _generatorService = ref.read(shoppingListV2GeneratorServiceProvider);
    _cloudService = ref.read(shoppingListCloudServiceProvider);
    _frigoService = ref.read(frigoFirestoreServiceProvider);
    _generateList();
  }

  Future<void> _generateList() async {
    setState(() => _isLoading = true);

    try {
      final items = await _generatorService.generateSmartList(
        sources: widget.selectedSources,
        startDate: widget.startDate,
        endDate: widget.endDate,
        subtractStock: widget.subtractStock,
      );

      setState(() {
        _items = items;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste de courses'),
        actions: [
          IconButton(
            icon: Icon(_viewByCategory ? Icons.view_list : Icons.category),
            onPressed: () => setState(() => _viewByCategory = !_viewByCategory),
            tooltip: _viewByCategory ? 'Vue liste' : 'Vue catégories',
          ),
        ],
      ),
      body: _isLoading ? _buildLoading() : _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _addManualItem,
        child: const Icon(Icons.add),
        tooltip: 'Ajouter un article',
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Génération de la liste...',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            '${widget.startDate.day}/${widget.startDate.month} → ${widget.endDate.day}/${widget.endDate.month}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_items.isEmpty) {
      return _buildEmptyState();
    }

    final activeItems = _items.where((item) => !item.isCompleted).toList();
    final completedItems = _items.where((item) => item.isCompleted).toList();

    return Column(
      children: [
        // Stats
        _buildStatsHeader(activeItems, completedItems),

        // Toggle complétés
        if (completedItems.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => setState(() => _showCompleted = !_showCompleted),
                  icon: Icon(_showCompleted ? Icons.visibility_off : Icons.visibility),
                  label: Text(
                    _showCompleted ? 'Masquer complétés' : 'Afficher complétés',
                  ),
                ),
              ],
            ),
          ),

        // Liste
        Expanded(
          child: _viewByCategory
              ? _buildCategoryView(activeItems, completedItems)
              : _buildListView(activeItems, completedItems),
        ),

        // Actions
        if (activeItems.isNotEmpty || completedItems.isNotEmpty)
          _buildActionButtons(activeItems, completedItems),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'Aucun article à acheter',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.subtractStock
                  ? 'Vous avez déjà tout en stock ! 🎉'
                  : 'Aucun repas planifié sur cette période',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _addManualItem,
              icon: const Icon(Icons.add),
              label: const Text('Ajouter un article'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFBBF24),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsHeader(
      List<ShoppingItemWithOrigin> active,
      List<ShoppingItemWithOrigin> completed,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFBBF24).withOpacity(0.1),
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatChip('À acheter', active.length.toString(), Colors.orange),
          _buildStatChip('Dans le panier', completed.length.toString(), Colors.green),
          _buildStatChip(
            'Total',
            (active.length + completed.length).toString(),
            const Color(0xFFFBBF24),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
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
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }

  // Suite dans partie 2...
// lib/screens/shopping_list_v2_screen.dart (PARTIE 2/3)
// Vues et interactions avec les items

  Widget _buildCategoryView(
      List<ShoppingItemWithOrigin> active,
      List<ShoppingItemWithOrigin> completed,
      ) {
    final activeGrouped = _groupByCategory(active);
    final sortedCategories = activeGrouped.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedCategories.length + (_showCompleted && completed.isNotEmpty ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < sortedCategories.length) {
          final category = sortedCategories[index];
          final items = activeGrouped[category]!;
          final info = ShoppingListCategoryHelper.getCategoryInfo(category);

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ExpansionTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: info.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(info.emoji, style: const TextStyle(fontSize: 24)),
              ),
              title: Text(
                category,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('${items.length} article(s)'),
              initiallyExpanded: true,
              children: items.map((item) => _buildItemTile(item)).toList(),
            ),
          );
        } else {
          // Section complétés
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ExpansionTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.check_circle, color: Colors.green),
              ),
              title: const Text(
                'Dans le panier',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('${completed.length} article(s)'),
              initiallyExpanded: false,
              children: completed.map((item) => _buildItemTile(item)).toList(),
            ),
          );
        }
      },
    );
  }

  Widget _buildListView(
      List<ShoppingItemWithOrigin> active,
      List<ShoppingItemWithOrigin> completed,
      ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (active.isNotEmpty) ...[
          const Text(
            'À acheter',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...active.map((item) => _buildItemTile(item)),
        ],
        if (_showCompleted && completed.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text(
            'Dans le panier',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...completed.map((item) => _buildItemTile(item)),
        ],
      ],
    );
  }

  Widget _buildItemTile(ShoppingItemWithOrigin item) {
    final categoryInfo = item.category != null
        ? ShoppingListCategoryHelper.getCategoryInfo(item.category!)
        : null;

    final destination = _itemDestinations[item.id] ?? 'frigo';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Checkbox(
          value: item.isCompleted,
          onChanged: (value) => _toggleItemStatus(item, value ?? false),
        ),
        title: Row(
          children: [
            if (categoryInfo != null) ...[
              Text(categoryInfo.emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                item.ingredientName,
                style: TextStyle(
                  decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                  color: item.isCompleted ? Colors.grey : null,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${item.totalQuantity.toStringAsFixed(item.totalQuantity % 1 == 0 ? 0 : 1)} ${item.unit}',
              style: TextStyle(
                color: item.isCompleted ? Colors.grey : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),

            // Répartition par source
            if (item.needsBySource.length > 1) ...[
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: item.needsBySource.entries.map((entry) {
                  final sourceName = _getSourceName(entry.key);
                  final sourceColor = _getSourceColor(entry.key);
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: sourceColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: sourceColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      '$sourceName: ${entry.value.toStringAsFixed(0)}g',
                      style: TextStyle(
                        fontSize: 10,
                        color: sourceColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],

            // Destination si complété
            if (item.isCompleted) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    _getDestinationIcon(destination),
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    destination,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: item.isCompleted
            ? PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'destination',
              child: Text('Changer destination'),
            ),
            const PopupMenuItem(
              value: 'uncomplete',
              child: Text('Remettre à acheter'),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Supprimer'),
            ),
          ],
          onSelected: (value) {
            if (value == 'destination') _changeDestination(item);
            if (value == 'uncomplete') _toggleItemStatus(item, false);
            if (value == 'delete') _deleteItem(item);
          },
        )
            : IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () => _showItemOptions(item),
        ),
        onTap: item.isCompleted
            ? null
            : () => _showCompletionDialog(item),
      ),
    );
  }

  Map<String, List<ShoppingItemWithOrigin>> _groupByCategory(
      List<ShoppingItemWithOrigin> items,
      ) {
    final grouped = <String, List<ShoppingItemWithOrigin>>{};
    for (final item in items) {
      final category = item.category ?? 'Autre';
      grouped.putIfAbsent(category, () => []).add(item);
    }
    return grouped;
  }

  String _getSourceName(String sourceId) {
    if (sourceId == 'private') return 'Privé';
    final group = widget.selectedSources
        .where((s) => s == sourceId)
        .firstOrNull;
    return group != null ? 'Groupe' : sourceId;
  }

  Color _getSourceColor(String sourceId) {
    return sourceId == 'private'
        ? const Color(0xFF3B82F6)
        : const Color(0xFF10B981);
  }

  IconData _getDestinationIcon(String destination) {
    switch (destination) {
      case 'frigo':
        return Icons.ac_unit;
      case 'congélateur':
        return Icons.severe_cold;
      case 'placard':
        return Icons.door_sliding;
      default:
        return Icons.kitchen;
    }
  }

  void _showCompletionDialog(ShoppingItemWithOrigin item) {
    String destination = _itemDestinations[item.id] ?? 'frigo';

    showDialog(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c2, setDialogState) => AlertDialog(
          title: Text('Mettre "${item.ingredientName}" dans le panier'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Où allez-vous ranger cet article ?'),
              const SizedBox(height: 16),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'frigo',
                    label: Text('🧊 Frigo'),
                  ),
                  ButtonSegment(
                    value: 'placard',
                    label: Text('📦 Placard'),
                  ),
                  ButtonSegment(
                    value: 'congélateur',
                    label: Text('❄️ Congélateur'),
                  ),
                ],
                selected: {destination},
                onSelectionChanged: (Set<String> newSelection) {
                  setDialogState(() => destination = newSelection.first);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                _itemDestinations[item.id] = destination;
                _toggleItemStatus(item, true);
                Navigator.pop(c);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
              ),
              child: const Text('Valider'),
            ),
          ],
        ),
      ),
    );
  }

  void _changeDestination(ShoppingItemWithOrigin item) {
    String destination = _itemDestinations[item.id] ?? 'frigo';

    showDialog(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c2, setDialogState) => AlertDialog(
          title: const Text('Changer la destination'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'frigo', label: Text('🧊 Frigo')),
                  ButtonSegment(value: 'placard', label: Text('📦 Placard')),
                  ButtonSegment(value: 'congélateur', label: Text('❄️ Congélateur')),
                ],
                selected: {destination},
                onSelectionChanged: (Set<String> newSelection) {
                  setDialogState(() => destination = newSelection.first);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() => _itemDestinations[item.id] = destination);
                Navigator.pop(c);
              },
              child: const Text('Valider'),
            ),
          ],
        ),
      ),
    );
  }

// Suite dans partie 3...
// lib/screens/shopping_list_v2_screen.dart (PARTIE 3/3)
// Actions et mise en stock intelligente

  void _showItemOptions(ShoppingItemWithOrigin item) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Modifier la quantité'),
              onTap: () {
                Navigator.pop(context);
                _editQuantity(item);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Supprimer', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deleteItem(item);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editQuantity(ShoppingItemWithOrigin item) async {
    final controller = TextEditingController(
      text: item.totalQuantity.toStringAsFixed(item.totalQuantity % 1 == 0 ? 0 : 1),
    );

    final result = await showDialog<double>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Modifier "${item.ingredientName}"'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Quantité (${item.unit})',
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = double.tryParse(controller.text);
              Navigator.pop(c, value);
            },
            child: const Text('Valider'),
          ),
        ],
      ),
    );

    if (result != null && result > 0) {
      setState(() {
        final index = _items.indexWhere((i) => i.id == item.id);
        if (index != -1) {
          _items[index] = item.copyWith(totalQuantity: result);
        }
      });
    }
  }

  void _toggleItemStatus(ShoppingItemWithOrigin item, bool isCompleted) {
    setState(() {
      final index = _items.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        _items[index] = item.copyWith(isCompleted: isCompleted);
      }
    });
  }

  void _deleteItem(ShoppingItemWithOrigin item) {
    setState(() {
      _items.removeWhere((i) => i.id == item.id);
    });
  }

  Widget _buildActionButtons(
      List<ShoppingItemWithOrigin> active,
      List<ShoppingItemWithOrigin> completed,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            if (completed.isNotEmpty)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _addToStock(completed),
                  icon: const Icon(Icons.kitchen_rounded),
                  label: Text('Mettre en stock (${completed.length})'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            if (completed.isNotEmpty) const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: active.isEmpty
                        ? null
                        : () => _selectAll(active),
                    icon: const Icon(Icons.select_all),
                    label: const Text('Tout cocher'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: completed.isEmpty
                        ? null
                        : () => _clearCompleted(),
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Effacer panier'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _selectAll(List<ShoppingItemWithOrigin> active) {
    // Afficher un dialog pour sélectionner la destination par défaut
    String defaultDestination = 'frigo';

    showDialog(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c2, setDialogState) => AlertDialog(
          title: const Text('Tout mettre dans le panier'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Destination par défaut :'),
              const SizedBox(height: 16),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'frigo', label: Text('🧊 Frigo')),
                  ButtonSegment(value: 'placard', label: Text('📦 Placard')),
                  ButtonSegment(value: 'congélateur', label: Text('❄️ Congélateur')),
                ],
                selected: {defaultDestination},
                onSelectionChanged: (Set<String> newSelection) {
                  setDialogState(() => defaultDestination = newSelection.first);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  for (final item in active) {
                    _itemDestinations[item.id] = defaultDestination;
                    final index = _items.indexWhere((i) => i.id == item.id);
                    if (index != -1) {
                      _items[index] = item.copyWith(isCompleted: true);
                    }
                  }
                });
                Navigator.pop(c);
              },
              child: const Text('Valider'),
            ),
          ],
        ),
      ),
    );
  }

  void _clearCompleted() {
    setState(() {
      _items.removeWhere((item) => item.isCompleted);
      _itemDestinations.clear();
    });
  }

  // ========================================================================
  // MISE EN STOCK INTELLIGENTE
  // ========================================================================

  Future<void> _addToStock(List<ShoppingItemWithOrigin> completedItems) async {
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
    int errorCount = 0;

    for (final item in completedItems) {
      try {
        final destination = _itemDestinations[item.id] ?? 'frigo';

        // Pour chaque source, ajouter la quantité correspondante
        for (final entry in item.needsBySource.entries) {
          final sourceId = entry.key;
          final quantityGrams = entry.value;

          // Convertir en unité appropriée
          final displayQuantity = quantityGrams / 1000;
          final displayUnit = displayQuantity >= 1 ? 'kg' : 'g';
          final finalQuantity = displayQuantity >= 1 ? displayQuantity : quantityGrams;

          // Déterminer la visibilité
          final visibility = sourceId == 'private'
              ? FrigoVisibility.private
              : FrigoVisibility.group;
          final groupId = sourceId == 'private' ? null : sourceId;

          await _frigoService.addToFrigo(
            ingredientId: item.ingredientId,
            ingredientName: item.ingredientName,
            quantity: finalQuantity,
            unit: displayUnit,
            location: destination,
            bestBefore: null,
            visibility: visibility,
            groupId: groupId,
            caloriesPer100g: item.caloriesPer100g ?? 0,
            proteinsPer100g: item.proteinsPer100g ?? 0,
            fatsPer100g: item.fatsPer100g ?? 0,
            carbsPer100g: item.carbsPer100g ?? 0,
            fibersPer100g: item.fibersPer100g ?? 0,
            densityGPerMl: item.densityGPerMl,
            avgWeightPerUnitG: item.avgWeightPerUnitG,
          );
        }

        addedCount++;
      } catch (e) {
        print('❌ Erreur ajout au stock: $e');
        errorCount++;
      }
    }

    // Fermer le loading
    if (mounted) {
      Navigator.pop(context);
    }

    // Supprimer les items mis en stock
    setState(() {
      _items.removeWhere((item) => completedItems.contains(item));
      for (final item in completedItems) {
        _itemDestinations.remove(item.id);
      }
    });

    // Afficher le résultat
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            addedCount > 0
                ? '✅ $addedCount article(s) ajouté(s) au stock !'
                : '⚠️ Aucun article ajouté',
          ),
          backgroundColor: addedCount > 0 ? Colors.green : Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // ========================================================================
  // AJOUT MANUEL AVEC SCAN
  // ========================================================================

  Future<void> _addManualItem() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Saisir manuellement'),
                onTap: () {
                  Navigator.pop(context);
                  _showManualAddDialog();
                },
              ),
              ListTile(
                leading: const Icon(Icons.qr_code_scanner),
                title: const Text('Scanner un code-barres'),
                onTap: () {
                  Navigator.pop(context);
                  _scanBarcode();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showManualAddDialog() async {
    final nameCtrl = TextEditingController();
    final quantityCtrl = TextEditingController(text: '1');
    String unit = 'unité';

    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Ajouter un article'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Nom',
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
                    value: unit,
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
                    onChanged: (v) => unit = v!,
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
    );

    if (ok == true && nameCtrl.text.isNotEmpty) {
      final quantity = double.tryParse(quantityCtrl.text) ?? 1.0;
      // TODO: Ajouter à la liste
    }
  }

  Future<void> _scanBarcode() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => const ScanForShoppingScreen(),
      ),
    );

    if (result != null && mounted) {
      final ingredient = result['ingredient'] as IngredientFirestore;
      final quantity = result['quantity'] as double;
      final unit = result['unit'] as String;

      // Convertir en grammes pour la cohérence
      final gramsQuantity = UnitConverter.toGrams(
        quantity: quantity,
        unit: unit,
        weightPerPieceGrams: ingredient.avgWeightPerUnitG,
        densityGramsPerMl: ingredient.densityGPerMl ?? 1.0,
      );

      // Créer un nouvel item
      final newItem = ShoppingItemWithOrigin(
        id: ingredient.id,
        ingredientId: ingredient.id,
        ingredientName: ingredient.name,
        totalQuantity: quantity,
        unit: unit,
        category: ingredient.category,
        needsBySource: {'private': gramsQuantity}, // Par défaut en privé
        caloriesPer100g: ingredient.caloriesPer100g,
        proteinsPer100g: ingredient.proteinsPer100g,
        fatsPer100g: ingredient.fatsPer100g,
        carbsPer100g: ingredient.carbsPer100g,
        fibersPer100g: ingredient.fibersPer100g,
        densityGPerMl: ingredient.densityGPerMl,
        avgWeightPerUnitG: ingredient.avgWeightPerUnitG,
      );

      setState(() {
        // Vérifier si l'item existe déjà
        final existingIndex = _items.indexWhere((i) => i.ingredientId == ingredient.id);
        if (existingIndex != -1) {
          // Mettre à jour la quantité
          final existing = _items[existingIndex];
          _items[existingIndex] = existing.copyWith(
            totalQuantity: existing.totalQuantity + quantity,
          );
        } else {
          // Ajouter le nouvel item
          _items.add(newItem);
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ ${ingredient.name} ajouté à la liste'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}