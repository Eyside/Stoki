// lib/screens/profiles_screen.dart
// Mon profil : un compte = un profil (stocké dans Firestore, privé).
// Le nom et le coefficient de mangeur sont copiés dans vos groupes ; l'âge, la
// taille, le poids et les calories restent privés.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import '../models/app_profile.dart';
import '../services/account_deletion_service.dart';
import '../services/profile_firestore_service.dart';

class ProfilesScreen extends ConsumerStatefulWidget {
  const ProfilesScreen({super.key});

  @override
  ConsumerState<ProfilesScreen> createState() => _ProfilesScreenState();
}

class _ProfilesScreenState extends ConsumerState<ProfilesScreen> {
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();

  String _sex = 'male';
  String _activityLevel = 'moderate';
  double _eaterMultiplier = 1.0;

  double? _bmr;
  double? _tdee;

  late ProfileFirestoreService _profileService;
  bool _loading = true;
  bool _saving = false;
  bool _isNew = true;

  @override
  void initState() {
    super.initState();
    _profileService = ref.read(profileFirestoreServiceProvider);
    _load();
  }

  Future<void> _load() async {
    try {
      final p = await _profileService.getMyProfile();
      if (p != null) {
        _isNew = false;
        _nameCtrl.text = p.name;
        _ageCtrl.text = p.age.toString();
        _heightCtrl.text = p.heightCm.toString();
        _weightCtrl.text = p.weightKg.toString();
        _sex = p.sex;
        _activityLevel = p.activityLevel;
        _eaterMultiplier = p.eaterMultiplier;
      } else {
        _nameCtrl.text = '';
        _ageCtrl.text = '30';
        _heightCtrl.text = '170';
        _weightCtrl.text = '70';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de chargement : $e'), backgroundColor: Colors.red),
        );
      }
    }
    if (!mounted) return;
    setState(() => _loading = false);
    _calculateBMRandTDEE();
  }

  void _calculateBMRandTDEE() {
    final age = int.tryParse(_ageCtrl.text) ?? 30;
    final heightCm = double.tryParse(_heightCtrl.text.replaceAll(',', '.')) ?? 170;
    final weightKg = double.tryParse(_weightCtrl.text.replaceAll(',', '.')) ?? 70;

    final bmr = AppProfile.computeBmr(
        sex: _sex, age: age, heightCm: heightCm, weightKg: weightKg);
    final tdee = AppProfile.computeTdee(bmr, _activityLevel);

    setState(() {
      _bmr = bmr;
      _tdee = tdee;
    });
  }

  Future<void> _saveProfile() async {
    final name = _nameCtrl.text.trim();
    final age = int.tryParse(_ageCtrl.text) ?? 30;
    final heightCm = double.tryParse(_heightCtrl.text.replaceAll(',', '.')) ?? 170;
    final weightKg = double.tryParse(_weightCtrl.text.replaceAll(',', '.')) ?? 70;

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le nom est obligatoire')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await _profileService.saveMyProfile(
        name: name,
        sex: _sex,
        age: age,
        heightCm: heightCm,
        weightKg: weightKg,
        eaterMultiplier: _eaterMultiplier,
        activityLevel: _activityLevel,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red),
      );
      return;
    }

    if (mounted) {
      final wasNew = _isNew;
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(wasNew ? 'Profil créé !' : 'Profil mis à jour !'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _confirmDeleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Supprimer mon compte ?'),
        content: const Text(
          'Votre profil, votre suivi calorique, vos repas planifiés, votre '
          'stock privé, votre liste de courses et vos recettes privées seront '
          'effacés définitivement. Vous quitterez tous vos groupes ; ce qui '
          'appartient aux groupes (recettes et stock de groupe) y reste.\n\n'
          'Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(c, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer définitivement'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _saving = true);
    try {
      await AccountDeletionService().deleteEverything();
      if (!mounted) return;
      // Le compte n'existe plus : retour à l'écran de connexion
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 8),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saving ? null : _saveProfile,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Votre prénom *',
                hintText: 'Affiché aux membres de vos groupes',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              autofocus: _isNew,
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
                onPressed: _saving ? null : _saveProfile,
                icon: const Icon(Icons.check),
                label: const Text('Enregistrer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),

            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 8),
            Center(
              child: TextButton.icon(
                onPressed: _saving ? null : _confirmDeleteAccount,
                icon: const Icon(Icons.delete_forever, color: Colors.red),
                label: const Text(
                  'Supprimer mon compte et mes données',
                  style: TextStyle(color: Colors.red),
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