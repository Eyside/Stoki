// lib/screens/frigo_screen.dart
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../database.dart';
import '../models/frigo_firestore.dart';
import '../repositories/frigo_repository.dart';
import '../repositories/ingredient_repository.dart';
import '../services/frigo_firestore_service.dart';
import '../services/group_service.dart';
import '../services/auth_service.dart';
import '../services/openfoodfacts_service.dart';
import '../utils/permission_helper.dart';

enum FrigoSource {
  all,
  local,
  private,
  group,
}

enum FrigoLocation {
  all,
  frigo,
  placard,
  congelateur,
}

class FrigoSourceOption {
  final FrigoSource type;
  final String label;
  final IconData icon;
  final String? groupId;
  final String? groupName;

  FrigoSourceOption({
    required this.type,
    required this.label,
    required this.icon,
    this.groupId,
    this.groupName,
  });
}

class FrigoLocationOption {
  final FrigoLocation type;
  final String label;
  final String emoji;
  final String? value;

  FrigoLocationOption({
    required this.type,
    required this.label,
    required this.emoji,
    this.value,
  });
}

class FrigoScreen extends StatefulWidget {
  final FrigoRepository frigoRepository;
  final IngredientRepository ingredientRepository;

  const FrigoScreen({
    super.key,
    required this.frigoRepository,
    required this.ingredientRepository,
  });

  @override
  State<FrigoScreen> createState() => _FrigoScreenState();
}

class _FrigoScreenState extends State<FrigoScreen> {
  final _frigoService = FrigoFirestoreService();
  final _groupService = GroupService();
  final _authService = AuthService();

  late Future<List<Map<String, dynamic>>> _localFrigoFuture;
  final _searchController = TextEditingController();

  List<FrigoSourceOption> _sourceOptions = [];
  FrigoSourceOption? _selectedSource;
  FrigoLocationOption? _selectedLocation;
  List<Map<String, dynamic>> _userGroups = [];
  String _searchQuery = '';

  final _locationOptions = [
    FrigoLocationOption(type: FrigoLocation.all, label: 'Tout', emoji: '📍'),
    FrigoLocationOption(type: FrigoLocation.frigo, label: 'Frigo', emoji: '🧊', value: 'frigo'),
    FrigoLocationOption(type: FrigoLocation.placard, label: 'Placard', emoji: '📦', value: 'placard'),
    FrigoLocationOption(type: FrigoLocation.congelateur, label: 'Congélateur', emoji: '❄️', value: 'congélateur'),
  ];

  @override
  void initState() {
    super.initState();
    _selectedLocation = _locationOptions.first;
    _loadSourceOptions();
    _refresh();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSourceOptions() async {
    final userId = _authService.currentUser?.uid;

    final options = <FrigoSourceOption>[
      FrigoSourceOption(type: FrigoSource.all, label: 'Tout le stock', icon: Icons.all_inclusive),
      FrigoSourceOption(type: FrigoSource.local, label: 'Stock local', icon: Icons.phone_android),
    ];

    if (userId != null) {
      options.add(FrigoSourceOption(type: FrigoSource.private, label: 'Stock cloud', icon: Icons.cloud));

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

    final options = <FrigoSourceOption>[
      FrigoSourceOption(type: FrigoSource.all, label: 'Tout le stock', icon: Icons.all_inclusive),
      FrigoSourceOption(type: FrigoSource.local, label: 'Stock local', icon: Icons.phone_android),
    ];

    if (userId != null) {
      options.add(FrigoSourceOption(type: FrigoSource.private, label: 'Stock cloud', icon: Icons.cloud));

      for (final group in _userGroups) {
        options.add(FrigoSourceOption(
          type: FrigoSource.group,
          label: group['name'] ?? 'Groupe',
          icon: Icons.group,
          groupId: group['id'],
          groupName: group['name'],
        ));
      }
    }

    setState(() {
      _sourceOptions = options;
      _selectedSource ??= options.first;
    });
  }

  void _refresh() {
    setState(() {
      _localFrigoFuture = widget.frigoRepository.getAllFrigoWithIngredients();
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
                  const Text('Filtrer le stock', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
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
                  final isSelected = _selectedSource == option;
                  return ListTile(
                    leading: Icon(option.icon, color: isSelected ? Colors.green : null),
                    title: Text(option.label, style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.green : null,
                    )),
                    trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
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

  void _showLocationMenu() {
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
                  const Icon(Icons.place),
                  const SizedBox(width: 12),
                  const Text('Filtrer par emplacement', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
            ),
            const Divider(height: 1),
            ListView.builder(
              shrinkWrap: true,
              itemCount: _locationOptions.length,
              itemBuilder: (context, index) {
                final option = _locationOptions[index];
                final isSelected = _selectedLocation == option;
                return ListTile(
                  leading: Text(option.emoji, style: const TextStyle(fontSize: 24)),
                  title: Text(option.label, style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.green : null,
                  )),
                  trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
                  onTap: () {
                    setState(() => _selectedLocation = option);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // SCAN + AJOUT
  // ============================================================================
  Future<void> _scanAndAdd() async {
    final hasPermission = await PermissionHelper.ensureCameraPermission();
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Permission caméra refusée")),
        );
      }
      return;
    }

    if (!mounted) return;

    final scannedProduct = await Navigator.push<OpenFoodFactsProduct>(
      context,
      MaterialPageRoute(builder: (_) => _BarcodeScannerScreen()),
    );

    if (scannedProduct == null) return;

    if (scannedProduct.kcal100g == 0) {
      if (!mounted) return;
      final addManually = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text("⚠️ Valeurs nutritionnelles manquantes"),
          content: Text("Le produit '${scannedProduct.name}' a été trouvé mais ne contient pas de valeurs nutritionnelles.\n\nVoulez-vous l'ajouter manuellement ?"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: const Text("Annuler")),
            ElevatedButton(onPressed: () => Navigator.pop(c, true), child: const Text("Ajouter manuellement")),
          ],
        ),
      );

      if (addManually == true) {
        _addManual(prefillName: scannedProduct.name);
      }
      return;
    }

    _confirmAddScannedProduct(scannedProduct);
  }

  Future<void> _confirmAddScannedProduct(OpenFoodFactsProduct product) async {
    String location = 'frigo';
    final quantCtrl = TextEditingController(text: '1');
    String unit = 'unité';
    DateTime? bestBefore;
    bool addToCloud = _authService.currentUser != null;
    FrigoVisibility visibility = FrigoVisibility.private;
    String? selectedGroupId;

    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c2, setDialogState) => AlertDialog(
          title: Text("Ajouter '${product.name}'"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Calories: ${product.kcal100g.toStringAsFixed(0)} kcal/100g", style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: quantCtrl,
                        decoration: const InputDecoration(labelText: "Quantité", border: OutlineInputBorder()),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: unit,
                        decoration: const InputDecoration(labelText: "Unité", border: OutlineInputBorder()),
                        items: const [
                          DropdownMenuItem(value: 'g', child: Text('g')),
                          DropdownMenuItem(value: 'ml', child: Text('ml')),
                          DropdownMenuItem(value: 'unité', child: Text('unité')),
                        ],
                        onChanged: (v) => setDialogState(() => unit = v ?? 'unité'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: location,
                  decoration: const InputDecoration(labelText: "Emplacement", border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'frigo', child: Text('🧊 Frigo')),
                    DropdownMenuItem(value: 'placard', child: Text('📦 Placard')),
                    DropdownMenuItem(value: 'congélateur', child: Text('❄️ Congélateur')),
                  ],
                  onChanged: (v) => setDialogState(() => location = v ?? 'frigo'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 7)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                    );
                    if (picked != null) setDialogState(() => bestBefore = picked);
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: Text(bestBefore == null ? "Date de péremption (optionnel)" : "DLC: ${bestBefore!.toIso8601String().split('T')[0]}"),
                ),
                if (_authService.currentUser != null) ...[
                  const SizedBox(height: 12),
                  const Divider(),
                  SwitchListTile(
                    title: const Text("Ajouter au cloud"),
                    subtitle: const Text("Synchronisé sur tous vos appareils"),
                    value: addToCloud,
                    onChanged: (v) => setDialogState(() => addToCloud = v),
                  ),
                  if (addToCloud) ...[
                    RadioListTile<FrigoVisibility>(
                      title: const Text('Stock privé'),
                      subtitle: const Text('Visible uniquement par vous'),
                      value: FrigoVisibility.private,
                      groupValue: visibility,
                      onChanged: (v) => setDialogState(() {
                        visibility = v!;
                        selectedGroupId = null;
                      }),
                      secondary: const Icon(Icons.lock),
                    ),
                    RadioListTile<FrigoVisibility>(
                      title: const Text('Stock de groupe'),
                      subtitle: const Text('Partagé avec un groupe'),
                      value: FrigoVisibility.group,
                      groupValue: visibility,
                      onChanged: (v) => setDialogState(() => visibility = v!),
                      secondary: const Icon(Icons.group),
                    ),
                    if (visibility == FrigoVisibility.group)
                      DropdownButtonFormField<String>(
                        initialValue: selectedGroupId,
                        decoration: const InputDecoration(labelText: 'Groupe *', border: OutlineInputBorder(), prefixIcon: Icon(Icons.group)),
                        items: _userGroups.map((group) => DropdownMenuItem<String>(value: group['id'], child: Text(group['name'] ?? 'Groupe'))).toList(),
                        onChanged: (v) => setDialogState(() => selectedGroupId = v),
                      ),
                  ],
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: const Text("Annuler")),
            ElevatedButton(onPressed: () => Navigator.pop(c, true), child: const Text("Ajouter")),
          ],
        ),
      ),
    );

    if (ok != true) return;

    final quantity = double.tryParse(quantCtrl.text.trim()) ?? 0.0;
    if (quantity <= 0) return;

    // Créer ou récupérer l'ingrédient
    Ingredient? existingIngredient = await widget.ingredientRepository.findByBarcode(product.barcode);

    int ingredientId;
    if (existingIngredient != null) {
      ingredientId = existingIngredient.id;
    } else {
      ingredientId = await widget.ingredientRepository.insertScannedIngredient(
        name: product.name,
        caloriesPer100g: product.kcal100g,
        barcode: product.barcode,
      );
    }

    // Ajouter au frigo (local ou cloud)
    if (addToCloud && _authService.currentUser != null) {
      if (visibility == FrigoVisibility.group && selectedGroupId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sélectionnez un groupe')));
        }
        return;
      }

      await _frigoService.addToFrigo(
        ingredientId: ingredientId.toString(),
        ingredientName: product.name,
        quantity: quantity,
        unit: unit,
        location: location,
        bestBefore: bestBefore,
        visibility: visibility,
        groupId: selectedGroupId,
        caloriesPer100g: product.kcal100g,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${product.name} ajouté au cloud !")));
      }
    } else {
      await widget.frigoRepository.addToFrigo(
        ingredientId: ingredientId,
        quantity: quantity,
        unit: unit,
        bestBefore: bestBefore,
        location: location,
      );

      _refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${product.name} ajouté au stock local !")));
      }
    }
  }

  // ============================================================================
  // AJOUT MANUEL
  // ============================================================================
  Future<void> _addManual({String? prefillName}) async {
    final nameCtrl = TextEditingController(text: prefillName ?? '');
    final caloriesCtrl = TextEditingController();
    final proteinsCtrl = TextEditingController();
    final fatsCtrl = TextEditingController();
    final carbsCtrl = TextEditingController();
    final categoryCtrl = TextEditingController();

    final quantCtrl = TextEditingController(text: '1');
    String unit = 'g';
    String location = 'frigo';
    DateTime? bestBefore;
    bool addToCloud = _authService.currentUser != null;
    FrigoVisibility visibility = FrigoVisibility.private;
    String? selectedGroupId;

    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c2, setDialogState) => AlertDialog(
          title: const Text("Ajouter un produit"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Nom *", border: OutlineInputBorder())),
                const SizedBox(height: 8),
                TextField(controller: caloriesCtrl, decoration: const InputDecoration(labelText: "Calories (kcal/100g) *", border: OutlineInputBorder()), keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(flex: 2, child: TextField(controller: quantCtrl, decoration: const InputDecoration(labelText: "Quantité", border: OutlineInputBorder()), keyboardType: const TextInputType.numberWithOptions(decimal: true))),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: unit,
                        decoration: const InputDecoration(labelText: "Unité", border: OutlineInputBorder()),
                        items: const [
                          DropdownMenuItem(value: 'g', child: Text('g')),
                          DropdownMenuItem(value: 'ml', child: Text('ml')),
                          DropdownMenuItem(value: 'unité', child: Text('unité')),
                        ],
                        onChanged: (v) => setDialogState(() => unit = v ?? 'g'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: location,
                  decoration: const InputDecoration(labelText: "Emplacement", border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'frigo', child: Text('🧊 Frigo')),
                    DropdownMenuItem(value: 'placard', child: Text('📦 Placard')),
                    DropdownMenuItem(value: 'congélateur', child: Text('❄️ Congélateur')),
                  ],
                  onChanged: (v) => setDialogState(() => location = v ?? 'frigo'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(context: context, initialDate: DateTime.now().add(const Duration(days: 7)), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365 * 2)));
                    if (picked != null) setDialogState(() => bestBefore = picked);
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: Text(bestBefore == null ? "Date de péremption" : "DLC: ${bestBefore!.toIso8601String().split('T')[0]}"),
                ),
                if (_authService.currentUser != null) ...[
                  const SizedBox(height: 12),
                  const Divider(),
                  SwitchListTile(
                    title: const Text("Ajouter au cloud"),
                    value: addToCloud,
                    onChanged: (v) => setDialogState(() => addToCloud = v),
                  ),
                  if (addToCloud) ...[
                    RadioListTile<FrigoVisibility>(
                      title: const Text('Privé'),
                      value: FrigoVisibility.private,
                      groupValue: visibility,
                      onChanged: (v) => setDialogState(() {
                        visibility = v!;
                        selectedGroupId = null;
                      }),
                    ),
                    RadioListTile<FrigoVisibility>(
                      title: const Text('Groupe'),
                      value: FrigoVisibility.group,
                      groupValue: visibility,
                      onChanged: (v) => setDialogState(() => visibility = v!),
                    ),
                    if (visibility == FrigoVisibility.group)
                      DropdownButtonFormField<String>(
                        initialValue: selectedGroupId,
                        decoration: const InputDecoration(labelText: 'Groupe *'),
                        items: _userGroups.map((g) => DropdownMenuItem<String>(value: g['id'], child: Text(g['name'] ?? 'Groupe'))).toList(),
                        onChanged: (v) => setDialogState(() => selectedGroupId = v),
                      ),
                  ],
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: const Text("Annuler")),
            ElevatedButton(onPressed: () => Navigator.pop(c, true), child: const Text("Ajouter")),
          ],
        ),
      ),
    );

    if (ok != true) return;

    final name = nameCtrl.text.trim();
    final calories = double.tryParse(caloriesCtrl.text.trim()) ?? 0.0;
    final quantity = double.tryParse(quantCtrl.text.trim()) ?? 0.0;

    if (name.isEmpty || calories <= 0 || quantity <= 0) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Nom, calories et quantité requis")));
      return;
    }

    final ingredientId = await widget.ingredientRepository.insertIngredient(
      name: name,
      caloriesPer100g: calories,
      proteinsPer100g: double.tryParse(proteinsCtrl.text.trim()) ?? 0.0,
      fatsPer100g: double.tryParse(fatsCtrl.text.trim()) ?? 0.0,
      carbsPer100g: double.tryParse(carbsCtrl.text.trim()) ?? 0.0,
      category: categoryCtrl.text.trim().isEmpty ? null : categoryCtrl.text.trim(),
      isCustom: true,
    );

    if (addToCloud && _authService.currentUser != null) {
      await _frigoService.addToFrigo(
        ingredientId: ingredientId.toString(),
        ingredientName: name,
        quantity: quantity,
        unit: unit,
        location: location,
        bestBefore: bestBefore,
        visibility: visibility,
        groupId: selectedGroupId,
        caloriesPer100g: calories,
      );
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$name ajouté au cloud !")));
    } else {
      await widget.frigoRepository.addToFrigo(
        ingredientId: ingredientId,
        quantity: quantity,
        unit: unit,
        bestBefore: bestBefore,
        location: location,
      );
      _refresh();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$name ajouté au stock local !")));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedSource == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Stock'),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_selectedSource!.icon, size: 14, color: Colors.green.shade700),
                  const SizedBox(width: 4),
                  Text(_selectedSource!.label, style: TextStyle(fontSize: 12, color: Colors.green.shade700, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.filter_list), tooltip: 'Filtrer par source', onPressed: _showSourceMenu),
          IconButton(icon: Icon(Icons.place, color: _selectedLocation?.type != FrigoLocation.all ? Colors.green : null), tooltip: 'Filtrer par emplacement', onPressed: _showLocationMenu),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refresh),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un produit...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty ? IconButton(icon: const Icon(Icons.clear), onPressed: () => _searchController.clear()) : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          Expanded(child: _buildStockList()),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(heroTag: 'scan', onPressed: _scanAndAdd, child: const Icon(Icons.qr_code_scanner)),
          const SizedBox(height: 12),
          FloatingActionButton(heroTag: 'add', onPressed: () => _addManual(), child: const Icon(Icons.add)),
        ],
      ),
    );
  }

  Widget _buildStockList() {
    if (_selectedSource!.type == FrigoSource.all) return _buildAllStock();
    if (_selectedSource!.type == FrigoSource.local) return _buildLocalStock();
    return _buildCloudStock();
  }

  Widget _buildLocalStock() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _localFrigoFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError) return Center(child: Text('Erreur: ${snapshot.error}'));

        var items = snapshot.data ?? [];
        items = _filterLocalItems(items);

        if (items.isEmpty) return _buildEmptyState();

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: items.length,
          itemBuilder: (c, i) {
            final item = items[i];
            final frigo = item['frigo'] as FrigoData;
            final ingredient = item['ingredient'] as Ingredient?;
            if (ingredient == null) return const SizedBox.shrink();
            return _buildLocalFrigoCard(frigo, ingredient);
          },
        );
      },
    );
  }

  Widget _buildCloudStock() {
    Stream<List<FrigoFirestore>> stream;

    if (_selectedSource!.type == FrigoSource.private) {
      stream = _frigoService.getMyStock().map((list) => list.where((f) => f.visibility == FrigoVisibility.private).toList());
    } else {
      final groupId = _selectedSource!.groupId!;
      stream = _frigoService.getGroupStock(groupId);
    }

    return StreamBuilder<List<FrigoFirestore>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError) return Center(child: Text('Erreur: ${snapshot.error}'));

        var items = snapshot.data ?? [];
        items = _filterCloudItems(items);

        if (items.isEmpty) return _buildEmptyState();

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: items.length,
          itemBuilder: (c, i) => _buildCloudFrigoCard(items[i]),
        );
      },
    );
  }

  Widget _buildAllStock() {
    return FutureBuilder<List<dynamic>>(
      future: _loadAllStock(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

        var items = snapshot.data ?? [];
        items = _filterAllItems(items);

        if (items.isEmpty) return _buildEmptyState();

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: items.length,
          itemBuilder: (c, i) {
            final item = items[i];
            if (item is Map<String, dynamic>) {
              final frigo = item['frigo'] as FrigoData;
              final ingredient = item['ingredient'] as Ingredient?;
              if (ingredient == null) return const SizedBox.shrink();
              return _buildLocalFrigoCard(frigo, ingredient);
            } else if (item is FrigoFirestore) {
              return _buildCloudFrigoCard(item);
            }
            return const SizedBox.shrink();
          },
        );
      },
    );
  }

  Future<List<dynamic>> _loadAllStock() async {
    final localItems = await _localFrigoFuture;
    final List<dynamic> allItems = List.from(localItems);

    if (_authService.currentUser != null) {
      try {
        final cloudItems = await _frigoService.getMyStock().first;
        allItems.addAll(cloudItems);
      } catch (e) {
        // Ignorer les erreurs cloud
      }
    }

    return allItems;
  }

  List<Map<String, dynamic>> _filterLocalItems(List<Map<String, dynamic>> items) {
    return items.where((item) {
      final frigo = item['frigo'] as FrigoData;
      final ingredient = item['ingredient'] as Ingredient?;

      if (_selectedLocation?.type != FrigoLocation.all) {
        if (frigo.location != _selectedLocation?.value) return false;
      }

      if (_searchQuery.isNotEmpty && ingredient != null) {
        if (!ingredient.name.toLowerCase().contains(_searchQuery)) return false;
      }

      return true;
    }).toList();
  }

  List<FrigoFirestore> _filterCloudItems(List<FrigoFirestore> items) {
    return items.where((item) {
      if (_selectedLocation?.type != FrigoLocation.all) {
        if (item.location != _selectedLocation?.value) return false;
      }

      if (_searchQuery.isNotEmpty) {
        if (!item.ingredientName.toLowerCase().contains(_searchQuery)) return false;
      }

      return true;
    }).toList();
  }

  List<dynamic> _filterAllItems(List<dynamic> items) {
    return items.where((item) {
      String location;
      String name;

      if (item is Map<String, dynamic>) {
        final frigo = item['frigo'] as FrigoData;
        final ingredient = item['ingredient'] as Ingredient?;
        location = frigo.location;
        name = ingredient?.name ?? '';
      } else if (item is FrigoFirestore) {
        location = item.location;
        name = item.ingredientName;
      } else {
        return false;
      }

      if (_selectedLocation?.type != FrigoLocation.all) {
        if (location != _selectedLocation?.value) return false;
      }

      if (_searchQuery.isNotEmpty) {
        if (!name.toLowerCase().contains(_searchQuery)) return false;
      }

      return true;
    }).toList();
  }

  Widget _buildLocalFrigoCard(FrigoData frigo, Ingredient ingredient) {
    final expirationColor = _getExpirationColor(frigo.bestBefore);
    final locationEmoji = _getLocationEmoji(frigo.location);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Stack(
          children: [
            CircleAvatar(
              backgroundColor: expirationColor.withValues(alpha: 0.2),
              child: Text(locationEmoji, style: const TextStyle(fontSize: 20)),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.phone_android, size: 12, color: Colors.blue),
              ),
            ),
          ],
        ),
        title: Text(ingredient.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${frigo.quantity} ${frigo.unit} • ${frigo.location}"),
            if (frigo.bestBefore != null)
              Text("DLC: ${frigo.bestBefore!.toIso8601String().split('T')[0]}", style: TextStyle(color: expirationColor, fontWeight: FontWeight.bold)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (frigo.bestBefore != null) Icon(Icons.warning_amber_rounded, color: expirationColor, size: 20),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                await widget.frigoRepository.deleteFrigoItem(frigo.id);
                _refresh();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCloudFrigoCard(FrigoFirestore frigo) {
    final expirationColor = _getExpirationColor(frigo.bestBefore);
    final locationEmoji = _getLocationEmoji(frigo.location);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Stack(
          children: [
            CircleAvatar(
              backgroundColor: expirationColor.withValues(alpha: 0.2),
              child: Text(locationEmoji, style: const TextStyle(fontSize: 20)),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Icon(
                  frigo.visibility == FrigoVisibility.private ? Icons.cloud : Icons.group,
                  size: 12,
                  color: frigo.visibility == FrigoVisibility.private ? Colors.grey : Colors.green,
                ),
              ),
            ),
          ],
        ),
        title: Text(frigo.ingredientName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${frigo.quantity} ${frigo.unit} • ${frigo.location}"),
            if (frigo.bestBefore != null)
              Text("DLC: ${frigo.bestBefore!.toIso8601String().split('T')[0]}", style: TextStyle(color: expirationColor, fontWeight: FontWeight.bold)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (frigo.bestBefore != null) Icon(Icons.warning_amber_rounded, color: expirationColor, size: 20),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                await _frigoService.deleteFrigoItem(frigo.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.kitchen, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('Stock vide', style: TextStyle(fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 8),
          const Text('Scannez ou ajoutez des produits', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  String _getLocationEmoji(String location) {
    switch (location) {
      case 'frigo': return '🧊';
      case 'placard': return '📦';
      case 'congélateur': return '❄️';
      default: return '📍';
    }
  }

  Color _getExpirationColor(DateTime? bestBefore) {
    if (bestBefore == null) return Colors.grey;
    final days = bestBefore.difference(DateTime.now()).inDays;
    if (days < 0) return Colors.red;
    if (days <= 3) return Colors.orange;
    return Colors.green;
  }
}

// ============================================================================
// SCANNER SCREEN
// ============================================================================
class _BarcodeScannerScreen extends StatefulWidget {
  @override
  State<_BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<_BarcodeScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final barcode = capture.barcodes.isNotEmpty ? capture.barcodes.first.rawValue : null;
    if (barcode == null) return;

    setState(() => _isProcessing = true);
    _controller.stop();

    final product = await OpenFoodFactsService.fetchProduct(barcode);

    if (!mounted) return;

    if (product == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Produit non trouvé")));
      Navigator.pop(context);
      return;
    }

    Navigator.pop(context, product);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scanner un code-barres"),
        backgroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text("Recherche du produit...", style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}