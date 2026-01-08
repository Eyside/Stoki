// lib/screens/shopping_list_screen_new.dart (PARTIE 1/4 - CORRIGÉ)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database.dart';
import '../models/shopping_list_firestore.dart';
import '../providers.dart';
import '../repositories/shopping_list_repository.dart';
import '../repositories/frigo_repository.dart';
import '../services/shopping_list_cloud_service.dart';
import '../services/shopping_list_generator_service.dart';
import '../services/group_service.dart';
import '../services/auth_service.dart';
import '../utils/shopping_list_category_helper.dart';
import '../models/frigo_firestore.dart'; // ✅ Pour FrigoVisibility
import '../services/frigo_firestore_service.dart'; // ✅ Pour le service cloud


/// Options de source pour la liste de courses
class ShoppingSourceOption {
  final ShoppingListSource type;
  final String label;
  final IconData icon;
  final String? groupId;
  final String? groupName;

  ShoppingSourceOption({
    required this.type,
    required this.label,
    required this.icon,
    this.groupId,
    this.groupName,
  });
}

class ShoppingListScreenNew extends ConsumerStatefulWidget {
  const ShoppingListScreenNew({super.key});

  @override
  ConsumerState<ShoppingListScreenNew> createState() => _ShoppingListScreenNewState();
}

class _ShoppingListScreenNewState extends ConsumerState<ShoppingListScreenNew> {
  final _authService = AuthService();
  final _groupService = GroupService();

  late ShoppingListCloudService _cloudService;
  late ShoppingListGeneratorService _generatorService;
  late ShoppingListRepository _localRepo;
  late FrigoRepository _frigoRepo;

  List<ShoppingSourceOption> _sourceOptions = [];
  ShoppingSourceOption? _selectedSource;
  List<Map<String, dynamic>> _userGroups = [];

  bool _showCompleted = false;
  bool _viewByCategory = true;

  @override
  void initState() {
    super.initState();
    final db = ref.read(databaseProvider);
    _cloudService = ShoppingListCloudService();
    _generatorService = ref.read(shoppingListGeneratorServiceProvider);
    _localRepo = ShoppingListRepository(db);
    _frigoRepo = ref.read(frigoRepositoryProvider);
    _loadSourceOptions();
  }

  Future<void> _loadSourceOptions() async {
    final userId = _authService.currentUser?.uid;

    final options = <ShoppingSourceOption>[
      ShoppingSourceOption(
        type: ShoppingListSource.all,
        label: 'Tout',
        icon: Icons.all_inclusive,
      ),
      ShoppingSourceOption(
        type: ShoppingListSource.local,
        label: 'Local',
        icon: Icons.phone_android,
      ),
    ];

    if (userId != null) {
      options.add(ShoppingSourceOption(
        type: ShoppingListSource.private,
        label: 'Cloud privé',
        icon: Icons.cloud,
      ));

      _groupService.getUserGroups(userId).listen((groups) {
        if (mounted) {
          setState(() {
            _userGroups = groups;
            _buildSourceOptions();
          });
        }
      });
    }

    setState(() {
      _sourceOptions = options;
      _selectedSource = options.first;
    });
  }

  void _buildSourceOptions() {
    final userId = _authService.currentUser?.uid;

    final options = <ShoppingSourceOption>[
      ShoppingSourceOption(
        type: ShoppingListSource.all,
        label: 'Tout',
        icon: Icons.all_inclusive,
      ),
      ShoppingSourceOption(
        type: ShoppingListSource.local,
        label: 'Local',
        icon: Icons.phone_android,
      ),
    ];

    if (userId != null) {
      options.add(ShoppingSourceOption(
        type: ShoppingListSource.private,
        label: 'Cloud privé',
        icon: Icons.cloud,
      ));

      for (final group in _userGroups) {
        options.add(ShoppingSourceOption(
          type: ShoppingListSource.group,
          label: group['name'] ?? 'Groupe',
          icon: Icons.group,
          groupId: group['id'],
          groupName: group['name'],
        ));
      }
    }

    setState(() {
      _sourceOptions = options;
      if (_selectedSource == null ||
          !options.any((opt) => opt.type == _selectedSource!.type &&
              opt.groupId == _selectedSource!.groupId)) {
        _selectedSource = options.first;
      }
    });
  }

  void _showSourceMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.filter_list),
                  const SizedBox(width: 12),
                  const Text(
                    'Filtrer la liste',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _sourceOptions.length,
                itemBuilder: (context, index) {
                  final option = _sourceOptions[index];
                  final isSelected = _selectedSource?.type == option.type &&
                      _selectedSource?.groupId == option.groupId;
                  return ListTile(
                    leading: Icon(
                      option.icon,
                      color: isSelected ? Colors.green : null,
                    ),
                    title: Text(
                      option.label,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.green : null,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check, color: Colors.green)
                        : null,
                    onTap: () {
                      setState(() => _selectedSource = option);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedSource == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Liste de courses'),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _selectedSource!.icon,
                    size: 14,
                    color: Colors.green.shade700,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _selectedSource!.label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(_viewByCategory ? Icons.view_list : Icons.category),
            onPressed: () {
              setState(() => _viewByCategory = !_viewByCategory);
            },
            tooltip: _viewByCategory ? 'Vue liste' : 'Vue catégories',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showSourceMenu,
            tooltip: 'Filtrer',
          ),
        ],
      ),
      body: _buildBody(),
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

// Suite dans partie 2...
// lib/screens/shopping_list_screen_new.dart (PARTIE 2/4 - CORRIGÉ)
// Cette partie continue directement après la Partie 1

  Widget _buildBody() {
    return FutureBuilder<List<ShoppingListFirestore>>(
      future: _loadAllItems(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Erreur: ${snapshot.error}'),
              ],
            ),
          );
        }

        final allItems = snapshot.data ?? [];

        if (allItems.isEmpty) {
          return _buildEmptyState();
        }

        final activeItems = allItems.where((item) =>
        item.status == ShoppingStatus.pending
        ).toList();

        final completedItems = allItems.where((item) =>
        item.status == ShoppingStatus.completed ||
            item.status == ShoppingStatus.stored
        ).toList();

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

            // Liste
            Expanded(
              child: _viewByCategory
                  ? _buildCategoryView(activeItems, completedItems)
                  : _buildListView(activeItems, completedItems),
            ),

            // Actions
            if (allItems.isNotEmpty) _buildActionButtons(completedItems),
          ],
        );
      },
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
            'Liste vide',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey),
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

  Widget _buildStatsHeader(
      List<ShoppingListFirestore> active,
      List<ShoppingListFirestore> completed,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.green.shade50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatChip('À acheter', active.length.toString(), Colors.orange),
          _buildStatChip('Complétés', completed.length.toString(), Colors.green),
          _buildStatChip('Total', (active.length + completed.length).toString(), Colors.blue),
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

  Widget _buildCategoryView(
      List<ShoppingListFirestore> active,
      List<ShoppingListFirestore> completed,
      ) {
    final activeGrouped = ShoppingListCategoryHelper.groupByCategory(active);
    final sortedCategories = ShoppingListCategoryHelper.getSortedCategoryNames(activeGrouped);

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
                'Complétés',
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
      List<ShoppingListFirestore> active,
      List<ShoppingListFirestore> completed,
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
            'Complétés',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...completed.map((item) => _buildItemTile(item)),
        ],
      ],
    );
  }

  Widget _buildItemTile(ShoppingListFirestore item) {
    final isCompleted = item.status == ShoppingStatus.completed ||
        item.status == ShoppingStatus.stored;
    final displayName = item.ingredientName ?? item.customName ?? 'Article';
    final categoryInfo = item.category != null
        ? ShoppingListCategoryHelper.getCategoryInfo(item.category!)
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Checkbox(
          value: isCompleted,
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
                displayName,
                style: TextStyle(
                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                  color: isCompleted ? Colors.grey : null,
                ),
              ),
            ),
          ],
        ),
        subtitle: Row(
          children: [
            Text(
              '${item.quantity.toStringAsFixed(item.quantity % 1 == 0 ? 0 : 1)} ${item.unit}',
              style: TextStyle(color: isCompleted ? Colors.grey : Colors.black54),
            ),
            const SizedBox(width: 8),
            if (item.isAutoGenerated)
              const Tooltip(
                message: 'Généré automatiquement',
                child: Icon(Icons.auto_awesome, color: Colors.blue, size: 14),
              ),
            if (item.visibility == ShoppingVisibility.group)
              const Tooltip(
                message: 'Partagé avec le groupe',
                child: Icon(Icons.group, color: Colors.green, size: 14),
              ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('Modifier')),
            const PopupMenuItem(value: 'delete', child: Text('Supprimer')),
          ],
          onSelected: (value) {
            if (value == 'edit') _editItem(item);
            if (value == 'delete') _deleteItem(item);
          },
        ),
      ),
    );
  }

  Widget _buildActionButtons(List<ShoppingListFirestore> completed) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (completed.isNotEmpty)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _addCompletedToFrigo(completed),
                icon: const Icon(Icons.kitchen),
                label: const Text('Ajouter les complétés au frigo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          if (completed.isNotEmpty) const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: completed.isEmpty ? null : _clearCompleted,
                  icon: const Icon(Icons.delete_sweep),
                  label: const Text('Supprimer complétés'),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
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
    );
  }

// Suite dans partie 3...
// lib/screens/shopping_list_screen_new.dart (PARTIE 3/4 - CORRIGÉ)

  // ============================================================================
  // CHARGEMENT DES DONNÉES
  // ============================================================================

  Future<List<ShoppingListFirestore>> _loadAllItems() async {
    final List<ShoppingListFirestore> allItems = [];

    // Charger selon la source sélectionnée
    if (_selectedSource!.type == ShoppingListSource.local) {
      // Local uniquement
      final localItems = await _localRepo.getAllShoppingList();
      for (final item in localItems) {
        allItems.add(ShoppingListFirestore(
          id: item.id.toString(),
          ownerId: '',
          ingredientId: item.ingredientId?.toString(),
          ingredientName: null,
          customName: item.customName,
          quantity: item.quantity,
          unit: item.unit,
          category: null,
          status: item.isChecked ? ShoppingStatus.completed : ShoppingStatus.pending,
          storageLocation: null,
          isAutoGenerated: item.isAutoGenerated,
          visibility: ShoppingVisibility.local,
          groupId: null,
          caloriesPer100g: null,
          proteinsPer100g: null,
          fatsPer100g: null,
          carbsPer100g: null,
          fibersPer100g: null,
          densityGPerMl: null,
          avgWeightPerUnitG: null,
          createdAt: item.createdAt ?? DateTime.now(),
          updatedAt: DateTime.now(),
        ));
      }
    } else if (_selectedSource!.type == ShoppingListSource.private) {
      // Cloud privé uniquement
      final cloudItems = await _cloudService.getMyShoppingList().first;
      allItems.addAll(cloudItems);
    } else if (_selectedSource!.type == ShoppingListSource.group && _selectedSource!.groupId != null) {
      // Groupe spécifique
      final groupItems = await _cloudService.getGroupShoppingList(_selectedSource!.groupId!).first;
      allItems.addAll(groupItems);
    } else {
      // Tout (local + cloud)
      final localItems = await _localRepo.getAllShoppingList();
      for (final item in localItems) {
        allItems.add(ShoppingListFirestore(
          id: item.id.toString(),
          ownerId: '',
          ingredientId: item.ingredientId?.toString(),
          ingredientName: null,
          customName: item.customName,
          quantity: item.quantity,
          unit: item.unit,
          category: null,
          status: item.isChecked ? ShoppingStatus.completed : ShoppingStatus.pending,
          storageLocation: null,
          isAutoGenerated: item.isAutoGenerated,
          visibility: ShoppingVisibility.local,
          groupId: null,
          caloriesPer100g: null,
          proteinsPer100g: null,
          fatsPer100g: null,
          carbsPer100g: null,
          fibersPer100g: null,
          densityGPerMl: null,
          avgWeightPerUnitG: null,
          createdAt: item.createdAt ?? DateTime.now(),
          updatedAt: DateTime.now(),
        ));
      }

      if (_authService.currentUser != null) {
        try {
          final cloudItems = await _cloudService.getAllMyLists().first;
          allItems.addAll(cloudItems);
        } catch (e) {
          print('⚠️ Erreur chargement cloud: $e');
        }
      }
    }

    return allItems;
  }

  // ============================================================================
  // ACTIONS SUR LES ARTICLES
  // ============================================================================

  Future<void> _toggleItemStatus(ShoppingListFirestore item, bool isCompleted) async {
    final newStatus = isCompleted ? ShoppingStatus.completed : ShoppingStatus.pending;

    if (item.visibility == ShoppingVisibility.local) {
      // Local
      await _localRepo.toggleChecked(int.parse(item.id), isCompleted);
    } else {
      // Cloud
      await _cloudService.updateItemStatus(
        itemId: item.id,
        status: newStatus,
      );
    }

    setState(() {});
  }

  Future<void> _editItem(ShoppingListFirestore item) async {
    final quantityCtrl = TextEditingController(text: item.quantity.toString());
    String unit = item.unit;
    String? category = item.category;

    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c2, setDialogState) => AlertDialog(
          title: const Text('Modifier l\'article'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                      onChanged: (v) => setDialogState(() => unit = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: category,
                decoration: const InputDecoration(
                  labelText: 'Catégorie',
                  border: OutlineInputBorder(),
                ),
                items: ShoppingListCategoryHelper.categories.keys
                    .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (v) => setDialogState(() => category = v),
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
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );

    if (ok == true) {
      final quantity = double.tryParse(quantityCtrl.text.trim()) ?? item.quantity;

      if (item.visibility == ShoppingVisibility.local) {
        // Local: pas de support catégorie
        // On ne peut pas modifier facilement, juste recréer
      } else {
        // Cloud
        await _cloudService.updateItem(
          itemId: item.id,
          quantity: quantity,
          unit: unit,
          category: category,
        );
      }

      setState(() {});
    }
  }

  Future<void> _deleteItem(ShoppingListFirestore item) async {
    final displayName = item.ingredientName ?? item.customName ?? 'Article';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Supprimer cet article ?'),
        content: Text('Voulez-vous supprimer "$displayName" ?'),
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
      if (item.visibility == ShoppingVisibility.local) {
        await _localRepo.deleteItem(int.parse(item.id));
      } else {
        await _cloudService.deleteItem(item.id);
      }

      setState(() {});
    }
  }

  // ============================================================================
  // ACTIONS GLOBALES
  // ============================================================================

  Future<void> _clearCompleted() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Supprimer les complétés ?'),
        content: const Text('Voulez-vous supprimer tous les articles complétés ?'),
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
      if (_selectedSource!.type == ShoppingListSource.local) {
        await _localRepo.clearChecked();
      } else {
        await _cloudService.clearCompleted();
      }

      setState(() {});
    }
  }

  Future<void> _clearAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Tout supprimer ?'),
        content: const Text('Voulez-vous supprimer TOUS les articles ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(c, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Tout supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (_selectedSource!.type == ShoppingListSource.local) {
        await _localRepo.clearAll();
      } else if (_selectedSource!.type == ShoppingListSource.group && _selectedSource!.groupId != null) {
        await _cloudService.clearGroupList(_selectedSource!.groupId!);
      } else {
        await _cloudService.clearAll();
      }

      setState(() {});
    }
  }

  Future<void> _addCompletedToFrigo(List<ShoppingListFirestore> completed) async {
    String location = 'frigo';

    // ✅ AUTO-DÉTECTION de la visibilité et du groupe
    // On utilise la source actuellement sélectionnée dans la liste de courses
    final FrigoVisibility visibility = _selectedSource!.type == ShoppingListSource.group
        ? FrigoVisibility.group
        : FrigoVisibility.private;

    final String? targetGroupId = _selectedSource!.type == ShoppingListSource.group
        ? _selectedSource!.groupId
        : null;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c2, setDialogState) => AlertDialog(
          title: const Text('Ajouter au stock'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Info sur la destination
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: visibility == FrigoVisibility.private
                      ? Colors.blue.shade50
                      : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: visibility == FrigoVisibility.private
                        ? Colors.blue.shade200
                        : Colors.green.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      visibility == FrigoVisibility.private
                          ? Icons.lock_rounded
                          : Icons.group_rounded,
                      color: visibility == FrigoVisibility.private
                          ? Colors.blue.shade700
                          : Colors.green.shade700,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            visibility == FrigoVisibility.private
                                ? 'Stock privé'
                                : 'Stock du groupe: ${_selectedSource!.groupName ?? "Groupe"}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: visibility == FrigoVisibility.private
                                  ? Colors.blue.shade900
                                  : Colors.green.shade900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${completed.length} article(s) seront ajoutés',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Sélection de l'emplacement
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Emplacement de stockage:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),

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
                    label: Text('❄️ Congél.'),
                  ),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: visibility == FrigoVisibility.private
                    ? Colors.blue
                    : Colors.green,
              ),
              child: const Text('Ajouter au stock'),
            ),
          ],
        ),
      ),
    );

    if (confirm != true) return;

    // ✅ AJOUT AU CLOUD avec auto-détection
    final frigoCloudService = ref.read(frigoFirestoreServiceProvider);
    int addedCount = 0;
    int skippedCount = 0;

    // Afficher un indicateur de chargement
    if (mounted) {
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
    }

    for (final item in completed) {
      try {
        // Ajouter au cloud avec la visibilité détectée automatiquement
        await frigoCloudService.addToFrigo(
          ingredientId: item.ingredientId ?? '',
          ingredientName: item.ingredientName ?? item.customName ?? 'Article',
          quantity: item.quantity,
          unit: item.unit,
          location: location,
          bestBefore: null, // Pas de date de péremption depuis la liste de courses
          visibility: visibility,
          groupId: targetGroupId,
          caloriesPer100g: item.caloriesPer100g ?? 0,
          proteinsPer100g: item.proteinsPer100g ?? 0,
          fatsPer100g: item.fatsPer100g ?? 0,
          carbsPer100g: item.carbsPer100g ?? 0,
          fibersPer100g: item.fibersPer100g ?? 0,
          densityGPerMl: item.densityGPerMl,
          avgWeightPerUnitG: item.avgWeightPerUnitG,
        );

        addedCount++;

        // Supprimer de la liste de courses
        if (item.visibility == ShoppingVisibility.local) {
          await _localRepo.deleteItem(int.parse(item.id));
        } else {
          await _cloudService.deleteItem(item.id);
        }
      } catch (e) {
        print('❌ Erreur ajout au frigo: $e');
        skippedCount++;
      }
    }

    // Fermer le loading
    if (mounted) {
      Navigator.pop(context);
    }

    // Afficher le résultat
    if (mounted) {
      final String destinationType = visibility == FrigoVisibility.private
          ? 'stock privé'
          : 'stock du groupe "${_selectedSource!.groupName}"';

      final message = addedCount > 0
          ? '✅ $addedCount article(s) ajouté(s) au $destinationType ($location) !'
          : '⚠️ Aucun article ajouté';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
              if (skippedCount > 0)
                Text(
                  '$skippedCount article(s) ignoré(s) (erreur)',
                  style: const TextStyle(fontSize: 12),
                ),
            ],
          ),
          backgroundColor: addedCount > 0 ? Colors.green : Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
      setState(() {});
    }
  }

// Suite dans partie 4...
// lib/screens/shopping_list_screen_new.dart (PARTIE 4/4 - CORRIGÉ)

  // ============================================================================
  // GÉNÉRATION DEPUIS LE PLANNING
  // ============================================================================
  Future<void> _generateFromPlanning() async {
    // Variables pour la configuration
    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime.now().add(const Duration(days: 7));
    ShoppingListSource? sourceType;
    String? groupId;
    bool subtractStock = true;

    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c2, setDialogState) => AlertDialog(
          title: const Text('Générer la liste'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Source
                const Text('Source du planning:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButtonFormField<ShoppingListSource>(
                  value: sourceType,
                  decoration: const InputDecoration(
                    labelText: 'Depuis quel planning ?',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: ShoppingListSource.local, child: Text('📱 Planning local')),
                    DropdownMenuItem(value: ShoppingListSource.private, child: Text('☁️ Planning cloud privé')),
                    DropdownMenuItem(value: ShoppingListSource.group, child: Text('👥 Planning d\'un groupe')),
                  ],
                  onChanged: (v) => setDialogState(() {
                    sourceType = v;
                    groupId = null;
                  }),
                ),

                // Groupe si nécessaire
                if (sourceType == ShoppingListSource.group) ...[
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: groupId,
                    decoration: const InputDecoration(
                      labelText: 'Groupe',
                      border: OutlineInputBorder(),
                    ),
                    items: _userGroups
                        .map((g) => DropdownMenuItem<String>(
                      value: g['id'],
                      child: Text(g['name'] ?? 'Groupe'),
                    ))
                        .toList(),
                    onChanged: (v) => setDialogState(() => groupId = v),
                  ),
                ],

                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),

                // ✅ NOUVELLE SECTION: Sélection des dates
                const Text('Période:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                // Date de début
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: c,
                      initialDate: startDate,
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      locale: const Locale('fr'),
                    );
                    if (picked != null) {
                      setDialogState(() {
                        startDate = picked;
                        // S'assurer que endDate >= startDate
                        if (endDate.isBefore(startDate)) {
                          endDate = startDate.add(const Duration(days: 7));
                        }
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date de début',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      _formatDate(startDate),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Date de fin
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: c,
                      initialDate: endDate,
                      firstDate: startDate,
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      locale: const Locale('fr'),
                    );
                    if (picked != null) {
                      setDialogState(() => endDate = picked);
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date de fin',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      _formatDate(endDate),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Info durée
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 16, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Période: ${endDate.difference(startDate).inDays + 1} jour(s)',
                          style: const TextStyle(fontSize: 12, color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Boutons rapides
                const Text('Raccourcis:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('Aujourd\'hui'),
                      selected: false,
                      onSelected: (_) => setDialogState(() {
                        startDate = DateTime.now();
                        endDate = DateTime.now();
                      }),
                    ),
                    FilterChip(
                      label: const Text('3 jours'),
                      selected: false,
                      onSelected: (_) => setDialogState(() {
                        startDate = DateTime.now();
                        endDate = DateTime.now().add(const Duration(days: 2));
                      }),
                    ),
                    FilterChip(
                      label: const Text('7 jours'),
                      selected: false,
                      onSelected: (_) => setDialogState(() {
                        startDate = DateTime.now();
                        endDate = DateTime.now().add(const Duration(days: 6));
                      }),
                    ),
                    FilterChip(
                      label: const Text('14 jours'),
                      selected: false,
                      onSelected: (_) => setDialogState(() {
                        startDate = DateTime.now();
                        endDate = DateTime.now().add(const Duration(days: 13));
                      }),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),

                // Options
                const Text('Options:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),

                Container(
                  decoration: BoxDecoration(
                    color: subtractStock ? Colors.green.shade50 : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: subtractStock ? Colors.green : Colors.orange,
                      width: 2,
                    ),
                  ),
                  child: SwitchListTile(
                    title: Text(
                      subtractStock ? 'Soustraire le stock ✅' : 'Liste complète (sans soustraction)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: subtractStock ? Colors.green.shade900 : Colors.orange.shade900,
                      ),
                    ),
                    subtitle: Text(
                      subtractStock
                          ? 'Le stock du frigo sera déduit de la liste'
                          : 'Tous les ingrédients seront ajoutés, même ceux en stock',
                      style: const TextStyle(fontSize: 12),
                    ),
                    value: subtractStock,
                    onChanged: (v) => setDialogState(() => subtractStock = v),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    activeColor: Colors.green,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: sourceType == null || (sourceType == ShoppingListSource.group && groupId == null)
                  ? null
                  : () => Navigator.pop(c, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                disabledBackgroundColor: Colors.grey,
              ),
              child: const Text('Générer'),
            ),
          ],
        ),
      ),
    );

    if (ok != true || sourceType == null) return;

    // Afficher chargement
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                const Text('Génération en cours...'),
                const SizedBox(height: 8),
                Text(
                  'Période: ${_formatDate(startDate)} → ${_formatDate(endDate)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  subtractStock ? 'Avec soustraction du stock' : 'Sans soustraction du stock',
                  style: TextStyle(
                    fontSize: 12,
                    color: subtractStock ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // Générer avec les nouvelles dates
      final items = await _generatorService.generateFromPlanning(
        startDate: startDate,
        endDate: endDate,
        source: sourceType!,
        groupId: groupId,
        subtractStock: subtractStock,
        runDiagnostic: true,
      );

      if (!mounted) return;
      Navigator.pop(context); // Fermer le loading

      if (items.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aucun article à ajouter !'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Ajouter selon la source sélectionnée
      final targetVisibility = _selectedSource!.type == ShoppingListSource.group
          ? ShoppingVisibility.group
          : _selectedSource!.type == ShoppingListSource.private
          ? ShoppingVisibility.private
          : ShoppingVisibility.local;

      int addedCount = 0;

      for (final item in items) {
        if (targetVisibility == ShoppingVisibility.local) {
          await _localRepo.addToShoppingList(
            ingredientId: int.tryParse(item['ingredientId'] ?? ''),
            customName: item['ingredientName'],
            quantity: item['quantity'] ?? 0,
            unit: item['unit'] ?? 'g',
            isAutoGenerated: true,
          );
        } else {
          await _cloudService.addToShoppingList(
            ingredientId: item['ingredientId'],
            ingredientName: item['ingredientName'],
            quantity: item['quantity'] ?? 0,
            unit: item['unit'] ?? 'g',
            category: item['category'],
            isAutoGenerated: true,
            visibility: targetVisibility,
            groupId: _selectedSource!.groupId,
            caloriesPer100g: item['caloriesPer100g'],
            proteinsPer100g: item['proteinsPer100g'],
            fatsPer100g: item['fatsPer100g'],
            carbsPer100g: item['carbsPer100g'],
            fibersPer100g: item['fibersPer100g'],
            densityGPerMl: item['densityGPerMl'],
            avgWeightPerUnitG: item['avgWeightPerUnitG'],
          );
        }
        addedCount++;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '✅ $addedCount article(s) ajouté(s) !',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Période: ${_formatDate(startDate)} → ${_formatDate(endDate)}',
                  style: const TextStyle(fontSize: 12),
                ),
                if (subtractStock)
                  const Text(
                    'Stock soustrait',
                    style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                  ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
        setState(() {});
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Fermer le loading

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  // ============================================================================
  // AJOUT MANUEL
  // ============================================================================

  Future<void> _addManualItem() async {
    final nameCtrl = TextEditingController();
    final quantityCtrl = TextEditingController(text: '1');
    String unit = 'unité';
    String? category;

    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c2, setDialogState) => AlertDialog(
          title: const Text('Ajouter un article'),
          content: SingleChildScrollView(
            child: Column(
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
                        onChanged: (v) => setDialogState(() => unit = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: category,
                  decoration: const InputDecoration(
                    labelText: 'Catégorie (optionnel)',
                    border: OutlineInputBorder(),
                  ),
                  items: ShoppingListCategoryHelper.categories.keys
                      .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                      .toList(),
                  onChanged: (v) => setDialogState(() => category = v),
                ),
              ],
            ),
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

      if (name.isEmpty) return;

      // CORRECTION LIGNE 681: Inférer la catégorie si non spécifiée
      if (category?.isEmpty ?? true) {
        category = ShoppingListCategoryHelper.inferCategory(name);
      }

      // Ajouter selon la source sélectionnée
      if (_selectedSource!.type == ShoppingListSource.local) {
        await _localRepo.addToShoppingList(
          customName: name,
          quantity: quantity,
          unit: unit,
          isAutoGenerated: false,
        );
      } else {
        final targetVisibility = _selectedSource!.type == ShoppingListSource.group
            ? ShoppingVisibility.group
            : ShoppingVisibility.private;

        await _cloudService.addToShoppingList(
          customName: name,
          quantity: quantity,
          unit: unit,
          category: category,
          isAutoGenerated: false,
          visibility: targetVisibility,
          groupId: _selectedSource!.groupId,
        );
      }

      setState(() {});
    }
  }

  // ============================================================================
  // HELPERS
  // ============================================================================

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
} // Fin de la classe _ShoppingListScreenNewState