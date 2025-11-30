// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import '../database.dart';
import '../providers.dart';
import '../repositories/user_profile_repository.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();

  String _sex = 'male';
  String _activityLevel = 'moderate';
  double _eaterMultiplier = 1.0;

  double? _bmr;
  double? _tdee;

  UserProfile? _currentProfile;
  late UserProfileRepository _profileRepo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _profileRepo = UserProfileRepository(ref.read(databaseProvider));
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await _profileRepo.getActiveProfile();

    if (profile != null) {
      setState(() {
        _currentProfile = profile;
        _nameCtrl.text = profile.name;
        _ageCtrl.text = profile.age.toString();
        _heightCtrl.text = profile.heightCm.toString();
        _weightCtrl.text = profile.weightKg.toString();
        _sex = profile.sex;
        _activityLevel = profile.activityLevel;
        _eaterMultiplier = profile.eaterMultiplier;
        _isLoading = false;
      });
      _calculateBMRandTDEE();
    } else {
      // Valeurs par défaut si pas de profil
      setState(() {
        _nameCtrl.text = 'Utilisateur';
        _ageCtrl.text = '30';
        _heightCtrl.text = '170';
        _weightCtrl.text = '70';
        _isLoading = false;
      });
      _calculateBMRandTDEE();
    }
  }

  void _calculateBMRandTDEE() {
    final age = int.tryParse(_ageCtrl.text) ?? 30;
    final heightCm = double.tryParse(_heightCtrl.text) ?? 170;
    final weightKg = double.tryParse(_weightCtrl.text) ?? 70;

    // Formule de Harris-Benedict
    double bmr;
    if (_sex == 'male') {
      bmr = 88.362 + (13.397 * weightKg) + (4.799 * heightCm) - (5.677 * age);
    } else {
      bmr = 447.593 + (9.247 * weightKg) + (3.098 * heightCm) - (4.330 * age);
    }

    // Facteur d'activité
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

    if (_currentProfile == null) {
      // Créer un nouveau profil
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
      // Mettre à jour le profil existant (via update dans le repository)
      final db = ref.read(databaseProvider);
      await (db.update(db.userProfiles)..where((t) => t.id.equals(_currentProfile!.id)))
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
        ),
      );
    }

    await _loadProfile();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil enregistré !')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mon profil')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar et nom
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.green.shade100,
                    child: const Icon(Icons.person, size: 60, color: Colors.green),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 200,
                    child: TextField(
                      controller: _nameCtrl,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Votre nom',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // Informations personnelles
            const Text(
              'Informations personnelles',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Sexe
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

            // Âge, Taille, Poids
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

            const SizedBox(height: 24),

            // Niveau d'activité
            const Text(
              'Niveau d\'activité',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _activityLevel,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'sedentary', child: Text('Sédentaire (peu ou pas d\'exercice)')),
                DropdownMenuItem(value: 'light', child: Text('Léger (exercice 1-3j/semaine)')),
                DropdownMenuItem(value: 'moderate', child: Text('Modéré (exercice 3-5j/semaine)')),
                DropdownMenuItem(value: 'active', child: Text('Actif (exercice 6-7j/semaine)')),
                DropdownMenuItem(value: 'very_active', child: Text('Très actif (sport intense quotidien)')),
              ],
              onChanged: (v) {
                setState(() {
                  _activityLevel = v ?? 'moderate';
                  _calculateBMRandTDEE();
                });
              },
            ),

            const SizedBox(height: 24),

            // Type de mangeur
            const Text(
              'Type de mangeur',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
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
                        const Text('Multiplicateur de portions'),
                        Text(
                          'x${_eaterMultiplier.toStringAsFixed(1)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _eaterMultiplier,
                      min: 0.5,
                      max: 1.5,
                      divisions: 10,
                      label: 'x${_eaterMultiplier.toStringAsFixed(1)}',
                      onChanged: (v) {
                        setState(() => _eaterMultiplier = v);
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Petit (0.5)', style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
                        Text('Moyen (1.0)', style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
                        Text('Gros (1.5)', style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // Résultats calculés
            const Text(
              'Besoins caloriques',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    title: 'BMR',
                    subtitle: 'Métabolisme de base',
                    value: _bmr != null ? '${_bmr!.toStringAsFixed(0)} kcal' : '...',
                    icon: Icons.local_fire_department,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    title: 'TDEE',
                    subtitle: 'Dépense quotidienne',
                    value: _tdee != null ? '${_tdee!.toStringAsFixed(0)} kcal' : '...',
                    icon: Icons.bolt,
                    color: Colors.red,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Card(
              color: Colors.green.shade50,
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.green),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Le BMR est le nombre de calories brûlées au repos. '
                            'Le TDEE inclut votre niveau d\'activité.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Bouton sauvegarder
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saveProfile,
                icon: const Icon(Icons.save),
                label: const Text('Enregistrer le profil'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
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

class _MetricCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}