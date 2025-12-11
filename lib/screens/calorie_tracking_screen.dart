// lib/screens/calorie_tracking_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database.dart';
import '../providers.dart';
import '../repositories/calorie_tracking_repository.dart';
import '../repositories/user_profile_repository.dart';

class CalorieTrackingScreen extends ConsumerStatefulWidget {
  const CalorieTrackingScreen({super.key});

  @override
  ConsumerState<CalorieTrackingScreen> createState() => _CalorieTrackingScreenState();
}

class _CalorieTrackingScreenState extends ConsumerState<CalorieTrackingScreen> {
  DateTime _selectedDate = DateTime.now();
  final String _viewMode = 'day';

  late CalorieTrackingRepository _trackingRepo;
  late UserProfileRepository _profileRepo;

  UserProfile? _activeProfile;
  double _targetCalories = 2000;

  @override
  void initState() {
    super.initState();
    final db = ref.read(databaseProvider);
    _trackingRepo = CalorieTrackingRepository(db);
    _profileRepo = UserProfileRepository(db);
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await _profileRepo.getActiveProfile();
    if (profile != null && mounted) {
      setState(() {
        _activeProfile = profile;
        _targetCalories = profile.tdee ?? 2000;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_activeProfile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Suivi calorique')),
        body: Center(
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
                'Créez votre profil pour commencer le suivi',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  // Ouvrir le profil via le drawer
                },
                icon: const Icon(Icons.person_add),
                label: const Text('Créer mon profil'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Suivi calorique'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() => _selectedDate = picked);
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<List<CalorieTrackingData>>(
        future: _trackingRepo.getTrackingForDateRange(
          _activeProfile!.id,
          DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day),
          DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 23, 59, 59),
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final trackings = snapshot.data ?? [];
          final totalCalories = trackings.fold<double>(0, (sum, t) => sum + t.calories);
          final totalProteins = trackings.fold<double>(0, (sum, t) => sum + t.proteins);
          final totalCarbs = trackings.fold<double>(0, (sum, t) => sum + t.carbs);
          final totalFats = trackings.fold<double>(0, (sum, t) => sum + t.fats);

          final progress = (totalCalories / _targetCalories).clamp(0.0, 1.0);
          final remaining = (_targetCalories - totalCalories).clamp(0.0, double.infinity);

          // Objectifs macros (exemple : 30% protéines, 50% glucides, 20% lipides)
          final targetProteins = (_targetCalories * 0.30) / 4; // 1g protéine = 4 kcal
          final targetCarbs = (_targetCalories * 0.50) / 4;
          final targetFats = (_targetCalories * 0.20) / 9; // 1g lipide = 9 kcal

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date sélectionnée
                Text(
                  _formatDate(_selectedDate),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 24),

                // Cercle de progression
                Center(
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
                              totalCalories.toStringAsFixed(0),
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'sur ${_targetCalories.toStringAsFixed(0)} kcal',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Stats détaillées
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'Restant',
                        value: remaining.toStringAsFixed(0),
                        unit: 'kcal',
                        color: Colors.blue,
                        icon: Icons.trending_down,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        label: 'Objectif',
                        value: _targetCalories.toStringAsFixed(0),
                        unit: 'kcal',
                        color: Colors.green,
                        icon: Icons.flag,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Macros
                const Text(
                  'Macronutriments',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                _MacroBar(
                  label: 'Protéines',
                  current: totalProteins,
                  target: targetProteins,
                  color: Colors.red,
                  unit: 'g',
                ),
                const SizedBox(height: 8),
                _MacroBar(
                  label: 'Glucides',
                  current: totalCarbs,
                  target: targetCarbs,
                  color: Colors.blue,
                  unit: 'g',
                ),
                const SizedBox(height: 8),
                _MacroBar(
                  label: 'Lipides',
                  current: totalFats,
                  target: targetFats,
                  color: Colors.purple,
                  unit: 'g',
                ),

                const SizedBox(height: 24),

                // Historique des repas
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Repas consommés',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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
                            const Text(
                              'Aucun repas consommé aujourd\'hui',
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Marquez vos repas planifiés comme "consommés" depuis l\'onglet Planning',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  ...trackings.map((tracking) {
                    return _buildMealCard(
                      _getMealName(tracking.mealType),
                      tracking.calories,
                      _getMealIcon(tracking.mealType),
                      _getMealColor(tracking.mealType),
                      tracking,
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMealCard(String name, double calories, IconData icon, Color color, CalorieTrackingData tracking) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(name),
        subtitle: Text(
          '${calories.toStringAsFixed(0)} kcal • '
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

  String _getMealName(String mealType) {
    switch (mealType) {
      case 'breakfast': return 'Petit-déjeuner';
      case 'lunch': return 'Déjeuner';
      case 'dinner': return 'Dîner';
      case 'snack': return 'Collation';
      default: return 'Repas';
    }
  }

  IconData _getMealIcon(String mealType) {
    switch (mealType) {
      case 'breakfast': return Icons.free_breakfast;
      case 'lunch': return Icons.lunch_dining;
      case 'dinner': return Icons.dinner_dining;
      case 'snack': return Icons.cookie;
      default: return Icons.restaurant;
    }
  }

  Color _getMealColor(String mealType) {
    switch (mealType) {
      case 'breakfast': return Colors.orange;
      case 'lunch': return Colors.green;
      case 'dinner': return Colors.blue;
      case 'snack': return Colors.purple;
      default: return Colors.grey;
    }
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
}

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