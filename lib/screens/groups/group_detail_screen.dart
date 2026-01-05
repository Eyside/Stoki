// lib/screens/groups/group_detail_screen.dart (AVEC SÉLECTEUR)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/group_service.dart';
import '../../services/auth_service.dart';
import '../../services/group_profile_service.dart';
import '../../repositories/user_profile_repository.dart';
import '../../database.dart';
import '../../providers.dart';
import '../../widgets/group_profiles_list.dart';

class GroupDetailScreen extends ConsumerStatefulWidget {
  final String groupId;
  final String groupName;

  const GroupDetailScreen({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  ConsumerState<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends ConsumerState<GroupDetailScreen> {
  final _groupService = GroupService();
  final _groupProfileService = GroupProfileService();
  final _authService = AuthService();
  Map<String, dynamic>? _groupDetails;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGroupDetails();
  }

  Future<void> _loadGroupDetails() async {
    final details = await _groupService.getGroupDetails(widget.groupId);
    setState(() {
      _groupDetails = details;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'invite') _showInviteCode();
              if (value == 'leave') _leaveGroup();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'invite',
                child: Row(
                  children: [
                    Icon(Icons.share),
                    SizedBox(width: 8),
                    Text('Partager le code'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'leave',
                child: Row(
                  children: [
                    Icon(Icons.exit_to_app, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Quitter le groupe', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadGroupDetails,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Informations du groupe
              _buildGroupInfoCard(),
              const SizedBox(height: 16),

              // ✅ NOUVEAU: Gérer mes profils dans ce groupe
              _buildMyProfilesManager(),
              const SizedBox(height: 16),

              // Liste de tous les profils du groupe
              const Text(
                'Profils des membres',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              GroupProfilesList(
                groupId: widget.groupId,
                groupProfileService: _groupProfileService,
              ),

              const SizedBox(height: 16),

              // Code d'invitation
              _buildInviteCodeCard(),
              const SizedBox(height: 16),

              // Liste des membres
              _buildMembersList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.green.shade100,
                  child: const Icon(Icons.group, size: 32, color: Colors.green),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.groupName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_groupDetails?['description'] != null &&
                          _groupDetails!['description'].toString().isNotEmpty)
                        Text(
                          _groupDetails!['description'],
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      '${_groupDetails?['memberCount'] ?? 0}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text('Membres'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ✅ NOUVEAU WIDGET: Gérer mes profils dans le groupe
  Widget _buildMyProfilesManager() {
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
                    Icon(Icons.person_pin, color: Colors.green, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Mes profils dans ce groupe',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: _showProfileSelector,
                  tooltip: 'Gérer mes profils',
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Liste des profils actuellement dans le groupe
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _getMyProfilesInGroup(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final myProfiles = snapshot.data ?? [];

                if (myProfiles.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Aucun profil ajouté à ce groupe',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: _showProfileSelector,
                          icon: const Icon(Icons.add),
                          label: const Text('Ajouter mes profils'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    ...myProfiles.map((profile) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.green.shade100,
                            child: Icon(
                              profile['sex'] == 'male' ? Icons.man : Icons.woman,
                              color: Colors.green.shade700,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  profile['name'] ?? 'Profil',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${profile['age']} ans • ${(profile['eaterMultiplier'] ?? 1.0).toStringAsFixed(1)}x portions',
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: () => _removeProfileFromGroup(profile),
                            color: Colors.red,
                          ),
                        ],
                      ),
                    )),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _showProfileSelector,
                      icon: const Icon(Icons.add),
                      label: const Text('Ajouter d\'autres profils'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Récupère les profils de l'utilisateur actuel dans ce groupe
  Future<List<Map<String, dynamic>>> _getMyProfilesInGroup() async {
    final userId = _authService.currentUser?.uid ?? '';
    final allProfiles = await _groupProfileService.getGroupProfiles(widget.groupId);
    return allProfiles.where((p) => p['userId'] == userId).toList();
  }

  // Affiche le sélecteur de profils
  Future<void> _showProfileSelector() async {
    final db = ref.read(databaseProvider);
    final profileRepo = UserProfileRepository(db, groupProfileService: _groupProfileService);

    // Récupérer tous mes profils locaux
    final allMyProfiles = await profileRepo.getAllProfiles();

    if (allMyProfiles.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Créez d\'abord des profils dans "Mes Profils"'),
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {}, // ✅ CORRIGÉ: fonction vide au lieu de null
          ),
        ),
      );
      return;
    }

    // Récupérer les profils déjà dans le groupe
    final profilesInGroup = await _getMyProfilesInGroup();
    final profileIdsInGroup = profilesInGroup.map((p) => p['localProfileId'] as int).toSet();

    if (!mounted) return;

    final selectedIds = await showDialog<Set<int>>(
      context: context,
      builder: (c) => _ProfileSelectorDialog(
        allProfiles: allMyProfiles,
        initialSelectedIds: profileIdsInGroup,
        groupName: widget.groupName,
      ),
    );

    if (selectedIds != null) {
      await _updateGroupProfiles(selectedIds, allMyProfiles);
    }
  }

  // Met à jour les profils dans le groupe
  Future<void> _updateGroupProfiles(Set<int> selectedIds, List<UserProfile> allProfiles) async {
    try {
      // Supprimer tous mes profils du groupe
      final profilesInGroup = await _getMyProfilesInGroup();
      for (final profile in profilesInGroup) {
        await _groupProfileService.removeSpecificProfile(
          widget.groupId,
          profile['userId'],
          profile['localProfileId'],
        );
      }

      // Ajouter les profils sélectionnés
      final selectedProfiles = allProfiles.where((p) => selectedIds.contains(p.id)).toList();

      for (final profile in selectedProfiles) {
        await _groupProfileService.addProfileToGroup(
          groupId: widget.groupId,
          profile: profile,
        );
      }

      if (mounted) {
        setState(() {}); // Rafraîchir l'affichage
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${selectedProfiles.length} profil(s) ajouté(s) au groupe'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Retire un profil du groupe
  Future<void> _removeProfileFromGroup(Map<String, dynamic> profile) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Retirer ce profil'),
        content: Text('Voulez-vous retirer "${profile['name']}" de ce groupe ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(c, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Retirer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _groupProfileService.removeSpecificProfile(
          widget.groupId,
          profile['userId'],
          profile['localProfileId'],
        );

        if (mounted) {
          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profil retiré du groupe')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _buildInviteCodeCard() {
    return Card(
      color: Colors.blue.shade50,
      child: ListTile(
        leading: const Icon(Icons.qr_code, color: Colors.blue),
        title: const Text('Code d\'invitation'),
        subtitle: Text(
          _groupDetails?['inviteCode'] ?? 'Chargement...',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.copy),
          onPressed: () => _showInviteCode(),
        ),
      ),
    );
  }

  Widget _buildMembersList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Membres',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: _groupService.getGroupMembers(widget.groupId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final members = snapshot.data!;

            return Column(
              children: members.map((member) {
                final isCurrentUser = member['userId'] == _authService.currentUser?.uid;

                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey.shade200,
                      child: Text(
                        member['displayName']?.toString().substring(0, 1).toUpperCase() ?? '?',
                      ),
                    ),
                    title: Text(member['displayName'] ?? 'Utilisateur'),
                    subtitle: Text(member['email'] ?? ''),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (member['role'] == 'admin')
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Admin',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        if (isCurrentUser)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Vous',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  void _showInviteCode() {
    final code = _groupDetails?['inviteCode'] ?? '';

    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Code d\'invitation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Partagez ce code pour inviter des membres :'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green),
              ),
              child: Text(
                code,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Fermer'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: code));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Code copié !')),
              );
              Navigator.pop(c);
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copier'),
          ),
        ],
      ),
    );
  }

  Future<void> _leaveGroup() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Quitter le groupe'),
        content: const Text('Êtes-vous sûr de vouloir quitter ce groupe ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(c, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Quitter'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final userId = _authService.currentUser?.uid;
      if (userId != null) {
        final success = await _groupService.leaveGroup(
          groupId: widget.groupId,
          userId: userId,
        );

        if (success && mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vous avez quitté le groupe')),
          );
        }
      }
    }
  }
}

// ============================================================================
// DIALOGUE DE SÉLECTION DES PROFILS
// ============================================================================

class _ProfileSelectorDialog extends StatefulWidget {
  final List<UserProfile> allProfiles;
  final Set<int> initialSelectedIds;
  final String groupName;

  const _ProfileSelectorDialog({
    required this.allProfiles,
    required this.initialSelectedIds,
    required this.groupName,
  });

  @override
  State<_ProfileSelectorDialog> createState() => _ProfileSelectorDialogState();
}

class _ProfileSelectorDialogState extends State<_ProfileSelectorDialog> {
  late Set<int> selectedIds;

  @override
  void initState() {
    super.initState();
    selectedIds = Set.from(widget.initialSelectedIds);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Mes profils'),
          const SizedBox(height: 4),
          Text(
            'Dans le groupe "${widget.groupName}"',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.allProfiles.length,
          itemBuilder: (context, index) {
            final profile = widget.allProfiles[index];
            final isSelected = selectedIds.contains(profile.id);

            return CheckboxListTile(
              value: isSelected,
              onChanged: (checked) {
                setState(() {
                  if (checked == true) {
                    selectedIds.add(profile.id);
                  } else {
                    selectedIds.remove(profile.id);
                  }
                });
              },
              secondary: CircleAvatar(
                backgroundColor: isSelected ? Colors.green.shade100 : Colors.grey.shade200,
                child: Icon(
                  profile.sex == 'male' ? Icons.man : Icons.woman,
                  color: isSelected ? Colors.green : Colors.grey,
                ),
              ),
              title: Text(profile.name),
              subtitle: Text(
                '${profile.age} ans • ${profile.eaterMultiplier.toStringAsFixed(1)}x portions',
                style: const TextStyle(fontSize: 12),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, selectedIds),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: Text('Valider (${selectedIds.length})'),
        ),
      ],
    );
  }
}