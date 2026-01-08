// lib/screens/recette/group_recipe_selection_screen.dart
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/group_service.dart';
import '../../services/recette_firestore_service.dart';
import 'group_recipe_detail_screen.dart';

class GroupRecipeSelectionScreen extends StatefulWidget {
  const GroupRecipeSelectionScreen({super.key});

  @override
  State<GroupRecipeSelectionScreen> createState() => _GroupRecipeSelectionScreenState();
}

class _GroupRecipeSelectionScreenState extends State<GroupRecipeSelectionScreen> {
  final _authService = AuthService();
  final _groupService = GroupService();
  final _recetteService = RecetteFirestoreService();

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
        title: const Text('Choisir des recettes'),
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
            // Carte "Toutes mes recettes"
            _buildRecipeCard(
              context,
              title: 'Toutes mes recettes',
              subtitle: 'Voir toutes mes recettes',
              icon: Icons.all_inclusive_rounded,
              gradient: const LinearGradient(
                colors: [Color(0xFFFFE4E1), Color(0xFFFFD6D1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onTap: () => _navigateToRecipeDetail(
                context,
                recipeType: RecipeType.all,
                title: 'Toutes mes recettes',
              ),
            ),

            const SizedBox(height: 16),

            // Carte "Mes recettes privées"
            _buildRecipeCard(
              context,
              title: 'Mes recettes privées',
              subtitle: 'Visible uniquement par moi',
              icon: Icons.lock_person_rounded,
              gradient: const LinearGradient(
                colors: [Color(0xFFE1F5FE), Color(0xFFB3E5FC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onTap: () => _navigateToRecipeDetail(
                context,
                recipeType: RecipeType.private,
                title: 'Mes recettes privées',
              ),
            ),

            if (_userGroups.isNotEmpty) ...[
              const SizedBox(height: 32),
              const Text(
                'Recettes de groupe',
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
                      'Créez ou rejoignez un groupe pour partager vos recettes',
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

  Widget _buildRecipeCard(
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
        colors: [Color(0xFFD4E9D7), Color(0xFFC1E1C1)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      const LinearGradient(
        colors: [Color(0xFFE1D5E7), Color(0xFFCFBBD9)],
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
      stream: _getGroupRecipeCount(groupId),
      builder: (context, snapshot) {
        final recipeCount = snapshot.data ?? 0;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _navigateToRecipeDetail(
              context,
              recipeType: RecipeType.group,
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
                    if (recipeCount > 0) ...[
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
                              Icons.restaurant_menu_rounded,
                              size: 16,
                              color: Color(0xFF1E293B),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '$recipeCount recette${recipeCount > 1 ? 's' : ''}',
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

  Stream<int> _getGroupRecipeCount(String groupId) {
    return _recetteService.getGroupRecettes(groupId).map((recipes) => recipes.length);
  }

  void _navigateToRecipeDetail(
      BuildContext context, {
        required RecipeType recipeType,
        String? groupId,
        required String title,
      }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GroupRecipeDetailScreen(
          recipeType: recipeType,
          groupId: groupId,
          title: title,
        ),
      ),
    );
  }
}