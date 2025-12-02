// lib/screens/groups/invite_screen.dart
import 'package:flutter/material.dart';
import '../../services/group_service.dart';
import '../../services/auth_service.dart';

class InviteScreen extends StatefulWidget {
  const InviteScreen({super.key});

  @override
  State<InviteScreen> createState() => _InviteScreenState();
}

class _InviteScreenState extends State<InviteScreen> {
  final _codeCtrl = TextEditingController();
  final _groupService = GroupService();
  final _authService = AuthService();
  bool _isLoading = false;

  Future<void> _joinGroup() async {
    final code = _codeCtrl.text.trim().toUpperCase();

    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entrez un code d\'invitation')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = _authService.currentUser?.uid;
      if (userId == null) throw 'Non connecté';

      final success = await _groupService.joinGroupWithCode(
        inviteCode: code,
        userId: userId,
      );

      setState(() => _isLoading = false);

      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vous avez rejoint le groupe !'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rejoindre un groupe'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group_add, size: 100, color: Colors.green.shade600),
            const SizedBox(height: 32),
            const Text(
              'Entrez le code d\'invitation',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _codeCtrl,
              decoration: const InputDecoration(
                labelText: 'Code d\'invitation',
                hintText: 'ABC123',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.qr_code),
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
              textCapitalization: TextCapitalization.characters,
              maxLength: 6,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _joinGroup,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
                child: _isLoading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text('Rejoindre le groupe'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }
}