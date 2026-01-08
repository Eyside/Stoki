// lib/screens/recette/recette_firestore_form.dart (VERSION CLOUD FINALE)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/recette_firestore.dart';
import '../../models/ingredient_firestore.dart';
import '../../services/recette_firestore_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/ingredient_picker_cloud_widget.dart';
import 'recette_firestore_detail.dart';

class RecetteFirestoreForm extends ConsumerStatefulWidget {
  final RecetteFirestore? recette;

  // ✅ Paramètres pour pré-remplir selon le contexte
  final RecetteVisibility? defaultVisibility;
  final String? groupId;
  final String? groupName;

  const RecetteFirestoreForm({
    super.key,
    this.recette,
    this.defaultVisibility,
    this.groupId,
    this.groupName,
  });

  @override
  ConsumerState<RecetteFirestoreForm> createState() => _RecetteFirestoreFormState();
}

class _RecetteFirestoreFormState extends ConsumerState<RecetteFirestoreForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _instructionsCtrl = TextEditingController();
  final _servingsCtrl = TextEditingController(text: '1');
  final _notesCtrl = TextEditingController();

  final _recetteService = RecetteFirestoreService();
  final _authService = AuthService();

  late RecetteVisibility _visibility;
  String? _selectedCategory;
  late String? _selectedGroupId;
  late String? _selectedGroupName;
  bool _isLoading = false;

  final List<RecetteIngredientFirestore> _pendingIngredients = [];

  final _categories = [
    'Petit déjeuner',
    'Déjeuner',
    'Dîner',
    'Collation',
    'Dessert',
    'Entrée',
    'Plat principal',
    'Accompagnement',
    'Boisson',
    'Autre',
  ];

  @override
  void initState() {
    super.initState();

    if (widget.recette != null) {
      // Mode édition
      _nameCtrl.text = widget.recette!.name;
      _instructionsCtrl.text = widget.recette!.instructions ?? '';
      _servingsCtrl.text = widget.recette!.servings.toString();
      _notesCtrl.text = widget.recette!.notes ?? '';
      _selectedCategory = widget.recette!.category;
      _visibility = widget.recette!.visibility;
      _selectedGroupId = widget.recette!.groupId;
      _selectedGroupName = null; // Le groupName n'existe pas sur RecetteFirestore
    } else {
      // Mode création - utiliser les valeurs par défaut du contexte
      _visibility = widget.defaultVisibility ?? RecetteVisibility.private;
      _selectedGroupId = widget.groupId;
      _selectedGroupName = widget.groupName;
    }
  }

  // ✅ VERSION CLOUD avec le nouveau picker
  Future<void> _addIngredient() async {
    // Afficher le picker d'ingrédients cloud
    final ingredient = await showIngredientPickerCloud(context, ref);

    if (ingredient == null) return;

    if (!mounted) return;

    // Demander la quantité
    final quantCtrl = TextEditingController();
    String unite = 'g';

    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c2, setDialogState) => AlertDialog(
          title: Text("Ajouter ${ingredient.name}"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Infos de l'ingrédient
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      ingredient.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${ingredient.caloriesPer100g.toStringAsFixed(0)} kcal/100g',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Quantité
              TextField(
                controller: quantCtrl,
                decoration: const InputDecoration(
                  labelText: "Quantité",
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
              ),
              const SizedBox(height: 12),

              // Unité
              DropdownButtonFormField<String>(
                value: unite,
                decoration: const InputDecoration(
                  labelText: "Unité",
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'g', child: Text('g (grammes)')),
                  DropdownMenuItem(value: 'kg', child: Text('kg (kilogrammes)')),
                  DropdownMenuItem(value: 'ml', child: Text('ml (millilitres)')),
                  DropdownMenuItem(value: 'L', child: Text('L (litres)')),
                  DropdownMenuItem(value: 'unité', child: Text('unité (pièce)')),
                ],
                onChanged: (v) => setDialogState(() => unite = v ?? 'g'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(c, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
              ),
              child: const Text("Ajouter"),
            ),
          ],
        ),
      ),
    );

    if (ok == true) {
      final q = double.tryParse(quantCtrl.text.trim()) ?? 0.0;
      if (q > 0) {
        final recetteIngredient = RecetteIngredientFirestore(
          ingredientId: ingredient.id, // ✅ ID Cloud (String)
          ingredientName: ingredient.name,
          quantity: q,
          unit: unite,
          caloriesPer100g: ingredient.caloriesPer100g,
          proteinsPer100g: ingredient.proteinsPer100g,
          fatsPer100g: ingredient.fatsPer100g,
          carbsPer100g: ingredient.carbsPer100g,
          fibersPer100g: ingredient.fibersPer100g,
          densityGPerMl: ingredient.densityGPerMl,
          avgWeightPerUnitG: ingredient.avgWeightPerUnitG,
        );

        setState(() {
          _pendingIngredients.add(recetteIngredient);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${ingredient.name} ajouté ($q $unite)'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _removeIngredient(int index) {
    setState(() {
      _pendingIngredients.removeAt(index);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_visibility == RecetteVisibility.group && _selectedGroupId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur: groupe non défini')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (widget.recette == null) {
        // Création
        final recetteId = await _recetteService.createRecette(
          name: _nameCtrl.text.trim(),
          instructions: _instructionsCtrl.text.trim().isEmpty ? null : _instructionsCtrl.text.trim(),
          servings: int.tryParse(_servingsCtrl.text) ?? 1,
          category: _selectedCategory,
          notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
          visibility: _visibility,
          groupId: _visibility == RecetteVisibility.group ? _selectedGroupId : null,
        );

        // Ajouter tous les ingrédients
        for (final ingredient in _pendingIngredients) {
          await _recetteService.addIngredient(
            recetteId: recetteId,
            ingredient: ingredient,
          );
        }

        if (mounted) {
          Navigator.pop(context); // Ferme le formulaire
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RecetteFirestoreDetail(recetteId: recetteId),
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_pendingIngredients.isEmpty
                  ? 'Recette créée !'
                  : 'Recette créée avec ${_pendingIngredients.length} ingrédient(s) !'),
              backgroundColor: const Color(0xFF10B981),
            ),
          );
        }
      } else {
        // Modification
        await _recetteService.updateRecette(
          recetteId: widget.recette!.id,
          name: _nameCtrl.text.trim(),
          instructions: _instructionsCtrl.text.trim().isEmpty ? null : _instructionsCtrl.text.trim(),
          servings: int.tryParse(_servingsCtrl.text) ?? 1,
          category: _selectedCategory,
          notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        );

        if (mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Recette modifiée !'),
              backgroundColor: Color(0xFF10B981),
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
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

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.recette != null;
    final isGroupContext = widget.groupId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier la recette' : 'Nouvelle recette'),
        actions: [
          IconButton(
            icon: _isLoading
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Icon(Icons.check),
            onPressed: _isLoading ? null : _save,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ✅ Info du contexte (si groupe)
            if (isGroupContext && !isEditing) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF059669)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.group, color: Color(0xFF059669)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Recette de groupe',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF059669),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Sera ajoutée au groupe "${_selectedGroupName ?? widget.groupName}"',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF047857),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Nom
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Nom de la recette *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.restaurant),
              ),
              validator: (v) => v?.trim().isEmpty ?? true ? 'Obligatoire' : null,
            ),

            const SizedBox(height: 16),

            // Catégorie
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Catégorie',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: _categories.map((cat) {
                return DropdownMenuItem(value: cat, child: Text(cat));
              }).toList(),
              onChanged: (v) => setState(() => _selectedCategory = v),
            ),

            const SizedBox(height: 16),

            // Nombre de portions
            TextFormField(
              controller: _servingsCtrl,
              decoration: const InputDecoration(
                labelText: 'Nombre de portions *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.restaurant_menu),
              ),
              keyboardType: TextInputType.number,
              validator: (v) {
                final n = int.tryParse(v ?? '');
                if (n == null || n < 1) return 'Minimum 1 portion';
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Instructions
            TextFormField(
              controller: _instructionsCtrl,
              decoration: const InputDecoration(
                labelText: 'Instructions',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
                alignLabelWithHint: true,
              ),
              maxLines: 5,
            ),

            const SizedBox(height: 16),

            // Notes
            TextFormField(
              controller: _notesCtrl,
              decoration: const InputDecoration(
                labelText: 'Notes personnelles',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 24),

            // Section ingrédients
            if (!isEditing) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Ingrédients (optionnel)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    onPressed: _addIngredient,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Ajouter'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              if (_pendingIngredients.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Aucun ingrédient ajouté',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                ..._pendingIngredients.asMap().entries.map((entry) {
                  final index = entry.key;
                  final ingredient = entry.value;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF10B981),
                        child: Text(
                          ingredient.ingredientName[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        ingredient.ingredientName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        '${ingredient.quantity} ${ingredient.unit} • '
                            '${ingredient.caloriesPer100g.toStringAsFixed(0)} kcal/100g',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeIngredient(index),
                      ),
                    ),
                  );
                }),

              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _instructionsCtrl.dispose();
    _servingsCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }
}