// lib/screens/planning/group_planning_selection_screen.dart
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/group_service.dart';
import '../../services/planning_firestore_service.dart';
import 'group_planning_detail_screen.dart';

class GroupPlanningSelectionScreen extends StatefulWidget {
  const GroupPlanningSelectionScreen({super.key});

  @override
  State<GroupPlanningSelectionScreen> createState() => _GroupPlanningSelectionScreenState();
}

class _GroupPlanningSelectionScreenState extends State<GroupPlanningSelectionScreen> {
  final _authService = AuthService();
  final _groupService = GroupService();
  final _planningService = PlanningFirestoreService();

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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Mes plannings'),
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
            // Carte "Tous mes plannings"
            _buildPlanningCard(
              context,
              title: 'Tous mes plannings',
              subtitle: 'Vue d\'ensemble complète',
              icon: Icons.calendar_view_month_rounded,
              gradient: const LinearGradient(
                colors: [Color(0xFFE1D5E7), Color(0xFFCFBBD9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onTap: () => _navigateToPlanningDetail(
                context,
                sourceType: PlanningSourceType.all,
                title: 'Tous mes plannings',
              ),
            ),

            const SizedBox(height: 16),

            // Carte "Plannings privés"
            _buildPlanningCard(
              context,
              title: 'Mes plannings privés',
              subtitle: 'Visibles uniquement par moi',
              icon: Icons.lock_person_rounded,
              gradient: const LinearGradient(
                colors: [Color(0xFFE1F5FE), Color(0xFFB3E5FC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onTap: () => _navigateToPlanningDetail(
                context,
                sourceType: PlanningSourceType.private,
                title: 'Mes plannings privés',
              ),
            ),

            if (_userGroups.isNotEmpty) ...[
              const SizedBox(height: 32),
              const Text(
                'Plannings de groupe',
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
                      'Créez ou rejoignez un groupe pour planifier en famille',
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

  Widget _buildPlanningCard(
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

    // Couleurs variées pour les groupes
    final gradients = [
      const LinearGradient(
        colors: [Color(0xFFFFE4B5), Color(0xFFFFD6A5)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      const LinearGradient(
        colors: [Color(0xFFD4E9D7), Color(0xFFC1E1C1)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      const LinearGradient(
        colors: [Color(0xFFFFCDD2), Color(0xFFEF9A9A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      const LinearGradient(
        colors: [Color(0xFFFFF0E5), Color(0xFFFFE0CC)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      const LinearGradient(
        colors: [Color(0xFFD4F1F4), Color(0xFFB8E5E9)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ];

    final gradient = gradients[index % gradients.length];

    return StreamBuilder<int>(
      stream: _getGroupPlanningCount(groupId),
      builder: (context, snapshot) {
        final planningCount = snapshot.data ?? 0;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _navigateToPlanningDetail(
              context,
              sourceType: PlanningSourceType.group,
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
                    if (planningCount > 0) ...[
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
                              Icons.event_rounded,
                              size: 16,
                              color: Color(0xFF1E293B),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '$planningCount repas planifié${planningCount > 1 ? 's' : ''}',
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

  Stream<int> _getGroupPlanningCount(String groupId) {
    return _planningService.getGroupPlanning(groupId).map((plannings) => plannings.length);
  }

  void _navigateToPlanningDetail(
      BuildContext context, {
        required PlanningSourceType sourceType,
        String? groupId,
        required String title,
      }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GroupPlanningDetailScreen(
          sourceType: sourceType,
          groupId: groupId,
          title: title,
        ),
      ),
    );
  }
}