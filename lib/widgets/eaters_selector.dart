// lib/widgets/eaters_selector.dart - VERSION ULTRA-ROBUSTE
import 'package:flutter/material.dart';
import '../models/app_profile.dart';

class EatersSelector extends StatefulWidget {
  final List<GroupMember> allProfiles;
  final List<String> selectedProfileIds;
  final Function(List<String>) onSelectionChanged;

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
  // ✅ État local complètement indépendant
  final Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _selectedIds.addAll(widget.selectedProfileIds);
  }

  @override
  void didUpdateWidget(EatersSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedProfileIds != oldWidget.selectedProfileIds) {
      setState(() {
        _selectedIds.clear();
        _selectedIds.addAll(widget.selectedProfileIds);
      });
    }
  }

  void _toggleProfile(String profileId) {
    debugPrint('🎯 Toggle: $profileId, Set actuel: $_selectedIds');

    setState(() {
      if (_selectedIds.contains(profileId)) {
        _selectedIds.remove(profileId);
        debugPrint('   ➖ Retiré');
      } else {
        _selectedIds.add(profileId);
        debugPrint('   ➕ Ajouté');
      }
    });

    debugPrint('   Nouveau Set: $_selectedIds');
    widget.onSelectionChanged(_selectedIds.toList());
  }

  String _eaterLabel(double m) {
    final label = m < 0.8
        ? 'Petit mangeur'
        : m < 1.2
            ? 'Mangeur moyen'
            : 'Gros mangeur';
    return '$label • x${m.toStringAsFixed(1)}';
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🎨 EatersSelector build - Set: $_selectedIds, Profils: ${widget.allProfiles.map((p) => '${p.name}(${p.uid})').toList()}');

    if (widget.allProfiles.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.grey),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Aucun membre avec un profil dans ce groupe.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.people, size: 20, color: Color(0xFF64748B)),
                const SizedBox(width: 8),
                Expanded( // ✅ AJOUTÉ pour éviter l'overflow
                  child: Text(
                    '${_selectedIds.length} personne(s) sélectionnée(s)',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF475569),
                    ),
                  ),
                ),
                if (_selectedIds.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      setState(() => _selectedIds.clear());
                      widget.onSelectionChanged([]);
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8), // ✅ Réduire le padding
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Tout désélectionner',
                      style: TextStyle(fontSize: 11), // ✅ Réduire la taille
                    ),
                  ),
              ],
            ),
          ),

          // Liste des profils
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.allProfiles.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final profile = widget.allProfiles[index];
              final isSelected = _selectedIds.contains(profile.uid);

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: CircleAvatar(
                  backgroundColor: isSelected
                      ? const Color(0xFF10B981)
                      : Colors.grey.shade300,
                  child: Text(
                    (profile.name.isEmpty ? '?' : profile.name[0]).toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                    ),
                  ),
                ),
                title: Text(
                  profile.name,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? const Color(0xFF1E293B)
                        : const Color(0xFF475569),
                  ),
                ),
                subtitle: Text(
                  _eaterLabel(profile.eaterMultiplier),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                trailing: Checkbox(
                  value: isSelected,
                  onChanged: (_) => _toggleProfile(profile.uid),
                  activeColor: const Color(0xFF10B981),
                  // ✅ AJOUTÉ : tristate false pour forcer true/false uniquement
                  tristate: false,
                ),
                onTap: () => _toggleProfile(profile.uid),
              );
            },
          ),
        ],
      ),
    );
  }
}