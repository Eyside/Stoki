// lib/widgets/eaters_selector.dart (VERSION AMÉLIORÉE)
import 'package:flutter/material.dart';
import 'dart:convert';
import '../database.dart';

class EatersSelector extends StatefulWidget {
  final List<UserProfile> allProfiles;
  final List<int> selectedProfileIds;
  final Function(List<int>) onSelectionChanged;
  final bool compact; // Mode compact pour dialogue

  const EatersSelector({
    super.key,
    required this.allProfiles,
    required this.selectedProfileIds,
    required this.onSelectionChanged,
    this.compact = false,
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

  @override
  void didUpdateWidget(EatersSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedProfileIds != oldWidget.selectedProfileIds) {
      _selectedIds = Set.from(widget.selectedProfileIds);
    }
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
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.orange.shade700),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Aucun profil disponible. Créez des profils dans les paramètres pour gérer qui mange ce repas.',
                style: TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.people, size: 18, color: Colors.green),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Qui mange ?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            if (_selectedIds.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.restaurant, size: 12, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      '${_getTotalPortions().toStringAsFixed(1)} portion${_getTotalPortions() > 1 ? 's' : ''}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 11,
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
          return _buildProfileCard(profile, isSelected);
        }),

        // Bouton tout sélectionner / désélectionner
        if (widget.allProfiles.length > 1) ...[
          const SizedBox(height: 8),
          Center(
            child: TextButton.icon(
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
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildProfileCard(UserProfile profile, bool isSelected) {
    return GestureDetector(
      onTap: () => _toggleProfile(profile.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.shade50 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Checkbox animé
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? Colors.green : Colors.transparent,
                border: Border.all(
                  color: isSelected ? Colors.green : Colors.grey.shade400,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
            const SizedBox(width: 12),

            // Avatar
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getProfileColor(profile).withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  profile.name[0].toUpperCase(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _getProfileColor(profile),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Nom et type
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.name,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        _getProfileIcon(profile),
                        size: 12,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getProfileTypeLabel(profile),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Badge multiplicateur
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getProfileColor(profile).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
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
  }

  IconData _getProfileIcon(UserProfile profile) {
    if (profile.eaterMultiplier < 0.8) return Icons.child_care;
    if (profile.eaterMultiplier > 1.2) return Icons.fitness_center;
    return Icons.person;
  }

  Color _getProfileColor(UserProfile profile) {
    if (profile.eaterMultiplier < 0.8) return Colors.blue;
    if (profile.eaterMultiplier > 1.2) return Colors.purple;
    return Colors.green;
  }

  String _getProfileTypeLabel(UserProfile profile) {
    if (profile.eaterMultiplier < 0.8) return 'Petit appétit';
    if (profile.eaterMultiplier > 1.2) return 'Gros appétit';
    return 'Appétit moyen';
  }
}

// Helper pour encoder/décoder la liste des eaters (INCHANGÉ)
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