// lib/screens/profiles_screen.dart (PAGE UNIQUE)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import '../database.dart';
import '../providers.dart';
import '../repositories/user_profile_repository.dart';
import '../services/group_profile_service.dart';

class ProfilesScreen extends ConsumerStatefulWidget {
  const ProfilesScreen({super.key});

  @override
  ConsumerState<ProfilesScreen> createState() => _ProfilesScreenState();
}

class _ProfilesScreenState extends ConsumerState<ProfilesScreen> {
  late UserProfileRepository _profileRepo;
  late GroupProfileService _groupProfileService;
  List<UserProfile> _profiles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _profileRepo = ref.read(userProfileRepositoryProvider);
    _groupProfileService = ref.read(groupProfileServiceProvider);
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    setState(() => _isLoading = true);
    final profiles = await _profileRepo.getAllProfiles();
    setState(() {
      _profiles = profiles;
      _isLoading = false;
    });
  }

  Future<void> _deleteProfile(UserProfile profile) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le profil'),
        content: Text('Voulez-vous vraiment supprimer le profil "${profile.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final db = ref.read(databaseProvider);
      await (db.delete(db.userProfiles)..where((t) => t.id.equals(profile.id))).go();
      await _loadProfiles();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil supprimé')),
        );
      }
    }
  }

  void _showProfileForm([UserProfile? profile]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileFormScreen(profile: profile),
      ),
    ).then((_) => _loadProfiles());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Profils'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (c) => AlertDialog(
                  title: const Text('💡 Comment ça marche ?'),
                  content: const SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('1. Créez vos profils', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('   → Vous, vos enfants, vos amis...'),
                        SizedBox(height: 12),
                        Text('2. Ils seront synchronisés', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('   → Automatiquement dans tous vos groupes'),
                        SizedBox(height: 12),
                        Text('3. Sélectionnez dans le planning', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('   → Choisissez qui mange quoi'),
                        SizedBox(height: 12),
                        Text('4. Modifiez à tout moment', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('   → Les changements sont partout'),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(c),
                      child: const Text('Compris'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _profiles.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
        onRefresh: _loadProfiles,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _profiles.length,
          itemBuilder: (context, index) {
            final profile = _profiles[index];
            return ProfileCard(
              profile: profile,
              onTap: () => _showProfileForm(profile),
              onDelete: () => _deleteProfile(profile),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showProfileForm(),
        icon: const Icon(Icons.add),
        label: const Text('Nouveau profil'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Aucun profil',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'Créez votre premier profil',
            style: TextStyle(color: Colors.grey.shade500),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showProfileForm(),
            icon: const Icon(Icons.add),
            label: const Text('Créer mon profil'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileCard extends StatelessWidget {
  final UserProfile profile;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ProfileCard({
    super.key,
    required this.profile,
    required this.onTap,
    required this.onDelete,
  });

  IconData _getAvatarIcon() {
    if (profile.sex == 'male') return Icons.man;
    if (profile.sex == 'female') return Icons.woman;
    return Icons.person;
  }

  Color _getAvatarColor() {
    if (profile.eaterMultiplier < 0.8) return Colors.blue;
    if (profile.eaterMultiplier > 1.2) return Colors.purple;
    return Colors.green;
  }

  String _getProfileTypeLabel() {
    if (profile.eaterMultiplier < 0.6) return 'Très petit mangeur';
    if (profile.eaterMultiplier < 0.8) return 'Petit mangeur';
    if (profile.eaterMultiplier < 1.2) return 'Mangeur moyen';
    if (profile.eaterMultiplier < 1.5) return 'Gros mangeur';
    return 'Très gros mangeur';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 30,
                backgroundColor: _getAvatarColor().withOpacity(0.2),
                child: Icon(_getAvatarIcon(), size: 32, color: _getAvatarColor()),
              ),
              const SizedBox(width: 16),

              // Infos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${profile.age} ans • ${profile.weightKg.toStringAsFixed(0)} kg • ${profile.heightCm.toStringAsFixed(0)} cm',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.restaurant, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          _getProfileTypeLabel(),
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getAvatarColor().withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'x${profile.eaterMultiplier.toStringAsFixed(1)}',
                            style: TextStyle(
                              color: _getAvatarColor(),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Actions
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') onTap();
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 12),
                        Text('Modifier'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: Colors.red),
                        SizedBox(width: 12),
                        Text('Supprimer', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// FORMULAIRE DE PROFIL
// ============================================================================

class ProfileFormScreen extends ConsumerStatefulWidget {
  final UserProfile? profile;

  const ProfileFormScreen({super.key, this.profile});

  @override
  ConsumerState<ProfileFormScreen> createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends ConsumerState<ProfileFormScreen> {
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();

  String _sex = 'male';
  String _activityLevel = 'moderate';
  double _eaterMultiplier = 1.0;

  double? _bmr;
  double? _tdee;

  late UserProfileRepository _profileRepo;

  @override
  void initState() {
    super.initState();
    _profileRepo = ref.read(userProfileRepositoryProvider);

    if (widget.profile != null) {
      final p = widget.profile!;
      _nameCtrl.text = p.name;
      _ageCtrl.text = p.age.toString();
      _heightCtrl.text = p.heightCm.toString();
      _weightCtrl.text = p.weightKg.toString();
      _sex = p.sex;
      _activityLevel = p.activityLevel;
      _eaterMultiplier = p.eaterMultiplier;
    } else {
      _nameCtrl.text = 'Moi';
      _ageCtrl.text = '30';
      _heightCtrl.text = '170';
      _weightCtrl.text = '70';
    }

    _calculateBMRandTDEE();
  }

  void _calculateBMRandTDEE() {
    final age = int.tryParse(_ageCtrl.text) ?? 30;
    final heightCm = double.tryParse(_heightCtrl.text) ?? 170;
    final weightKg = double.tryParse(_weightCtrl.text) ?? 70;

    double bmr;
    if (_sex == 'male') {
      bmr = 88.362 + (13.397 * weightKg) + (4.799 * heightCm) - (5.677 * age);
    } else {
      bmr = 447.593 + (9.247 * weightKg) + (3.098 * heightCm) - (4.330 * age);
    }

    final activityFactors = {
      'sedentary': 1.2,
      'light': 1.375,
      'moderate': 1.55,
      'active': 1.725,
      'very_active': 1.9,
    };

    final tdee = bmr * (activityFactors[_activityLevel] ?? 1.55);

    setState(() {
      _bmr = bmr;
      _tdee = tdee;
    });
  }

  Future<void> _saveProfile() async {
    final name = _nameCtrl.text.trim();
    final age = int.tryParse(_ageCtrl.text) ?? 30;
    final heightCm = double.tryParse(_heightCtrl.text) ?? 170;
    final weightKg = double.tryParse(_weightCtrl.text) ?? 70;

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le nom est obligatoire')),
      );
      return;
    }

    if (widget.profile == null) {
      // Création
      await _profileRepo.createProfile(
        name: name,
        sex: _sex,
        age: age,
        heightCm: heightCm,
        weightKg: weightKg,
        eaterMultiplier: _eaterMultiplier,
        activityLevel: _activityLevel,
        setAsActive: false, // Pas de notion d'actif
      );
    } else {
      // Modification (avec auto-sync)
      await _profileRepo.updateProfile(
        widget.profile!.id,
        name: name,
        sex: _sex,
        age: age,
        heightCm: heightCm,
        weightKg: weightKg,
        eaterMultiplier: _eaterMultiplier,
        activityLevel: _activityLevel,
      );
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.profile == null ? 'Profil créé !' : 'Profil mis à jour !'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.profile == null ? 'Nouveau profil' : 'Modifier le profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Nom du profil *',
                hintText: 'Ex: Moi, Marie, Paul...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              autofocus: widget.profile == null,
            ),
            const SizedBox(height: 16),

            const Text('Sexe', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'male', label: Text('Homme'), icon: Icon(Icons.male)),
                ButtonSegment(value: 'female', label: Text('Femme'), icon: Icon(Icons.female)),
              ],
              selected: {_sex},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _sex = newSelection.first;
                  _calculateBMRandTDEE();
                });
              },
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ageCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Âge',
                      suffixText: 'ans',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _calculateBMRandTDEE(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _heightCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Taille',
                      suffixText: 'cm',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _calculateBMRandTDEE(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _weightCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Poids',
                      suffixText: 'kg',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _calculateBMRandTDEE(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            const Text('Niveau d\'activité', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _activityLevel,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'sedentary', child: Text('Sédentaire')),
                DropdownMenuItem(value: 'light', child: Text('Léger')),
                DropdownMenuItem(value: 'moderate', child: Text('Modéré')),
                DropdownMenuItem(value: 'active', child: Text('Actif')),
                DropdownMenuItem(value: 'very_active', child: Text('Très actif')),
              ],
              onChanged: (v) {
                setState(() {
                  _activityLevel = v ?? 'moderate';
                  _calculateBMRandTDEE();
                });
              },
            ),

            const SizedBox(height: 16),

            const Text('Portions mangées', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              color: Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_getEaterLabel(_eaterMultiplier)),
                        Text(
                          'x${_eaterMultiplier.toStringAsFixed(1)}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Slider(
                      value: _eaterMultiplier,
                      min: 0.3,
                      max: 2.0,
                      divisions: 17,
                      label: 'x${_eaterMultiplier.toStringAsFixed(1)}',
                      onChanged: (v) => setState(() => _eaterMultiplier = v),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            if (_bmr != null && _tdee != null)
              Row(
                children: [
                  Expanded(
                    child: Card(
                      color: Colors.green.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            const Text('BMR', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            Text('${_bmr!.toStringAsFixed(0)} kcal', style: const TextStyle(fontSize: 18)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Card(
                      color: Colors.blue.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            const Text('TDEE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            Text('${_tdee!.toStringAsFixed(0)} kcal', style: const TextStyle(fontSize: 18)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saveProfile,
                icon: const Icon(Icons.check),
                label: const Text('Enregistrer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getEaterLabel(double multiplier) {
    if (multiplier < 0.6) return 'Très petit mangeur';
    if (multiplier < 0.8) return 'Petit mangeur';
    if (multiplier < 1.2) return 'Mangeur moyen';
    if (multiplier < 1.5) return 'Gros mangeur';
    return 'Très gros mangeur';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }
}