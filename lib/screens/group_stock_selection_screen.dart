// lib/screens/group_stock_selection_screen.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/group_service.dart';
import '../models/frigo_firestore.dart';
import '../services/frigo_firestore_service.dart';
import 'group_stock_detail_screen.dart';

class GroupStockSelectionScreen extends StatefulWidget {
  const GroupStockSelectionScreen({super.key});

  @override
  State<GroupStockSelectionScreen> createState() => _GroupStockSelectionScreenState();
}

class _GroupStockSelectionScreenState extends State<GroupStockSelectionScreen> {
  final _authService = AuthService();
  final _groupService = GroupService();
  final _frigoService = FrigoFirestoreService();

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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async => _loadGroups(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  _stockTile(
                    title: 'Mon stock privé',
                    subtitle: 'Visible uniquement par moi',
                    icon: Icons.lock_person_rounded,
                    color: const Color(0xFF42A5F5),
                    stream: _frigoService.getMyStock().map((items) => items
                        .where((i) => i.visibility == FrigoVisibility.private)
                        .toList()),
                    onTap: () => _navigateToStockDetail(
                      context,
                      stockType: StockType.private,
                      title: 'Mon stock privé',
                    ),
                  ),
                  if (_userGroups.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.fromLTRB(4, 20, 4, 8),
                      child: Text(
                        'STOCKS DE GROUPE',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                    for (var i = 0; i < _userGroups.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _groupTile(_userGroups[i], i),
                      ),
                  ] else
                    const Padding(
                      padding: EdgeInsets.only(top: 24),
                      child: Text(
                        'Créez ou rejoignez un groupe pour partager un stock.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  static const _groupColors = [
    Color(0xFFFFA726),
    Color(0xFFEF5350),
    Color(0xFF7E57C2),
    Color(0xFF26A69A),
    Color(0xFFD4B106),
  ];

  Widget _groupTile(Map<String, dynamic> group, int index) {
    final groupId = group['id'] as String;
    final name = (group['name'] ?? 'Groupe') as String;
    return _stockTile(
      title: name,
      subtitle: 'Stock partagé',
      icon: Icons.group_rounded,
      color: _groupColors[index % _groupColors.length],
      stream: _frigoService.getGroupStock(groupId),
      onTap: () => _navigateToStockDetail(
        context,
        stockType: StockType.group,
        groupId: groupId,
        title: name,
      ),
    );
  }

  /// Ligne compacte : icône, nom, nombre de produits et produits à consommer
  /// dans les 3 jours.
  Widget _stockTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Stream<List<FrigoFirestore>> stream,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    StreamBuilder<List<FrigoFirestore>>(
                      stream: stream,
                      builder: (context, snap) {
                        final items = snap.data;
                        if (items == null) {
                          return Text(subtitle,
                              style: const TextStyle(
                                  fontSize: 12, color: Color(0xFF64748B)));
                        }
                        final soon = DateTime.now().add(const Duration(days: 3));
                        final expiring = items
                            .where((i) =>
                                i.bestBefore != null &&
                                i.bestBefore!.isBefore(soon))
                            .length;
                        final count =
                            '${items.length} produit${items.length > 1 ? 's' : ''}';
                        return Text(
                          expiring > 0 ? '$count · $expiring à consommer vite' : count,
                          style: TextStyle(
                            fontSize: 12,
                            color: expiring > 0
                                ? const Color(0xFFE65100)
                                : const Color(0xFF64748B),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToStockDetail(
      BuildContext context, {
        required StockType stockType,
        String? groupId,
        required String title,
      }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GroupStockDetailScreen(
          stockType: stockType,
          groupId: groupId,
          title: title,
        ),
      ),
    );
  }
}