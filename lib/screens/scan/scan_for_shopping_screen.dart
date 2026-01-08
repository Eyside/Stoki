// lib/screens/scan/scan_for_shopping_screen.dart
// Écran de scan spécifique pour ajouter à la liste de courses

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../providers.dart';
import '../../services/openfoodfacts_service.dart';
import '../../services/ingredient_firestore_service.dart';
import '../../models/ingredient_firestore.dart';
import '../../utils/permission_helper.dart';

class ScanForShoppingScreen extends ConsumerStatefulWidget {
  const ScanForShoppingScreen({super.key});

  @override
  ConsumerState<ScanForShoppingScreen> createState() => _ScanForShoppingScreenState();
}

class _ScanForShoppingScreenState extends ConsumerState<ScanForShoppingScreen> {
  bool _loading = false;
  String? _message;
  OpenFoodFactsProduct? _product;
  IngredientFirestore? _ingredient;
  bool _isDetecting = false;
  late final MobileScannerController _cameraController;

  // Quantité à ajouter
  final _quantityController = TextEditingController(text: '1');
  String _selectedUnit = 'unité';

  @override
  void initState() {
    super.initState();
    _cameraController = MobileScannerController();
    _startScan();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _startScan() async {
    setState(() {
      _loading = true;
      _message = null;
      _product = null;
      _isDetecting = false;
    });

    final ok = await PermissionHelper.ensureCameraPermission();
    if (!ok) {
      setState(() {
        _loading = false;
        _message = 'Permission caméra refusée.';
      });
      return;
    }

    setState(() {
      _loading = false;
      _isDetecting = true;
    });
    _cameraController.start();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (!_isDetecting) return;
    final barcode = capture.barcodes.isNotEmpty ? capture.barcodes.first.rawValue : null;
    if (barcode == null) return;

    setState(() => _isDetecting = false);
    _cameraController.stop();

    setState(() {
      _loading = true;
      _message = 'Recherche du produit...';
    });

    // 1. Vérifier si l'ingrédient existe déjà dans le cloud
    final ingredientService = ref.read(ingredientFirestoreServiceProvider);
    final existingIngredient = await ingredientService.findByBarcode(barcode);

    if (existingIngredient != null) {
      // Produit déjà connu
      setState(() {
        _loading = false;
        _ingredient = existingIngredient;
        _message = 'Produit trouvé dans votre base !';
      });
      return;
    }

    // 2. Sinon, chercher sur OpenFoodFacts
    final prod = await OpenFoodFactsService.fetchProduct(barcode);

    setState(() {
      _loading = false;
      _product = prod;
      _message = prod == null
          ? 'Produit introuvable. Vous pouvez l\'ajouter manuellement.'
          : 'Produit trouvé sur OpenFoodFacts !';
    });
  }

  Future<void> _addToShoppingList() async {
    final quantity = double.tryParse(_quantityController.text);
    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Quantité invalide'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Si le produit n'existe pas encore dans la base cloud, le créer
    if (_ingredient == null && _product != null) {
      final ingredientService = ref.read(ingredientFirestoreServiceProvider);
      final id = await ingredientService.addIngredient(
        name: _product!.name,
        caloriesPer100g: _product!.kcal100g,
        proteinsPer100g: _product!.proteins100g,
        fatsPer100g: _product!.fats100g,
        carbsPer100g: _product!.carbs100g,
        fibersPer100g: _product!.fibers100g,
        saltPer100g: _product!.salt100g,
        barcode: _product!.barcode,
        nutriscore: _product!.nutriscore,
        imageUrl: _product!.imageUrl,
        brand: _product!.brand,
        category: _product!.category,
        visibility: IngredientVisibility.private,
      );

      _ingredient = await ingredientService.getById(id);
    }

    if (_ingredient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur: impossible de créer l\'ingrédient'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Retourner les infos pour l'ajout à la liste
    if (mounted) {
      Navigator.pop(context, {
        'ingredient': _ingredient,
        'quantity': quantity,
        'unit': _selectedUnit,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner un produit'),
        actions: [
          if (_isDetecting)
            IconButton(
              icon: const Icon(Icons.flash_on),
              onPressed: () => _cameraController.toggleTorch(),
              tooltip: 'Flash',
            ),
        ],
      ),
      body: Column(
        children: [
          // Zone de scan
          if (_isDetecting)
            Expanded(
              flex: 2,
              child: Stack(
                children: [
                  MobileScanner(
                    controller: _cameraController,
                    onDetect: _onDetect,
                  ),
                  Center(
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Positionnez le code-barres dans le cadre',
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else if (_loading)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Recherche en cours...'),
                  ],
                ),
              ),
            )
          else
            const Expanded(
              child: Center(
                child: Icon(Icons.check_circle, size: 64, color: Colors.green),
              ),
            ),

          // Informations produit
          Container(
            padding: const EdgeInsets.all(20),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_message != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _product != null || _ingredient != null
                            ? Colors.green.shade50
                            : Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _product != null || _ingredient != null
                              ? Colors.green.shade200
                              : Colors.orange.shade200,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _product != null || _ingredient != null
                                ? Icons.check_circle
                                : Icons.info,
                            color: _product != null || _ingredient != null
                                ? Colors.green
                                : Colors.orange,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _message!,
                              style: TextStyle(
                                color: _product != null || _ingredient != null
                                    ? Colors.green.shade900
                                    : Colors.orange.shade900,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Infos produit
                  if (_product != null || _ingredient != null) ...[
                    Text(
                      _ingredient?.name ?? _product?.name ?? 'Produit',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    if (_product != null) ...[
                      if (_product!.brand != null)
                        Text(
                          _product!.brand!,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        _product!.nutritionSummary,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      if (_product!.nutriscore != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Text('Nutri-Score: '),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getNutriscoreColor(_product!.nutriscore!),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _product!.nutriscore!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],

                    if (_ingredient != null)
                      Text(
                        '${_ingredient!.caloriesPer100g.toStringAsFixed(0)} kcal/100g',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),

                    const SizedBox(height: 20),

                    // Quantité
                    const Text(
                      'Quantité à acheter:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _quantityController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Quantité',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedUnit,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Unité',
                            ),
                            items: const [
                              DropdownMenuItem(value: 'g', child: Text('g')),
                              DropdownMenuItem(value: 'kg', child: Text('kg')),
                              DropdownMenuItem(value: 'ml', child: Text('ml')),
                              DropdownMenuItem(value: 'L', child: Text('L')),
                              DropdownMenuItem(value: 'unité', child: Text('unité')),
                            ],
                            onChanged: (v) => setState(() => _selectedUnit = v!),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Boutons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                _product = null;
                                _ingredient = null;
                                _message = null;
                              });
                              _startScan();
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Nouveau scan'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _addToShoppingList,
                            icon: const Icon(Icons.add_shopping_cart),
                            label: const Text('Ajouter'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getNutriscoreColor(String score) {
    switch (score.toLowerCase()) {
      case 'a':
        return Colors.green;
      case 'b':
        return Colors.lightGreen;
      case 'c':
        return Colors.yellow;
      case 'd':
        return Colors.orange;
      case 'e':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}