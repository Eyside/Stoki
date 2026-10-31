// lib/screens/home_screen.dart
// Accueil = résumé : suivi calorique de la semaine, prochains repas,
// produits bientôt périmés.
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_profile.dart';
import '../models/frigo_firestore.dart';
import '../providers.dart';
import '../services/auth_service.dart';
import '../services/frigo_firestore_service.dart';
import '../services/group_service.dart';
import '../services/planning_firestore_service.dart';
import 'calorie_tracking_screen.dart';

class _HomeData {
  final AppProfile? profile;
  final double weekCalories;
  final List<Map<String, dynamic>> meals;
  final List<FrigoFirestore> expiring;
  const _HomeData(this.profile, this.weekCalories, this.meals, this.expiring);
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _planningService = PlanningFirestoreService();
  final _frigoService = FrigoFirestoreService();
  final _groupService = GroupService();

  late Future<_HomeData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<void> _refresh() async {
    final f = _load();
    setState(() => _future = f);
    await f;
  }

  Future<_HomeData> _load() async {
    final profileService = ref.read(profileFirestoreServiceProvider);
    final tracking = ref.read(calorieTrackingFirestoreServiceProvider);

    AppProfile? profile;
    try {
      profile = await profileService.getMyProfile();
    } catch (e) {
      debugPrint('Accueil - profil: $e');
    }

    // Semaine en cours : lundi 00:00 -> dimanche 23:59
    final now = DateTime.now();
    final monday = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final sunday = monday
        .add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));

    double weekCalories = 0;
    try {
      final entries = await tracking.getRange(monday, sunday);
      weekCalories = entries.fold(0.0, (sum, e) => sum + e.calories);
    } catch (e) {
      debugPrint('Accueil - calories: $e');
    }

    List<Map<String, dynamic>> meals = [];
    try {
      meals = await _planningService.getUpcomingMeals(limit: 3).first;
    } catch (e) {
      debugPrint('Accueil - repas: $e');
    }

    final expiring = await _loadExpiring();
    return _HomeData(profile, weekCalories, meals, expiring);
  }

  /// Produits de mon stock privé et des stocks de mes groupes qui expirent
  /// dans les 7 jours (ou sont déjà périmés).
  Future<List<FrigoFirestore>> _loadExpiring() async {
    final items = <FrigoFirestore>[];
    try {
      final mine = await _frigoService.getAllMyStocks().first;
      items.addAll(mine.where((i) => i.visibility == FrigoVisibility.private));

      final uid = AuthService().currentUser?.uid;
      if (uid != null) {
        final groups = await _groupService.getUserGroups(uid).first;
        for (final g in groups) {
          items.addAll(await _frigoService.getGroupStock(g['id'] as String).first);
        }
      }
    } catch (e) {
      debugPrint('Accueil - stocks: $e');
    }

    final limit = DateTime.now().add(const Duration(days: 7));
    final expiring = items
        .where((i) => i.bestBefore != null && i.bestBefore!.isBefore(limit))
        .toList()
      ..sort((a, b) => a.bestBefore!.compareTo(b.bestBefore!));
    return expiring;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: FutureBuilder<_HomeData>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snap.data;
          if (data == null) {
            return ListView(children: const [
              SizedBox(height: 120),
              Center(child: Text('Impossible de charger le résumé')),
            ]);
          }
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              _buildCalorieCard(data),
              const SizedBox(height: 16),
              _buildMealsCard(data.meals),
              const SizedBox(height: 16),
              _buildExpiringCard(data.expiring),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CARTE CALORIES
  // ---------------------------------------------------------------------------

  Widget _card({required String title, IconData? icon, Widget? trailing, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: const Color(0xFF64748B)),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildCalorieCard(_HomeData data) {
    final profile = data.profile;

    if (profile == null) {
      return _card(
        title: 'Suivi calorique',
        icon: Icons.local_fire_department_rounded,
        child: Column(
          children: [
            const Text(
              'Créez votre profil pour suivre vos calories et votre objectif.',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () async {
                  await Navigator.pushNamed(context, '/profiles');
                  _refresh();
                },
                child: const Text('Créer mon profil'),
              ),
            ),
          ],
        ),
      );
    }

    final weekTarget = profile.tdee * 7;
    final progress = weekTarget <= 0 ? 0.0 : data.weekCalories / weekTarget;
    final remaining = math.max(0.0, weekTarget - data.weekCalories);

    return _card(
      title: 'Cette semaine',
      icon: Icons.local_fire_department_rounded,
      trailing: TextButton(
        style: TextButton.styleFrom(
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CalorieTrackingScreen()),
          );
          _refresh();
        },
        child: const Text('Détails'),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            height: 90,
            child: CustomPaint(
              painter: _ArcGaugePainter(
                progress: progress,
                color: progress > 1.0
                    ? const Color(0xFFEF5350)
                    : const Color(0xFF43A047),
              ),
              child: Align(
                alignment: const Alignment(0, 0.55),
                child: Text(
                  '${(progress * 100).round()} %',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _stat('Consommé', '${data.weekCalories.round()} kcal'),
                _stat('Objectif', '${weekTarget.round()} kcal'),
                _stat('Restant', '${remaining.round()} kcal'),
                _stat('Poids', '${_fmt(profile.weightKg)} kg'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          Text(value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B))),
        ],
      ),
    );
  }

  String _fmt(double v) =>
      v == v.roundToDouble() ? v.round().toString() : v.toStringAsFixed(1);

  // ---------------------------------------------------------------------------
  // PROCHAINS REPAS
  // ---------------------------------------------------------------------------

  Widget _buildMealsCard(List<Map<String, dynamic>> meals) {
    return _card(
      title: 'Prochains repas',
      icon: Icons.restaurant_rounded,
      child: meals.isEmpty
          ? const Text('Aucun repas planifié.',
              style: TextStyle(color: Color(0xFF64748B)))
          : Column(
              children: [for (final m in meals) _mealRow(m)],
            ),
    );
  }

  Widget _mealRow(Map<String, dynamic> meal) {
    final mealType = meal['mealType'] as String? ?? '';
    final color = _getMealColor(mealType);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_getMealIcon(mealType), size: 18, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal['recipeName'] as String? ?? 'Repas',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
                Text(
                  '${_formatDate(meal['date'] as DateTime)} · ${_getMealTypeLabel(mealType)}',
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BIENTÔT PÉRIMÉS
  // ---------------------------------------------------------------------------

  Widget _buildExpiringCard(List<FrigoFirestore> items) {
    final shown = items.take(8).toList();
    return _card(
      title: 'À consommer cette semaine',
      icon: Icons.hourglass_bottom_rounded,
      child: items.isEmpty
          ? const Text('Rien ne périme dans les 7 prochains jours.',
              style: TextStyle(color: Color(0xFF64748B)))
          : Column(
              children: [
                for (final i in shown) _expiringRow(i),
                if (items.length > shown.length)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text('+ ${items.length - shown.length} autres',
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF64748B))),
                  ),
              ],
            ),
    );
  }

  Widget _expiringRow(FrigoFirestore item) {
    final today = DateTime.now();
    final d0 = DateTime(today.year, today.month, today.day);
    final b = item.bestBefore!;
    final days = DateTime(b.year, b.month, b.day).difference(d0).inDays;

    final String label;
    final Color color;
    if (days < 0) {
      label = 'Périmé';
      color = const Color(0xFFE53935);
    } else if (days == 0) {
      label = "Aujourd'hui";
      color = const Color(0xFFE53935);
    } else if (days == 1) {
      label = 'Demain';
      color = const Color(0xFFFB8C00);
    } else {
      label = 'Dans $days j';
      color = const Color(0xFFF9A825);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              item.ingredientName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(
            '${_fmt(item.quantity)} ${item.unit}',
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(label,
                style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w600, color: color)),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // OUTILS
  // ---------------------------------------------------------------------------

  IconData _getMealIcon(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return Icons.free_breakfast_rounded;
      case 'lunch':
        return Icons.lunch_dining_rounded;
      case 'dinner':
        return Icons.dinner_dining_rounded;
      case 'snack':
        return Icons.cookie_rounded;
      default:
        return Icons.restaurant_rounded;
    }
  }

  Color _getMealColor(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return const Color(0xFFFFA726);
      case 'lunch':
        return const Color(0xFF66BB6A);
      case 'dinner':
        return const Color(0xFF5C6BC0);
      case 'snack':
        return const Color(0xFFEC407A);
      default:
        return const Color(0xFF78909C);
    }
  }

  String _getMealTypeLabel(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return 'Petit-déj';
      case 'lunch':
        return 'Déjeuner';
      case 'dinner':
        return 'Dîner';
      case 'snack':
        return 'Collation';
      default:
        return 'Repas';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);

    if (target == today) return "Aujourd'hui";
    if (target == today.add(const Duration(days: 1))) return 'Demain';

    const weekdays = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    const months = [
      'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin',
      'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'
    ];
    return '${weekdays[date.weekday - 1]} ${date.day} ${months[date.month - 1]}';
  }
}

/// Jauge en demi-cercle : fond gris + arc coloré proportionnel à [progress]
/// (plafonné à 100 % pour le tracé).
class _ArcGaugePainter extends CustomPainter {
  final double progress;
  final Color color;

  _ArcGaugePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 12.0;
    final radius = math.min(size.width / 2, size.height) - stroke / 2;
    final center = Offset(size.width / 2, size.height - stroke / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);

    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFE2E8F0);
    canvas.drawArc(rect, math.pi, math.pi, false, base);

    final p = progress.clamp(0.0, 1.0);
    if (p > 0) {
      final fg = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = color;
      canvas.drawArc(rect, math.pi, math.pi * p, false, fg);
    }
  }

  @override
  bool shouldRepaint(_ArcGaugePainter old) =>
      old.progress != progress || old.color != color;
}
