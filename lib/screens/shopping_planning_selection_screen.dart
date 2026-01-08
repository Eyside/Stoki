// lib/screens/shopping_planning_selection_screen.dart
// Écran de sélection des plannings pour générer la liste de courses

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../services/group_service.dart';
import 'shopping_list_v2_screen.dart';

class ShoppingPlanningSelectionScreen extends ConsumerStatefulWidget {
  const ShoppingPlanningSelectionScreen({super.key});

  @override
  ConsumerState<ShoppingPlanningSelectionScreen> createState() =>
      _ShoppingPlanningSelectionScreenState();
}

class _ShoppingPlanningSelectionScreenState
    extends ConsumerState<ShoppingPlanningSelectionScreen> {
  final _authService = AuthService();
  final _groupService = GroupService();

  List<Map<String, dynamic>> _userGroups = [];
  Set<String> _selectedSources = {'private'}; // Sources cochées
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));
  bool _subtractStock = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    _groupService.getUserGroups(userId).listen((groups) {
      if (mounted) {
        setState(() {
          _userGroups = groups;
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste de courses'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFFBBF24),
                    const Color(0xFFFBBF24).withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.shopping_cart_rounded,
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Générer votre liste',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sélectionnez les plannings à inclure',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Section: Période
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📅 Période',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Date de début
                  _buildDateSelector(
                    label: 'Date de début',
                    date: _startDate,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _startDate,
                        firstDate: DateTime.now().subtract(const Duration(days: 30)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setState(() {
                          _startDate = picked;
                          if (_endDate.isBefore(_startDate)) {
                            _endDate = _startDate.add(const Duration(days: 7));
                          }
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 12),

                  // Date de fin
                  _buildDateSelector(
                    label: 'Date de fin',
                    date: _endDate,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _endDate,
                        firstDate: _startDate,
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setState(() => _endDate = picked);
                      }
                    },
                  ),

                  const SizedBox(height: 12),

                  // Info durée
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          'Période de ${_endDate.difference(_startDate).inDays + 1} jour(s)',
                          style: TextStyle(
                            color: Colors.blue.shade900,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Raccourcis
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildQuickDateChip('3 jours', 2),
                      _buildQuickDateChip('7 jours', 6),
                      _buildQuickDateChip('14 jours', 13),
                      _buildQuickDateChip('30 jours', 29),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Section: Sources de plannings
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📋 Plannings à inclure',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Cochez les plannings dont vous voulez les ingrédients',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Planning privé
                  _buildSourceCard(
                    id: 'private',
                    title: 'Mon planning privé',
                    icon: Icons.lock_rounded,
                    color: const Color(0xFF3B82F6),
                    isSelected: _selectedSources.contains('private'),
                  ),

                  const SizedBox(height: 12),

                  // Plannings de groupes
                  if (_userGroups.isNotEmpty)
                    ..._userGroups.map((group) {
                      final groupId = group['id'] as String;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildSourceCard(
                          id: groupId,
                          title: group['name'] ?? 'Groupe',
                          icon: Icons.group_rounded,
                          color: const Color(0xFF10B981),
                          isSelected: _selectedSources.contains(groupId),
                          subtitle: '${group['memberCount'] ?? 0} membre(s)',
                        ),
                      );
                    }).toList(),

                  if (_userGroups.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.grey.shade600),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Vous n\'avez pas encore de groupe',
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Section: Options
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '⚙️ Options',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    decoration: BoxDecoration(
                      color: _subtractStock ? Colors.green.shade50 : Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _subtractStock ? Colors.green : Colors.orange,
                        width: 2,
                      ),
                    ),
                    child: SwitchListTile(
                      value: _subtractStock,
                      onChanged: (value) => setState(() => _subtractStock = value),
                      title: Text(
                        _subtractStock
                            ? 'Soustraire le stock ✅'
                            : 'Liste complète (sans soustraction)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _subtractStock
                              ? Colors.green.shade900
                              : Colors.orange.shade900,
                        ),
                      ),
                      subtitle: Text(
                        _subtractStock
                            ? 'Le stock sera déduit de la liste'
                            : 'Tous les ingrédients seront ajoutés',
                        style: const TextStyle(fontSize: 12),
                      ),
                      activeColor: Colors.green,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: _selectedSources.isEmpty ? null : _generateList,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFBBF24),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.auto_awesome_rounded),
                const SizedBox(width: 12),
                Text(
                  'Générer la liste (${_selectedSources.length} source${_selectedSources.length > 1 ? 's' : ''})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelector({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.grey.shade600, size: 20),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(date),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickDateChip(String label, int daysFromToday) {
    return FilterChip(
      label: Text(label),
      onSelected: (_) {
        setState(() {
          _startDate = DateTime.now();
          _endDate = DateTime.now().add(Duration(days: daysFromToday));
        });
      },
      backgroundColor: Colors.grey.shade100,
      selectedColor: const Color(0xFFFBBF24).withOpacity(0.2),
      checkmarkColor: const Color(0xFFFBBF24),
    );
  }

  Widget _buildSourceCard({
    required String id,
    required String title,
    required IconData icon,
    required Color color,
    required bool isSelected,
    String? subtitle,
  }) {
    return InkWell(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedSources.remove(id);
          } else {
            _selectedSources.add(id);
          }
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected ? color : Colors.black87,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: color, size: 28)
            else
              Icon(Icons.circle_outlined, color: Colors.grey.shade400, size: 28),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin',
      'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _generateList() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ShoppingListV2Screen(
          selectedSources: _selectedSources.toList(),
          startDate: _startDate,
          endDate: _endDate,
          subtractStock: _subtractStock,
        ),
      ),
    );
  }
}