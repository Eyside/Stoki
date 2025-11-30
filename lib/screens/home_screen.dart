// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import '../database.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ingredientsAsync = ref.watch(ingredientsProvider);
    final frigoAsync = ref.watch(frigoProvider);
    final recettesAsync = ref.watch(recettesProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(ingredientsProvider);
        ref.invalidate(frigoProvider);
        ref.invalidate(recettesProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête de bienvenue
            Card(
              elevation: 0,
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(Icons.waving_hand, size: 48, color: Colors.orange.shade700),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bienvenue sur Stoki !',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Gérez vos stocks et recettes intelligemment',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Statistiques rapides
            const Text(
              'Vue d\'ensemble',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.eco,
                    label: 'Ingrédients',
                    value: ingredientsAsync.when(
                      data: (list) => list.length.toString(),
                      loading: () => '...',
                      error: (_, __) => 'Erreur',
                    ),
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.kitchen,
                    label: 'En stock',
                    value: frigoAsync.when(
                      data: (list) => list.length.toString(),
                      loading: () => '...',
                      error: (_, __) => 'Erreur',
                    ),
                    color: Colors.blue,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.restaurant_menu,
                    label: 'Recettes',
                    value: recettesAsync.when(
                      data: (list) => list.length.toString(),
                      loading: () => '...',
                      error: (_, __) => 'Erreur',
                    ),
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.calendar_month,
                    label: 'Planifiés',
                    value: '0', // TODO: À implémenter
                    color: Colors.purple,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Actions rapides
            const Text(
              'Actions rapides',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            _QuickActionCard(
              icon: Icons.qr_code_scanner,
              title: 'Scanner un produit',
              subtitle: 'Ajoutez rapidement au stock',
              color: Colors.green,
              onTap: () {
                // TODO: Navigation vers scan
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Allez dans l\'onglet Stock pour scanner')),
                );
              },
            ),

            const SizedBox(height: 12),

            _QuickActionCard(
              icon: Icons.add_circle,
              title: 'Créer une recette',
              subtitle: 'Nouvelle recette personnalisée',
              color: Colors.orange,
              onTap: () {
                // TODO: Navigation vers création recette
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Allez dans l\'onglet Recettes')),
                );
              },
            ),

            const SizedBox(height: 12),

            _QuickActionCard(
              icon: Icons.event_note,
              title: 'Planifier un repas',
              subtitle: 'Organisez vos menus',
              color: Colors.purple,
              onTap: () {
                // TODO: Navigation vers planning
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Allez dans l\'onglet Planning')),
                );
              },
            ),

            const SizedBox(height: 24),

            // Produits bientôt périmés
            const Text(
              '⚠️ Produits à consommer rapidement',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            frigoAsync.when(
              data: (frigoList) {
                // Filtrer les produits périmés ou bientôt périmés
                final now = DateTime.now();
                final urgentItems = frigoList.where((item) {
                  final frigoData = item['frigo'] as FrigoData;
                  if (frigoData.bestBefore == null) return false;
                  final daysUntil = frigoData.bestBefore!.difference(now).inDays;
                  return daysUntil <= 3;
                }).toList();

                if (urgentItems.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green.shade700),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text('Aucun produit à consommer en urgence'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  children: urgentItems.take(3).map((item) {
                    final frigoData = item['frigo'] as FrigoData;
                    final ingredient = item['ingredient'] as Ingredient?;

                    if (ingredient == null) return const SizedBox.shrink();

                    final daysUntil = frigoData.bestBefore!.difference(now).inDays;
                    final isExpired = daysUntil < 0;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      color: isExpired ? Colors.red.shade50 : Colors.orange.shade50,
                      child: ListTile(
                        leading: Icon(
                          isExpired ? Icons.error : Icons.warning_amber,
                          color: isExpired ? Colors.red : Colors.orange,
                        ),
                        title: Text(ingredient.name),
                        subtitle: Text(
                          isExpired
                              ? 'PÉRIMÉ depuis ${-daysUntil} jour(s)'
                              : 'Expire dans $daysUntil jour(s)',
                          style: TextStyle(
                            color: isExpired ? Colors.red : Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: Text(
                          '${frigoData.quantity} ${frigoData.unit}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Erreur de chargement'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
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
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}