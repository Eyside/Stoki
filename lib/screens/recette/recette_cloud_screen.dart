// lib/screens/recette/recette_cloud_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/recette_firestore.dart';
import '../../services/recette_firestore_service.dart';
import '../../services/group_service.dart';
import '../../services/auth_service.dart';
import '../../providers.dart';
import 'recette_firestore_form.dart';
import 'recette_firestore_detail.dart';


enum RecetteFilter {
  all,      // Toutes mes recettes
  private,  // Seulement privées
  group,    // Seulement de groupe
}

class RecetteCloudScreen extends ConsumerStatefulWidget {
  const RecetteCloudScreen({super.key});

  @override
  ConsumerState<RecetteCloudScreen> createState() => _RecetteCloudScreenState();
}

class _RecetteCloudScreenState extends ConsumerState<RecetteCloudScreen> {
  final _recetteService = RecetteFirestoreService();
  final _groupService = GroupService();
  final _authService = AuthService();

  RecetteFilter _currentFilter = RecetteFilter.all;
  List<Map<String, dynamic>> _userGroups = [];

  @override
  void initState() {
    super.initState();
    _loadUserGroups();
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

  void _openForm([RecetteFirestore? recette]) async {
    final ingredientRepo = ref.read(ingredientRepositoryProvider);

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecetteFirestoreForm(
          recette: recette,
          ingredientRepository: ingredientRepo,
        ),
      ),
    );

    if (result != null) {
      setState(() {}); // Refresh
    }
  }

  void _openDetail(RecetteFirestore recette) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecetteFirestoreDetail(recetteId: recette.id),
      ),
    );
  }

  Future<void> _deleteRecette(RecetteFirestore recette) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Supprimer la recette'),
        content: Text('Voulez-vous vraiment supprimer « ${recette.name} » ?'),
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
      await _recetteService.deleteRecette(recette.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recette supprimée')),
        );
      }
    }
  }

  Future<void> _duplicateRecette(RecetteFirestore recette) async {
    await _recetteService.duplicateRecette(sourceRecetteId: recette.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recette dupliquée dans vos recettes privées')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recettes Cloud'),
        actions: [
          // Filtres
          PopupMenuButton<RecetteFilter>(
            icon: const Icon(Icons.filter_list),
            onSelected: (filter) => setState(() => _currentFilter = filter),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: RecetteFilter.all,
                child: Row(
                  children: [
                    Icon(Icons.all_inclusive),
                    SizedBox(width: 8),
                    Text('Toutes'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: RecetteFilter.private,
                child: Row(
                  children: [
                    Icon(Icons.lock),
                    SizedBox(width: 8),
                    Text('Privées'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: RecetteFilter.group,
                child: Row(
                  children: [
                    Icon(Icons.group),
                    SizedBox(width: 8),
                    Text('De groupe'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Chip de filtre actif
          if (_currentFilter != RecetteFilter.all)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.grey.shade100,
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  Chip(
                    label: Text(_getFilterLabel()),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () => setState(() => _currentFilter = RecetteFilter.all),
                  ),
                ],
              ),
            ),

          // Liste des recettes
          Expanded(
            child: StreamBuilder<List<RecetteFirestore>>(
              stream: _recetteService.getMyRecettes(),
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

                // Appliquer les filtres
                recettes = _applyFilter(recettes);

                if (recettes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.restaurant_menu, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          _getEmptyMessage(),
                          style: const TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => _openForm(),
                          icon: const Icon(Icons.add),
                          label: const Text('Créer une recette'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: recettes.length,
                  itemBuilder: (context, index) {
                    final recette = recettes[index];
                    final userId = _authService.currentUser?.uid ?? '';

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getVisibilityColor(recette.visibility),
                          child: Icon(
                            _getVisibilityIcon(recette.visibility),
                            color: Colors.white,
                          ),
                        ),
                        title: Row(
                          children: [
                            Expanded(child: Text(recette.name)),
                            _buildVisibilityBadge(recette),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (recette.category != null) ...[
                              const SizedBox(height: 4),
                              Text('📁 ${recette.category}'),
                            ],
                            const SizedBox(height: 2),
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
                            switch (value) {
                              case 'edit':
                                _openForm(recette);
                                break;
                              case 'duplicate':
                                _duplicateRecette(recette);
                                break;
                              case 'delete':
                                _deleteRecette(recette);
                                break;
                            }
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
    );
  }

  List<RecetteFirestore> _applyFilter(List<RecetteFirestore> recettes) {
    switch (_currentFilter) {
      case RecetteFilter.all:
        return recettes;
      case RecetteFilter.private:
        return recettes.where((r) => r.visibility == RecetteVisibility.private).toList();
      case RecetteFilter.group:
        return recettes.where((r) => r.visibility == RecetteVisibility.group).toList();
    }
  }

  String _getFilterLabel() {
    switch (_currentFilter) {
      case RecetteFilter.all:
        return 'Toutes';
      case RecetteFilter.private:
        return 'Privées';
      case RecetteFilter.group:
        return 'De groupe';
    }
  }

  String _getEmptyMessage() {
    switch (_currentFilter) {
      case RecetteFilter.all:
        return 'Aucune recette cloud';
      case RecetteFilter.private:
        return 'Aucune recette privée';
      case RecetteFilter.group:
        return 'Aucune recette de groupe';
    }
  }

  Widget _buildVisibilityBadge(RecetteFirestore recette) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _getVisibilityColor(recette.visibility).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getVisibilityColor(recette.visibility),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getVisibilityIcon(recette.visibility),
            size: 12,
            color: _getVisibilityColor(recette.visibility),
          ),
          const SizedBox(width: 4),
          Text(
            recette.visibilityLabel,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: _getVisibilityColor(recette.visibility),
            ),
          ),
        ],
      ),
    );
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