// lib/widgets/ingredient_picker_cloud_widget.dart
// Widget pour sélectionner un ingrédient depuis le cloud

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ingredient_firestore.dart';
import '../services/ingredient_firestore_service.dart';
import '../providers.dart';

class IngredientPickerCloud extends ConsumerStatefulWidget {
  final Function(IngredientFirestore) onIngredientSelected;
  final String? preSelectedId;

  const IngredientPickerCloud({
    super.key,
    required this.onIngredientSelected,
    this.preSelectedId,
  });

  @override
  ConsumerState<IngredientPickerCloud> createState() => _IngredientPickerCloudState();
}

class _IngredientPickerCloudState extends ConsumerState<IngredientPickerCloud> {
  List<IngredientFirestore> _ingredients = [];
  List<IngredientFirestore> _filteredIngredients = [];
  bool _isLoading = true;
  String _searchQuery = '';
  IngredientFirestore? _selectedIngredient;

  @override
  void initState() {
    super.initState();
    _loadIngredients();
  }

  Future<void> _loadIngredients() async {
    setState(() => _isLoading = true);
    try {
      final service = ref.read(ingredientFirestoreServiceProvider);
      final ingredients = await service.getAllAccessibleIngredients();
      setState(() {
        _ingredients = ingredients;
        _filteredIngredients = ingredients;
        _isLoading = false;

        // Pré-sélection si ID fourni
        if (widget.preSelectedId != null) {
          try {
            _selectedIngredient = ingredients
                .firstWhere((i) => i.id == widget.preSelectedId);
          } catch (e) {
            _selectedIngredient = null;
          }
        }
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterIngredients(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredIngredients = _ingredients;
      } else {
        _filteredIngredients = _ingredients
            .where((ing) => ing.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // En-tête
            Row(
              children: [
                const Icon(Icons.search),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Sélectionner un ingrédient',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Barre de recherche
            TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              onChanged: _filterIngredients,
              autofocus: true,
            ),
            const SizedBox(height: 16),

            // Liste des ingrédients
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredIngredients.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _searchQuery.isEmpty
                          ? 'Aucun ingrédient'
                          : 'Aucun résultat',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                itemCount: _filteredIngredients.length,
                itemBuilder: (context, index) {
                  final ingredient = _filteredIngredients[index];
                  final isSelected = _selectedIngredient?.id == ingredient.id;

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: isSelected
                        ? Colors.green.shade50
                        : null,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: ingredient.isCustom
                            ? Colors.blue
                            : Colors.green,
                        child: Text(
                          ingredient.name[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        ingredient.name,
                        style: TextStyle(
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (ingredient.category != null)
                            Text(
                              ingredient.category!,
                              style: const TextStyle(fontSize: 12),
                            ),
                          Text(
                            '${ingredient.caloriesPer100g.toStringAsFixed(0)} kcal/100g',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      trailing: isSelected
                          ? const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                      )
                          : null,
                      onTap: () {
                        setState(() => _selectedIngredient = ingredient);
                        widget.onIngredientSelected(ingredient);
                        Navigator.pop(context, ingredient);
                      },
                    ),
                  );
                },
              ),
            ),

            // Bouton de création rapide
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO: Ouvrir dialog de création rapide d'ingrédient
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Création rapide - À venir'),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Créer un nouvel ingrédient'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fonction helper pour afficher le picker
Future<IngredientFirestore?> showIngredientPickerCloud(
    BuildContext context,
    WidgetRef ref, {
      String? preSelectedId,
    }) async {
  return await showDialog<IngredientFirestore>(
    context: context,
    builder: (context) => IngredientPickerCloud(
      preSelectedId: preSelectedId,
      onIngredientSelected: (ingredient) {
        // Le dialog se ferme automatiquement avec le résultat
      },
    ),
  );
}