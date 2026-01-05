// lib/screens/recette/recette_form.dart
import 'package:flutter/material.dart';
import '../../repositories/recette_repository.dart';
import '../../repositories/ingredient_repository.dart';
import '../../database.dart';

class RecetteFormScreen extends StatefulWidget {
  final RecetteRepository recetteRepository;

  const RecetteFormScreen({
    super.key,
    required this.recetteRepository,
  });

  @override
  State<RecetteFormScreen> createState() => _RecetteFormScreenState();
}

class _RecetteFormScreenState extends State<RecetteFormScreen> {
  final _nameCtrl = TextEditingController();
  final _instructionsCtrl = TextEditingController();
  final _servingsCtrl = TextEditingController(text: '1');

  final List<Map<String, dynamic>> _localIngredients = [];

  Ingredient? _selectedIngredient;
  final _quantCtrl = TextEditingController();
  String _unite = 'g';

  Future<List<Ingredient>> _loadIngredients() async {
    final repo = IngredientRepository(widget.recetteRepository.attachedDatabase);
    return repo.getAllIngredients();
  }

  void _addLocalIngredient() {
    final ing = _selectedIngredient;
    final q = double.tryParse(_quantCtrl.text.trim()) ?? 0.0;
    if (ing == null || q <= 0) return;

    setState(() {
      _localIngredients.add({
        'ingredient': ing,
        'quantity': q,
        'unit': _unite,
      });
      _selectedIngredient = null;
      _quantCtrl.clear();
      _unite = 'g';
    });
  }

  Future<void> _saveRecette() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Le nom de la recette est obligatoire")),
      );
      return;
    }

    final instructions = _instructionsCtrl.text.trim();
    final servings = int.tryParse(_servingsCtrl.text.trim()) ?? 1;

    // Créer la recette
    final newId = await widget.recetteRepository.insertRecette(
      name: name,
      instructions: instructions.isEmpty ? null : instructions,
      servings: servings,
    );

    // Ajouter les ingrédients
    for (final row in _localIngredients) {
      final Ingredient ing = row['ingredient'];
      final double q = row['quantity'];
      final String unite = row['unit'];

      await widget.recetteRepository.addIngredientToRecette(
        recetteId: newId,
        ingredientId: ing.id,
        quantity: q,
        unit: unite,
      );
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Recette créée avec succès !")),
    );

    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _instructionsCtrl.dispose();
    _servingsCtrl.dispose();
    _quantCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Créer une recette"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveRecette,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informations de base
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                        labelText: "Nom de la recette *",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.restaurant),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _servingsCtrl,
                      decoration: const InputDecoration(
                        labelText: "Nombre de portions",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.people),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _instructionsCtrl,
                      decoration: const InputDecoration(
                        labelText: "Instructions de préparation",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.note),
                        hintText: "Étapes de préparation...",
                      ),
                      maxLines: 6,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Section des ingrédients
            Text(
              "Ingrédients",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),

            FutureBuilder<List<Ingredient>>(
              future: _loadIngredients(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final list = snap.data ?? [];

                if (list.isEmpty) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        "Aucun ingrédient disponible.\nAjoutez d'abord des ingrédients depuis l'onglet Ingrédients.",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                return Column(
                  children: [
                    // Formulaire d'ajout d'ingrédient
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            DropdownButtonFormField<Ingredient>(
                              initialValue: _selectedIngredient,
                              hint: const Text("Choisir un ingrédient"),
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.search),
                              ),
                              isExpanded: true,
                              items: list
                                  .map((i) => DropdownMenuItem(
                                value: i,
                                child: Text(i.name),
                              ))
                                  .toList(),
                              onChanged: (v) => setState(() => _selectedIngredient = v),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: TextField(
                                    controller: _quantCtrl,
                                    decoration: const InputDecoration(
                                      labelText: "Quantité",
                                      border: OutlineInputBorder(),
                                    ),
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 1,
                                  child: DropdownButtonFormField<String>(
                                    initialValue: _unite,
                                    decoration: const InputDecoration(
                                      labelText: "Unité",
                                      border: OutlineInputBorder(),
                                    ),
                                    items: const [
                                      DropdownMenuItem(value: 'g', child: Text('g')),
                                      DropdownMenuItem(value: 'ml', child: Text('ml')),
                                      DropdownMenuItem(value: 'unité', child: Text('unité')),
                                    ],
                                    onChanged: (v) => setState(() => _unite = v ?? 'g'),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _addLocalIngredient,
                                icon: const Icon(Icons.add),
                                label: const Text("Ajouter l'ingrédient"),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Liste des ingrédients ajoutés
                    if (_localIngredients.isEmpty)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            "Aucun ingrédient ajouté pour le moment",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ),
                      )
                    else
                      Card(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.list, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    "${_localIngredients.length} ingrédient(s) ajouté(s)",
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(height: 1),
                            ..._localIngredients.map((row) {
                              final Ingredient ing = row['ingredient'];
                              final double qty = row['quantity'];
                              final String unit = row['unit'];

                              return ListTile(
                                leading: CircleAvatar(
                                  child: Text(ing.name[0].toUpperCase()),
                                ),
                                title: Text(ing.name),
                                subtitle: Text("$qty $unit"),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    setState(() => _localIngredients.remove(row));
                                  },
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),

            const SizedBox(height: 20),

            // Bouton de sauvegarde
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saveRecette,
                icon: const Icon(Icons.save),
                label: const Text("Enregistrer la recette"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}