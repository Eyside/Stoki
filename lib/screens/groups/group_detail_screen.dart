// lib/screens/groups/group_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/group_service.dart';
import '../../services/auth_service.dart';

class GroupDetailScreen extends StatefulWidget {
  final String groupId;
  final String groupName;

  const GroupDetailScreen({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  final _groupService = GroupService();
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
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informations du groupe
            Card(
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
                        Column(
                          children: [
                            const Text(
                              '0',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text('Recettes'),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Code d'invitation
            Card(
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
            ),

            const SizedBox(height: 24),

            // Liste des membres
            const Text(
              'Membres',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
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
        ),
      ),
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