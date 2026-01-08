// lib/screens/recette/group_recipe_detail_screen.dart
import 'package:flutter/material.dart';
import '../../services/recette_firestore_service.dart';
import '../../services/auth_service.dart';
import '../../models/recette_firestore.dart';
import 'recette_firestore_detail.dart';
import 'recette_firestore_form.dart';
import '../../providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum RecipeType {
  all,
  private,
  group,
}

class GroupRecipeDetailScreen extends ConsumerStatefulWidget {
  final RecipeType recipeType;
  final String? groupId;
  final String title;

  const GroupRecipeDetailScreen({
    super.key,
    required this.recipeType,
    this.groupId,
    required this.title,
  });

  @override
  ConsumerState<GroupRecipeDetailScreen> createState() => _GroupRecipeDetailScreenState();
}

class _GroupRecipeDetailScreenState extends ConsumerState<GroupRecipeDetailScreen> {
  final _recetteService = RecetteFirestoreService();
  final _authService = AuthService();
  final _searchController = TextEditingController();

  String _searchQuery = '';
  String? _selectedCategory;

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
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
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
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        actions: [
          // Filtre par catégorie
          PopupMenuButton<String?>(
            icon: Icon(
              _selectedCategory != null ? Icons.category : Icons.category_outlined,
              color: _selectedCategory != null ? const Color(0xFF10B981) : const Color(0xFF64748B),
            ),
            tooltip: 'Filtrer par catégorie',
            onSelected: (value) {
              setState(() => _selectedCategory = value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Row(
                  children: [
                    Text('📍', style: TextStyle(fontSize: 20)),
                    SizedBox(width: 12),
                    Text('Toutes les catégories'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              ..._categories.map((cat) => PopupMenuItem(
                value: cat,
                child: Row(
                  children: [
                    Icon(
                      Icons.category,
                      color: _selectedCategory == cat ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(width: 12),
                    Text(cat),
                  ],
                ),
              )),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher une recette...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _searchController.clear(),
                )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),

          // Liste des recettes
          Expanded(
            child: StreamBuilder<List<RecetteFirestore>>(
              stream: _getRecipeStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return _buildErrorState(snapshot.error.toString());
                }

                var recipes = snapshot.data ?? [];

                // Filtrer par recherche
                if (_searchQuery.isNotEmpty) {
                  recipes = recipes.where((recipe) {
                    return recipe.name.toLowerCase().contains(_searchQuery);
                  }).toList();
                }

                // Filtrer par catégorie
                if (_selectedCategory != null) {
                  recipes = recipes.where((recipe) => recipe.category == _selectedCategory).toList();
                }

                if (recipes.isEmpty) {
                  return _buildEmptyState();
                }

                // Grouper par catégorie
                final groupedRecipes = _groupByCategory(recipes);

                return ListView(
                  padding: const EdgeInsets.only(top: 8, bottom: 80),
                  children: groupedRecipes.entries.map((entry) {
                    final category = entry.key;
                    final categoryRecipes = entry.value;

                    return _buildCategorySection(
                      category,
                      categoryRecipes,
                      _getCategoryColor(category),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addRecipe,
        backgroundColor: const Color(0xFF10B981),
        icon: const Icon(Icons.add),
        label: const Text('Créer'),
      ),
    );
  }

  // ============================================================================
  // CONSTRUCTION DES WIDGETS
  // ============================================================================

  Widget _buildCategorySection(String category, List<RecetteFirestore> recipes, Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header de section
        Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Text(
                category,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${recipes.length}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Liste des recettes de cette section
        ...recipes.map((recipe) => _buildRecipeCard(recipe)),

        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildRecipeCard(RecetteFirestore recipe) {
    final userId = _authService.currentUser?.uid ?? '';
    final canEdit = recipe.canEdit(userId);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showRecipeDetails(recipe),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icône de visibilité
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: recipe.visibility == RecetteVisibility.private
                        ? const Color(0xFFE0F2FE)
                        : const Color(0xFFD1FAE5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    recipe.visibility == RecetteVisibility.private
                        ? Icons.lock_outline
                        : Icons.group_outlined,
                    size: 24,
                    color: recipe.visibility == RecetteVisibility.private
                        ? const Color(0xFF0284C7)
                        : const Color(0xFF059669),
                  ),
                ),
                const SizedBox(width: 16),

                // Informations de la recette
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          // Portions
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.people_outline, size: 14, color: Color(0xFF475569)),
                                const SizedBox(width: 4),
                                Text(
                                  '${recipe.servings}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF475569),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Calories si disponibles
                          if (recipe.nutrition != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.local_fire_department, size: 14, color: Colors.orange),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${recipe.nutrition!['calories']?.toStringAsFixed(0) ?? '0'} kcal',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Menu d'actions
                if (canEdit)
                  PopupMenuButton(
                    icon: const Icon(Icons.more_vert, color: Color(0xFF64748B)),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'duplicate',
                        child: Row(
                          children: [
                            Icon(Icons.copy, size: 20),
                            SizedBox(width: 12),
                            Text('Dupliquer'),
                          ],
                        ),
                      ),
                      if (recipe.ownerId == userId)
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red, size: 20),
                              SizedBox(width: 12),
                              Text('Supprimer', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                    ],
                    onSelected: (value) {
                      if (value == 'duplicate') {
                        _duplicateRecipe(recipe);
                      } else if (value == 'delete') {
                        _deleteRecipe(recipe);
                      }
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.restaurant_menu_outlined,
                size: 64,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Aucune recette',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty || _selectedCategory != null
                  ? 'Aucune recette trouvée'
                  : 'Créez votre première recette',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF94A3B8),
              ),
            ),
            if (_searchQuery.isEmpty && _selectedCategory == null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _addRecipe,
                icon: const Icon(Icons.add),
                label: const Text('Créer une recette'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Color(0xFFEF4444)),
            const SizedBox(height: 16),
            const Text(
              'Erreur de chargement',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // LOGIQUE
  // ============================================================================

  Stream<List<RecetteFirestore>> _getRecipeStream() {
    switch (widget.recipeType) {
      case RecipeType.all:
        return _recetteService.getMyRecettes();
      case RecipeType.private:
        return _recetteService.getMyRecettes().map((recipes) {
          return recipes.where((r) => r.visibility == RecetteVisibility.private).toList();
        });
      case RecipeType.group:
        if (widget.groupId != null) {
          return _recetteService.getGroupRecettes(widget.groupId!);
        }
        return Stream.value([]);
    }
  }

  Map<String, List<RecetteFirestore>> _groupByCategory(List<RecetteFirestore> recipes) {
    final map = <String, List<RecetteFirestore>>{};

    for (final recipe in recipes) {
      final category = recipe.category ?? 'Autre';
      if (!map.containsKey(category)) {
        map[category] = [];
      }
      map[category]!.add(recipe);
    }

    // Trier chaque groupe par nom
    for (final list in map.values) {
      list.sort((a, b) => a.name.compareTo(b.name));
    }

    return map;
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Petit déjeuner':
        return const Color(0xFFFFE4B5);
      case 'Déjeuner':
        return const Color(0xFFD4E9D7);
      case 'Dîner':
        return const Color(0xFFE1D5E7);
      case 'Collation':
        return const Color(0xFFFFF0E5);
      case 'Dessert':
        return const Color(0xFFFFCDD2);
      case 'Entrée':
        return const Color(0xFFD4F1F4);
      case 'Plat principal':
        return const Color(0xFFFEF3C7);
      case 'Accompagnement':
        return const Color(0xFFDCFCE7);
      case 'Boisson':
        return const Color(0xFFDBEAFE);
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  // ============================================================================
  // ACTIONS
  // ============================================================================

  void _showRecipeDetails(RecetteFirestore recipe) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecetteFirestoreDetail(recetteId: recipe.id),
      ),
    );
  }

  Future<void> _addRecipe() async {
    RecetteVisibility visibility;
    String? groupId;
    String? groupName;

    if (widget.recipeType == RecipeType.group) {
      visibility = RecetteVisibility.group;
      groupId = widget.groupId;
      groupName = widget.title;
    } else {
      visibility = RecetteVisibility.private;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecetteFirestoreForm(
          defaultVisibility: visibility,
          groupId: groupId,
          groupName: groupName,
        ),
      ),
    );
  }

  Future<void> _duplicateRecipe(RecetteFirestore recipe) async {
    try {
      await _recetteService.duplicateRecette(sourceRecetteId: recipe.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${recipe.name} dupliquée !'),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
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

  Future<void> _deleteRecipe(RecetteFirestore recipe) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Supprimer cette recette ?'),
        content: Text('Voulez-vous vraiment supprimer "${recipe.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(c, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _recetteService.deleteRecette(recipe.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${recipe.name} supprimée'),
              backgroundColor: const Color(0xFF10B981),
            ),
          );
        }
      } catch (e) {
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
  }
}