// lib/screens/group_stock_selection_screen.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/group_service.dart';
import '../services/frigo_firestore_service.dart';
import 'group_stock_detail_screen.dart';

class GroupStockSelectionScreen extends StatefulWidget {
  const GroupStockSelectionScreen({super.key});

  @override
  State<GroupStockSelectionScreen> createState() => _GroupStockSelectionScreenState();
}

class _GroupStockSelectionScreenState extends State<GroupStockSelectionScreen> {
  final _authService = AuthService();
  final _groupService = GroupService();
  final _frigoService = FrigoFirestoreService();

  List<Map<String, dynamic>> _userGroups = [];
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choisir un stock'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: () async => _loadGroups(),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Carte "Tout le stock"
            _buildStockCard(
              context,
              title: 'Tout le stock',
              subtitle: 'Voir tous mes stocks',
              icon: Icons.all_inclusive_rounded,
              gradient: const LinearGradient(
                colors: [Color(0xFFB8E6D5), Color(0xFF95D9C3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onTap: () => _navigateToStockDetail(
                context,
                stockType: StockType.all,
                title: 'Tout le stock',
              ),
            ),

            const SizedBox(height: 16),

            // Carte "Mon stock privé"
            _buildStockCard(
              context,
              title: 'Mon stock privé',
              subtitle: 'Visible uniquement par moi',
              icon: Icons.lock_person_rounded,
              gradient: const LinearGradient(
                colors: [Color(0xFFBBDEFB), Color(0xFF90CAF9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onTap: () => _navigateToStockDetail(
                context,
                stockType: StockType.private,
                title: 'Mon stock privé',
              ),
            ),

            if (_userGroups.isNotEmpty) ...[
              const SizedBox(height: 32),
              const Text(
                'Stocks de groupe',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Cartes des groupes
            ..._userGroups.asMap().entries.map((entry) {
              final index = entry.key;
              final group = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildGroupCard(context, group, index),
              );
            }),

            const SizedBox(height: 16),

            // Message si aucun groupe
            if (_userGroups.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.group_add_rounded,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Aucun groupe',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Créez ou rejoignez un groupe pour partager vos stocks',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockCard(
      BuildContext context, {
        required String title,
        required String subtitle,
        required IconData icon,
        required Gradient gradient,
        required VoidCallback onTap,
      }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, size: 32, color: const Color(0xFF1E293B)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: const Color(0xFF1E293B).withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 18,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGroupCard(BuildContext context, Map<String, dynamic> group, int index) {
    final groupName = group['name'] ?? 'Groupe';
    final groupId = group['id'] as String;
    final memberCount = group['memberCount'] ?? 0;

    // Couleurs pastelles variées pour les groupes
    final gradients = [
      const LinearGradient(
        colors: [Color(0xFFFFE4B5), Color(0xFFFFD6A5)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      const LinearGradient(
        colors: [Color(0xFFFFCDD2), Color(0xFFFF8A95)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      const LinearGradient(
        colors: [Color(0xFFD1C4E9), Color(0xFFB39DDB)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      const LinearGradient(
        colors: [Color(0xFFFFF9C4), Color(0xFFFFF176)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      const LinearGradient(
        colors: [Color(0xFFB2DFDB), Color(0xFF80CBC4)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ];

    final gradient = gradients[index % gradients.length];

    return StreamBuilder<int>(
      stream: _getGroupStockCount(groupId),
      builder: (context, snapshot) {
        final stockCount = snapshot.data ?? 0;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _navigateToStockDetail(
              context,
              stockType: StockType.group,
              groupId: groupId,
              title: groupName,
            ),
            borderRadius: BorderRadius.circular(20),
            child: Ink(
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.group_rounded,
                            size: 28,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                groupName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$memberCount membre${memberCount > 1 ? 's' : ''}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: const Color(0xFF1E293B).withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 18,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                    if (stockCount > 0) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.inventory_2_rounded,
                              size: 16,
                              color: Color(0xFF1E293B),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '$stockCount produit${stockCount > 1 ? 's' : ''} en stock',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Stream<int> _getGroupStockCount(String groupId) {
    return _frigoService.getGroupStock(groupId).map((items) => items.length);
  }

  void _navigateToStockDetail(
      BuildContext context, {
        required StockType stockType,
        String? groupId,
        required String title,
      }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GroupStockDetailScreen(
          stockType: stockType,
          groupId: groupId,
          title: title,
        ),
      ),
    );
  }
}