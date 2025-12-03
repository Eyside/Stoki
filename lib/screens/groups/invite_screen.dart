// lib/screens/groups/invite_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/group_service.dart';
import '../../services/auth_service.dart';

class InviteScreen extends StatefulWidget {
  const InviteScreen({super.key});

  @override
  State<InviteScreen> createState() => _InviteScreenState();
}

class _InviteScreenState extends State<InviteScreen> with SingleTickerProviderStateMixin {
  final _codeCtrl = TextEditingController();
  final _groupService = GroupService();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _showPreview = false;
  Map<String, dynamic>? _groupPreview;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Listener pour vérifier automatiquement le code
    _codeCtrl.addListener(_onCodeChanged);
  }

  void _onCodeChanged() {
    final code = _codeCtrl.text.trim();
    // Si le code fait 6 caractères, on peut faire une preview
    if (code.length == 6 && !_isLoading) {
      _previewGroup();
    } else if (code.length < 6 && _showPreview) {
      setState(() {
        _showPreview = false;
        _groupPreview = null;
      });
      _animationController.reverse();
    }
  }

  Future<void> _previewGroup() async {
    final code = _codeCtrl.text.trim().toUpperCase();

    setState(() => _isLoading = true);

    try {
      final preview = await _groupService.previewGroupByCode(code);

      if (preview != null) {
        setState(() {
          _groupPreview = preview;
          _showPreview = true;
          _isLoading = false;
        });
        _animationController.forward();
      } else {
        setState(() {
          _isLoading = false;
          _showPreview = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _showPreview = false;
      });
    }
  }

  Future<void> _pasteFromClipboard() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData?.text != null) {
      final code = clipboardData!.text!.trim().toUpperCase();
      // Ne garder que les caractères alphanumériques et limiter à 6
      final cleanCode = code.replaceAll(RegExp(r'[^A-Z0-9]'), '').substring(0, code.length > 6 ? 6 : code.length);
      _codeCtrl.text = cleanCode;
    }
  }

  Future<void> _joinGroup() async {
    final code = _codeCtrl.text.trim().toUpperCase();

    if (code.isEmpty || code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le code doit contenir 6 caractères')),
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
        // Animation de succès
        _showSuccessDialog();
      }
    } catch (e) {
      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                size: 64,
                color: Colors.green.shade700,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Félicitations !',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Vous avez rejoint le groupe\n"${_groupPreview?['name'] ?? 'le groupe'}"',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(c);
              Navigator.pop(context, true); // Retour avec succès
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
            child: const Text('Voir le groupe'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rejoindre un groupe'),
        actions: [
          IconButton(
            icon: const Icon(Icons.content_paste),
            onPressed: _pasteFromClipboard,
            tooltip: 'Coller depuis le presse-papier',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Icône principale
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.group_add,
                size: 80,
                color: Colors.green.shade600,
              ),
            ),

            const SizedBox(height: 32),

            const Text(
              'Entrez le code d\'invitation',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Demandez le code à l\'administrateur du groupe',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Champ de saisie du code
            TextField(
              controller: _codeCtrl,
              decoration: InputDecoration(
                labelText: 'Code d\'invitation',
                hintText: 'ABC123',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.qr_code_2),
                suffixIcon: _codeCtrl.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _codeCtrl.clear();
                    setState(() {
                      _showPreview = false;
                      _groupPreview = null;
                    });
                  },
                )
                    : null,
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 8,
              ),
              textCapitalization: TextCapitalization.characters,
              maxLength: 6,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
                UpperCaseTextFormatter(),
              ],
            ),

            const SizedBox(height: 24),

            // Preview du groupe
            if (_showPreview && _groupPreview != null)
              FadeTransition(
                opacity: _fadeAnimation,
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.green.shade100,
                              child: const Icon(
                                Icons.group,
                                size: 32,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _groupPreview!['name'] ?? 'Groupe',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (_groupPreview!['description'] != null &&
                                      _groupPreview!['description'].toString().isNotEmpty)
                                    Text(
                                      _groupPreview!['description'],
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${_groupPreview!['memberCount'] ?? 0} membre(s)',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.verified,
                              color: Colors.green.shade600,
                              size: 28,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Bouton rejoindre
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_isLoading || !_showPreview) ? null : _joinGroup,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Text(
                  'Rejoindre le groupe',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Info box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Comment ça marche ?',
                          style: TextStyle(
                            color: Colors.blue.shade900,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '1. Demandez le code à l\'admin du groupe\n'
                              '2. Entrez le code de 6 caractères\n'
                              '3. Vérifiez les infos du groupe\n'
                              '4. Rejoignez le groupe !',
                          style: TextStyle(
                            color: Colors.blue.shade800,
                            fontSize: 12,
                          ),
                        ),
                      ],
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

  @override
  void dispose() {
    _codeCtrl.removeListener(_onCodeChanged);
    _codeCtrl.dispose();
    _animationController.dispose();
    super.dispose();
  }
}

// Formatter pour forcer les majuscules
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}