// lib/screens/recette/recette_screen.dart
import 'package:flutter/material.dart';
import '../../database.dart';
import '../../repositories/recette_repository.dart';
import '../../utils/snackbar_helper.dart';
import 'recette_detail.dart';
import 'recette_form.dart';

class RecetteScreen extends StatefulWidget {
  final RecetteRepository recetteRepository;

  const RecetteScreen({
    super.key,
    required this.recetteRepository,
  });

  @override
  State<RecetteScreen> createState() => _RecetteScreenState();
}

class _RecetteScreenState extends State<RecetteScreen> {
  late Future<List<RecetteWithNutrition>> _recettesFuture;

  @override
  void initState() {
    super.initState();
    _loadRecettes();
  }

  void _loadRecettes() {
    setState(() {
      _recettesFuture = _loadRecettesWithNutrition();
    });
  }

  Future<List<RecetteWithNutrition>> _loadRecettesWithNutrition() async {
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

  Future<void> _duplicateRecette(Recette recette) async {
    final newId = await widget.recetteRepository.duplicateRecette(recette.id);
    if (!mounted) return;

    SnackBarHelper.showUndoSnackBar(
      context: context,
      message: "Recette dupliquée",
      onUndo: () async {
        await widget.recetteRepository.deleteRecette(newId);
        _loadRecettes();
      },
    );

    _loadRecettes();
  }

  Future<void> _deleteRecette(Recette recette) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Supprimer la recette"),
        content: Text("Voulez-vous vraiment supprimer « ${recette.name} » ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(c, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Supprimer"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await widget.recetteRepository.deleteRecette(recette.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Recette supprimée")),
        );
        _loadRecettes();
      }
    }
  }

  void _openForm() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecetteFormScreen(
          recetteRepository: widget.recetteRepository,
        ),
      ),
    );
    if (result == true) {
      _loadRecettes();
    }
  }

  void _openDetail(Recette recette) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecetteDetailScreen(
          recetteRepository: widget.recetteRepository,
          recette: recette,
        ),
      ),
    );
    _loadRecettes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes Recettes"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRecettes,
          ),
        ],
      ),
      body: FutureBuilder<List<RecetteWithNutrition>>(
        future: _recettesFuture,
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
                  Text("Erreur: ${snapshot.error}"),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadRecettes,
                    child: const Text("Réessayer"),
                  ),
                ],
              ),
            );
          }

          final recettesWithNutrition = snapshot.data ?? [];

          if (recettesWithNutrition.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.restaurant_menu, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    "Aucune recette",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Appuyez sur + pour créer votre première recette",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _openForm,
                    icon: const Icon(Icons.add),
                    label: const Text("Créer une recette"),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: recettesWithNutrition.length,
            itemBuilder: (context, index) {
              final item = recettesWithNutrition[index];
              final recette = item.recette;
              final nutrition = item.nutrition;

              final calories = nutrition['calories'] ?? 0.0;
              final proteins = nutrition['proteins'] ?? 0.0;
              final carbs = nutrition['carbs'] ?? 0.0;
              final fats = nutrition['fats'] ?? 0.0;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Text(
                      recette.name[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    recette.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        "${calories.toStringAsFixed(0)} kcal • ${recette.servings} portion(s)",
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "P: ${proteins.toStringAsFixed(0)}g • G: ${carbs.toStringAsFixed(0)}g • L: ${fats.toStringAsFixed(0)}g",
                        style: const TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                  onTap: () => _openDetail(recette),
                  trailing: PopupMenuButton(
                    icon: const Icon(Icons.more_vert),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'duplicate',
                        child: Row(
                          children: [
                            Icon(Icons.copy),
                            SizedBox(width: 8),
                            Text("Dupliquer"),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text("Supprimer", style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
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
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openForm,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Classe helper pour combiner recette et nutrition
class RecetteWithNutrition {
  final Recette recette;
  final Map<String, double> nutrition;

  RecetteWithNutrition({
    required this.recette,
    required this.nutrition,
  });
}