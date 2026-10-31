// lib/screens/scan/scan_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../providers.dart';
import '../../services/openfoodfacts_service.dart';
import '../../utils/permission_helper.dart';
import '../../widgets/ingredient_match_dialog.dart';

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  bool _loading = false;
  String? _message;
  OpenFoodFactsProduct? _product;
  bool _isDetecting = false;
  bool _saving = false;
  late final MobileScannerController _cameraController;

  @override
  void initState() {
    super.initState();
    _cameraController = MobileScannerController();
  }

  @override
  void dispose() {
    _cameraController.dispose();
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

    final prod = await OpenFoodFactsService.fetchProduct(barcode);
    setState(() {
      _loading = false;
      _product = prod;
      _message = prod == null ? 'Produit introuvable.' : 'Produit trouvé.';
    });
  }

  /// Enregistre le produit scanné dans Firestore (collection `ingredients`).
  /// Si ce code-barres existe déjà pour vous (ou en public), on n'ajoute pas de doublon.
  Future<void> _saveProduct() async {
    final product = _product;
    if (product == null || _saving) return;

    setState(() => _saving = true);
    try {
      final service = ref.read(ingredientFirestoreServiceProvider);

      final ingredient =
          await IngredientMatchDialog.resolveScanned(context, service, product);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('« ${ingredient.name} » ajouté à vos ingrédients')),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'enregistrement : $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scanner un produit')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Lancer le scan'),
              onPressed: _startScan,
            ),
            const SizedBox(height: 12),
            if (_isDetecting)
              Expanded(
                child: MobileScanner(
                  controller: _cameraController,
                  onDetect: _onDetect,
                ),
              )
            else
              Expanded(
                child: Center(
                  child: _loading
                      ? const CircularProgressIndicator()
                      : _product == null
                      ? Text(_message ?? 'Appuyez sur "Lancer le scan"')
                      : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_product!.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      if (_product!.brand != null && _product!.brand!.isNotEmpty)
                        Text(_product!.brand!, style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 8),
                      Text(_product!.nutritionSummary),
                      const Text('(pour 100 g)', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _saving ? null : _saveProduct,
                        child: _saving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Ajouter à mes ingrédients'),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
