// lib/screens/calorie_tracking_screen.dart - PARTIE 1/3
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database.dart';
import '../providers.dart';
import '../repositories/calorie_tracking_repository.dart';
import '../repositories/user_profile_repository.dart';

enum ViewMode { day, week, month }

class CalorieTrackingScreen extends ConsumerStatefulWidget {
  const CalorieTrackingScreen({super.key});

  @override
  ConsumerState<CalorieTrackingScreen> createState() => _CalorieTrackingScreenState();
}

class _CalorieTrackingScreenState extends ConsumerState<CalorieTrackingScreen> {
  DateTime _selectedDate = DateTime.now();
  ViewMode _viewMode = ViewMode.day;

  late CalorieTrackingRepository _trackingRepo;
  late UserProfileRepository _profileRepo;

  List<UserProfile> _allProfiles = [];
  UserProfile? _selectedProfile;

  @override
  void initState() {
    super.initState();
    final db = ref.read(databaseProvider);
    _trackingRepo = CalorieTrackingRepository(db);
    _profileRepo = UserProfileRepository(db, groupProfileService: ref.read(groupProfileServiceProvider));
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    final profiles = await _profileRepo.getAllProfiles();
    if (profiles.isNotEmpty && mounted) {
      setState(() {
        _allProfiles = profiles;
        _selectedProfile = profiles.first;
      });
    }
  }

  void _changeDate(int delta) {
    setState(() {
      switch (_viewMode) {
        case ViewMode.day:
          _selectedDate = _selectedDate.add(Duration(days: delta));
          break;
        case ViewMode.week:
          _selectedDate = _selectedDate.add(Duration(days: delta * 7));
          break;
        case ViewMode.month:
          _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + delta, 1);
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedProfile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Suivi calorique')),
        body: _buildEmptyState(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Suivi calorique'),
        actions: [
          // Sélecteur de profil
          PopupMenuButton<UserProfile>(
            icon: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.green.shade100,
              child: Icon(
                _selectedProfile!.sex == 'male' ? Icons.man : Icons.woman,
                size: 20,
                color: Colors.green,
              ),
            ),
            tooltip: 'Changer de profil',
            itemBuilder: (context) => _allProfiles.map((profile) {
              return PopupMenuItem<UserProfile>(
                value: profile,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: profile.id == _selectedProfile!.id
                          ? Colors.green.shade100
                          : Colors.grey.shade200,
                      child: Icon(
                        profile.sex == 'male' ? Icons.man : Icons.woman,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(profile.name)),
                    if (profile.id == _selectedProfile!.id)
                      const Icon(Icons.check, color: Colors.green, size: 20),
                  ],
                ),
              );
            }).toList(),
            onSelected: (profile) {
              setState(() => _selectedProfile = profile);
            },
          ),
          // Calendrier
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now().add(const Duration(days: 7)),
              );
              if (picked != null) {
                setState(() => _selectedDate = picked);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildNavigationBar(),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_off, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Aucun profil configuré',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Créez vos profils pour commencer le suivi',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/profiles');
            },
            icon: const Icon(Icons.person_add),
            label: const Text('Créer un profil'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.green.shade50,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => _changeDate(-1),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    _getDateLabel(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _canGoForward() ? () => _changeDate(1) : null,
              ),
            ],
          ),
          const SizedBox(height: 12),
          SegmentedButton<ViewMode>(
            segments: const [
              ButtonSegment(value: ViewMode.day, label: Text('Jour'), icon: Icon(Icons.today, size: 16)),
              ButtonSegment(value: ViewMode.week, label: Text('Semaine'), icon: Icon(Icons.view_week, size: 16)),
              ButtonSegment(value: ViewMode.month, label: Text('Mois'), icon: Icon(Icons.calendar_month, size: 16)),
            ],
            selected: {_viewMode},
            onSelectionChanged: (Set<ViewMode> newSelection) {
              setState(() => _viewMode = newSelection.first);
            },
          ),
        ],
      ),
    );
  }

  bool _canGoForward() {
    switch (_viewMode) {
      case ViewMode.day:
        return _selectedDate.isBefore(DateTime.now());
      case ViewMode.week:
        final nextWeek = _selectedDate.add(const Duration(days: 7));
        return nextWeek.isBefore(DateTime.now());
      case ViewMode.month:
        final nextMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
        return nextMonth.isBefore(DateTime.now());
    }
  }

  String _getDateLabel() {
    switch (_viewMode) {
      case ViewMode.day:
        return _formatDate(_selectedDate);
      case ViewMode.week:
        final weekStart = _getWeekStart(_selectedDate);
        final weekEnd = weekStart.add(const Duration(days: 6));
        return '${_formatShortDate(weekStart)} - ${_formatShortDate(weekEnd)}';
      case ViewMode.month:
        final months = ['Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
          'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'];
        return '${months[_selectedDate.month - 1]} ${_selectedDate.year}';
    }
  }

  Widget _buildContent() {
    switch (_viewMode) {
      case ViewMode.day:
        return _buildDayView();
      case ViewMode.week:
        return _buildWeekView();
      case ViewMode.month:
        return _buildMonthView();
    }
  }

  // VUE JOUR
  Widget _buildDayView() {
    return FutureBuilder<List<CalorieTrackingData>>(
      future: _trackingRepo.getTrackingForDateRange(
        _selectedProfile!.id,
        DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day),
        DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 23, 59, 59),
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final trackings = snapshot.data ?? [];
        final stats = _calculateDayStats(trackings);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildProgressCircle(stats),
              const SizedBox(height: 24),
              _buildStatsRow(stats),
              const SizedBox(height: 24),
              _buildMacrosSection(stats),
              const SizedBox(height: 24),
              _buildMealsSection(trackings),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressCircle(Map<String, double> stats) {
    final targetCalories = _selectedProfile!.tdee ?? 2000;
    final progress = (stats['calories']! / targetCalories).clamp(0.0, 1.0);
    final remaining = (targetCalories - stats['calories']!).clamp(0.0, double.infinity);

    return Center(
      child: SizedBox(
        width: 200,
        height: 200,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 200,
              height: 200,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 20,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress > 0.9 ? Colors.red : Colors.green,
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  stats['calories']!.toStringAsFixed(0),
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'sur ${targetCalories.toStringAsFixed(0)} kcal',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${remaining.toStringAsFixed(0)} kcal restantes',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(Map<String, double> stats) {
    final targetCalories = _selectedProfile!.tdee ?? 2000;
    final remaining = (targetCalories - stats['calories']!).clamp(0.0, double.infinity);

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Consommé',
            value: stats['calories']!.toStringAsFixed(0),
            unit: 'kcal',
            color: Colors.green,
            icon: Icons.restaurant,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Restant',
            value: remaining.toStringAsFixed(0),
            unit: 'kcal',
            color: Colors.blue,
            icon: Icons.trending_down,
          ),
        ),
      ],
    );
  }

  Widget _buildMacrosSection(Map<String, double> stats) {
    final targetCalories = _selectedProfile!.tdee ?? 2000;
    final targetProteins = (targetCalories * 0.30) / 4;
    final targetCarbs = (targetCalories * 0.50) / 4;
    final targetFats = (targetCalories * 0.20) / 9;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Macronutriments',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _MacroBar(
          label: 'Protéines',
          current: stats['proteins']!,
          target: targetProteins,
          color: Colors.red,
          unit: 'g',
        ),
        const SizedBox(height: 8),
        _MacroBar(
          label: 'Glucides',
          current: stats['carbs']!,
          target: targetCarbs,
          color: Colors.blue,
          unit: 'g',
        ),
        const SizedBox(height: 8),
        _MacroBar(
          label: 'Lipides',
          current: stats['fats']!,
          target: targetFats,
          color: Colors.purple,
          unit: 'g',
        ),
      ],
    );
  }

// SUITE DANS PARTIE 2...
// lib/screens/calorie_tracking_screen.dart - PARTIE 2/3
// SUITE DE LA PARTIE 1

  Widget _buildMealsSection(List<CalorieTrackingData> trackings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Repas consommés',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '${trackings.length} repas',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (trackings.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.restaurant_menu, size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 8),
                    const Text('Aucun repas consommé', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
          )
        else
          ...trackings.map((tracking) => _buildMealCard(tracking)),
      ],
    );
  }

  Widget _buildMealCard(CalorieTrackingData tracking) {
    final mealInfo = _getMealInfo(tracking.mealType);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (mealInfo['color'] as Color).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(mealInfo['icon'] as IconData, color: mealInfo['color'] as Color),
        ),
        title: Text(mealInfo['name'] as String),
        subtitle: Text(
          '${tracking.calories.toStringAsFixed(0)} kcal • '
              'P: ${tracking.proteins.toStringAsFixed(0)}g • '
              'G: ${tracking.carbs.toStringAsFixed(0)}g • '
              'L: ${tracking.fats.toStringAsFixed(0)}g',
        ),
        trailing: Text(
          '${tracking.date.hour.toString().padLeft(2, '0')}:${tracking.date.minute.toString().padLeft(2, '0')}',
          style: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  // ============================================================================
  // VUE SEMAINE
  // ============================================================================

  Widget _buildWeekView() {
    final weekStart = _getWeekStart(_selectedDate);
    final weekEnd = weekStart.add(const Duration(days: 6, hours: 23, minutes: 59));

    return FutureBuilder<List<CalorieTrackingData>>(
      future: _trackingRepo.getTrackingForDateRange(
        _selectedProfile!.id,
        weekStart,
        weekEnd,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final trackings = snapshot.data ?? [];
        final dailyStats = _groupByDay(trackings, weekStart);
        final weekStats = _calculateWeekStats(trackings);
        final targetCalories = _selectedProfile!.tdee ?? 2000;
        final avgCalories = weekStats['calories']! / 7;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Stats hebdomadaires
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Moyenne/jour',
                      value: avgCalories.toStringAsFixed(0),
                      unit: 'kcal',
                      color: Colors.green,
                      icon: Icons.show_chart,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Total semaine',
                      value: weekStats['calories']!.toStringAsFixed(0),
                      unit: 'kcal',
                      color: Colors.blue,
                      icon: Icons.calendar_view_week,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Graphique par jour
              const Text(
                'Calories par jour',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...List.generate(7, (index) {
                final day = weekStart.add(Duration(days: index));
                final dayKey = '${day.year}-${day.month}-${day.day}';
                final stats = dailyStats[dayKey] ?? {'calories': 0.0};
                final progress = (stats['calories']! / targetCalories).clamp(0.0, 1.0);

                return _buildDayBar(day, stats['calories']!, targetCalories, progress);
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDayBar(DateTime day, double calories, double target, double progress) {
    final isToday = day.year == DateTime.now().year &&
        day.month == DateTime.now().month &&
        day.day == DateTime.now().day;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isToday ? Colors.green.shade50 : null,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDayName(day),
                  style: TextStyle(
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                Text(
                  '${calories.toStringAsFixed(0)} / ${target.toStringAsFixed(0)} kcal',
                  style: TextStyle(
                    color: progress > 0.9 ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 12,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress > 0.9 ? Colors.red : Colors.green,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // VUE MOIS
  // ============================================================================

  Widget _buildMonthView() {
    final monthStart = DateTime(_selectedDate.year, _selectedDate.month, 1);
    final monthEnd = DateTime(_selectedDate.year, _selectedDate.month + 1, 0, 23, 59);

    return FutureBuilder<List<CalorieTrackingData>>(
      future: _trackingRepo.getTrackingForDateRange(
        _selectedProfile!.id,
        monthStart,
        monthEnd,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final trackings = snapshot.data ?? [];
        final monthStats = _calculateMonthStats(trackings);
        final targetCalories = _selectedProfile!.tdee ?? 2000;
        final daysInMonth = monthEnd.day;
        final avgCalories = monthStats['calories']! / daysInMonth;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Stats mensuelles
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Moyenne/jour',
                      value: avgCalories.toStringAsFixed(0),
                      unit: 'kcal',
                      color: Colors.green,
                      icon: Icons.show_chart,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Total mois',
                      value: monthStats['calories']!.toStringAsFixed(0),
                      unit: 'kcal',
                      color: Colors.purple,
                      icon: Icons.calendar_month,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Macros du mois
              _buildMacrosSection(monthStats),
              const SizedBox(height: 24),

              // Tendance
              const Text(
                'Tendance du mois',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildMonthStat('Jours suivis', '${trackings.map((t) => '${t.date.year}-${t.date.month}-${t.date.day}').toSet().length}', Icons.check_circle),
                          _buildMonthStat('Repas total', '${trackings.length}', Icons.restaurant),
                          _buildMonthStat('Objectif atteint', '${_countDaysWithinTarget(trackings, targetCalories)}', Icons.flag),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMonthStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.green, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ============================================================================
  // HELPERS
  // ============================================================================

  Map<String, double> _calculateDayStats(List<CalorieTrackingData> trackings) {
    return {
      'calories': trackings.fold(0.0, (sum, t) => sum + t.calories),
      'proteins': trackings.fold(0.0, (sum, t) => sum + t.proteins),
      'carbs': trackings.fold(0.0, (sum, t) => sum + t.carbs),
      'fats': trackings.fold(0.0, (sum, t) => sum + t.fats),
    };
  }

  Map<String, double> _calculateWeekStats(List<CalorieTrackingData> trackings) {
    return _calculateDayStats(trackings);
  }

  Map<String, double> _calculateMonthStats(List<CalorieTrackingData> trackings) {
    return _calculateDayStats(trackings);
  }

  Map<String, Map<String, double>> _groupByDay(List<CalorieTrackingData> trackings, DateTime weekStart) {
    final grouped = <String, Map<String, double>>{};

    for (final tracking in trackings) {
      final dayKey = '${tracking.date.year}-${tracking.date.month}-${tracking.date.day}';
      if (!grouped.containsKey(dayKey)) {
        grouped[dayKey] = {'calories': 0.0, 'proteins': 0.0, 'carbs': 0.0, 'fats': 0.0};
      }
      grouped[dayKey]!['calories'] = grouped[dayKey]!['calories']! + tracking.calories;
      grouped[dayKey]!['proteins'] = grouped[dayKey]!['proteins']! + tracking.proteins;
      grouped[dayKey]!['carbs'] = grouped[dayKey]!['carbs']! + tracking.carbs;
      grouped[dayKey]!['fats'] = grouped[dayKey]!['fats']! + tracking.fats;
    }

    return grouped;
  }

  int _countDaysWithinTarget(List<CalorieTrackingData> trackings, double target) {
    final dailyCalories = <String, double>{};

    for (final tracking in trackings) {
      final dayKey = '${tracking.date.year}-${tracking.date.month}-${tracking.date.day}';
      dailyCalories[dayKey] = (dailyCalories[dayKey] ?? 0) + tracking.calories;
    }

    return dailyCalories.values.where((cal) => cal >= target * 0.8 && cal <= target * 1.1).length;
  }

  DateTime _getWeekStart(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Aujourd\'hui';
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day) {
      return 'Hier';
    }
    final months = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin', 'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatShortDate(DateTime date) {
    return '${date.day}/${date.month}';
  }

  String _formatDayName(DateTime date) {
    final days = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
    return '${days[date.weekday - 1]} ${date.day}/${date.month}';
  }

  Map<String, dynamic> _getMealInfo(String mealType) {
    switch (mealType) {
      case 'breakfast':
        return {'name': 'Petit-déjeuner', 'icon': Icons.free_breakfast, 'color': Colors.orange};
      case 'lunch':
        return {'name': 'Déjeuner', 'icon': Icons.lunch_dining, 'color': Colors.green};
      case 'dinner':
        return {'name': 'Dîner', 'icon': Icons.dinner_dining, 'color': Colors.blue};
      case 'snack':
        return {'name': 'Collation', 'icon': Icons.cookie, 'color': Colors.purple};
      default:
        return {'name': 'Repas', 'icon': Icons.restaurant, 'color': Colors.grey};
    }
  }
}

// SUITE DANS PARTIE 3...
// lib/screens/calorie_tracking_screen.dart - PARTIE 3/3
// WIDGETS RÉUTILISABLES

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroBar extends StatelessWidget {
  final String label;
  final double current;
  final double target;
  final Color color;
  final String unit;

  const _MacroBar({
    required this.label,
    required this.current,
    required this.target,
    required this.color,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (current / target).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '${current.toStringAsFixed(0)} / ${target.toStringAsFixed(0)} $unit',
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 12,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}