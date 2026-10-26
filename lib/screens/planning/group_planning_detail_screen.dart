// lib/screens/planning/group_planning_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart'; // ✅ AJOUTÉ
import '../../database.dart';
import '../../models/planning_firestore.dart';
import '../../providers.dart';
import '../../repositories/planning_repository.dart';
import '../../repositories/recette_repository.dart';
import '../../repositories/user_profile_repository.dart';
import '../../services/planning_firestore_service.dart';
import '../../services/auth_service.dart';
import '../../services/recette_firestore_service.dart';
import '../../widgets/planning_detail_dialog.dart';
import '../../models/recette_firestore.dart';
import 'planning_form_screen.dart';
import '../../services/meal_consumption_service.dart';
import '../../widgets/consume_meal_dialog.dart';
import '../../utils/portion_calculator.dart';

enum PlanningSourceType {
  all,
  private,
  group,
}

class GroupPlanningDetailScreen extends ConsumerStatefulWidget {
  final PlanningSourceType sourceType;
  final String? groupId;
  final String title;

  const GroupPlanningDetailScreen({
    super.key,
    required this.sourceType,
    this.groupId,
    required this.title,
  });

  @override
  ConsumerState<GroupPlanningDetailScreen> createState() => _GroupPlanningDetailScreenState();
}

class _GroupPlanningDetailScreenState extends ConsumerState<GroupPlanningDetailScreen> {
  final _planningService = PlanningFirestoreService();
  final _authService = AuthService();
  final _recetteService = RecetteFirestoreService();

  late PlanningRepository _planningRepo;
  late RecetteRepository _recetteRepo;
  late UserProfileRepository _profileRepo;

  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  String? _selectedMealType;

  final _mealTypes = [
    {'value': 'breakfast', 'label': '🌅 Petit-déjeuner', 'color': Color(0xFFFFE4B5)},
    {'value': 'lunch', 'label': '☀️ Déjeuner', 'color': Color(0xFFD4E9D7)},
    {'value': 'snack', 'label': '🍪 Collation', 'color': Color(0xFFFFF0E5)},
    {'value': 'dinner', 'label': '🌙 Dîner', 'color': Color(0xFFE1D5E7)},
  ];

  @override
  void initState() {
    super.initState();
    final db = ref.read(databaseProvider);
    _planningRepo = PlanningRepository(db);
    _recetteRepo = ref.read(recetteRepositoryProvider);
    _profileRepo = UserProfileRepository(db);

    // ✅ Initialiser la locale française pour table_calendar
    initializeDateFormatting('fr_FR', null);
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
          // Filtre par type de repas
          PopupMenuButton<String?>(
            icon: Icon(
              _selectedMealType != null ? Icons.filter_alt : Icons.filter_alt_outlined,
              color: _selectedMealType != null ? const Color(0xFF10B981) : const Color(0xFF64748B),
            ),
            tooltip: 'Filtrer par type de repas',
            onSelected: (value) {
              setState(() => _selectedMealType = value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Row(
                  children: [
                    Icon(Icons.clear_all, size: 20),
                    SizedBox(width: 12),
                    Text('Tous les repas'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              ..._mealTypes.map((type) => PopupMenuItem(
                value: type['value'] as String,
                child: Row(
                  children: [
                    Text(
                      type['label'] as String,
                      style: TextStyle(
                        fontWeight: _selectedMealType == type['value']
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: _selectedMealType == type['value']
                            ? Colors.green
                            : null,
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Calendrier
          _buildCalendarView(),

          // Résumé nutritionnel
          _buildNutritionSummary(),

          // Liste des repas
          Expanded(child: _buildPlanningList()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addMeal,
        backgroundColor: const Color(0xFF10B981),
        icon: const Icon(Icons.add),
        label: const Text('Planifier'),
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
        calendarFormat: CalendarFormat.week,
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

  Widget _buildNutritionSummary() {
    return FutureBuilder<Map<String, double>>(
      future: _getDailyNutrition(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        final nutrition = snapshot.data!;
        final calories = nutrition['calories'] ?? 0;
        final proteins = nutrition['proteins'] ?? 0;
        final fats = nutrition['fats'] ?? 0;
        final carbs = nutrition['carbs'] ?? 0;

        if (calories == 0) return const SizedBox.shrink();

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
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

  Widget _buildPlanningList() {
    return FutureBuilder<List<dynamic>>(
      future: _loadAllPlanningForDate(_selectedDate),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        var plannings = snapshot.data ?? [];

        // Filtrer par type de repas
        if (_selectedMealType != null) {
          plannings = plannings.where((planning) {
            if (planning is PlanningFirestore) {
              return planning.mealType == _selectedMealType;
            }
            return false;
          }).toList();
        }

        if (plannings.isEmpty) {
          return _buildEmptyState();
        }

        // Grouper par type de repas
        final byMealType = <String, List<dynamic>>{};
        for (final type in _mealTypes) {
          byMealType[type['value'] as String] = [];
        }

        for (final planning in plannings) {
          String mealType;
          if (planning is PlanningFirestore) {
            mealType = planning.mealType;
          } else {
            continue;
          }
          byMealType[mealType]?.add(planning);
        }

        // Afficher uniquement les sections non vides
        final nonEmptySections = byMealType.entries
            .where((entry) => entry.value.isNotEmpty)
            .toList();

        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 80),
          itemCount: nonEmptySections.length,
          itemBuilder: (context, index) {
            final entry = nonEmptySections[index];
            final mealTypeData = _mealTypes.firstWhere(
                  (t) => t['value'] == entry.key,
              orElse: () => {'value': entry.key, 'label': entry.key, 'color': Colors.grey},
            );

            return _buildMealSection(
              entry.key,
              mealTypeData['label'] as String,
              mealTypeData['color'] as Color,
              entry.value,
            );
          },
        );
      },
    );
  }

  Widget _buildMealSection(
      String mealType,
      String mealLabel,
      Color color,
      List<dynamic> meals,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Column(
        children: [
          // Header de section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Text(
                  mealLabel,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${meals.length}',
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

          // Liste des repas
          ...meals.map((meal) {
            if (meal is PlanningFirestore) return _buildCloudMealTile(meal);
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildLocalMealTile(MealPlanningData planning) {
    // Cette méthode n'est plus utilisée car on a supprimé le support local
    return const SizedBox.shrink();
  }

  Widget _buildCloudMealTile(PlanningFirestore planning) {
    final hasModifications = planning.modifiedIngredients != null;
    final isConsumed = planning.isConsumed;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: isConsumed ? Colors.green.shade50 : null,
      child: ListTile(
        leading: Stack(
          children: [
            CircleAvatar(
              backgroundColor: isConsumed
                  ? Colors.green.shade100
                  : planning.visibility == PlanningVisibility.private
                  ? Colors.grey.shade200
                  : Colors.green.shade200,
              child: Icon(
                isConsumed
                    ? Icons.check_circle
                    : planning.visibility == PlanningVisibility.private
                    ? Icons.cloud
                    : Icons.group,
                color: isConsumed
                    ? Colors.green
                    : planning.visibility == PlanningVisibility.private
                    ? Colors.grey
                    : Colors.green,
                size: 20,
              ),
            ),
            if (hasModifications && !isConsumed)
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
            Expanded(
              child: Text(
                planning.recetteName,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  decoration: isConsumed ? TextDecoration.lineThrough : null,
                  color: isConsumed ? Colors.green.shade700 : null,
                ),
              ),
            ),
            if (isConsumed)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Consommé',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(planning.visibilityLabel),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.local_fire_department, size: 12, color: Colors.orange),
                const SizedBox(width: 4),
                Text(
                  '${(planning.modifiedCalories ?? planning.totalCalories).toStringAsFixed(0)} kcal',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _buildMealActionButton(
                  label: planning.cooked ? 'Cuisiné' : 'Cuisiner',
                  icon: planning.cooked ? Icons.check_circle : Icons.soup_kitchen,
                  done: planning.cooked,
                  color: Colors.amber.shade800,
                  onPressed: () => _runMealAction(planning, MealAction.cook),
                ),
                _buildMealActionButton(
                  label: isConsumed ? 'Consommé' : 'Consommer',
                  icon: isConsumed ? Icons.check_circle : Icons.restaurant,
                  done: isConsumed,
                  color: Colors.green.shade700,
                  onPressed: () => _runMealAction(planning, MealAction.consume),
                ),
              ],
            ),
          ],
        ),
        trailing: isConsumed
            ? null
            : PopupMenuButton<String>( // ✅ AJOUTÉ <String>
          itemBuilder: (context) => <PopupMenuEntry<String>>[ // ✅ AJOUTÉ <PopupMenuEntry<String>>
            const PopupMenuItem<String>( // ✅ AJOUTÉ <String>
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red, size: 20),
                  SizedBox(width: 12),
                  Text('Supprimer'),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'delete') {
              _deleteCloudMeal(planning);
            }
          },
        ),
        onTap: () => _showCloudMealDetails(planning),
      ),
    );
  }

// 3. Ajoutez cette nouvelle méthode pour consommer un repas:

  /// Détermine QUI mange ce repas (et avec quel coefficient).
  /// 1) les convives enregistrés dans le planning ; 2) sinon, l'unique profil ;
  /// 3) sinon, on demande à l'utilisateur de choisir.
  Future<List<EaterPortion>?> _resolveEaters(PlanningFirestore planning) async {
    final resolver = ref.read(eaterResolverProvider);
    final fromPlanning = await resolver.resolve(planning.eaters);
    if (fromPlanning.isNotEmpty) return fromPlanning;

    final profiles = await _profileRepo.getAllProfiles();
    if (profiles.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Créez d\'abord un profil (onglet Suivi calorique)'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }

    UserProfile? chosen;
    if (profiles.length == 1) {
      chosen = profiles.first;
    } else {
      if (!mounted) return null;
      chosen = await showDialog<UserProfile>(
        context: context,
        builder: (c) => SimpleDialog(
          title: const Text('Qui mange ce repas ?'),
          children: profiles
              .map((p) => SimpleDialogOption(
                    onPressed: () => Navigator.pop(c, p),
                    child: Text(p.name),
                  ))
              .toList(),
        ),
      );
    }
    if (chosen == null) return null;

    return [
      EaterPortion(
        profileId: chosen.id,
        name: chosen.name,
        multiplier: chosen.eaterMultiplier,
      ),
    ];
  }

  /// Petit bouton d'action d'un repas (Cuisiner / Consommer).
  Widget _buildMealActionButton({
    required String label,
    required IconData icon,
    required bool done,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 30,
      child: done
          ? Chip(
              avatar: Icon(icon, size: 16, color: Colors.white),
              label: Text(label, style: const TextStyle(color: Colors.white, fontSize: 11)),
              backgroundColor: color,
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
            )
          : OutlinedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon, size: 16, color: color),
              label: Text(label, style: TextStyle(color: color, fontSize: 11)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: color),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                visualDensity: VisualDensity.compact,
              ),
            ),
    );
  }

  /// Lance « Cuisiner » (déduction du stock) ou « Consommer » (calcul calorique).
  Future<void> _runMealAction(PlanningFirestore planning, MealAction action) async {
    List<EaterPortion>? eaters;
    if (action == MealAction.cook) {
      // Pour le stock, pas besoin de choisir un profil : sans convive, on compte 1 personne.
      eaters = await ref.read(eaterResolverProvider).resolve(planning.eaters);
    } else {
      eaters = await _resolveEaters(planning);
    }
    if (eaters == null || !mounted) return;
    final resolvedEaters = eaters;

    // Afficher le dialog de confirmation
    final result = await showDialog<MealConsumptionResult>(
      context: context,
      builder: (context) => ConsumeMealDialog(
        planning: planning,
        consumptionService: ref.read(mealConsumptionServiceProvider),
        eaters: resolvedEaters,
        action: action,
      ),
    );

    if (result != null && mounted) {
      // Afficher le résultat
      final color = result.success ? Colors.green : Colors.red;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(result.message),
              if (result.warnings.isNotEmpty) ...[
                const SizedBox(height: 8),
                ...result.warnings.map((w) => Text(w, style: const TextStyle(fontSize: 12))),
              ],
            ],
          ),
          backgroundColor: color,
          duration: const Duration(seconds: 6),
          action: result.warnings.isNotEmpty
              ? SnackBarAction(
            label: 'Détails',
            textColor: Colors.white,
            onPressed: () {
              _showConsumptionDetails(result);
            },
          )
              : null,
        ),
      );

      // Rafraîchir l'écran
      setState(() {});
    }
  }

// 4. Ajoutez cette méthode pour afficher les détails de la consommation:

  void _showConsumptionDetails(MealConsumptionResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Détails de la consommation'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                result.message,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (result.warnings.isNotEmpty) ...[
                const Text(
                  'Informations :',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...result.warnings.map((w) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('• $w', style: const TextStyle(fontSize: 12)),
                )),
              ],
              if (result.stockAdjustments.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Ajustements du stock:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...result.stockAdjustments.map((adj) => Card(
                  color: adj.sufficient ? Colors.green.shade50 : Colors.red.shade50,
                  child: ListTile(
                    dense: true,
                    leading: Icon(
                      adj.sufficient ? Icons.check : Icons.warning,
                      color: adj.sufficient ? Colors.green : Colors.red,
                      size: 20,
                    ),
                    title: Text(adj.ingredientName, style: const TextStyle(fontSize: 13)),
                    subtitle: Text(
                      '${adj.quantityNeeded} ${adj.unit} nécessaire(s) / '
                          '${adj.quantityAvailable} ${adj.unit} disponible(s)',
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                )),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
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
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.event_busy_rounded,
                size: 64,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Aucun repas planifié',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedMealType != null
                  ? 'Aucun repas trouvé pour ce type'
                  : 'Planifiez votre premier repas',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _addMeal,
              icon: const Icon(Icons.add),
              label: const Text('Planifier un repas'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
            ),
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

  Future<List<dynamic>> _loadAllPlanningForDate(DateTime date) async {
    final List<dynamic> all = [];

    if (_authService.currentUser == null) {
      return all;
    }

    try {
      // Charger selon le type de source
      switch (widget.sourceType) {
        case PlanningSourceType.all:
        // Charger tous les plannings cloud (privés + groupes)
          final cloud = await _planningService.getPlanningForDate(date).first;
          all.addAll(cloud);
          break;

        case PlanningSourceType.private:
        // Charger uniquement les plannings privés
          final cloud = await _planningService.getPlanningForDate(date).first;
          all.addAll(cloud.where((p) => p.visibility == PlanningVisibility.private));
          break;

        case PlanningSourceType.group:
        // Charger uniquement les plannings du groupe sélectionné
          if (widget.groupId != null) {
            final cloud = await _planningService.getPlanningForDate(date).first;
            all.addAll(cloud.where((p) =>
            p.visibility == PlanningVisibility.group && p.groupId == widget.groupId
            ));
          }
          break;
      }
    } catch (e) {
      debugPrint('Erreur chargement planning: $e');
    }

    return all;
  }

  Future<int> _getMealCountForDay(DateTime day) async {
    final plannings = await _loadAllPlanningForDate(day);
    return plannings.length;
  }

  Future<Map<String, double>> _getDailyNutrition() async {
    double totalCalories = 0, totalProteins = 0, totalFats = 0, totalCarbs = 0;

    final plannings = await _loadAllPlanningForDate(_selectedDate);

    for (final planning in plannings) {
      if (planning is PlanningFirestore) {
        totalCalories += planning.totalCalories;
        totalProteins += planning.totalProteins;
        totalFats += planning.totalFats;
        totalCarbs += planning.totalCarbs;
      }
    }

    return {
      'calories': totalCalories,
      'proteins': totalProteins,
      'fats': totalFats,
      'carbs': totalCarbs,
    };
  }

  // ============================================================================
  // ACTIONS
  // ============================================================================

  Future<void> _addMeal() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => PlanningFormScreen(
          selectedDate: _selectedDate,
          sourceType: widget.sourceType,
          groupId: widget.groupId,
          groupName: widget.title,
        ),
      ),
    );

    if (result == true) {
      setState(() {});
    }
  }

  Future<void> _showLocalMealDetails(MealPlanningData planning, Recette? recette) async {
    if (recette == null) return;

    final nutrition = await _recetteRepo.calculateNutritionForRecette(recette.id);
    final portionFactor = planning.servings / recette.servings;

    final adjustedNutrition = nutrition.map((key, value) =>
        MapEntry(key, value * portionFactor)
    );

    final db = ref.read(databaseProvider);
    final ingredients = await (db.select(db.recetteIngredients)
      ..where((ri) => ri.recetteId.equals(recette.id)))
        .get();

    final profile = await _profileRepo.getActiveProfile();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (c) => PlanningDetailDialog(
        recetteName: recette.name,
        servings: planning.servings,
        nutrition: adjustedNutrition,
        ingredients: ingredients,
        userProfile: profile,
      ),
    );
  }

  Future<void> _showCloudMealDetails(PlanningFirestore planning) async {
    final ingredients = await _recetteService.getIngredients(planning.recetteId);
    final profile = await _profileRepo.getActiveProfile();

    final nutrition = {
      'calories': planning.totalCalories,
      'proteins': planning.totalProteins,
      'fats': planning.totalFats,
      'carbs': planning.totalCarbs,
      'fibers': planning.totalFibers,
    };

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (c) => PlanningDetailDialog(
        recetteName: planning.recetteName,
        servings: 1,
        nutrition: nutrition,
        ingredients: ingredients,
        userProfile: profile,
      ),
    );
  }

  Future<void> _deleteLocalMeal(MealPlanningData planning) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Supprimer ce repas ?'),
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
      await _planningService.deletePlanning(planning.id);
      setState(() {});
    }
  }
}