// lib/screens/scan/scan_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../providers.dart';
import '../../services/openfoodfacts_service.dart';
import '../../utils/permission_helper.dart';

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

  @override
  Widget build(BuildContext context) {
    final ingredientRepo = ref.watch(ingredientRepositoryProvider);

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
                      Text('Calories /100g : ${_product!.kcal100g}'),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () async {
                          await ingredientRepo.insertScannedIngredient(
                            name: _product!.name,
                            caloriesPer100g: _product!.kcal100g,
                            barcode: _product!.barcode,
                          );
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Produit enregistré')));
                        },
                        child: const Text('Enregistrer localement'),
                      )
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
