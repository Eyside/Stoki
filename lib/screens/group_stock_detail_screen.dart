// lib/screens/group_stock_detail_screen.dart
import 'package:flutter/material.dart';
import '../services/frigo_firestore_service.dart';
import '../models/frigo_firestore.dart';

enum StockType {
  all,
  private,
  group,
}

class GroupStockDetailScreen extends StatefulWidget {
  final StockType stockType;
  final String? groupId;
  final String title;

  const GroupStockDetailScreen({
    super.key,
    required this.stockType,
    this.groupId,
    required this.title,
  });

  @override
  State<GroupStockDetailScreen> createState() => _GroupStockDetailScreenState();
}

class _GroupStockDetailScreenState extends State<GroupStockDetailScreen> {
  final _frigoService = FrigoFirestoreService();
  final _searchController = TextEditingController();

  String _searchQuery = '';
  String? _selectedLocation; // null = tous les emplacements

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        actions: [
          // Filtre par emplacement
          PopupMenuButton<String?>(
            icon: Icon(
              _selectedLocation != null ? Icons.filter_alt : Icons.filter_alt_outlined,
              color: _selectedLocation != null ? const Color(0xFF10B981) : const Color(0xFF64748B),
            ),
            tooltip: 'Filtrer par emplacement',
            onSelected: (value) {
              setState(() => _selectedLocation = value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Row(
                  children: [
                    Text('📍', style: TextStyle(fontSize: 20)),
                    SizedBox(width: 12),
                    Text('Tous les emplacements'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'frigo',
                child: Row(
                  children: [
                    Text('🧊', style: TextStyle(fontSize: 20)),
                    SizedBox(width: 12),
                    Text('Frigo'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'placard',
                child: Row(
                  children: [
                    Text('📦', style: TextStyle(fontSize: 20)),
                    SizedBox(width: 12),
                    Text('Placard'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'congélateur',
                child: Row(
                  children: [
                    Text('❄️', style: TextStyle(fontSize: 20)),
                    SizedBox(width: 12),
                    Text('Congélateur'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un produit...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _searchController.clear(),
                )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),

          // Liste des produits
          Expanded(
            child: StreamBuilder<List<FrigoFirestore>>(
              stream: _getStockStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return _buildErrorState(snapshot.error.toString());
                }

                var items = snapshot.data ?? [];

                // Filtrer par recherche
                if (_searchQuery.isNotEmpty) {
                  items = items.where((item) {
                    return item.ingredientName.toLowerCase().contains(_searchQuery);
                  }).toList();
                }

                // Filtrer par emplacement sélectionné
                if (_selectedLocation != null) {
                  items = items.where((item) => item.location == _selectedLocation).toList();
                }

                if (items.isEmpty) {
                  return _buildEmptyState();
                }

                // Grouper par emplacement
                final groupedItems = _groupByLocation(items);

                return ListView(
                  padding: const EdgeInsets.only(top: 8, bottom: 80),
                  children: [
                    // Afficher chaque section d'emplacement
                    if (groupedItems.containsKey('frigo'))
                      _buildLocationSection(
                        '🧊 Frigo',
                        groupedItems['frigo']!,
                        const Color(0xFFDCFCE7), // Vert pastel
                      ),
                    if (groupedItems.containsKey('placard'))
                      _buildLocationSection(
                        '📦 Placard',
                        groupedItems['placard']!,
                        const Color(0xFFFEF3C7), // Jaune pastel
                      ),
                    if (groupedItems.containsKey('congélateur'))
                      _buildLocationSection(
                        '❄️ Congélateur',
                        groupedItems['congélateur']!,
                        const Color(0xFFDBEAFE), // Bleu pastel
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addProduct,
        backgroundColor: const Color(0xFF10B981),
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
      ),
    );
  }

  // ============================================================================
  // CONSTRUCTION DES WIDGETS
  // ============================================================================

  Widget _buildLocationSection(String title, List<FrigoFirestore> items, Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header de section
        Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${items.length}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Liste des produits de cette section
        ...items.map((item) => _buildProductCard(item)),

        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildProductCard(FrigoFirestore item) {
    final expirationColor = _getExpirationColor(item.bestBefore);
    final daysUntilExpiration = item.bestBefore != null
        ? item.bestBefore!.difference(DateTime.now()).inDays
        : null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showProductDetails(item),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icône de visibilité (privé ou groupe)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: item.visibility == FrigoVisibility.private
                        ? const Color(0xFFE0F2FE)
                        : const Color(0xFFD1FAE5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    item.visibility == FrigoVisibility.private
                        ? Icons.lock_outline
                        : Icons.group_outlined,
                    size: 24,
                    color: item.visibility == FrigoVisibility.private
                        ? const Color(0xFF0284C7)
                        : const Color(0xFF059669),
                  ),
                ),
                const SizedBox(width: 16),

                // Informations du produit
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.ingredientName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          // Quantité
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${item.quantity.toStringAsFixed(item.quantity % 1 == 0 ? 0 : 1)} ${item.unit}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF475569),
                              ),
                            ),
                          ),

                          // Date de péremption si existe
                          if (item.bestBefore != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: expirationColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: expirationColor.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 12,
                                    color: expirationColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    daysUntilExpiration! < 0
                                        ? 'Périmé'
                                        : daysUntilExpiration == 0
                                        ? 'Aujourd\'hui'
                                        : '$daysUntilExpiration j',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: expirationColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Bouton de suppression
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
                  onPressed: () => _deleteProduct(item),
                  tooltip: 'Supprimer',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                size: 64,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Stock vide',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Aucun produit trouvé'
                  : 'Ajoutez des produits pour commencer',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Color(0xFFEF4444)),
            const SizedBox(height: 16),
            const Text(
              'Erreur de chargement',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // LOGIQUE
  // ============================================================================

  Stream<List<FrigoFirestore>> _getStockStream() {
    switch (widget.stockType) {
      case StockType.all:
        return _frigoService.getAllMyStocks();
      case StockType.private:
        return _frigoService.getMyStock().map((items) {
          return items.where((item) => item.visibility == FrigoVisibility.private).toList();
        });
      case StockType.group:
        if (widget.groupId != null) {
          return _frigoService.getGroupStock(widget.groupId!);
        }
        return Stream.value([]);
    }
  }

  Map<String, List<FrigoFirestore>> _groupByLocation(List<FrigoFirestore> items) {
    final map = <String, List<FrigoFirestore>>{};

    for (final item in items) {
      if (!map.containsKey(item.location)) {
        map[item.location] = [];
      }
      map[item.location]!.add(item);
    }

    // Trier les éléments de chaque groupe par date de péremption
    for (final list in map.values) {
      list.sort((a, b) {
        if (a.bestBefore == null && b.bestBefore == null) return 0;
        if (a.bestBefore == null) return 1;
        if (b.bestBefore == null) return -1;
        return a.bestBefore!.compareTo(b.bestBefore!);
      });
    }

    return map;
  }

  Color _getExpirationColor(DateTime? bestBefore) {
    if (bestBefore == null) return const Color(0xFF94A3B8);

    final days = bestBefore.difference(DateTime.now()).inDays;
    if (days < 0) return const Color(0xFFEF4444); // Rouge - périmé
    if (days <= 3) return const Color(0xFFF97316); // Orange - urgent
    if (days <= 7) return const Color(0xFFFBBF24); // Jaune - bientôt
    return const Color(0xFF10B981); // Vert - ok
  }

  // ============================================================================
  // ACTIONS
  // ============================================================================

  void _showProductDetails(FrigoFirestore item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Barre de poignée
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Titre
            Text(
              item.ingredientName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 20),

            // Informations
            _buildDetailRow('📍 Emplacement', _getLocationLabel(item.location)),
            _buildDetailRow('📊 Quantité', '${item.quantity} ${item.unit}'),
            if (item.bestBefore != null)
              _buildDetailRow(
                '📅 Date de péremption',
                _formatDate(item.bestBefore!),
              ),
            _buildDetailRow(
              '👁️ Visibilité',
              item.visibility == FrigoVisibility.private ? 'Privé' : 'Groupe',
            ),
            _buildDetailRow('🔥 Calories', '${item.caloriesPer100g.toStringAsFixed(0)} kcal/100g'),

            const SizedBox(height: 24),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _editProduct(item);
                    },
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Modifier'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _deleteProduct(item);
                    },
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Supprimer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addProduct() async {
    final nameCtrl = TextEditingController();
    final quantityCtrl = TextEditingController(text: '1');
    final caloriesCtrl = TextEditingController();

    String unit = 'unité';
    String location = 'frigo';
    DateTime? bestBefore;

    // Déterminer la visibilité par défaut selon le type de stock
    FrigoVisibility visibility = widget.stockType == StockType.group
        ? FrigoVisibility.group
        : FrigoVisibility.private;

    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c2, setDialogState) => AlertDialog(
          title: const Text('Ajouter un produit'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Nom du produit
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nom du produit *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.shopping_basket),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),

                // Quantité et unité
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: quantityCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Quantité *',
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
                const SizedBox(height: 16),

                // Emplacement
                DropdownButtonFormField<String>(
                  value: location,
                  decoration: const InputDecoration(
                    labelText: 'Emplacement *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.place),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'frigo',
                      child: Row(
                        children: [
                          Text('🧊', style: TextStyle(fontSize: 20)),
                          SizedBox(width: 8),
                          Text('Frigo'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'placard',
                      child: Row(
                        children: [
                          Text('📦', style: TextStyle(fontSize: 20)),
                          SizedBox(width: 8),
                          Text('Placard'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'congélateur',
                      child: Row(
                        children: [
                          Text('❄️', style: TextStyle(fontSize: 20)),
                          SizedBox(width: 8),
                          Text('Congélateur'),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (v) => setDialogState(() => location = v!),
                ),
                const SizedBox(height: 16),

                // Date de péremption
                OutlinedButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: c,
                      initialDate: DateTime.now().add(const Duration(days: 7)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                      locale: const Locale('fr'),
                    );
                    if (picked != null) {
                      setDialogState(() => bestBefore = picked);
                    }
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    bestBefore == null
                        ? 'Date de péremption (optionnel)'
                        : 'DLC: ${bestBefore!.day}/${bestBefore!.month}/${bestBefore!.year}',
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                if (bestBefore != null) ...[
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => setDialogState(() => bestBefore = null),
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('Retirer la date'),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                  ),
                ],
                const SizedBox(height: 16),

                // Calories
                TextField(
                  controller: caloriesCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Calories (kcal/100g)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.local_fire_department),
                    hintText: '0',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 16),

                // Visibilité (si applicable)
                if (widget.stockType == StockType.all) ...[
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text(
                    'Visibilité',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  RadioListTile<FrigoVisibility>(
                    title: const Text('Stock privé'),
                    subtitle: const Text('Visible uniquement par vous'),
                    value: FrigoVisibility.private,
                    groupValue: visibility,
                    onChanged: (v) => setDialogState(() => visibility = v!),
                    secondary: const Icon(Icons.lock_outline),
                  ),
                  if (widget.groupId != null)
                    RadioListTile<FrigoVisibility>(
                      title: const Text('Stock de groupe'),
                      subtitle: Text('Partagé avec ${widget.title}'),
                      value: FrigoVisibility.group,
                      groupValue: visibility,
                      onChanged: (v) => setDialogState(() => visibility = v!),
                      secondary: const Icon(Icons.group_outlined),
                    ),
                ],
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
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
              ),
              child: const Text('Ajouter'),
            ),
          ],
        ),
      ),
    );

    if (ok != true) return;

    // Validation
    final name = nameCtrl.text.trim();
    final quantity = double.tryParse(quantityCtrl.text.trim()) ?? 0;
    final calories = double.tryParse(caloriesCtrl.text.trim()) ?? 0;

    if (name.isEmpty || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nom et quantité requis'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    // Ajouter au stock
    try {
      await _frigoService.addToFrigo(
        ingredientId: DateTime.now().millisecondsSinceEpoch.toString(),
        ingredientName: name,
        quantity: quantity,
        unit: unit,
        location: location,
        bestBefore: bestBefore,
        visibility: widget.stockType == StockType.group ? FrigoVisibility.group : visibility,
        groupId: widget.stockType == StockType.group ? widget.groupId : null,
        caloriesPer100g: calories,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$name ajouté au stock !'),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  Future<void> _editProduct(FrigoFirestore item) async {
    final quantityCtrl = TextEditingController(text: item.quantity.toString());

    String unit = item.unit;
    String location = item.location;
    DateTime? bestBefore = item.bestBefore;

    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c2, setDialogState) => AlertDialog(
          title: Text('Modifier ${item.ingredientName}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Quantité et unité
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: quantityCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Quantité *',
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
                const SizedBox(height: 16),

                // Emplacement
                DropdownButtonFormField<String>(
                  value: location,
                  decoration: const InputDecoration(
                    labelText: 'Emplacement *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.place),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'frigo',
                      child: Row(
                        children: [
                          Text('🧊', style: TextStyle(fontSize: 20)),
                          SizedBox(width: 8),
                          Text('Frigo'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'placard',
                      child: Row(
                        children: [
                          Text('📦', style: TextStyle(fontSize: 20)),
                          SizedBox(width: 8),
                          Text('Placard'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'congélateur',
                      child: Row(
                        children: [
                          Text('❄️', style: TextStyle(fontSize: 20)),
                          SizedBox(width: 8),
                          Text('Congélateur'),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (v) => setDialogState(() => location = v!),
                ),
                const SizedBox(height: 16),

                // Date de péremption
                OutlinedButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: c,
                      initialDate: bestBefore ?? DateTime.now().add(const Duration(days: 7)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                      locale: const Locale('fr'),
                    );
                    if (picked != null) {
                      setDialogState(() => bestBefore = picked);
                    }
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    bestBefore == null
                        ? 'Date de péremption (optionnel)'
                        : 'DLC: ${bestBefore!.day}/${bestBefore!.month}/${bestBefore!.year}',
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                if (bestBefore != null) ...[
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => setDialogState(() => bestBefore = null),
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('Retirer la date'),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                  ),
                ],
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
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
              ),
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );

    if (ok != true) return;

    // Validation
    final quantity = double.tryParse(quantityCtrl.text.trim()) ?? 0;

    if (quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Quantité invalide'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    // Mettre à jour
    try {
      await _frigoService.updateFrigoItem(
        frigoId: item.id,
        quantity: quantity,
        unit: unit,
        location: location,
        bestBefore: bestBefore,
        clearBestBefore: bestBefore == null && item.bestBefore != null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.ingredientName} modifié !'),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  Future<void> _deleteProduct(FrigoFirestore item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Supprimer ce produit ?'),
        content: Text('Voulez-vous vraiment supprimer "${item.ingredientName}" du stock ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(c, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _frigoService.deleteFrigoItem(item.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${item.ingredientName} supprimé'),
              backgroundColor: const Color(0xFF10B981),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: $e'),
              backgroundColor: const Color(0xFFEF4444),
            ),
          );
        }
      }
    }
  }

  // ============================================================================
  // HELPERS
  // ============================================================================

  String _getLocationLabel(String location) {
    switch (location) {
      case 'frigo':
        return '🧊 Frigo';
      case 'placard':
        return '📦 Placard';
      case 'congélateur':
        return '❄️ Congélateur';
      default:
        return location;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference < 0) {
      return 'Périmé depuis ${-difference} jour(s)';
    } else if (difference == 0) {
      return 'Expire aujourd\'hui';
    } else if (difference == 1) {
      return 'Expire demain';
    } else {
      return 'Expire dans $difference jours';
    }
  }
}