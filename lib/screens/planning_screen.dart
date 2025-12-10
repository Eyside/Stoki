// lib/screens/planning_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database.dart';
import '../providers.dart';
import '../repositories/planning_repository.dart';
import '../repositories/recette_repository.dart';
import '../repositories/calorie_tracking_repository.dart';
import '../repositories/user_profile_repository.dart';
import '../widgets/eaters_selector.dart';

class PlanningScreen extends ConsumerStatefulWidget {
  const PlanningScreen({super.key});

  @override
  ConsumerState<PlanningScreen> createState() => _PlanningScreenState();
}

class _PlanningScreenState extends ConsumerState<PlanningScreen> {
  DateTime _selectedDate = DateTime.now();

  void _refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Déplacer les repositories ici pour éviter les problèmes de contexte
    final db = ref.watch(databaseProvider);
    final planningRepo = PlanningRepository(db);
    final recetteRepo = ref.watch(recetteRepositoryProvider);

    return Scaffold(
      body: Column(
        children: [
          // Sélecteur de date
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () {
                      setState(() {
                        _selectedDate = _selectedDate.subtract(const Duration(days: 1));
                      });
                    },
                  ),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setState(() => _selectedDate = picked);
                      }
                    },
                    child: Column(
                      children: [
                        Text(
                          _formatDate(_selectedDate),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _isToday(_selectedDate)
                              ? 'Aujourd\'hui'
                              : _isTomorrow(_selectedDate)
                              ? 'Demain'
                              : _getDayName(_selectedDate),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () {
                      setState(() {
                        _selectedDate = _selectedDate.add(const Duration(days: 1));
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          // Liste des repas
          Expanded(
            child: FutureBuilder<List<MealPlanningData>>(
              future: planningRepo.getPlanningForDate(_selectedDate),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final plannings = snapshot.data ?? [];

                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildMealSection('breakfast', 'Petit-déjeuner', Icons.free_breakfast, Colors.orange, plannings, recetteRepo),
                    const SizedBox(height: 12),
                    _buildMealSection('lunch', 'Déjeuner', Icons.lunch_dining, Colors.green, plannings, recetteRepo),
                    const SizedBox(height: 12),
                    _buildMealSection('dinner', 'Dîner', Icons.dinner_dining, Colors.blue, plannings, recetteRepo),
                    const SizedBox(height: 12),
                    _buildMealSection('snack', 'Collation', Icons.cookie, Colors.purple, plannings, recetteRepo),
                    const SizedBox(height: 80), // Pour le FAB
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Génération liste de courses
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Génération de la liste de courses - À venir')),
          );
        },
        icon: const Icon(Icons.shopping_cart),
        label: const Text('Générer liste'),
      ),
    );
  }

  Widget _buildMealSection(
      String mealType,
      String mealName,
      IconData icon,
      Color color,
      List<MealPlanningData> allPlannings,
      RecetteRepository recetteRepo,
      ) {
    final mealsOfType = allPlannings.where((p) => p.mealType == mealType).toList();

    if (mealsOfType.isEmpty) {
      return _MealCard(
        mealType: mealName,
        icon: icon,
        color: color,
        isEmpty: true,
        onAdd: () => _addMealDialog(mealType, mealName),
      );
    }

    return Column(
      children: mealsOfType.map((planning) {
        return _buildPlannedMealCard(planning, mealName, icon, color, recetteRepo);
      }).toList(),
    );
  }

  Widget _buildPlannedMealCard(
      MealPlanningData planning,
      String mealName,
      IconData icon,
      Color color,
      RecetteRepository recetteRepo,
      ) {
    return FutureBuilder<Recette?>(
      future: recetteRepo.getRecetteById(planning.recetteId ?? 0),
      builder: (context, snapshot) {
        final recette = snapshot.data;

        return Card(
          child: InkWell(
            onTap: () => _showMealDetails(planning, recette, recetteRepo),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mealName,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          recette?.name ?? 'Chargement...',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${planning.servings} portion(s)',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                        // Affichage des profils qui mangent
                        if (planning.eaters != null && planning.eaters!.isNotEmpty)
                          _buildEatersDisplay(planning.eaters!),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'consume',
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green),
                            SizedBox(width: 8),
                            Text('Marquer comme consommé'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: Colors.blue),
                            SizedBox(width: 8),
                            Text('Modifier'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Supprimer'),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'consume') {
                        _markAsConsumed(planning, recette, recetteRepo);
                      } else if (value == 'edit') {
                        _editMeal(planning, recette);
                      } else if (value == 'delete') {
                        _deleteMeal(planning);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEatersDisplay(String eatersJson) {
    final db = ref.watch(databaseProvider);
    final profileRepo = UserProfileRepository(db);

    return FutureBuilder<List<UserProfile>>(
      future: profileRepo.getProfilesByIds(
        EatersHelper.decodeEaters(eatersJson),
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        final eaters = snapshot.data!;
        if (eaters.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Wrap(
            spacing: 4,
            children: eaters.map((profile) {
              return Tooltip(
                message: profile.name,
                child: CircleAvatar(
                  radius: 10,
                  backgroundColor: _getProfileColor(profile).withOpacity(0.3),
                  child: Text(
                    profile.name[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _getProfileColor(profile),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Future<void> _addMealDialog(String mealType, String mealName) async {
    // Récupérer les repositories dans le contexte actuel
    final db = ref.read(databaseProvider);
    final recetteRepo = ref.read(recetteRepositoryProvider);
    final profileRepo = UserProfileRepository(db);
    final planningRepo = PlanningRepository(db);

    final recettes = await recetteRepo.getAllRecettes();
    final profiles = await profileRepo.getAllProfiles();

    if (!mounted) return;

    if (recettes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucune recette disponible. Créez-en une d\'abord !'),
        ),
      );
      return;
    }

    Recette? selectedRecette;
    final servingsCtrl = TextEditingController(text: '1');
    List<int> selectedEaters = [];

    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (builderContext, setDialogState) => AlertDialog(
          title: Text('Planifier $mealName'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.of(dialogContext).size.width * 0.9,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Sélection de la recette
                  DropdownButtonFormField<Recette>(
                    value: selectedRecette,
                    hint: const Text('Choisir une recette'),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.restaurant_menu),
                    ),
                    isExpanded: true,
                    items: recettes.map((r) {
                      return DropdownMenuItem(
                        value: r,
                        child: Text(r.name),
                      );
                    }).toList(),
                    onChanged: (v) => setDialogState(() => selectedRecette = v),
                  ),
                  const SizedBox(height: 16),

                  // Nombre de portions
                  TextField(
                    controller: servingsCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de portions',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.people),
                    ),
                    keyboardType: TextInputType.number,
                  ),

                  // Sélecteur de profils
                  if (profiles.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    EatersSelector(
                      allProfiles: profiles,
                      selectedProfileIds: selectedEaters,
                      onSelectionChanged: (ids) {
                        setDialogState(() => selectedEaters = ids);
                      },
                    ),
                  ],

                  // Informations nutritionnelles
                  if (selectedRecette != null) ...[
                    const SizedBox(height: 16),
                    FutureBuilder<Map<String, double>>(
                      future: recetteRepo.calculateNutritionForRecette(selectedRecette!.id),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const SizedBox.shrink();

                        final nutrition = snapshot.data!;
                        final servings = int.tryParse(servingsCtrl.text) ?? 1;
                        final caloriesPerServing = (nutrition['calories'] ?? 0) / selectedRecette!.servings * servings;

                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'Valeurs nutritionnelles',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text('${caloriesPerServing.toStringAsFixed(0)} kcal'),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: selectedRecette == null
                  ? null
                  : () => Navigator.pop(dialogContext, true),
              child: const Text('Ajouter'),
            ),
          ],
        ),
      ),
    );

    if (ok == true && selectedRecette != null) {
      final servings = int.tryParse(servingsCtrl.text) ?? 1;

      final mealTime = _getMealTime(mealType);
      final plannedDate = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        mealTime.hour,
        mealTime.minute,
      );

      // Encoder les profils sélectionnés
      final eatersJson = selectedEaters.isNotEmpty
          ? EatersHelper.encodeEaters(selectedEaters)
          : null;

      await planningRepo.addMealToPlanning(
        date: plannedDate,
        mealType: mealType,
        recetteId: selectedRecette!.id,
        servings: servings,
        eaters: eatersJson,
      );

      _refresh();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${selectedRecette!.name} ajouté au planning !')),
        );
      }
    }
  }

  DateTime _getMealTime(String mealType) {
    switch (mealType) {
      case 'breakfast':
        return DateTime(2000, 1, 1, 8, 0);
      case 'lunch':
        return DateTime(2000, 1, 1, 12, 0);
      case 'dinner':
        return DateTime(2000, 1, 1, 19, 0);
      case 'snack':
        return DateTime(2000, 1, 1, 16, 0);
      default:
        return DateTime(2000, 1, 1, 12, 0);
    }
  }

  Future<void> _showMealDetails(MealPlanningData planning, Recette? recette, RecetteRepository recetteRepo) async {
    if (recette == null) return;

    final nutrition = await recetteRepo.calculateNutritionForRecette(recette.id);

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(recette.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${planning.servings} portion(s)'),
            const SizedBox(height: 16),
            const Text(
              'Valeurs nutritionnelles totales:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Calories: ${(nutrition['calories']! / recette.servings * planning.servings).toStringAsFixed(0)} kcal'),
            Text('Protéines: ${(nutrition['proteins']! / recette.servings * planning.servings).toStringAsFixed(1)}g'),
            Text('Glucides: ${(nutrition['carbs']! / recette.servings * planning.servings).toStringAsFixed(1)}g'),
            Text('Lipides: ${(nutrition['fats']! / recette.servings * planning.servings).toStringAsFixed(1)}g'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
  Future<void> _editMeal(MealPlanningData planning, Recette? currentRecette) async {
    if (currentRecette == null) return;

    final db = ref.read(databaseProvider);
    final recetteRepo = ref.read(recetteRepositoryProvider);
    final profileRepo = UserProfileRepository(db);
    final planningRepo = PlanningRepository(db);

    final recettes = await recetteRepo.getAllRecettes();
    final profiles = await profileRepo.getAllProfiles();

    if (!mounted) return;

    Recette? selectedRecette = currentRecette;
    final servingsCtrl = TextEditingController(text: planning.servings.toString());
    List<int> selectedEaters = EatersHelper.decodeEaters(planning.eaters);

    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (builderContext, setDialogState) => AlertDialog(
          title: const Text('Modifier le repas'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.of(dialogContext).size.width * 0.9,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<Recette>(
                    value: selectedRecette,
                    hint: const Text('Choisir une recette'),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.restaurant_menu),
                    ),
                    isExpanded: true,
                    items: recettes.map((r) {
                      return DropdownMenuItem(
                        value: r,
                        child: Text(r.name),
                      );
                    }).toList(),
                    onChanged: (v) => setDialogState(() => selectedRecette = v),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: servingsCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de portions',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.people),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  if (profiles.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    EatersSelector(
                      allProfiles: profiles,
                      selectedProfileIds: selectedEaters,
                      onSelectionChanged: (ids) {
                        setDialogState(() => selectedEaters = ids);
                      },
                    ),
                  ],
                  if (selectedRecette != null) ...[
                    const SizedBox(height: 16),
                    FutureBuilder<Map<String, double>>(
                      future: recetteRepo.calculateNutritionForRecette(selectedRecette!.id),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const SizedBox.shrink();

                        final nutrition = snapshot.data!;
                        final servings = int.tryParse(servingsCtrl.text) ?? 1;
                        final caloriesPerServing = (nutrition['calories'] ?? 0) / selectedRecette!.servings * servings;

                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'Valeurs nutritionnelles',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text('${caloriesPerServing.toStringAsFixed(0)} kcal'),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: selectedRecette == null
                  ? null
                  : () => Navigator.pop(dialogContext, true),
              child: const Text('Modifier'),
            ),
          ],
        ),
      ),
    );

    if (ok == true && selectedRecette != null) {
      final newServings = int.tryParse(servingsCtrl.text) ?? 1;
      final eatersJson = selectedEaters.isNotEmpty
          ? EatersHelper.encodeEaters(selectedEaters)
          : null;

      // Supprimer l'ancien planning
      await planningRepo.deletePlanning(planning.id);

      // Créer le nouveau planning
      await planningRepo.addMealToPlanning(
        date: planning.date,
        mealType: planning.mealType,
        recetteId: selectedRecette!.id,
        servings: newServings,
        eaters: eatersJson,
      );

      _refresh();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Repas modifié !')),
        );
      }
    }
  }

  Future<void> _deleteMeal(MealPlanningData planning) async {
    final db = ref.read(databaseProvider);
    final planningRepo = PlanningRepository(db);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Supprimer ce repas ?'),
        content: const Text('Voulez-vous retirer ce repas du planning ?'),
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
      await planningRepo.deletePlanning(planning.id);
      _refresh();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Repas supprimé du planning')),
        );
      }
    }
  }

  Future<void> _markAsConsumed(MealPlanningData planning, Recette? recette, RecetteRepository recetteRepo) async {
    if (recette == null) return;

    final db = ref.read(databaseProvider);
    final profileRepo = UserProfileRepository(db);
    final trackingRepo = CalorieTrackingRepository(db);

    final profile = await profileRepo.getActiveProfile();

    if (profile == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Créez d\'abord votre profil dans le menu'),
        ),
      );
      return;
    }

    // Calculer les valeurs nutritionnelles
    final nutrition = await recetteRepo.calculateNutritionForRecette(recette.id);
    final portionFactor = planning.servings / recette.servings;

    final calories = (nutrition['calories'] ?? 0) * portionFactor;
    final proteins = (nutrition['proteins'] ?? 0) * portionFactor;
    final fats = (nutrition['fats'] ?? 0) * portionFactor;
    final carbs = (nutrition['carbs'] ?? 0) * portionFactor;
    final fibers = (nutrition['fibers'] ?? 0) * portionFactor;

    // Enregistrer dans le suivi calorique
    await trackingRepo.addTracking(
      userProfileId: profile.id,
      date: planning.date,
      mealType: planning.mealType,
      calories: calories,
      proteins: proteins,
      fats: fats,
      carbs: carbs,
      fibers: fibers,
      mealPlanningId: planning.id,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${recette.name} enregistré dans le suivi calorique !'),
        backgroundColor: Colors.green,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin', 'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  bool _isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year && date.month == tomorrow.month && date.day == tomorrow.day;
  }

  String _getDayName(DateTime date) {
    final days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    return days[date.weekday - 1];
  }

  Color _getProfileColor(UserProfile profile) {
    if (profile.eaterMultiplier < 0.8) return Colors.blue;
    if (profile.eaterMultiplier > 1.2) return Colors.purple;
    return Colors.green;
  }
}

class _MealCard extends StatelessWidget {
  final String mealType;
  final IconData icon;
  final Color color;
  final bool isEmpty;
  final VoidCallback onAdd;

  const _MealCard({
    required this.mealType,
    required this.icon,
    required this.color,
    required this.isEmpty,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: isEmpty ? onAdd : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mealType,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isEmpty)
                      const Text(
                        'Aucun repas planifié',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),
              if (isEmpty)
                Icon(Icons.add_circle_outline, color: color)
              else
                const Icon(Icons.edit, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

// Classe helper pour encoder/décoder les profils
class EatersHelper {
  static String encodeEaters(List<int> profileIds) {
    return profileIds.join(',');
  }

  static List<int> decodeEaters(String? eatersJson) {
    if (eatersJson == null || eatersJson.isEmpty) return [];
    return eatersJson.split(',').map((e) => int.tryParse(e) ?? 0).where((e) => e > 0).toList();
  }
}