// lib/screens/profiles_management_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import '../database.dart';
import '../providers.dart';
import '../repositories/user_profile_repository.dart';

class ProfilesManagementScreen extends ConsumerStatefulWidget {
  const ProfilesManagementScreen({super.key});

  @override
  ConsumerState<ProfilesManagementScreen> createState() => _ProfilesManagementScreenState();
}

class _ProfilesManagementScreenState extends ConsumerState<ProfilesManagementScreen> {
  late UserProfileRepository _profileRepo;
  List<UserProfile> _profiles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _profileRepo = UserProfileRepository(ref.read(databaseProvider));
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

  Future<void> _setActiveProfile(UserProfile profile) async {
    final db = ref.read(databaseProvider);

    // Désactiver tous les profils
    await (db.update(db.userProfiles)..where((t) => t.isActive.equals(true)))
        .write(const UserProfilesCompanion(isActive: Value(false)));

    // Activer le profil sélectionné
    await (db.update(db.userProfiles)..where((t) => t.id.equals(profile.id)))
        .write(const UserProfilesCompanion(isActive: Value(true)));

    await _loadProfiles();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profil actif : ${profile.name}')),
      );
    }
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
        title: const Text('Gestion des profils'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _profiles.isEmpty
          ? Center(
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
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _profiles.length,
        itemBuilder: (context, index) {
          final profile = _profiles[index];
          return ProfileCard(
            profile: profile,
            onTap: () => _showProfileForm(profile),
            onSetActive: () => _setActiveProfile(profile),
            onDelete: () => _deleteProfile(profile),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showProfileForm(),
        icon: const Icon(Icons.add),
        label: const Text('Nouveau profil'),
      ),
    );
  }
}

class ProfileCard extends StatelessWidget {
  final UserProfile profile;
  final VoidCallback onTap;
  final VoidCallback onSetActive;
  final VoidCallback onDelete;

  const ProfileCard({
    super.key,
    required this.profile,
    required this.onTap,
    required this.onSetActive,
    required this.onDelete,
  });

  IconData _getAvatarIcon() {
    if (profile.sex == 'male') return Icons.person;
    if (profile.sex == 'female') return Icons.person_outline;
    return Icons.person;
  }

  Color _getAvatarColor() {
    if (profile.eaterMultiplier < 0.8) return Colors.blue; // Enfant
    if (profile.eaterMultiplier > 1.2) return Colors.purple; // Gros mangeur
    return Colors.green; // Normal
  }

  String _getProfileTypeLabel() {
    if (profile.eaterMultiplier < 0.8) return 'Petit mangeur';
    if (profile.eaterMultiplier > 1.2) return 'Gros mangeur';
    return 'Mangeur moyen';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: profile.isActive ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: profile.isActive
            ? BorderSide(color: Colors.green.shade400, width: 2)
            : BorderSide.none,
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
                    Row(
                      children: [
                        Text(
                          profile.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (profile.isActive) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'ACTIF',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
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
                  if (value == 'active') onSetActive();
                  if (value == 'edit') onTap();
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (context) => [
                  if (!profile.isActive)
                    const PopupMenuItem(
                      value: 'active',
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, size: 20),
                          SizedBox(width: 12),
                          Text('Définir comme actif'),
                        ],
                      ),
                    ),
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

// FORMULAIRE DE PROFIL (réutilise la logique de profile_screen.dart)
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
    _profileRepo = UserProfileRepository(ref.read(databaseProvider));

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
      _nameCtrl.text = 'Nouveau profil';
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

    final db = ref.read(databaseProvider);

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
      );
    } else {
      // Modification
      await (db.update(db.userProfiles)..where((t) => t.id.equals(widget.profile!.id)))
          .write(
        UserProfilesCompanion(
          name: Value(name),
          sex: Value(_sex),
          age: Value(age),
          heightCm: Value(heightCm),
          weightKg: Value(weightKg),
          eaterMultiplier: Value(_eaterMultiplier),
          activityLevel: Value(_activityLevel),
          bmr: Value(_bmr),
          tdee: Value(_tdee),
          updatedAt: Value(DateTime.now()),
        ),
      );
    }

    if (mounted) {
      Navigator.pop(context);
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
                labelText: 'Nom du profil',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
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

            const Text('Type de mangeur', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Multiplicateur'),
                        Text(
                          'x${_eaterMultiplier.toStringAsFixed(1)}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Slider(
                      value: _eaterMultiplier,
                      min: 0.5,
                      max: 1.5,
                      divisions: 10,
                      label: 'x${_eaterMultiplier.toStringAsFixed(1)}',
                      onChanged: (v) => setState(() => _eaterMultiplier = v),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Petit (0.5)', style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
                        Text('Normal (1.0)', style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
                        Text('Gros (1.5)', style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            if (_bmr != null && _tdee != null)
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              const Text('BMR', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text('${_bmr!.toStringAsFixed(0)} kcal'),
                            ],
                          ),
                          Column(
                            children: [
                              const Text('TDEE', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text('${_tdee!.toStringAsFixed(0)} kcal'),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saveProfile,
                icon: const Icon(Icons.check),
                label: const Text('Enregistrer'),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
              ),
            ),
          ],
        ),
      ),
    );
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