// lib/screens/frigo_screen.dart
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../database.dart';
import '../repositories/frigo_repository.dart';
import '../repositories/ingredient_repository.dart';
import '../services/openfoodfacts_service.dart';
import '../utils/permission_helper.dart';

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
  late Future<List<Map<String, dynamic>>> _frigoFuture;
  String _filterLocation = 'all';

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _frigoFuture = widget.frigoRepository.getAllFrigoWithIngredients();
    });
  }

  List<Map<String, dynamic>> _filterItems(List<Map<String, dynamic>> items) {
    if (_filterLocation == 'all') return items;
    return items.where((item) {
      final frigo = item['frigo'] as FrigoData;
      return frigo.location == _filterLocation;
    }).toList();
  }

  // ============================================================================
  // SCAN + AJOUT AUTOMATIQUE
  // ============================================================================
  Future<void> _scanAndAddToFrigo() async {
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

    // Ouvrir le scanner
    final scannedProduct = await Navigator.push<OpenFoodFactsProduct>(
      context,
      MaterialPageRoute(
        builder: (_) => _BarcodeScannerScreen(),
      ),
    );

    if (scannedProduct == null) return;

    // Vérifier si le produit a des valeurs nutritionnelles
    if (scannedProduct.kcal100g == 0) {
      if (!mounted) return;
      final addManually = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text("⚠️ Valeurs nutritionnelles manquantes"),
          content: Text(
              "Le produit '${scannedProduct.name}' a été trouvé mais ne contient pas de valeurs nutritionnelles.\n\n"
                  "Voulez-vous l'ajouter manuellement avec vos propres valeurs ?"
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text("Ajouter manuellement"),
            ),
          ],
        ),
      );

      if (addManually == true) {
        _addManualIngredientToFrigo(prefillName: scannedProduct.name);
      }
      return;
    }

    // Le produit a des valeurs nutritionnelles, on peut l'ajouter
    _confirmAddScannedProduct(scannedProduct);
  }

  Future<void> _confirmAddScannedProduct(OpenFoodFactsProduct product) async {
    String location = 'frigo';
    final quantCtrl = TextEditingController(text: '1');
    String unit = 'unité';
    DateTime? bestBefore;

    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c2, setDialogState) => AlertDialog(
          title: Text("Ajouter '${product.name}'"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Calories: ${product.kcal100g.toStringAsFixed(0)} kcal/100g",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: quantCtrl,
                        decoration: const InputDecoration(
                          labelText: "Quantité",
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
                          labelText: "Unité",
                          border: OutlineInputBorder(),
                        ),
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
                  value: location,
                  decoration: const InputDecoration(
                    labelText: "Emplacement",
                    border: OutlineInputBorder(),
                  ),
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
                    if (picked != null) {
                      setDialogState(() => bestBefore = picked);
                    }
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    bestBefore == null
                        ? "Date de péremption (optionnel)"
                        : "DLC: ${bestBefore!.toIso8601String().split('T')[0]}",
                  ),
                ),
              ],
            ),
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

    if (ok != true) return;

    final quantity = double.tryParse(quantCtrl.text.trim()) ?? 0.0;
    if (quantity <= 0) return;

    // 1. Créer ou récupérer l'ingrédient
    Ingredient? existingIngredient = await widget.ingredientRepository.findByBarcode(product.barcode);

    int ingredientId;
    if (existingIngredient != null) {
      ingredientId = existingIngredient.id;
    } else {
      // Créer le nouvel ingrédient
      ingredientId = await widget.ingredientRepository.insertScannedIngredient(
        name: product.name,
        caloriesPer100g: product.kcal100g,
        barcode: product.barcode,
      );
    }

    // 2. Ajouter au frigo
    await widget.frigoRepository.addToFrigo(
      ingredientId: ingredientId,
      quantity: quantity,
      unit: unit,
      bestBefore: bestBefore,
      location: location,
    );

    _refresh();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${product.name} ajouté au $location !")),
      );
    }
  }

  // ============================================================================
  // AJOUT MANUEL
  // ============================================================================
  Future<void> _addManualIngredientToFrigo({String? prefillName}) async {
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

    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c2, setDialogState) => AlertDialog(
          title: const Text("Ajouter un ingrédient"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Informations produit:", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: "Nom *",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: categoryCtrl,
                  decoration: const InputDecoration(
                    labelText: "Catégorie",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                const Text("Valeurs nutritionnelles (pour 100g):", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: caloriesCtrl,
                  decoration: const InputDecoration(
                    labelText: "Calories (kcal) *",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: proteinsCtrl,
                  decoration: const InputDecoration(
                    labelText: "Protéines (g)",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: fatsCtrl,
                  decoration: const InputDecoration(
                    labelText: "Lipides (g)",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: carbsCtrl,
                  decoration: const InputDecoration(
                    labelText: "Glucides (g)",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 12),
                const Text("Quantité à ajouter:", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: quantCtrl,
                        decoration: const InputDecoration(
                          labelText: "Quantité",
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
                          labelText: "Unité",
                          border: OutlineInputBorder(),
                        ),
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
                  value: location,
                  decoration: const InputDecoration(
                    labelText: "Emplacement",
                    border: OutlineInputBorder(),
                  ),
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
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 7)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                    );
                    if (picked != null) {
                      setDialogState(() => bestBefore = picked);
                    }
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    bestBefore == null
                        ? "Date de péremption (optionnel)"
                        : "DLC: ${bestBefore!.toIso8601String().split('T')[0]}",
                  ),
                ),
              ],
            ),
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

    if (ok != true) return;

    final name = nameCtrl.text.trim();
    final calories = double.tryParse(caloriesCtrl.text.trim()) ?? 0.0;
    final quantity = double.tryParse(quantCtrl.text.trim()) ?? 0.0;

    if (name.isEmpty || calories <= 0 || quantity <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Nom, calories et quantité sont obligatoires")),
        );
      }
      return;
    }

    // 1. Créer l'ingrédient
    final ingredientId = await widget.ingredientRepository.insertIngredient(
      name: name,
      caloriesPer100g: calories,
      proteinsPer100g: double.tryParse(proteinsCtrl.text.trim()) ?? 0.0,
      fatsPer100g: double.tryParse(fatsCtrl.text.trim()) ?? 0.0,
      carbsPer100g: double.tryParse(carbsCtrl.text.trim()) ?? 0.0,
      category: categoryCtrl.text.trim().isEmpty ? null : categoryCtrl.text.trim(),
      isCustom: true,
    );

    // 2. Ajouter au frigo
    await widget.frigoRepository.addToFrigo(
      ingredientId: ingredientId,
      quantity: quantity,
      unit: unit,
      bestBefore: bestBefore,
      location: location,
    );

    _refresh();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$name ajouté au $location !")),
      );
    }
  }

  String _getLocationEmoji(String location) {
    switch (location) {
      case 'frigo':
        return '🧊';
      case 'placard':
        return '📦';
      case 'congélateur':
        return '❄️';
      default:
        return '📍';
    }
  }

  Color _getExpirationColor(DateTime? bestBefore) {
    if (bestBefore == null) return Colors.grey;
    final now = DateTime.now();
    final daysUntilExpiration = bestBefore.difference(now).inDays;

    if (daysUntilExpiration < 0) return Colors.red;
    if (daysUntilExpiration <= 3) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Stock"),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            initialValue: _filterLocation,
            onSelected: (value) {
              setState(() => _filterLocation = value);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'all', child: Text('📍 Tout')),
              PopupMenuItem(value: 'frigo', child: Text('🧊 Frigo')),
              PopupMenuItem(value: 'placard', child: Text('📦 Placard')),
              PopupMenuItem(value: 'congélateur', child: Text('❄️ Congélateur')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _frigoFuture,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snap.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text("Erreur: ${snap.error}"),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refresh,
                    child: const Text("Réessayer"),
                  ),
                ],
              ),
            );
          }

          final allItems = snap.data ?? [];
          final items = _filterItems(allItems);

          if (allItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.kitchen, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    "Stock vide",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Scannez ou ajoutez des produits",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _scanAndAddToFrigo,
                        icon: const Icon(Icons.qr_code_scanner),
                        label: const Text("Scanner"),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: () => _addManualIngredientToFrigo(),
                        icon: const Icon(Icons.add),
                        label: const Text("Ajouter"),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }

          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.filter_list_off, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    "Aucun élément dans cette catégorie",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      setState(() => _filterLocation = 'all');
                    },
                    child: const Text("Afficher tout"),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: items.length,
            itemBuilder: (c, i) {
              final item = items[i];
              final frigo = item['frigo'] as FrigoData;
              final ingredient = item['ingredient'] as Ingredient?;

              if (ingredient == null) return const SizedBox.shrink();

              final expirationColor = _getExpirationColor(frigo.bestBefore);
              final locationEmoji = _getLocationEmoji(frigo.location);

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: expirationColor.withValues(alpha: 0.2),
                    child: Text(
                      locationEmoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  title: Text(
                    ingredient.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${frigo.quantity} ${frigo.unit} • ${frigo.location}"),
                      if (frigo.bestBefore != null)
                        Text(
                          "DLC: ${frigo.bestBefore!.toIso8601String().split('T')[0]}",
                          style: TextStyle(
                            color: expirationColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (frigo.bestBefore != null)
                        Icon(
                          Icons.warning_amber_rounded,
                          color: expirationColor,
                          size: 20,
                        ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (c) => AlertDialog(
                              title: const Text("Supprimer"),
                              content: Text("Supprimer ${ingredient.name} du stock ?"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(c, false),
                                  child: const Text("Annuler"),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(c, true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  child: const Text("Supprimer"),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await widget.frigoRepository.deleteFrigoItem(frigo.id);
                            _refresh();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'scan',
            onPressed: _scanAndAddToFrigo,
            child: const Icon(Icons.qr_code_scanner),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'add',
            onPressed: () => _addManualIngredientToFrigo(),
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// ÉCRAN DE SCAN DÉDIÉ
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

    // Recherche du produit
    final product = await OpenFoodFactsService.fetchProduct(barcode);

    if (!mounted) return;

    if (product == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Produit non trouvé")),
      );
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
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      "Recherche du produit...",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}