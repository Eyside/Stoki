// lib/screens/planning_screen_new.dart (PARTIE 1/2 - CORRIGÉ)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../database.dart';
import '../models/planning_firestore.dart';
import '../providers.dart';
import '../repositories/planning_repository.dart';
import '../repositories/recette_repository.dart';
import '../repositories/calorie_tracking_repository.dart';
import '../repositories/user_profile_repository.dart';
import '../services/planning_firestore_service.dart';
import '../services/group_service.dart';
import '../services/auth_service.dart';
import '../widgets/eaters_selector.dart';
import '../services/recette_firestore_service.dart';
import '../services/recette_sync_service.dart';
import '../models/recette_firestore.dart';
import '../services/group_profile_service.dart';
import '../widgets/planning_detail_dialog.dart';
import '../widgets/edit_planned_meal_dialog.dart';
import 'dart:convert';

enum PlanningSource {
  all,
  local,
  private,
  group,
}

enum PlanningView {
  day,
  week,
  month,
}

enum RecetteSourceType {
  local,
  group,
}

class PlanningSourceOption {
  final PlanningSource type;
  final String label;
  final IconData icon;
  final String? groupId;
  final String? groupName;

  PlanningSourceOption({
    required this.type,
    required this.label,
    required this.icon,
    this.groupId,
    this.groupName,
  });
}

class PlanningScreen extends ConsumerStatefulWidget {
  const PlanningScreen({super.key});

  @override
  ConsumerState<PlanningScreen> createState() => _PlanningScreenState();
}

class _PlanningScreenState extends ConsumerState<PlanningScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  PlanningView _currentView = PlanningView.day;

  final _planningService = PlanningFirestoreService();
  final _groupService = GroupService();
  final _authService = AuthService();
  final _recetteService = RecetteFirestoreService();
  final _groupProfileService = GroupProfileService();

  late PlanningRepository _planningRepo;
  late RecetteRepository _recetteRepo;
  late CalorieTrackingRepository _trackingRepo;
  late UserProfileRepository _profileRepo;
  late RecetteSyncService _syncService;

  List<PlanningSourceOption> _sourceOptions = [];
  PlanningSourceOption? _selectedSource;
  List<Map<String, dynamic>> _userGroups = [];

  @override
  void initState() {
    super.initState();
    final db = ref.read(databaseProvider);
    _planningRepo = PlanningRepository(db);
    _recetteRepo = ref.read(recetteRepositoryProvider);
    _trackingRepo = CalorieTrackingRepository(db);
    _profileRepo = UserProfileRepository(db);
    _syncService = ref.read(recetteSyncServiceProvider);
    _loadSourceOptions();
  }
  /// Affiche les détails d'un repas planifié LOCAL avec possibilité de modification
  Future<void> _showLocalMealDetailsEnhanced(MealPlanningData planning) async {
    if (planning.recetteId == null) return;

    // Récupérer la recette
    final recette = await _recetteRepo.getRecetteById(planning.recetteId!);
    if (recette == null) return;

    // Récupérer les ingrédients de la recette
    final db = ref.read(databaseProvider);
    final recetteIngredients = await (db.select(db.recetteIngredients)
      ..where((ri) => ri.recetteId.equals(recette.id)))
        .get();

    // Convertir en RecetteIngredientFirestore pour uniformité
    final ingredients = <RecetteIngredientFirestore>[];
    for (final ri in recetteIngredients) {
      final ing = await db.getIngredientById(ri.ingredientId);
      if (ing != null) {
        ingredients.add(RecetteIngredientFirestore(
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
        ));
      }
    }

    // Calculer la nutrition (originale ou modifiée)
    Map<String, double> nutrition;
    List<RecetteIngredientFirestore> displayIngredients;

    if (planning.modifiedIngredients != null) {
      // Utiliser les valeurs modifiées
      nutrition = {
        'calories': planning.modifiedCalories ?? 0,
        'proteins': planning.modifiedProteins ?? 0,
        'fats': planning.modifiedFats ?? 0,
        'carbs': planning.modifiedCarbs ?? 0,
        'fibers': planning.modifiedFibers ?? 0,
      };

      // Charger les ingrédients modifiés
      try {
        final modified = EditedMealResult.fromJson(planning.modifiedIngredients!);
        displayIngredients = modified.modifiedIngredients.map((mod) {
          return RecetteIngredientFirestore(
            ingredientId: mod.ingredientId,
            ingredientName: mod.ingredientName,
            quantity: mod.newQuantity,
            unit: mod.unit,
            caloriesPer100g: 0,
            proteinsPer100g: 0,
            fatsPer100g: 0,
            carbsPer100g: 0,
            fibersPer100g: 0,
            densityGPerMl: null,
            avgWeightPerUnitG: null,
          );
        }).toList();
      } catch (e) {
        displayIngredients = ingredients;
        nutrition = await _recetteRepo.calculateNutritionForRecette(recette.id);
      }
    } else {
      // Utiliser les valeurs originales
      nutrition = await _recetteRepo.calculateNutritionForRecette(recette.id);
      displayIngredients = ingredients;
    }

    // Ajuster selon les portions
    final portionFactor = planning.servings / recette.servings;
    nutrition = nutrition.map((key, value) => MapEntry(key, value * portionFactor));

    final profile = await _profileRepo.getActiveProfile();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (c) => PlanningDetailDialog(
        recetteName: recette.name,
        servings: planning.servings,
        nutrition: nutrition,
        ingredients: displayIngredients,
        userProfile: profile,
        onEdit: () => _editLocalMealIngredients(planning, recette, ingredients),
      ),
    );
  }

  /// Permet d'éditer les quantités d'ingrédients d'un repas LOCAL
  Future<void> _editLocalMealIngredients(
      MealPlanningData planning,
      Recette recette,
      List<RecetteIngredientFirestore> ingredients,
      ) async {
    if (!mounted) return;

    final result = await showDialog<EditedMealResult>(
      context: context,
      builder: (c) => EditPlannedMealDialog(
        recetteName: recette.name,
        servings: planning.servings,
        ingredients: ingredients,
      ),
    );

    if (result == null) return;

    // Sauvegarder les modifications dans la base de données
    final success = await _planningRepo.updatePlanningWithModifiedIngredients(
      planningId: planning.id,
      modifiedIngredientsJson: result.toJson(),
      calories: result.newNutrition['calories'] ?? 0,
      proteins: result.newNutrition['proteins'] ?? 0,
      fats: result.newNutrition['fats'] ?? 0,
      carbs: result.newNutrition['carbs'] ?? 0,
      fibers: result.newNutrition['fibers'] ?? 0,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Modifications enregistrées !'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      setState(() {}); // Rafraîchir l'affichage
    }
  }

  /// Réinitialise les modifications d'un repas local
  Future<void> _resetLocalMealModifications(MealPlanningData planning) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Annuler les modifications ?'),
        content: const Text(
          'Les quantités d\'ingrédients seront réinitialisées à leurs valeurs d\'origine.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(c, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Réinitialiser'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final success = await _planningRepo.clearModifications(planning.id);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🔄 Modifications annulées'),
          backgroundColor: Colors.blue,
        ),
      );
      setState(() {});
    }
  }

  /// Affiche les détails d'un repas planifié CLOUD (version améliorée)
  Future<void> _showCloudMealDetailsEnhanced(PlanningFirestore planning) async {
    // Récupérer les ingrédients de la recette cloud
    final ingredients = await _recetteService.getIngredients(planning.recetteId);

    // Utiliser les valeurs modifiées si elles existent, sinon les originales
    Map<String, double> nutrition;
    List<RecetteIngredientFirestore> displayIngredients;

    if (planning.modifiedIngredients != null) {
      // Utiliser les valeurs modifiées
      nutrition = {
        'calories': planning.modifiedCalories ?? planning.totalCalories,
        'proteins': planning.modifiedProteins ?? planning.totalProteins,
        'fats': planning.modifiedFats ?? planning.totalFats,
        'carbs': planning.modifiedCarbs ?? planning.totalCarbs,
        'fibers': planning.modifiedFibers ?? planning.totalFibers,
      };

      // Charger les ingrédients modifiés
      try {
        final modified = EditedMealResult.fromJson(planning.modifiedIngredients!);
        displayIngredients = modified.modifiedIngredients.map((mod) {
          return RecetteIngredientFirestore(
            ingredientId: mod.ingredientId,
            ingredientName: mod.ingredientName,
            quantity: mod.newQuantity,
            unit: mod.unit,
            caloriesPer100g: 0,
            proteinsPer100g: 0,
            fatsPer100g: 0,
            carbsPer100g: 0,
            fibersPer100g: 0,
            densityGPerMl: null,
            avgWeightPerUnitG: null,
          );
        }).toList();
      } catch (e) {
        displayIngredients = ingredients;
        nutrition = {
          'calories': planning.totalCalories,
          'proteins': planning.totalProteins,
          'fats': planning.totalFats,
          'carbs': planning.totalCarbs,
          'fibers': planning.totalFibers,
        };
      }
    } else {
      // Utiliser les valeurs originales
      nutrition = {
        'calories': planning.totalCalories,
        'proteins': planning.totalProteins,
        'fats': planning.totalFats,
        'carbs': planning.totalCarbs,
        'fibers': planning.totalFibers,
      };
      displayIngredients = ingredients;
    }

    final profile = await _profileRepo.getActiveProfile();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (c) => PlanningDetailDialog(
        recetteName: planning.recetteName,
        servings: 1,
        nutrition: nutrition,
        ingredients: displayIngredients,
        userProfile: profile,
        onEdit: () => _editCloudMealIngredients(planning, ingredients), // ← BOUTON MODIFIER ACTIVÉ
      ),
    );
  }

  /// NOUVELLE MÉTHODE: Permet d'éditer les quantités d'ingrédients d'un repas CLOUD
  Future<void> _editCloudMealIngredients(
      PlanningFirestore planning,
      List<RecetteIngredientFirestore> ingredients,
      ) async {
    if (!mounted) return;

    final result = await showDialog<EditedMealResult>(
      context: context,
      builder: (c) => EditPlannedMealDialog(
        recetteName: planning.recetteName,
        servings: 1,
        ingredients: ingredients,
      ),
    );

    if (result == null) return;

    // Sauvegarder les modifications dans Firestore
    try {
      await _planningService.updatePlanningWithModifiedIngredients(
        planningId: planning.id,
        modifiedIngredientsJson: result.toJson(),
        calories: result.newNutrition['calories'] ?? 0,
        proteins: result.newNutrition['proteins'] ?? 0,
        fats: result.newNutrition['fats'] ?? 0,
        carbs: result.newNutrition['carbs'] ?? 0,
        fibers: result.newNutrition['fibers'] ?? 0,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Modifications enregistrées dans le cloud !'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        setState(() {}); // Rafraîchir l'affichage
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// NOUVELLE MÉTHODE: Réinitialise les modifications d'un repas cloud
  Future<void> _resetCloudMealModifications(PlanningFirestore planning) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Annuler les modifications ?'),
        content: const Text(
          'Les quantités d\'ingrédients seront réinitialisées à leurs valeurs d\'origine.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(c, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Réinitialiser'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _planningService.clearModifications(planning.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🔄 Modifications annulées'),
            backgroundColor: Colors.blue,
          ),
        );
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadSourceOptions() async {
    final userId = _authService.currentUser?.uid;

    final options = <PlanningSourceOption>[
      PlanningSourceOption(type: PlanningSource.all, label: 'Tout', icon: Icons.all_inclusive),
      PlanningSourceOption(type: PlanningSource.local, label: 'Local', icon: Icons.phone_android),
    ];

    if (userId != null) {
      options.add(PlanningSourceOption(type: PlanningSource.private, label: 'Cloud', icon: Icons.cloud));

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
      _selectedSource = options.first;
    });
  }

  void _buildSourceOptions() {
    final userId = _authService.currentUser?.uid;

    final options = <PlanningSourceOption>[
      PlanningSourceOption(type: PlanningSource.all, label: 'Tout', icon: Icons.all_inclusive),
      PlanningSourceOption(type: PlanningSource.local, label: 'Local', icon: Icons.phone_android),
    ];

    if (userId != null) {
      options.add(PlanningSourceOption(type: PlanningSource.private, label: 'Cloud', icon: Icons.cloud));

      for (final group in _userGroups) {
        options.add(PlanningSourceOption(
          type: PlanningSource.group,
          label: group['name'] ?? 'Groupe',
          icon: Icons.group,
          groupId: group['id'],
          groupName: group['name'],
        ));
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
                  const Text('Filtrer le planning', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
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
                    leading: Icon(option.icon, color: isSelected ? Colors.green : null),
                    title: Text(option.label, style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.green : null,
                    )),
                    trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
                    onTap: () {
                      setState(() => _selectedSource = option);
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

  @override
  Widget build(BuildContext context) {
    if (_selectedSource == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Planning'),
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
                  Text(_selectedSource!.label, style: TextStyle(fontSize: 12, color: Colors.green.shade700, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(_currentView == PlanningView.day ? Icons.calendar_view_day : _currentView == PlanningView.week ? Icons.calendar_view_week : Icons.calendar_month),
            onPressed: () {
              setState(() {
                _currentView = _currentView == PlanningView.day
                    ? PlanningView.week
                    : _currentView == PlanningView.week
                    ? PlanningView.month
                    : PlanningView.day;
              });
            },
            tooltip: 'Changer la vue',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showSourceMenu,
            tooltip: 'Filtrer',
          ),
        ],
      ),
      body: Column(
        children: [
          if (_currentView == PlanningView.month) _buildCalendarView(),
          if (_currentView == PlanningView.day) _buildDateSelector(),
          if (_currentView == PlanningView.week) _buildWeekSelector(),
          _buildNutritionSummary(),
          Expanded(child: _buildPlanningList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addMealDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCalendarView() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: TableCalendar(
        firstDay: DateTime.now().subtract(const Duration(days: 365)),
        lastDay: DateTime.now().add(const Duration(days: 365)),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
        calendarFormat: CalendarFormat.month,
        locale: 'fr_FR',
        startingDayOfWeek: StartingDayOfWeek.monday,
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
        ),
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: Colors.green.shade200,
            shape: BoxShape.circle,
          ),
          selectedDecoration: const BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
          ),
        ),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDate = selectedDay;
            _focusedDay = focusedDay;
            _currentView = PlanningView.day;
          });
        },
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, day, events) {
            return FutureBuilder<int>(
              future: _getMealCountForDay(day),
              builder: (context, snapshot) {
                final count = snapshot.data ?? 0;
                if (count == 0) return const SizedBox.shrink();

                return Positioned(
                  bottom: 1,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      count.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Card(
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
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _isToday(_selectedDate)
                        ? 'Aujourd\'hui'
                        : _isTomorrow(_selectedDate)
                        ? 'Demain'
                        : _getDayName(_selectedDate),
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
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
    );
  }

  Widget _buildWeekSelector() {
    final startOfWeek = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
    final weekDays = List.generate(7, (i) => startOfWeek.add(Duration(days: i)));

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: weekDays.length,
        itemBuilder: (context, index) {
          final day = weekDays[index];
          final isSelected = isSameDay(day, _selectedDate);
          final isToday = isSameDay(day, DateTime.now());

          return GestureDetector(
            onTap: () => setState(() => _selectedDate = day),
            child: Container(
              width: 70,
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.green : isToday ? Colors.green.shade100 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? Colors.green.shade700 : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getDayNameShort(day),
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white : Colors.black54,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    day.day.toString(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                  FutureBuilder<int>(
                    future: _getMealCountForDay(day),
                    builder: (context, snapshot) {
                      final count = snapshot.data ?? 0;
                      if (count == 0) return const SizedBox.shrink();
                      return Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.green,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          count.toString(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.green : Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNutritionSummary() {
    return FutureBuilder<Map<String, double>>(
      future: _getDailyNutrition(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final nutrition = snapshot.data!;
        final calories = nutrition['calories'] ?? 0;
        final proteins = nutrition['proteins'] ?? 0;
        final fats = nutrition['fats'] ?? 0;
        final carbs = nutrition['carbs'] ?? 0;

        if (calories == 0) {
          return const SizedBox.shrink();
        }

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.local_fire_department, color: Colors.orange, size: 16),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${calories.toStringAsFixed(0)} kcal',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    _buildMiniMacro('P', proteins, Colors.red),
                    const SizedBox(width: 8),
                    _buildMiniMacro('G', carbs, Colors.blue),
                    const SizedBox(width: 8),
                    _buildMiniMacro('L', fats, Colors.purple),
                  ],
                ),
                FutureBuilder<UserProfile?>(
                  future: _profileRepo.getActiveProfile(),
                  builder: (context, profileSnapshot) {
                    if (profileSnapshot.hasData && profileSnapshot.data?.tdee != null) {
                      final tdee = profileSnapshot.data!.tdee!;
                      final progress = (calories / tdee).clamp(0.0, 1.5);
                      final progressColor = progress > 1.2
                          ? Colors.red
                          : progress > 0.8
                          ? Colors.green
                          : Colors.orange;

                      return Column(
                        children: [
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: progress.clamp(0.0, 1.0),
                              backgroundColor: Colors.grey.shade300,
                              color: progressColor,
                              minHeight: 6,
                            ),
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMiniMacro(String label, double grams, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '${grams.toStringAsFixed(0)}g',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
  // lib/screens/planning_screen_new.dart (PARTIE 2/2 - CORRIGÉ)
// À COPIER-COLLER À LA SUITE DE LA PARTIE 1

  Future<void> _addMealDialog({String? mealType}) async {
    if (_authService.currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vous devez être connecté')),
        );
      }
      return;
    }

    RecetteSourceType? sourceType;
    String? selectedGroupId;
    String? selectedGroupName;

    await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (builderContext, setDialogState) => AlertDialog(
          title: const Text('Choisir la source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Où voulez-vous planifier ce repas ?', style: TextStyle(fontSize: 14)),
              const SizedBox(height: 16),
              RadioListTile<RecetteSourceType>(
                title: const Row(
                  children: [
                    Icon(Icons.phone_android, size: 20, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Recettes locales'),
                  ],
                ),
                subtitle: const Text('Synchro auto dans le cloud'),
                value: RecetteSourceType.local,
                groupValue: sourceType,
                contentPadding: EdgeInsets.zero,
                onChanged: (v) => setDialogState(() {
                  sourceType = v;
                  selectedGroupId = null;
                  selectedGroupName = null;
                }),
              ),
              RadioListTile<RecetteSourceType>(
                title: const Row(
                  children: [
                    Icon(Icons.group, size: 20, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Recettes de groupe'),
                  ],
                ),
                subtitle: const Text('Partagées avec un groupe'),
                value: RecetteSourceType.group,
                groupValue: sourceType,
                contentPadding: EdgeInsets.zero,
                onChanged: (v) => setDialogState(() => sourceType = v),
              ),
              if (sourceType == RecetteSourceType.group) ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedGroupId,
                  decoration: const InputDecoration(
                    labelText: 'Sélectionner un groupe *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.group),
                  ),
                  isExpanded: true,
                  items: _userGroups
                      .map((g) => DropdownMenuItem<String>(
                    value: g['id'],
                    child: Text(g['name'] ?? 'Groupe'),
                  ))
                      .toList(),
                  onChanged: (v) => setDialogState(() {
                    selectedGroupId = v;
                    selectedGroupName = _userGroups.firstWhere((g) => g['id'] == v)['name'];
                  }),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: sourceType == null || (sourceType == RecetteSourceType.group && selectedGroupId == null)
                  ? null
                  : () => Navigator.pop(dialogContext, true),
              child: const Text('Suivant'),
            ),
          ],
        ),
      ),
    );

    if (sourceType == null) return;

    List<dynamic> availableRecettes = [];

    if (sourceType == RecetteSourceType.local) {
      availableRecettes = await _recetteRepo.getAllRecettes();
    } else if (sourceType == RecetteSourceType.group && selectedGroupId != null) {
      final cloudRecettes = await _recetteService.getGroupRecettes(selectedGroupId!).first;
      availableRecettes = cloudRecettes;
    }

    if (!mounted) return;

    if (availableRecettes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(
            sourceType == RecetteSourceType.local
                ? 'Aucune recette locale disponible'
                : 'Aucune recette dans ce groupe'
        )),
      );
      return;
    }

    List<UserProfile> availableProfiles = [];

    if (sourceType == RecetteSourceType.local) {
      availableProfiles = await _profileRepo.getAllProfiles();
    } else if (sourceType == RecetteSourceType.group && selectedGroupId != null) {
      final groupProfilesData = await _groupProfileService.getGroupProfiles(selectedGroupId!);
      availableProfiles = _groupProfileService.convertToUserProfiles(groupProfilesData);

      if (availableProfiles.isEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aucun profil dans ce groupe. Les membres doivent d\'abord configurer leurs profils.'),
            duration: Duration(seconds: 4),
          ),
        );
      }
    }

    dynamic selectedRecette;
    String selectedMealType = mealType ?? 'lunch';
    List<int> selectedEaters = [];

    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (builderContext, setDialogState) => AlertDialog(
          title: Text(sourceType == RecetteSourceType.local
              ? 'Planifier une recette locale'
              : 'Planifier pour $selectedGroupName'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.of(dialogContext).size.width * 0.9,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<dynamic>(
                    value: selectedRecette,
                    decoration: InputDecoration(
                      labelText: 'Recette *',
                      border: const OutlineInputBorder(),
                      prefixIcon: Icon(
                        sourceType == RecetteSourceType.local ? Icons.phone_android : Icons.group,
                        color: sourceType == RecetteSourceType.local ? Colors.blue : Colors.green,
                      ),
                    ),
                    isExpanded: true,
                    items: availableRecettes.map((r) {
                      final name = r is Recette ? r.name : (r as RecetteFirestore).name;
                      return DropdownMenuItem(
                        value: r,
                        child: Text(name, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (v) => setDialogState(() => selectedRecette = v),
                  ),
                  if (selectedRecette != null) ...[
                    const SizedBox(height: 8),
                    TextButton.icon(
                      icon: const Icon(Icons.info_outline, size: 18),
                      label: const Text('Voir les ingrédients'),
                      onPressed: () => _showRecetteDetailsDialog(selectedRecette),
                    ),
                  ],
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedMealType,
                    decoration: const InputDecoration(
                      labelText: 'Type de repas',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.restaurant),
                    ),
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 'breakfast', child: Text('🌅 Petit-déjeuner')),
                      DropdownMenuItem(value: 'lunch', child: Text('☀️ Déjeuner')),
                      DropdownMenuItem(value: 'dinner', child: Text('🌙 Dîner')),
                      DropdownMenuItem(value: 'snack', child: Text('🍪 Collation')),
                    ],
                    onChanged: (v) => setDialogState(() => selectedMealType = v!),
                  ),
                  if (availableProfiles.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    EatersSelector(
                      allProfiles: availableProfiles,
                      selectedProfileIds: selectedEaters,
                      onSelectionChanged: (ids) => setDialogState(() => selectedEaters = ids),
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

    if (ok != true || selectedRecette == null) return;

    final mealTime = _getMealTime(selectedMealType);
    final plannedDate = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      mealTime.hour,
      mealTime.minute,
    );

    final eatersJson = selectedEaters.isNotEmpty ? EatersHelper.encodeEaters(selectedEaters) : null;

    try {
      if (sourceType == RecetteSourceType.local) {
        final recetteLocal = selectedRecette as Recette;

        // CORRECTION LIGNE 841 : Utiliser recetteLocal.name directement (pas nullable)
        debugPrint('📱 Recette locale détectée : ${recetteLocal.name} (ID local: ${recetteLocal.id})');
        debugPrint('🔄 Synchronisation vers le cloud en cours...');

        final cloudRecetteId = await _syncService.syncRecetteToCloud(
          localRecetteId: recetteLocal.id,
        );

        debugPrint('✅ Recette synchronisée ! Cloud ID: $cloudRecetteId');

        final cloudRecette = await _recetteService.getRecetteById(cloudRecetteId);
        final nutrition = cloudRecette?.nutrition ?? {};

        await _planningService.addToPlanning(
          date: plannedDate,
          mealType: selectedMealType,
          recetteId: cloudRecetteId,
          recetteName: recetteLocal.name,
          eaters: eatersJson,
          visibility: PlanningVisibility.private,
          groupId: null,
          totalCalories: nutrition['calories'] ?? 0,
          totalProteins: nutrition['proteins'] ?? 0,
          totalFats: nutrition['fats'] ?? 0,
          totalCarbs: nutrition['carbs'] ?? 0,
          totalFibers: nutrition['fibers'] ?? 0,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${recetteLocal.name} synchronisé et ajouté au planning !'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        final recetteCloud = selectedRecette as RecetteFirestore;
        final nutrition = recetteCloud.nutrition ?? {};

        await _planningService.addToPlanning(
          date: plannedDate,
          mealType: selectedMealType,
          recetteId: recetteCloud.id,
          recetteName: recetteCloud.name,
          eaters: eatersJson,
          visibility: PlanningVisibility.group,
          groupId: selectedGroupId,
          totalCalories: nutrition['calories'] ?? 0,
          totalProteins: nutrition['proteins'] ?? 0,
          totalFats: nutrition['fats'] ?? 0,
          totalCarbs: nutrition['carbs'] ?? 0,
          totalFibers: nutrition['fibers'] ?? 0,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${recetteCloud.name} ajouté au planning de groupe !')),
          );
        }
      }

      setState(() {});
    } catch (e, stackTrace) {
      debugPrint('❌ ERREUR lors de l\'ajout: $e');
      debugPrint('Stack: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _showRecetteDetailsDialog(dynamic recette) async {
    String recetteName;
    int servings;
    String? instructions;
    List<RecetteIngredientFirestore> ingredients = [];

    if (recette is Recette) {
      recetteName = recette.name;
      servings = recette.servings;
      instructions = recette.instructions;

      final db = ref.read(databaseProvider);
      final localIngredients = await (db.select(db.recetteIngredients)
        ..where((ri) => ri.recetteId.equals(recette.id)))
          .get();

      for (final ri in localIngredients) {
        final ing = await db.getIngredientById(ri.ingredientId);
        if (ing != null) {
          ingredients.add(RecetteIngredientFirestore(
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
          ));
        }
      }
    } else {
      final recetteCloud = recette as RecetteFirestore;
      recetteName = recetteCloud.name;
      servings = recetteCloud.servings;
      instructions = recetteCloud.instructions;

      ingredients = await _recetteService.getIngredients(recetteCloud.id);
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(recetteName),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.people, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text('$servings portion(s)', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Icon(Icons.restaurant, color: Colors.green, size: 20),
                  SizedBox(width: 8),
                  Text('Ingrédients:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              const SizedBox(height: 8),
              if (ingredients.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Aucun ingrédient', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                )
              else
                ...ingredients.map((ing) => Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.circle, size: 8, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          ing.ingredientName,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      Text(
                        '${ing.quantity.toStringAsFixed(0)} ${ing.unit}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                )),
              if (instructions != null && instructions.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Row(
                  children: [
                    Icon(Icons.description, color: Colors.teal, size: 20),
                    SizedBox(width: 8),
                    Text('Instructions:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    instructions,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ],
          ),
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

  DateTime _getMealTime(String mealType) {
    switch (mealType) {
      case 'breakfast': return DateTime(2000, 1, 1, 8, 0);
      case 'lunch': return DateTime(2000, 1, 1, 12, 0);
      case 'dinner': return DateTime(2000, 1, 1, 19, 0);
      case 'snack': return DateTime(2000, 1, 1, 16, 0);
      default: return DateTime(2000, 1, 1, 12, 0);
    }
  }

  Future<int> _getMealCountForDay(DateTime day) async {
    int count = 0;
    final localMeals = await _planningRepo.getPlanningForDate(day);
    count += localMeals.length;
    if (_authService.currentUser != null) {
      try {
        final cloudMeals = await _planningService.getPlanningForDate(day).first;
        count += cloudMeals.length;
      } catch (e) {
        // Ignore
      }
    }
    return count;
  }

  Future<Map<String, double>> _getDailyNutrition() async {
    double totalCalories = 0, totalProteins = 0, totalFats = 0, totalCarbs = 0, totalFibers = 0;

    final localPlanning = await _planningRepo.getPlanningForDate(_selectedDate);
    for (final planning in localPlanning) {
      if (planning.recetteId != null) {
        final nutrition = await _recetteRepo.calculateNutritionForRecette(planning.recetteId!);
        final recette = await _recetteRepo.getRecetteById(planning.recetteId!);
        if (recette != null) {
          final portionFactor = planning.servings / recette.servings;
          totalCalories += (nutrition['calories'] ?? 0) * portionFactor;
          totalProteins += (nutrition['proteins'] ?? 0) * portionFactor;
          totalFats += (nutrition['fats'] ?? 0) * portionFactor;
          totalCarbs += (nutrition['carbs'] ?? 0) * portionFactor;
          totalFibers += (nutrition['fibers'] ?? 0) * portionFactor;
        }
      }
    }

    if (_authService.currentUser != null) {
      try {
        final cloudNutrition = await _planningService.getDailyNutritionStats(_selectedDate);
        totalCalories += cloudNutrition['calories'] ?? 0;
        totalProteins += cloudNutrition['proteins'] ?? 0;
        totalFats += cloudNutrition['fats'] ?? 0;
        totalCarbs += cloudNutrition['carbs'] ?? 0;
        totalFibers += cloudNutrition['fibers'] ?? 0;
      } catch (e) {
        // Ignore
      }
    }

    return {
      'calories': totalCalories,
      'proteins': totalProteins,
      'fats': totalFats,
      'carbs': totalCarbs,
      'fibers': totalFibers,
    };
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
    final days = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
    return days[date.weekday - 1];
  }

  String _getDayNameShort(DateTime date) {
    final days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    return days[date.weekday - 1];
  }

  // CORRECTION : Une seule définition de _buildPlanningList
  Widget _buildPlanningList() {
    if (_currentView == PlanningView.day) {
      return _buildDayPlanningList();
    } else if (_currentView == PlanningView.week) {
      return _buildWeekPlanningList();
    }
    return const SizedBox.shrink();
  }

  Widget _buildDayPlanningList() {
    return FutureBuilder<List<dynamic>>(
      future: _loadAllPlanningForDate(_selectedDate),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final allPlanning = snapshot.data ?? [];
        final byMealType = <String, List<dynamic>>{
          'breakfast': [],
          'lunch': [],
          'dinner': [],
          'snack': [],
        };

        for (final item in allPlanning) {
          String mealType;
          if (item is MealPlanningData) {
            mealType = item.mealType;
          } else if (item is PlanningFirestore) {
            mealType = item.mealType;
          } else {
            continue;
          }
          byMealType[mealType]?.add(item);
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildMealSection('breakfast', 'Petit-déjeuner', Icons.free_breakfast, Colors.orange, byMealType['breakfast'] ?? []),
            const SizedBox(height: 12),
            _buildMealSection('lunch', 'Déjeuner', Icons.lunch_dining, Colors.green, byMealType['lunch'] ?? []),
            const SizedBox(height: 12),
            _buildMealSection('dinner', 'Dîner', Icons.dinner_dining, Colors.blue, byMealType['dinner'] ?? []),
            const SizedBox(height: 12),
            _buildMealSection('snack', 'Collation', Icons.cookie, Colors.purple, byMealType['snack'] ?? []),
            const SizedBox(height: 80),
          ],
        );
      },
    );
  }

  Widget _buildWeekPlanningList() {
    final startOfWeek = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
    final weekDays = List.generate(7, (i) => startOfWeek.add(Duration(days: i)));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: weekDays.length,
      itemBuilder: (context, index) {
        final day = weekDays[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            title: Text('${_getDayName(day)} ${day.day}/${day.month}', style: const TextStyle(fontWeight: FontWeight.bold)),
            leading: FutureBuilder<int>(
              future: _getMealCountForDay(day),
              builder: (context, snapshot) {
                final count = snapshot.data ?? 0;
                return CircleAvatar(
                  backgroundColor: count > 0 ? Colors.green : Colors.grey.shade300,
                  child: Text(count.toString(), style: const TextStyle(color: Colors.white)),
                );
              },
            ),
            children: [
              FutureBuilder<List<dynamic>>(
                future: _loadAllPlanningForDate(day),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()));
                  }
                  final meals = snapshot.data!;
                  if (meals.isEmpty) {
                    return const Padding(padding: EdgeInsets.all(16), child: Text('Aucun repas planifié', style: TextStyle(color: Colors.grey)));
                  }
                  return Column(
                    children: meals.map((meal) {
                      if (meal is MealPlanningData) return _buildLocalMealTile(meal, compact: true);
                      if (meal is PlanningFirestore) return _buildCloudMealTile(meal, compact: true);
                      return const SizedBox.shrink();
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<List<dynamic>> _loadAllPlanningForDate(DateTime date) async {
    final List<dynamic> all = [];
    final local = await _planningRepo.getPlanningForDate(date);
    all.addAll(local);
    if (_authService.currentUser != null) {
      try {
        final cloud = await _planningService.getPlanningForDate(date).first;
        all.addAll(cloud);
      } catch (e) {
        // Ignore
      }
    }
    return all;
  }

  Widget _buildMealSection(String mealType, String mealName, IconData icon, Color color, List<dynamic> meals) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: color),
            ),
            title: Text(mealName, style: const TextStyle(fontWeight: FontWeight.bold)),
            trailing: IconButton(icon: const Icon(Icons.add), onPressed: () => _addMealDialog(mealType: mealType)),
          ),
          if (meals.isEmpty)
            const Padding(padding: EdgeInsets.all(16), child: Text('Aucun repas planifié', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)))
          else
            ...meals.map((meal) {
              if (meal is MealPlanningData) return _buildLocalMealTile(meal);
              if (meal is PlanningFirestore) return _buildCloudMealTile(meal);
              return const SizedBox.shrink();
            }),
        ],
      ),
    );
  }

  Widget _buildLocalMealTile(MealPlanningData planning, {bool compact = false}) {
    return FutureBuilder<Recette?>(
      future: _recetteRepo.getRecetteById(planning.recetteId ?? 0),
      builder: (context, snapshot) {
        final recette = snapshot.data;
        final hasModifications = planning.modifiedIngredients != null;

        return ListTile(
          leading: compact
              ? Stack(
            children: [
              const Icon(Icons.phone_android, size: 20, color: Colors.blue),
              if (hasModifications)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          )
              : Stack(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.blue,
                child: Icon(Icons.phone_android, color: Colors.white, size: 20),
              ),
              if (hasModifications)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          title: Row(
            children: [
              Expanded(child: Text(recette?.name ?? 'Chargement...')),
              if (hasModifications)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Modifié',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ),
            ],
          ),
          subtitle: _buildMealEaters(planning.eaters),
          trailing: PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'details', child: Text('📊 Voir détails')),
              if (hasModifications)
                const PopupMenuItem(
                  value: 'reset',
                  child: Text('🔄 Annuler modifications'),
                ),
              const PopupMenuItem(value: 'consume', child: Text('✅ Consommer')),
              const PopupMenuItem(
                value: 'delete',
                child: Text('🗑️ Supprimer', style: TextStyle(color: Colors.red)),
              ),
            ],
            onSelected: (value) async {
              if (value == 'details') {
                _showLocalMealDetailsEnhanced(planning);
              } else if (value == 'reset') {
                await _resetLocalMealModifications(planning);
              } else if (value == 'consume') {
                _markLocalAsConsumed(planning, recette);
              } else if (value == 'delete') {
                _deleteLocalMeal(planning);
              }
            },
          ),
          onTap: () => _showLocalMealDetailsEnhanced(planning),
        );
      },
    );
  }


  // lib/screens/planning_screen_new.dart (FIN - À copier après la partie 2)
// SUITE ET FIN DU FICHIER

  Widget _buildCloudMealTile(PlanningFirestore planning, {bool compact = false}) {
    final hasModifications = planning.modifiedIngredients != null;

    return ListTile(
      leading: compact
          ? Stack(
        children: [
          Icon(
            planning.visibility == PlanningVisibility.private
                ? Icons.cloud
                : Icons.group,
            size: 20,
            color: planning.visibility == PlanningVisibility.private
                ? Colors.grey
                : Colors.green,
          ),
          if (hasModifications)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      )
          : Stack(
        children: [
          CircleAvatar(
            backgroundColor: planning.visibility == PlanningVisibility.private
                ? Colors.grey
                : Colors.green,
            child: Icon(
              planning.visibility == PlanningVisibility.private
                  ? Icons.cloud
                  : Icons.group,
              color: Colors.white,
              size: 20,
            ),
          ),
          if (hasModifications)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
      title: Row(
        children: [
          Expanded(child: Text(planning.recetteName)),
          if (hasModifications)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Modifié',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade700,
                ),
              ),
            ),
        ],
      ),
      subtitle: _buildMealEaters(planning.eaters),
      trailing: PopupMenuButton(
        itemBuilder: (context) => [
          const PopupMenuItem(value: 'details', child: Text('📊 Voir détails')),
          if (hasModifications)
            const PopupMenuItem(
              value: 'reset',
              child: Text('🔄 Annuler modifications'),
            ),
          const PopupMenuItem(value: 'consume', child: Text('✅ Consommer')),
          const PopupMenuItem(
            value: 'delete',
            child: Text('🗑️ Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
        onSelected: (value) async {
          if (value == 'details') {
            _showCloudMealDetailsEnhanced(planning);
          } else if (value == 'reset') {
            await _resetCloudMealModifications(planning);
          } else if (value == 'consume') {
            _markCloudAsConsumed(planning);
          } else if (value == 'delete') {
            _deleteCloudMeal(planning);
          }
        },
      ),
      onTap: () => _showCloudMealDetailsEnhanced(planning),
    );
  }

  Widget _buildMealEaters(String? eatersJson) {
    if (eatersJson == null || eatersJson.isEmpty) return const SizedBox.shrink();
    return FutureBuilder<List<UserProfile>>(
      future: _profileRepo.getProfilesByIds(EatersHelper.decodeEaters(eatersJson)),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const SizedBox.shrink();
        return Wrap(
          spacing: 4,
          children: snapshot.data!.map((profile) => Tooltip(
            message: profile.name,
            child: CircleAvatar(
              radius: 10,
              backgroundColor: _getProfileColor(profile).withValues(alpha: 0.3),
              child: Text(profile.name[0].toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _getProfileColor(profile))),
            ),
          )).toList(),
        );
      },
    );
  }

  Future<void> _deleteLocalMeal(MealPlanningData planning) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Supprimer ce repas ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Annuler')),
          ElevatedButton(onPressed: () => Navigator.pop(c, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Supprimer')),
        ],
      ),
    );
    if (confirm == true) {
      await _planningRepo.deletePlanning(planning.id);
      setState(() {});
    }
  }

  Future<void> _deleteCloudMeal(PlanningFirestore planning) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Supprimer ce repas ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Annuler')),
          ElevatedButton(onPressed: () => Navigator.pop(c, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Supprimer')),
        ],
      ),
    );
    if (confirm == true) {
      await _planningService.deletePlanning(planning.id);
      setState(() {});
    }
  }

  Future<void> _markLocalAsConsumed(MealPlanningData planning, Recette? recette) async {
    if (recette == null) return;
    final profile = await _profileRepo.getActiveProfile();
    if (profile == null) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Créez d\'abord votre profil')));
      return;
    }
    final nutrition = await _recetteRepo.calculateNutritionForRecette(recette.id);
    final portionFactor = planning.servings / recette.servings;
    await _trackingRepo.addTracking(
      userProfileId: profile.id,
      date: planning.date,
      mealType: planning.mealType,
      calories: (nutrition['calories'] ?? 0) * portionFactor,
      proteins: (nutrition['proteins'] ?? 0) * portionFactor,
      fats: (nutrition['fats'] ?? 0) * portionFactor,
      carbs: (nutrition['carbs'] ?? 0) * portionFactor,
      fibers: (nutrition['fibers'] ?? 0) * portionFactor,
      mealPlanningId: planning.id,
    );
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${recette.name} enregistré dans le suivi !'), backgroundColor: Colors.green));
  }

  Future<void> _markCloudAsConsumed(PlanningFirestore planning) async {
    final profile = await _profileRepo.getActiveProfile();
    if (profile == null) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Créez d\'abord votre profil')));
      return;
    }
    await _trackingRepo.addTracking(
      userProfileId: profile.id,
      date: planning.date,
      mealType: planning.mealType,
      calories: planning.totalCalories,
      proteins: planning.totalProteins,
      fats: planning.totalFats,
      carbs: planning.totalCarbs,
      fibers: planning.totalFibers,
    );
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${planning.recetteName} enregistré dans le suivi !'), backgroundColor: Colors.green));
  }

  Future<void> _showMealDetails(Recette? recette, int servings, String? eatersJson) async {
    if (recette == null) return;

    final nutrition = await _recetteRepo.calculateNutritionForRecette(recette.id);
    final portionFactor = servings / recette.servings;

    final db = ref.read(databaseProvider);
    final ingredients = await (db.select(db.recetteIngredients)
      ..where((ri) => ri.recetteId.equals(recette.id)))
        .get();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(recette.name),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.people, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text('$servings portion(s)', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Icon(Icons.restaurant, color: Colors.green, size: 20),
                  SizedBox(width: 8),
                  Text('Ingrédients:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              const SizedBox(height: 8),
              if (ingredients.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Aucun ingrédient', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                )
              else
                ...ingredients.map((ri) => FutureBuilder<Ingredient?>(
                  future: db.select(db.ingredients).get().then((list) {
                    try {
                      return list.firstWhere((i) => i.id == ri.ingredientId);
                    } catch (e) {
                      return null;
                    }
                  }),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data == null) return const SizedBox.shrink();
                    final ingredient = snapshot.data!;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.circle, size: 8, color: Colors.green),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              ingredient.name,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          Text(
                            '${ri.quantity.toStringAsFixed(0)} ${ri.unit}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                )),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Icon(Icons.pie_chart, color: Colors.orange, size: 20),
                  SizedBox(width: 8),
                  Text('Valeurs nutritionnelles:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              const SizedBox(height: 8),
              _buildNutrientRow('Calories', ((nutrition['calories'] ?? 0) * portionFactor).toStringAsFixed(0), 'kcal', Colors.orange),
              _buildNutrientRow('Protéines', ((nutrition['proteins'] ?? 0) * portionFactor).toStringAsFixed(1), 'g', Colors.red),
              _buildNutrientRow('Glucides', ((nutrition['carbs'] ?? 0) * portionFactor).toStringAsFixed(1), 'g', Colors.blue),
              _buildNutrientRow('Lipides', ((nutrition['fats'] ?? 0) * portionFactor).toStringAsFixed(1), 'g', Colors.purple),
              _buildNutrientRow('Fibres', ((nutrition['fibers'] ?? 0) * portionFactor).toStringAsFixed(1), 'g', Colors.brown),
            ],
          ),
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

  Future<void> _showCloudMealDetails(PlanningFirestore planning) async {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Row(
          children: [
            Expanded(child: Text(planning.recetteName)),
            Icon(
              planning.visibility == PlanningVisibility.private ? Icons.cloud : Icons.group,
              color: planning.visibility == PlanningVisibility.private ? Colors.grey : Colors.green,
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.pie_chart, color: Colors.orange, size: 20),
                  SizedBox(width: 8),
                  Text('Valeurs nutritionnelles:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              const SizedBox(height: 8),
              _buildNutrientRow('Calories', planning.totalCalories.toStringAsFixed(0), 'kcal', Colors.orange),
              _buildNutrientRow('Protéines', planning.totalProteins.toStringAsFixed(1), 'g', Colors.red),
              _buildNutrientRow('Glucides', planning.totalCarbs.toStringAsFixed(1), 'g', Colors.blue),
              _buildNutrientRow('Lipides', planning.totalFats.toStringAsFixed(1), 'g', Colors.purple),
            ],
          ),
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

  Widget _buildNutrientRow(String label, String value, String unit, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.circle, size: 12, color: color),
          const SizedBox(width: 8),
          Expanded(child: Text(label)),
          Text('$value $unit', style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Color _getProfileColor(UserProfile profile) {
    if (profile.eaterMultiplier < 0.8) return Colors.blue;
    if (profile.eaterMultiplier > 1.2) return Colors.purple;
    return Colors.green;
  }
} // Fin de la classe _PlanningScreenState