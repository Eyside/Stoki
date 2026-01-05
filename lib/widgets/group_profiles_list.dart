// lib/widgets/group_profiles_list.dart
import 'package:flutter/material.dart';
import '../services/group_profile_service.dart';

/// Widget pour afficher la liste des profils configurés dans un groupe
class GroupProfilesList extends StatelessWidget {
  final String groupId;
  final GroupProfileService groupProfileService;

  const GroupProfilesList({
    super.key,
    required this.groupId,
    required this.groupProfileService,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.people, color: Colors.green, size: 20),
                SizedBox(width: 8),
                Text(
                  'Profils des membres',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: groupProfileService.watchGroupProfiles(groupId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Erreur: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                final profiles = snapshot.data ?? [];

                if (profiles.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Icon(Icons.person_off, size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 8),
                        Text(
                          'Aucun profil configuré',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Les membres doivent configurer leurs profils',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: profiles.map((profile) => _buildProfileTile(profile)).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTile(Map<String, dynamic> profile) {
    final name = profile['name'] ?? 'Inconnu';
    final eaterMultiplier = profile['eaterMultiplier'] ?? 1.0;
    final sex = profile['sex'] ?? 'other';
    final age = profile['age'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: _getEaterColor(eaterMultiplier).withValues(alpha: 0.2),
            child: Icon(
              _getSexIcon(sex),
              color: _getEaterColor(eaterMultiplier),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Infos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  '$age ans • ${_getEaterLabel(eaterMultiplier)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          // Multiplicateur
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _getEaterColor(eaterMultiplier),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${eaterMultiplier.toStringAsFixed(1)}x',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getSexIcon(String sex) {
    switch (sex) {
      case 'male':
        return Icons.man;
      case 'female':
        return Icons.woman;
      default:
        return Icons.person;
    }
  }

  Color _getEaterColor(double multiplier) {
    if (multiplier < 0.8) return Colors.blue;
    if (multiplier > 1.2) return Colors.purple;
    return Colors.green;
  }

  String _getEaterLabel(double multiplier) {
    if (multiplier < 0.6) return 'Très petit mangeur';
    if (multiplier < 0.8) return 'Petit mangeur';
    if (multiplier < 1.2) return 'Mangeur moyen';
    if (multiplier < 1.5) return 'Gros mangeur';
    return 'Très gros mangeur';
  }
}