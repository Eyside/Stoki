// lib/screens/recette/recette_firestore_form.dart
import 'package:flutter/material.dart';
import '../../models/recette_firestore.dart';
import '../../services/recette_firestore_service.dart';
import '../../services/group_service.dart';
import '../../services/auth_service.dart';
import '../../repositories/ingredient_repository.dart';
import '../../database.dart';
import 'recette_firestore_detail.dart';

class RecetteFirestoreForm extends StatefulWidget {
  final RecetteFirestore? recette;
  final IngredientRepository ingredientRepository;

  const RecetteFirestoreForm({
    super.key,
    this.recette,
    required this.ingredientRepository,
  });

  @override
  State<RecetteFirestoreForm> createState() => _RecetteFirestoreFormState();
}

class _RecetteFirestoreFormState extends State<RecetteFirestoreForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _instructionsCtrl = TextEditingController();
  final _servingsCtrl = TextEditingController(text: '1');
  final _notesCtrl = TextEditingController();

  final _recetteService = RecetteFirestoreService();
  final _groupService = GroupService();
  final _authService = AuthService();

  RecetteVisibility _visibility = RecetteVisibility.private;
  String? _selectedCategory;
  String? _selectedGroupId;
  List<Map<String, dynamic>> _userGroups = [];
  bool _isLoading = false;

  // NOUVEAU: Liste des ingrédients en attente
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
    _loadUserGroups();

    if (widget.recette != null) {
      _nameCtrl.text = widget.recette!.name;
      _instructionsCtrl.text = widget.recette!.instructions ?? '';
      _servingsCtrl.text = widget.recette!.servings.toString();
      _notesCtrl.text = widget.recette!.notes ?? '';
      _selectedCategory = widget.recette!.category;
      _visibility = widget.recette!.visibility;
      _selectedGroupId = widget.recette!.groupId;
    }
  }

  Future<void> _loadUserGroups() async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) return;

    _groupService.getUserGroups(userId).listen((groups) {
      if (mounted) {
        setState(() {
          _userGroups = groups;
        });
      }
    });
  }

  // NOUVEAU: Ajouter un ingrédient à la liste temporaire
  Future<void> _addIngredient() async {
    final ingredients = await widget.ingredientRepository.getAllIngredients();

    if (!mounted) return;

    Ingredient? selected;
    final quantCtrl = TextEditingController();
    String unite = 'g';

    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c2, setDialogState) => AlertDialog(
          title: const Text("Ajouter ingrédient"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<Ingredient>(
                value: selected,
                hint: const Text("Choisir un ingrédient"),
                isExpanded: true,
                items: ingredients
                    .map((i) => DropdownMenuItem(
                  value: i,
                  child: Text(i.name),
                ))
                    .toList(),
                onChanged: (v) => setDialogState(() => selected = v),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: quantCtrl,
                decoration: const InputDecoration(
                  labelText: "Quantité",
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              DropdownButton<String>(
                value: unite,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 'g', child: Text('g (grammes)')),
                  DropdownMenuItem(value: 'ml', child: Text('ml (millilitres)')),
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
              child: const Text("Ajouter"),
            ),
          ],
        ),
      ),
    );

    if (ok == true && selected != null) {
      final q = double.tryParse(quantCtrl.text.trim()) ?? 0.0;
      if (q > 0) {
        final ingredient = RecetteIngredientFirestore(
          ingredientId: selected!.id.toString(),
          ingredientName: selected!.name,
          quantity: q,
          unit: unite,
          caloriesPer100g: selected!.caloriesPer100g,
          proteinsPer100g: selected!.proteinsPer100g,
          fatsPer100g: selected!.fatsPer100g,
          carbsPer100g: selected!.carbsPer100g,
          fibersPer100g: selected!.fibersPer100g,
          densityGPerMl: selected!.densityGPerMl,
          avgWeightPerUnitG: selected!.avgWeightPerUnitG,
        );

        setState(() {
          _pendingIngredients.add(ingredient);
        });
      }
    }
  }

  // NOUVEAU: Supprimer un ingrédient de la liste temporaire
  void _removeIngredient(int index) {
    setState(() {
      _pendingIngredients.removeAt(index);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_visibility == RecetteVisibility.group && _selectedGroupId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sélectionnez un groupe pour une recette de groupe')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (widget.recette == null) {
        // Création
        final recetteId = await _recetteService.createRecette(
          name: _nameCtrl.text.trim(),
          instructions: _instructionsCtrl.text.trim(),
          servings: int.tryParse(_servingsCtrl.text) ?? 1,
          category: _selectedCategory,
          notes: _notesCtrl.text.trim(),
          visibility: _visibility,
          groupId: _selectedGroupId,
        );

        // NOUVEAU: Ajouter tous les ingrédients
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
            ),
          );
        }
      } else {
        // Modification
        await _recetteService.updateRecette(
          recetteId: widget.recette!.id,
          name: _nameCtrl.text.trim(),
          instructions: _instructionsCtrl.text.trim(),
          servings: int.tryParse(_servingsCtrl.text) ?? 1,
          category: _selectedCategory,
          notes: _notesCtrl.text.trim(),
        );

        if (mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Recette modifiée !')),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.recette != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier la recette' : 'Nouvelle recette cloud'),
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
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
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

                  // Visibilité (seulement à la création)
                  if (!isEditing) ...[
                    Card(
                      color: Colors.blue.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.visibility, color: Colors.blue.shade700),
                                const SizedBox(width: 8),
                                Text(
                                  'Visibilité',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade700,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            RadioListTile<RecetteVisibility>(
                              title: const Text('Privée'),
                              subtitle: const Text('Visible uniquement par moi'),
                              value: RecetteVisibility.private,
                              groupValue: _visibility,
                              onChanged: (v) => setState(() {
                                _visibility = v!;
                                _selectedGroupId = null;
                              }),
                              secondary: const Icon(Icons.lock),
                            ),

                            RadioListTile<RecetteVisibility>(
                              title: const Text('Recette de groupe'),
                              subtitle: const Text('Tous les membres peuvent la modifier'),
                              value: RecetteVisibility.group,
                              groupValue: _visibility,
                              onChanged: (v) => setState(() => _visibility = v!),
                              secondary: const Icon(Icons.group),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],

                  // Sélection du groupe
                  if (_visibility == RecetteVisibility.group) ...[
                    DropdownButtonFormField<String>(
                      initialValue: _selectedGroupId,
                      decoration: const InputDecoration(
                        labelText: 'Groupe *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.group),
                      ),
                      items: _userGroups.map((group) {
                        return DropdownMenuItem<String>(
                          value: group['id'],
                          child: Text(group['name'] ?? 'Groupe'),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _selectedGroupId = v),
                      validator: (v) => v == null ? 'Sélectionnez un groupe' : null,
                    ),

                    const SizedBox(height: 16),
                  ],

                  // Catégorie
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
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

                  // NOUVEAU: Section ingrédients
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
                              child: Text(ingredient.ingredientName[0].toUpperCase()),
                            ),
                            title: Text(ingredient.ingredientName),
                            subtitle: Text('${ingredient.quantity} ${ingredient.unit}'),
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