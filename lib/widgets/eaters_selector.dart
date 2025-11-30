// lib/widgets/eaters_selector.dart
import 'package:flutter/material.dart';
import 'dart:convert';
import '../database.dart';

class EatersSelector extends StatefulWidget {
  final List<UserProfile> allProfiles;
  final List<int> selectedProfileIds;
  final Function(List<int>) onSelectionChanged;

  const EatersSelector({
    super.key,
    required this.allProfiles,
    required this.selectedProfileIds,
    required this.onSelectionChanged,
  });

  @override
  State<EatersSelector> createState() => _EatersSelectorState();
}

class _EatersSelectorState extends State<EatersSelector> {
  late Set<int> _selectedIds;

  @override
  void initState() {
    super.initState();
    _selectedIds = Set.from(widget.selectedProfileIds);
  }

  void _toggleProfile(int profileId) {
    setState(() {
      if (_selectedIds.contains(profileId)) {
        _selectedIds.remove(profileId);
      } else {
        _selectedIds.add(profileId);
      }
      widget.onSelectionChanged(_selectedIds.toList());
    });
  }

  double _getTotalPortions() {
    double total = 0;
    for (final id in _selectedIds) {
      final profile = widget.allProfiles.firstWhere((p) => p.id == id);
      total += profile.eaterMultiplier;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.allProfiles.isEmpty) {
      return Card(
        color: Colors.orange.shade50,
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.orange),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Aucun profil disponible. Créez des profils dans les paramètres.',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.people, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Qui mange ce repas ?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                if (_selectedIds.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.restaurant, size: 14, color: Colors.green.shade800),
                        const SizedBox(width: 4),
                        Text(
                          '${_getTotalPortions().toStringAsFixed(1)} portion(s)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade800,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Liste des profils
            ...widget.allProfiles.map((profile) {
              final isSelected = _selectedIds.contains(profile.id);
              return InkWell(
                onTap: () => _toggleProfile(profile.id),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.green.shade50 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? Colors.green : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Checkbox
                      Icon(
                        isSelected ? Icons.check_circle : Icons.circle_outlined,
                        color: isSelected ? Colors.green : Colors.grey,
                      ),
                      const SizedBox(width: 12),

                      // Avatar
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: _getProfileColor(profile).withOpacity(0.2),
                        child: Icon(
                          _getProfileIcon(profile),
                          size: 20,
                          color: _getProfileColor(profile),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Nom
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile.name,
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              _getProfileTypeLabel(profile),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Multiplicateur
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getProfileColor(profile).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'x${profile.eaterMultiplier.toStringAsFixed(1)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: _getProfileColor(profile),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            // Bouton tout sélectionner / tout désélectionner
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      if (_selectedIds.length == widget.allProfiles.length) {
                        _selectedIds.clear();
                      } else {
                        _selectedIds = Set.from(widget.allProfiles.map((p) => p.id));
                      }
                      widget.onSelectionChanged(_selectedIds.toList());
                    });
                  },
                  icon: Icon(
                    _selectedIds.length == widget.allProfiles.length
                        ? Icons.clear
                        : Icons.done_all,
                    size: 18,
                  ),
                  label: Text(
                    _selectedIds.length == widget.allProfiles.length
                        ? 'Tout désélectionner'
                        : 'Tout sélectionner',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getProfileIcon(UserProfile profile) {
    if (profile.sex == 'male') return Icons.person;
    if (profile.sex == 'female') return Icons.person_outline;
    return Icons.person;
  }

  Color _getProfileColor(UserProfile profile) {
    if (profile.eaterMultiplier < 0.8) return Colors.blue;
    if (profile.eaterMultiplier > 1.2) return Colors.purple;
    return Colors.green;
  }

  String _getProfileTypeLabel(UserProfile profile) {
    if (profile.eaterMultiplier < 0.8) return 'Petit mangeur';
    if (profile.eaterMultiplier > 1.2) return 'Gros mangeur';
    return 'Mangeur moyen';
  }
}

// Helper pour encoder/décoder la liste des eaters
class EatersHelper {
  /// Encode une liste d'IDs en JSON string
  static String encodeEaters(List<int> profileIds) {
    return jsonEncode(profileIds);
  }

  /// Décode un JSON string en liste d'IDs
  static List<int> decodeEaters(String? json) {
    if (json == null || json.isEmpty) return [];
    try {
      final decoded = jsonDecode(json);
      if (decoded is List) {
        return decoded.map((e) => e as int).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Calcule le total des portions pour une liste de profils
  static double calculateTotalPortions(List<UserProfile> profiles, List<int> eaterIds) {
    double total = 0;
    for (final id in eaterIds) {
      final profile = profiles.where((p) => p.id == id).firstOrNull;
      if (profile != null) {
        total += profile.eaterMultiplier;
      }
    }
    return total;
  }

  /// Retourne les profils qui mangent un repas
  static List<UserProfile> getEatersProfiles(
      List<UserProfile> allProfiles,
      String? eatersJson,
      ) {
    final eaterIds = decodeEaters(eatersJson);
    return allProfiles.where((p) => eaterIds.contains(p.id)).toList();
  }
}