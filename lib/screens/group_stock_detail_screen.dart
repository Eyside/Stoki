// lib/screens/group_stock_detail_screen.dart - PARTIE 1/2
// COPIER CE FICHIER JUSQU'À LA LIGNE "// ===== SUITE PARTIE 2/2 ====="

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/auth_service.dart';
import '../services/frigo_firestore_service.dart';
import '../services/group_service.dart';
import '../services/openfoodfacts_service.dart';
import '../services/ingredient_firestore_service.dart';
import '../models/frigo_firestore.dart';
import '../models/ingredient_firestore.dart';
import '../utils/permission_helper.dart';
import '../widgets/ingredient_match_dialog.dart';

enum StockType { private, group }

class GroupStockDetailScreen extends StatefulWidget {
  final StockType stockType;
  final String? groupId;
  final String title;

  const GroupStockDetailScreen({super.key, required this.stockType, this.groupId, required this.title});

  @override
  State<GroupStockDetailScreen> createState() => _GroupStockDetailScreenState();
}

class _GroupStockDetailScreenState extends State<GroupStockDetailScreen> {
  final _frigoService = FrigoFirestoreService();
  final _ingredientService = IngredientFirestoreService();
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() => _searchQuery = _searchController.text.toLowerCase()));
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
        actions: [
          PopupMenuButton<String?>(
            icon: Icon(_selectedLocation != null ? Icons.filter_alt : Icons.filter_alt_outlined, color: _selectedLocation != null ? const Color(0xFF10B981) : const Color(0xFF64748B)),
            tooltip: 'Filtrer par emplacement',
            onSelected: (value) => setState(() => _selectedLocation = value),
            itemBuilder: (context) => const [
              PopupMenuItem(value: null, child: Row(children: [Text('📍', style: TextStyle(fontSize: 20)), SizedBox(width: 12), Text('Tous')])),
              PopupMenuDivider(),
              PopupMenuItem(value: 'frigo', child: Row(children: [Text('🧊', style: TextStyle(fontSize: 20)), SizedBox(width: 12), Text('Frigo')])),
              PopupMenuItem(value: 'placard', child: Row(children: [Text('📦', style: TextStyle(fontSize: 20)), SizedBox(width: 12), Text('Placard')])),
              PopupMenuItem(value: 'congélateur', child: Row(children: [Text('❄️', style: TextStyle(fontSize: 20)), SizedBox(width: 12), Text('Congélateur')])),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty ? IconButton(icon: const Icon(Icons.clear), onPressed: () => _searchController.clear()) : null,
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<FrigoFirestore>>(
              stream: _getStockStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (snapshot.hasError) return _buildErrorState(snapshot.error.toString());

                var items = snapshot.data ?? [];
                if (_searchQuery.isNotEmpty) items = items.where((i) => i.ingredientName.toLowerCase().contains(_searchQuery)).toList();
                if (_selectedLocation != null) items = items.where((i) => i.location == _selectedLocation).toList();
                if (items.isEmpty) return _buildEmptyState();

                final grouped = _groupByLocation(items);
                return ListView(
                  padding: const EdgeInsets.only(bottom: 80),
                  children: [
                    if (grouped.containsKey('frigo')) _buildSection('🧊 Frigo', grouped['frigo']!, const Color(0xFFDCFCE7)),
                    if (grouped.containsKey('placard')) _buildSection('📦 Placard', grouped['placard']!, const Color(0xFFFEF3C7)),
                    if (grouped.containsKey('congélateur')) _buildSection('❄️ Congélateur', grouped['congélateur']!, const Color(0xFFDBEAFE)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(heroTag: 'scan', onPressed: _scanProduct, backgroundColor: const Color(0xFF6366F1), child: const Icon(Icons.qr_code_scanner)),
          const SizedBox(height: 12),
          FloatingActionButton.extended(heroTag: 'add', onPressed: _addProduct, backgroundColor: const Color(0xFF10B981), icon: const Icon(Icons.add), label: const Text('Ajouter')),
        ],
      ),
    );
  }

  // SCAN
  Future<void> _scanProduct() async {
    if (!await PermissionHelper.ensureCameraPermission()) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Permission refusée")));
      return;
    }

    if (!mounted) return;
    final product = await Navigator.push<OpenFoodFactsProduct>(context, MaterialPageRoute(builder: (_) => _BarcodeScannerScreen()));
    if (product == null || !mounted) return;

    if (product.kcal100g == 0) {
      final add = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text("⚠️ Valeurs manquantes"),
          content: Text("'${product.name}' trouvé mais sans valeurs nutritionnelles.\n\nAjouter manuellement ?"),
          actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text("Non")), ElevatedButton(onPressed: () => Navigator.pop(c, true), child: const Text("Oui"))],
        ),
      );
      if (add == true) _addProduct(prefillName: product.name);
      return;
    }

    _confirmAddScanned(product);
  }

  Future<void> _confirmAddScanned(OpenFoodFactsProduct product) async {
    String location = 'frigo', unit = 'unité';
    final qCtrl = TextEditingController(text: '1');
    DateTime? bestBefore;

    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (_, setState) => AlertDialog(
          title: Text("Ajouter '${product.name}'"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("${product.kcal100g.toStringAsFixed(0)} kcal/100g", style: const TextStyle(fontWeight: FontWeight.bold)),
                if (product.brand != null) Text("${product.brand}", style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(flex: 2, child: TextField(controller: qCtrl, decoration: const InputDecoration(labelText: "Qté", border: OutlineInputBorder()), keyboardType: const TextInputType.numberWithOptions(decimal: true))),
                  const SizedBox(width: 8),
                  Expanded(child: DropdownButtonFormField<String>(initialValue: unit, decoration: const InputDecoration(labelText: "Unité", border: OutlineInputBorder()), items: const [DropdownMenuItem(value: 'g', child: Text('g')), DropdownMenuItem(value: 'kg', child: Text('kg')), DropdownMenuItem(value: 'ml', child: Text('ml')), DropdownMenuItem(value: 'L', child: Text('L')), DropdownMenuItem(value: 'unité', child: Text('unité'))], onChanged: (v) => setState(() => unit = v!))),
                ]),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(initialValue: location, decoration: const InputDecoration(labelText: "Emplacement", border: OutlineInputBorder()), items: const [DropdownMenuItem(value: 'frigo', child: Text('🧊 Frigo')), DropdownMenuItem(value: 'placard', child: Text('📦 Placard')), DropdownMenuItem(value: 'congélateur', child: Text('❄️ Congélateur'))], onChanged: (v) => setState(() => location = v!)),
                const SizedBox(height: 12),
                OutlinedButton.icon(onPressed: () async {final p = await showDatePicker(context: c, initialDate: DateTime.now().add(const Duration(days: 7)), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 730))); if (p != null) setState(() => bestBefore = p);}, icon: const Icon(Icons.calendar_today), label: Text(bestBefore == null ? "DLC (optionnel)" : "DLC: ${bestBefore!.day}/${bestBefore!.month}/${bestBefore!.year}")),
                if (bestBefore != null) TextButton.icon(onPressed: () => setState(() => bestBefore = null), icon: const Icon(Icons.close, size: 16), label: const Text('Retirer'), style: TextButton.styleFrom(foregroundColor: Colors.red)),
              ],
            ),
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text("Annuler")), ElevatedButton(onPressed: () => Navigator.pop(c, true), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white), child: const Text("Ajouter"))],
        ),
      ),
    );

    if (ok != true || !mounted) return;
    final qty = double.tryParse(qCtrl.text.trim()) ?? 0;
    if (qty <= 0) return;

    try {
      final ingredient = await IngredientMatchDialog.resolveScanned(context, _ingredientService, product);
      final ingId = ingredient.id;

      await _frigoService.addToFrigo(ingredientId: ingId, ingredientName: ingredient.name, quantity: qty, unit: unit, location: location, bestBefore: bestBefore, visibility: widget.stockType == StockType.group ? FrigoVisibility.group : FrigoVisibility.private, groupId: widget.stockType == StockType.group ? widget.groupId : null, caloriesPer100g: product.kcal100g, proteinsPer100g: product.proteins100g, fatsPer100g: product.fats100g, carbsPer100g: product.carbs100g, fibersPer100g: product.fibers100g);

      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${ingredient.name} ajouté !"), backgroundColor: const Color(0xFF10B981)));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: const Color(0xFFEF4444)));
    }
  }

// ===== SUITE PARTIE 2/2 =====
// ===== SUITE DE LA PARTIE 1/2 - À COPIER APRÈS LA PREMIÈRE PARTIE =====

  Widget _buildSection(String title, List<FrigoFirestore> items, Color color) {
    return Column(
      children: [
        Container(margin: const EdgeInsets.all(16), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)), child: Row(children: [Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const Spacer(), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(8)), child: Text('${items.length}', style: const TextStyle(fontWeight: FontWeight.bold)))])),
        ...items.map((i) => _buildCard(i)),
      ],
    );
  }

  Widget _buildCard(FrigoFirestore item) {
    final color = _getExpColor(item.bestBefore);
    final days = item.bestBefore?.difference(DateTime.now()).inDays;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showDetails(item),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(children: [
              Container(padding: const EdgeInsets.all(7), decoration: BoxDecoration(color: item.visibility == FrigoVisibility.private ? const Color(0xFFE0F2FE) : const Color(0xFFD1FAE5), borderRadius: BorderRadius.circular(12)), child: Icon(item.visibility == FrigoVisibility.private ? Icons.lock_outline : Icons.group_outlined, size: 20, color: item.visibility == FrigoVisibility.private ? const Color(0xFF0284C7) : const Color(0xFF059669))),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(item.ingredientName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)), const SizedBox(height: 3), Row(children: [Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)), child: Text('${item.quantity.toStringAsFixed(item.quantity % 1 == 0 ? 0 : 1)} ${item.unit}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))), if (item.bestBefore != null) ...[const SizedBox(width: 8), Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6), border: Border.all(color: color.withValues(alpha: 0.3))), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.calendar_today, size: 12, color: color), const SizedBox(width: 4), Text(days! < 0 ? 'Périmé' : days == 0 ? 'Aujourd\'hui' : '$days j', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color))]))]])])),
              IconButton(icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)), onPressed: () => _delete(item)),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Container(padding: const EdgeInsets.all(24), decoration: const BoxDecoration(color: Color(0xFFF1F5F9), shape: BoxShape.circle), child: const Icon(Icons.inventory_2_outlined, size: 64, color: Color(0xFF94A3B8))), const SizedBox(height: 24), const Text('Stock vide', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF475569))), const SizedBox(height: 8), Text(_searchQuery.isNotEmpty ? 'Aucun résultat' : 'Scannez ou ajoutez des produits', style: const TextStyle(fontSize: 14, color: Color(0xFF94A3B8)))]));

  Widget _buildErrorState(String err) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.error_outline, size: 64, color: Color(0xFFEF4444)), const SizedBox(height: 16), const Text('Erreur', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 8), Text(err, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: Color(0xFF94A3B8)))]));

  Stream<List<FrigoFirestore>> _getStockStream() {
    switch (widget.stockType) {
      case StockType.private: return _frigoService.getMyStock().map((items) => items.where((i) => i.visibility == FrigoVisibility.private).toList());
      case StockType.group: return widget.groupId != null ? _frigoService.getGroupStock(widget.groupId!) : Stream.value([]);
    }
  }

  Map<String, List<FrigoFirestore>> _groupByLocation(List<FrigoFirestore> items) {
    final m = <String, List<FrigoFirestore>>{};
    for (final i in items) {
      (m[i.location] ??= []).add(i);
    }
    for (final l in m.values) {
      l.sort((a, b) => a.bestBefore == null ? 1 : b.bestBefore == null ? -1 : a.bestBefore!.compareTo(b.bestBefore!));
    }
    return m;
  }

  Color _getExpColor(DateTime? date) {
    if (date == null) return const Color(0xFF94A3B8);
    final d = date.difference(DateTime.now()).inDays;
    if (d < 0) return const Color(0xFFEF4444);
    if (d <= 3) return const Color(0xFFF97316);
    if (d <= 7) return const Color(0xFFFBBF24);
    return const Color(0xFF10B981);
  }

  void _showDetails(FrigoFirestore item) {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (c) => Container(decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))), padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2)))), const SizedBox(height: 24), Text(item.ingredientName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)), const SizedBox(height: 20), _row('📍', _getLoc(item.location)), _row('📊', '${item.quantity} ${item.unit}'), if (item.bestBefore != null) _row('📅', _getDate(item.bestBefore!)), _row('👁️', item.visibility == FrigoVisibility.private ? 'Privé' : 'Groupe'), _row('🔥', '${item.caloriesPer100g.toStringAsFixed(0)} kcal/100g'), const SizedBox(height: 24), Row(children: [Expanded(child: OutlinedButton.icon(onPressed: () {Navigator.pop(c); _edit(item);}, icon: const Icon(Icons.edit_outlined), label: const Text('Modifier'))), const SizedBox(width: 12), Expanded(child: ElevatedButton.icon(onPressed: () {Navigator.pop(c); _delete(item);}, icon: const Icon(Icons.delete_outline), label: const Text('Supprimer'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), foregroundColor: Colors.white)))]), const SizedBox(height: 12), SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: () {Navigator.pop(c); _transfer(item);}, icon: const Icon(Icons.swap_horiz), label: const Text('Transférer vers un autre stock'))), SizedBox(height: MediaQuery.of(c).padding.bottom)])));
  }

  Widget _row(String label, String value) => Padding(padding: const EdgeInsets.only(bottom: 16), child: Row(children: [SizedBox(width: 60, child: Text(label, style: const TextStyle(fontSize: 18))), Expanded(child: Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)))]));

  Future<void> _addProduct({String? prefillName}) async {
    final nCtrl = TextEditingController(text: prefillName ?? ''), qCtrl = TextEditingController(text: '1'), cCtrl = TextEditingController();
    String unit = 'unité', loc = 'frigo';
    DateTime? best;

    final ok = await showDialog<bool>(context: context, builder: (c) => StatefulBuilder(builder: (_, setState) => AlertDialog(title: const Text('Ajouter'), content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: nCtrl, decoration: const InputDecoration(labelText: 'Nom *', border: OutlineInputBorder()), autofocus: true), const SizedBox(height: 12), Row(children: [Expanded(flex: 2, child: TextField(controller: qCtrl, decoration: const InputDecoration(labelText: 'Qté *', border: OutlineInputBorder()), keyboardType: const TextInputType.numberWithOptions(decimal: true))), const SizedBox(width: 8), Expanded(child: DropdownButtonFormField<String>(initialValue: unit, decoration: const InputDecoration(labelText: 'Unité', border: OutlineInputBorder()), items: const [DropdownMenuItem(value: 'g', child: Text('g')), DropdownMenuItem(value: 'kg', child: Text('kg')), DropdownMenuItem(value: 'ml', child: Text('ml')), DropdownMenuItem(value: 'L', child: Text('L')), DropdownMenuItem(value: 'unité', child: Text('unité'))], onChanged: (v) => setState(() => unit = v!)))]), const SizedBox(height: 12), DropdownButtonFormField<String>(initialValue: loc, decoration: const InputDecoration(labelText: 'Emplacement', border: OutlineInputBorder()), items: const [DropdownMenuItem(value: 'frigo', child: Text('🧊 Frigo')), DropdownMenuItem(value: 'placard', child: Text('📦 Placard')), DropdownMenuItem(value: 'congélateur', child: Text('❄️ Congélateur'))], onChanged: (v) => setState(() => loc = v!)), const SizedBox(height: 12), OutlinedButton.icon(onPressed: () async {final p = await showDatePicker(context: c, initialDate: DateTime.now().add(const Duration(days: 7)), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 730)), locale: const Locale('fr')); if (p != null) setState(() => best = p);}, icon: const Icon(Icons.calendar_today), label: Text(best == null ? 'DLC (opt.)' : 'DLC: ${best!.day}/${best!.month}/${best!.year}')), if (best != null) TextButton.icon(onPressed: () => setState(() => best = null), icon: const Icon(Icons.close, size: 16), label: const Text('Retirer'), style: TextButton.styleFrom(foregroundColor: Colors.red)), const SizedBox(height: 12), TextField(controller: cCtrl, decoration: const InputDecoration(labelText: 'Calories (kcal/100g)', border: OutlineInputBorder(), hintText: '0'), keyboardType: const TextInputType.numberWithOptions(decimal: true))])), actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Annuler')), ElevatedButton(onPressed: () => Navigator.pop(c, true), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white), child: const Text('Ajouter'))])));

    if (ok != true || !mounted) return;
    final name = nCtrl.text.trim(), qty = double.tryParse(qCtrl.text.trim()) ?? 0, cal = double.tryParse(cCtrl.text.trim()) ?? 0;
    if (name.isEmpty || qty <= 0) {ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nom et quantité requis'), backgroundColor: Color(0xFFEF4444))); return;}

    try {
      final similar = await IngredientMatchDialog.checkManualName(context, _ingredientService, name);
      final ingId = similar?.id ?? await _ingredientService.addIngredient(name: name, caloriesPer100g: cal, visibility: IngredientVisibility.private);
      final stockName = similar?.name ?? name;
      await _frigoService.addToFrigo(ingredientId: ingId, ingredientName: stockName, quantity: qty, unit: unit, location: loc, bestBefore: best, visibility: widget.stockType == StockType.group ? FrigoVisibility.group : FrigoVisibility.private, groupId: widget.stockType == StockType.group ? widget.groupId : null, caloriesPer100g: cal);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$stockName ajouté !'), backgroundColor: const Color(0xFF10B981)));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: const Color(0xFFEF4444)));
    }
  }

  Future<void> _edit(FrigoFirestore item) async {
    final qCtrl = TextEditingController(text: item.quantity.toString());
    String unit = item.unit, loc = item.location;
    DateTime? best = item.bestBefore;

    final ok = await showDialog<bool>(context: context, builder: (c) => StatefulBuilder(builder: (_, setState) => AlertDialog(title: Text('Modifier ${item.ingredientName}'), content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [Row(children: [Expanded(flex: 2, child: TextField(controller: qCtrl, decoration: const InputDecoration(labelText: 'Qté *', border: OutlineInputBorder()), keyboardType: const TextInputType.numberWithOptions(decimal: true))), const SizedBox(width: 8), Expanded(child: DropdownButtonFormField<String>(initialValue: unit, decoration: const InputDecoration(labelText: 'Unité', border: OutlineInputBorder()), items: const [DropdownMenuItem(value: 'g', child: Text('g')), DropdownMenuItem(value: 'kg', child: Text('kg')), DropdownMenuItem(value: 'ml', child: Text('ml')), DropdownMenuItem(value: 'L', child: Text('L')), DropdownMenuItem(value: 'unité', child: Text('unité'))], onChanged: (v) => setState(() => unit = v!)))]), const SizedBox(height: 12), DropdownButtonFormField<String>(initialValue: loc, decoration: const InputDecoration(labelText: 'Emplacement', border: OutlineInputBorder()), items: const [DropdownMenuItem(value: 'frigo', child: Text('🧊 Frigo')), DropdownMenuItem(value: 'placard', child: Text('📦 Placard')), DropdownMenuItem(value: 'congélateur', child: Text('❄️ Congélateur'))], onChanged: (v) => setState(() => loc = v!)), const SizedBox(height: 12), OutlinedButton.icon(onPressed: () async {final p = await showDatePicker(context: c, initialDate: best ?? DateTime.now().add(const Duration(days: 7)), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 730)), locale: const Locale('fr')); if (p != null) setState(() => best = p);}, icon: const Icon(Icons.calendar_today), label: Text(best == null ? 'DLC (opt.)' : 'DLC: ${best!.day}/${best!.month}/${best!.year}')), if (best != null) TextButton.icon(onPressed: () => setState(() => best = null), icon: const Icon(Icons.close, size: 16), label: const Text('Retirer'), style: TextButton.styleFrom(foregroundColor: Colors.red))])), actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Annuler')), ElevatedButton(onPressed: () => Navigator.pop(c, true), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white), child: const Text('Enregistrer'))])));

    if (ok != true || !mounted) return;
    final qty = double.tryParse(qCtrl.text.trim()) ?? 0;
    if (qty <= 0) {ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Quantité invalide'), backgroundColor: Color(0xFFEF4444))); return;}

    try {
      await _frigoService.updateFrigoItem(frigoId: item.id, quantity: qty, unit: unit, location: loc, bestBefore: best, clearBestBefore: best == null && item.bestBefore != null);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${item.ingredientName} modifié !'), backgroundColor: const Color(0xFF10B981)));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: const Color(0xFFEF4444)));
    }
  }

  /// Transfère tout ou partie d'un produit vers mon stock privé ou le stock
  /// d'un de mes groupes.
  Future<void> _transfer(FrigoFirestore item) async {
    final uid = AuthService().currentUser?.uid;
    if (uid == null) return;

    // Destinations possibles : mon stock privé + mes groupes (sauf le stock actuel)
    final destinations = <MapEntry<String, String>>[];
    final inMyPrivate = item.visibility == FrigoVisibility.private && item.ownerId == uid;
    if (!inMyPrivate) destinations.add(const MapEntry('private', 'Mon stock privé'));
    try {
      final groups = await GroupService().getUserGroups(uid).first;
      for (final g in groups) {
        final id = g['id'] as String;
        if (item.visibility == FrigoVisibility.group && item.groupId == id) continue;
        destinations.add(MapEntry(id, 'Stock : ${g['name'] ?? 'Groupe'}'));
      }
    } catch (_) {}

    if (!mounted) return;
    if (destinations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucun autre stock disponible')),
      );
      return;
    }

    final qtyCtrl = TextEditingController(text: _formatQty(item.quantity));
    String? chosen = destinations.first.key;

    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (_, setState) => AlertDialog(
          title: Text('Transférer ${item.ingredientName}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Vers :', style: TextStyle(color: Colors.grey.shade700)),
                RadioGroup<String>(
                  groupValue: chosen,
                  onChanged: (v) => setState(() => chosen = v),
                  child: Column(
                    children: destinations
                        .map((d) => RadioListTile<String>(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              value: d.key,
                              title: Text(d.value),
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: qtyCtrl,
                  decoration: InputDecoration(
                    labelText: 'Quantité à transférer',
                    suffixText: item.unit,
                    helperText: 'Disponible : ${_formatQty(item.quantity)} ${item.unit}',
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Annuler')),
            ElevatedButton(
              onPressed: () => Navigator.pop(c, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
              ),
              child: const Text('Transférer'),
            ),
          ],
        ),
      ),
    );

    if (ok != true || chosen == null) return;

    final qty = double.tryParse(qtyCtrl.text.replaceAll(',', '.'));
    if (qty == null || qty <= 0 || qty > item.quantity + 0.000001) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Quantité invalide (maximum ${_formatQty(item.quantity)} ${item.unit})'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
      return;
    }

    try {
      await _frigoService.transferItem(item: item, destination: chosen!, quantity: qty);
      if (!mounted) return;
      final label = destinations.firstWhere((d) => d.key == chosen).value;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_formatQty(qty)} ${item.unit} de ${item.ingredientName} → $label'),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: const Color(0xFFEF4444)),
      );
    }
  }

  String _formatQty(double q) {
    final rounded = (q * 100).round() / 100;
    return rounded == rounded.roundToDouble()
        ? rounded.toStringAsFixed(0)
        : rounded.toString();
  }

  Future<void> _delete(FrigoFirestore item) async {
    final ok = await showDialog<bool>(context: context, builder: (c) => AlertDialog(title: const Text('Supprimer ?'), content: Text('Supprimer "${item.ingredientName}" du stock ?'), actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Non')), ElevatedButton(onPressed: () => Navigator.pop(c, true), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), foregroundColor: Colors.white), child: const Text('Oui'))]));
    if (ok != true || !mounted) return;

    try {
      await _frigoService.deleteFrigoItem(item.id);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${item.ingredientName} supprimé'), backgroundColor: const Color(0xFF10B981)));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: const Color(0xFFEF4444)));
    }
  }

  String _getLoc(String l) => l == 'frigo' ? '🧊 Frigo' : l == 'placard' ? '📦 Placard' : l == 'congélateur' ? '❄️ Congélateur' : l;

  String _getDate(DateTime d) {
    final diff = d.difference(DateTime.now()).inDays;
    if (diff < 0) return 'Périmé depuis ${-diff} j';
    if (diff == 0) return 'Expire aujourd\'hui';
    if (diff == 1) return 'Expire demain';
    return 'Expire dans $diff j';
  }
}

// SCANNER
class _BarcodeScannerScreen extends StatefulWidget {
  @override
  State<_BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<_BarcodeScannerScreen> {
  final _controller = MobileScannerController();
  bool _processing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_processing) return;
    final code = capture.barcodes.isNotEmpty ? capture.barcodes.first.rawValue : null;
    if (code == null) return;

    setState(() => _processing = true);
    _controller.stop();

    final product = await OpenFoodFactsService.fetchProduct(code);
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
      appBar: AppBar(title: const Text("Scanner"), backgroundColor: Colors.black, actions: [IconButton(icon: const Icon(Icons.flash_on), onPressed: () => _controller.toggleTorch())]),
      body: Stack(children: [MobileScanner(controller: _controller, onDetect: _onDetect), Center(child: Container(width: 250, height: 250, decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 2), borderRadius: BorderRadius.circular(12)))), if (_processing) Container(color: Colors.black54, child: const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [CircularProgressIndicator(color: Colors.white), SizedBox(height: 16), Text("Recherche...", style: TextStyle(color: Colors.white))])))]),
    );
  }
}