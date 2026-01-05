// lib/screens/recette/recette_unified_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../database.dart';
import '../../models/recette_firestore.dart';
import '../../repositories/recette_repository.dart';
import '../../services/recette_firestore_service.dart';
import '../../services/group_service.dart';
import '../../services/auth_service.dart';
import '../../providers.dart';
import 'recette_detail.dart';
import 'recette_form.dart';
import 'recette_firestore_form.dart';
import 'recette_firestore_detail.dart';

enum RecetteSource {
  all,
  local,
  private,
  group,
}

class RecetteSourceOption {
  final RecetteSource type;
  final String label;
  final IconData icon;
  final String? groupId;
  final String? groupName;

  RecetteSourceOption({
    required this.type,
    required this.label,
    required this.icon,
    this.groupId,
    this.groupName,
  });
}

class RecetteWithNutrition {
  final Recette recette;
  final Map<String, double> nutrition;

  RecetteWithNutrition({
    required this.recette,
    required this.nutrition,
  });
}

class RecetteUnifiedScreen extends ConsumerStatefulWidget {
  final RecetteRepository recetteRepository;

  const RecetteUnifiedScreen({
    super.key,
    required this.recetteRepository,
  });

  @override
  ConsumerState<RecetteUnifiedScreen> createState() => _RecetteUnifiedScreenState();
}

class _RecetteUnifiedScreenState extends ConsumerState<RecetteUnifiedScreen> {
  final _recetteService = RecetteFirestoreService();
  final _groupService = GroupService();
  final _authService = AuthService();
  final _searchController = TextEditingController();

  List<RecetteSourceOption> _sourceOptions = [];
  RecetteSourceOption? _selectedSource;
  List<Map<String, dynamic>> _userGroups = [];
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
    _loadSourceOptions();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSourceOptions() async {
    final userId = _authService.currentUser?.uid;

    final options = <RecetteSourceOption>[
      RecetteSourceOption(
        type: RecetteSource.all,
        label: 'Toutes les recettes',
        icon: Icons.all_inclusive,
      ),
      RecetteSourceOption(
        type: RecetteSource.local,
        label: 'Mes recettes locales',
        icon: Icons.phone_android,
      ),
    ];

    if (userId != null) {
      options.add(
        RecetteSourceOption(
          type: RecetteSource.private,
          label: 'Mes recettes cloud',
          icon: Icons.cloud,
        ),
      );

      // Charger les groupes
      _groupService.getUserGroups(userId).listen((groups) {
        if (mounted) {
          setState(() {
            _userGroups = groups;
            _buildSourceOptions();
          });
        }
      });
    }

    setState(() {
      _sourceOptions = options;
      _selectedSource = options.first; // "Toutes les recettes" par défaut
    });
  }

  void _buildSourceOptions() {
    final userId = _authService.currentUser?.uid;

    final options = <RecetteSourceOption>[
      RecetteSourceOption(
        type: RecetteSource.all,
        label: 'Toutes les recettes',
        icon: Icons.all_inclusive,
      ),
      RecetteSourceOption(
        type: RecetteSource.local,
        label: 'Mes recettes locales',
        icon: Icons.phone_android,
      ),
    ];

    if (userId != null) {
      options.add(
        RecetteSourceOption(
          type: RecetteSource.private,
          label: 'Mes recettes cloud',
          icon: Icons.cloud,
        ),
      );

      for (final group in _userGroups) {
        options.add(
          RecetteSourceOption(
            type: RecetteSource.group,
            label: group['name'] ?? 'Groupe',
            icon: Icons.group,
            groupId: group['id'],
            groupName: group['name'],
          ),
        );
      }
    }

    setState(() {
      _sourceOptions = options;
      _selectedSource ??= options.first;
    });
  }

  void _showSourceMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.filter_list),
                  const SizedBox(width: 12),
                  const Text(
                    'Filtrer les recettes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _sourceOptions.length,
                itemBuilder: (context, index) {
                  final option = _sourceOptions[index];
                  final isSelected = _selectedSource == option;

                  return ListTile(
                    leading: Icon(
                      option.icon,
                      color: isSelected ? Colors.green : null,
                    ),
                    title: Text(
                      option.label,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.green : null,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check, color: Colors.green)
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedSource = option;
                        _selectedCategory = null;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openForm() async {
    if (_selectedSource == null) return;

    final ingredientRepo = ref.read(ingredientRepositoryProvider);
    dynamic result;

    // Si "Toutes" ou "Locales" -> formulaire local
    if (_selectedSource!.type == RecetteSource.all ||
        _selectedSource!.type == RecetteSource.local) {
      result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RecetteFormScreen(
            recetteRepository: widget.recetteRepository,
          ),
        ),
      );
    } else {
      result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RecetteFirestoreForm(
            ingredientRepository: ingredientRepo,
          ),
        ),
      );
    }

    if (result != null) {
      setState(() {});
    }
  }

  void _openDetail(dynamic recette) async {
    if (recette is Recette) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RecetteDetailScreen(
            recetteRepository: widget.recetteRepository,
            recette: recette,
          ),
        ),
      );
      setState(() {});
    } else if (recette is RecetteFirestore) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RecetteFirestoreDetail(recetteId: recette.id),
        ),
      );
    }
  }

  Future<void> _duplicateRecette(dynamic recette) async {
    if (recette is Recette) {
      await widget.recetteRepository.duplicateRecette(recette.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recette locale dupliquée')),
        );
        setState(() {});
      }
    } else if (recette is RecetteFirestore) {
      await _recetteService.duplicateRecette(sourceRecetteId: recette.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recette cloud dupliquée')),
        );
      }
    }
  }

  Future<void> _deleteRecette(dynamic recette) async {
    final name = recette is Recette ? recette.name : (recette as RecetteFirestore).name;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Supprimer la recette'),
        content: Text('Voulez-vous vraiment supprimer « $name » ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(c, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (recette is Recette) {
        await widget.recetteRepository.deleteRecette(recette.id);
      } else if (recette is RecetteFirestore) {
        await _recetteService.deleteRecette(recette.id);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recette supprimée')),
        );
        setState(() {});
      }
    }
  }

  Future<void> _migrateToCloud(Recette recette) async {
    if (_authService.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vous devez être connecté pour migrer vers le cloud')),
      );
      return;
    }

    final visibility = await showDialog<RecetteVisibility>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Migrer vers le cloud'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Migrer « ${recette.name} » vers :'),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Recette privée'),
              subtitle: const Text('Visible uniquement par vous'),
              onTap: () => Navigator.pop(c, RecetteVisibility.private),
            ),
            if (_userGroups.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.group),
                title: const Text('Recette de groupe'),
                subtitle: const Text('Partagée avec un groupe'),
                onTap: () => Navigator.pop(c, RecetteVisibility.group),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );

    if (visibility == null) return;

    String? groupId;
    if (visibility == RecetteVisibility.group) {
      groupId = await showDialog<String>(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('Choisir un groupe'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _userGroups.length,
              itemBuilder: (context, index) {
                final group = _userGroups[index];
                return ListTile(
                  leading: const Icon(Icons.group),
                  title: Text(group['name'] ?? 'Groupe'),
                  onTap: () => Navigator.pop(c, group['id']),
                );
              },
            ),
          ),
        ),
      );

      if (groupId == null) return;
    }

    try {
      final ingredients = await widget.recetteRepository.getIngredientsForRecette(recette.id);

      final recetteId = await _recetteService.createRecette(
        name: recette.name,
        instructions: recette.instructions,
        servings: recette.servings,
        category: recette.category,
        notes: recette.notes,
        visibility: visibility,
        groupId: groupId,
      );

      for (final item in ingredients) {
        final ri = item['recetteIngredient'] as RecetteIngredient;
        final ing = item['ingredient'] as Ingredient?;

        if (ing != null) {
          final cloudIngredient = RecetteIngredientFirestore(
            ingredientId: ing.id.toString(),
            ingredientName: ing.name,
            quantity: ri.quantity,
            unit: ri.unit,
            caloriesPer100g: ing.caloriesPer100g,
            proteinsPer100g: ing.proteinsPer100g,
            fatsPer100g: ing.fatsPer100g,
            carbsPer100g: ing.carbsPer100g,
            fibersPer100g: ing.fibersPer100g,
            densityGPerMl: ing.densityGPerMl,
            avgWeightPerUnitG: ing.avgWeightPerUnitG,
          );

          await _recetteService.addIngredient(
            recetteId: recetteId,
            ingredient: cloudIngredient,
          );
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Recette migrée vers le cloud avec ${ingredients.length} ingrédient(s) !'),
            action: SnackBarAction(
              label: 'Supprimer locale',
              onPressed: () async {
                await widget.recetteRepository.deleteRecette(recette.id);
                setState(() {});
              },
            ),
          ),
        );
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la migration: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedSource == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Recettes'),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_selectedSource!.icon, size: 14, color: Colors.green.shade700),
                  const SizedBox(width: 4),
                  Text(
                    _selectedSource!.label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Bouton de filtre par source
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filtrer par source',
            onPressed: _showSourceMenu,
          ),
          // Bouton de filtre par catégorie
          PopupMenuButton<String>(
            icon: Icon(
              Icons.category,
              color: _selectedCategory != null ? Colors.green : null,
            ),
            tooltip: 'Filtrer par catégorie',
            onSelected: (value) {
              setState(() {
                _selectedCategory = value == 'all' ? null : value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Row(
                  children: [
                    Icon(Icons.all_inclusive),
                    SizedBox(width: 8),
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
                    const SizedBox(width: 8),
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher une recette...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          // Liste des recettes
          Expanded(child: _buildRecettesList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openForm,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildRecettesList() {
    if (_selectedSource!.type == RecetteSource.all) {
      return _buildAllRecettes();
    } else if (_selectedSource!.type == RecetteSource.local) {
      return _buildLocalRecettes();
    } else {
      return _buildCloudRecettes();
    }
  }

  Widget _buildAllRecettes() {
    return FutureBuilder<List<dynamic>>(
      future: _loadAllRecettes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Erreur: ${snapshot.error}'),
              ],
            ),
          );
        }

        var recettes = snapshot.data ?? [];
        recettes = _filterAllRecettes(recettes);

        if (recettes.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: recettes.length,
          itemBuilder: (context, index) {
            final item = recettes[index];
            if (item is RecetteWithNutrition) {
              return _buildLocalRecetteCard(item);
            } else if (item is RecetteFirestore) {
              return _buildCloudRecetteCard(item);
            }
            return const SizedBox.shrink();
          },
        );
      },
    );
  }

  Widget _buildLocalRecettes() {
    return FutureBuilder<List<RecetteWithNutrition>>(
      future: _loadLocalRecettesWithNutrition(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Erreur: ${snapshot.error}'),
              ],
            ),
          );
        }

        var recettes = snapshot.data ?? [];
        recettes = _filterLocalRecettes(recettes);

        if (recettes.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: recettes.length,
          itemBuilder: (context, index) {
            final item = recettes[index];
            return _buildLocalRecetteCard(item);
          },
        );
      },
    );
  }

  Widget _buildCloudRecettes() {
    Stream<List<RecetteFirestore>> stream;

    if (_selectedSource!.type == RecetteSource.private) {
      stream = _recetteService.getMyRecettes().map((list) =>
          list.where((r) => r.visibility == RecetteVisibility.private).toList());
    } else {
      final groupId = _selectedSource!.groupId!;
      stream = _recetteService.getGroupRecettes(groupId);
    }

    return StreamBuilder<List<RecetteFirestore>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Erreur: ${snapshot.error}'),
              ],
            ),
          );
        }

        var recettes = snapshot.data ?? [];
        recettes = _filterCloudRecettes(recettes);

        if (recettes.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: recettes.length,
          itemBuilder: (context, index) {
            final recette = recettes[index];
            return _buildCloudRecetteCard(recette);
          },
        );
      },
    );
  }

  Future<List<dynamic>> _loadAllRecettes() async {
    final localRecettes = await _loadLocalRecettesWithNutrition();
    final List<dynamic> allRecettes = List.from(localRecettes);

    if (_authService.currentUser != null) {
      try {
        final cloudRecettes = await _recetteService.getMyRecettes().first;
        allRecettes.addAll(cloudRecettes);
      } catch (e) {
        // Ignorer les erreurs cloud si non connecté
      }
    }

    return allRecettes;
  }

  List<dynamic> _filterAllRecettes(List<dynamic> recettes) {
    return recettes.where((item) {
      String name;
      String? category;

      if (item is RecetteWithNutrition) {
        name = item.recette.name;
        category = item.recette.category;
      } else if (item is RecetteFirestore) {
        name = item.name;
        category = item.category;
      } else {
        return false;
      }

      if (_searchQuery.isNotEmpty) {
        if (!name.toLowerCase().contains(_searchQuery)) {
          return false;
        }
      }

      if (_selectedCategory != null) {
        if (category != _selectedCategory) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  List<RecetteWithNutrition> _filterLocalRecettes(List<RecetteWithNutrition> recettes) {
    return recettes.where((item) {
      final recette = item.recette;

      if (_searchQuery.isNotEmpty) {
        if (!recette.name.toLowerCase().contains(_searchQuery)) {
          return false;
        }
      }

      if (_selectedCategory != null) {
        if (recette.category != _selectedCategory) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  List<RecetteFirestore> _filterCloudRecettes(List<RecetteFirestore> recettes) {
    return recettes.where((recette) {
      if (_searchQuery.isNotEmpty) {
        if (!recette.name.toLowerCase().contains(_searchQuery)) {
          return false;
        }
      }

      if (_selectedCategory != null) {
        if (recette.category != _selectedCategory) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  Widget _buildEmptyState() {
    String message = 'Aucune recette';

    if (_searchQuery.isNotEmpty || _selectedCategory != null) {
      message = 'Aucune recette trouvée';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant_menu, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
          if (_searchQuery.isNotEmpty || _selectedCategory != null) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _selectedCategory = null;
                });
              },
              icon: const Icon(Icons.clear),
              label: const Text('Réinitialiser les filtres'),
            ),
          ] else ...[
            const SizedBox(height: 8),
            Text(
              'Appuyez sur + pour créer votre première recette',
              style: TextStyle(color: Colors.grey.shade500),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _openForm,
              icon: const Icon(Icons.add),
              label: const Text('Créer une recette'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLocalRecetteCard(RecetteWithNutrition item) {
    final recette = item.recette;
    final nutrition = item.nutrition;

    return Card(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: ListTile(
          leading: Stack(
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue,
                child: Text(
                  recette.name[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.phone_android,
                    size: 12,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  recette.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              if (recette.category != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    recette.category!,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                '${nutrition['calories']?.toStringAsFixed(0) ?? '0'} kcal • ${recette.servings} portion(s)',
              ),
              const SizedBox(height: 2),
              Text(
                'P: ${nutrition['proteins']?.toStringAsFixed(0) ?? '0'}g • G: ${nutrition['carbs']?.toStringAsFixed(0) ?? '0'}g • L: ${nutrition['fats']?.toStringAsFixed(0) ?? '0'}g',
                style: const TextStyle(fontSize: 11),
              ),
            ],
          ),
          onTap: () => _openDetail(recette),
          trailing: PopupMenuButton(
              icon: const Icon(Icons.more_vert),
              itemBuilder: (context) => [
              if (_authService.currentUser != null)
          const PopupMenuItem(
          value: 'migrate',
          child: Row(
            children: [
              Icon(Icons.cloud_upload, color: Colors.blue),
              SizedBox(width: 8),
              Text('Migrer vers le cloud', style: TextStyle(color: Colors.blue)),
            ],
          ),
        ),
                const PopupMenuItem(
                  value: 'duplicate',
                  child: Row(
                    children: [
                      Icon(Icons.copy),
                      SizedBox(width: 8),
                      Text('Dupliquer'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Supprimer', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            onSelected: (value) {
              if (value == 'migrate') {
                _migrateToCloud(recette);
              } else if (value == 'duplicate') {
                _duplicateRecette(recette);
              } else if (value == 'delete') {
                _deleteRecette(recette);
              }
            },
          ),
        ),
    );
  }

  Widget _buildCloudRecetteCard(RecetteFirestore recette) {
    final userId = _authService.currentUser?.uid ?? '';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Stack(
          children: [
            CircleAvatar(
              backgroundColor: _getVisibilityColor(recette.visibility),
              child: Text(
                recette.name[0].toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getVisibilityIcon(recette.visibility),
                  size: 12,
                  color: _getVisibilityColor(recette.visibility),
                ),
              ),
            ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                recette.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            if (recette.category != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  recette.category!,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('${recette.servings} portion(s)'),
            if (recette.nutrition != null) ...[
              const SizedBox(height: 2),
              Text(
                '${recette.nutrition!['calories']?.toStringAsFixed(0)} kcal',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ],
        ),
        onTap: () => _openDetail(recette),
        trailing: PopupMenuButton(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) {
            final canEdit = recette.canEdit(userId);

            return [
              if (canEdit)
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('Modifier'),
                    ],
                  ),
                ),
              const PopupMenuItem(
                value: 'duplicate',
                child: Row(
                  children: [
                    Icon(Icons.copy),
                    SizedBox(width: 8),
                    Text('Dupliquer'),
                  ],
                ),
              ),
              if (canEdit && recette.ownerId == userId)
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Supprimer', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
            ];
          },
          onSelected: (value) {
            if (value == 'duplicate') {
              _duplicateRecette(recette);
            } else if (value == 'delete') {
              _deleteRecette(recette);
            }
          },
        ),
      ),
    );
  }

  Future<List<RecetteWithNutrition>> _loadLocalRecettesWithNutrition() async {
    final recettes = await widget.recetteRepository.getAllRecettes();
    final results = <RecetteWithNutrition>[];

    for (final recette in recettes) {
      final nutrition = await widget.recetteRepository.calculateNutritionForRecette(recette.id);
      results.add(RecetteWithNutrition(
        recette: recette,
        nutrition: nutrition,
      ));
    }

    return results;
  }

  IconData _getVisibilityIcon(RecetteVisibility visibility) {
    switch (visibility) {
      case RecetteVisibility.private:
        return Icons.lock;
      case RecetteVisibility.group:
        return Icons.group;
    }
  }

  Color _getVisibilityColor(RecetteVisibility visibility) {
    switch (visibility) {
      case RecetteVisibility.private:
        return Colors.grey;
      case RecetteVisibility.group:
        return Colors.green;
    }
  }
}