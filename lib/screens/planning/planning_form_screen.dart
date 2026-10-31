// lib/screens/planning/planning_form_screen.dart - VERSION COMPLÈTE CORRIGÉE
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/app_profile.dart';
import '../../models/planning_firestore.dart';
import '../../models/recette_firestore.dart';
import '../../services/planning_firestore_service.dart';
import '../../services/recette_firestore_service.dart';
import '../../services/auth_service.dart';
import '../../services/group_service.dart';
import '../../services/profile_firestore_service.dart';
import '../../utils/portion_calculator.dart';
import '../../widgets/eaters_selector.dart';
import 'group_planning_detail_screen.dart';

/// Une banque de recettes : « mes recettes » ou les recettes d'un groupe.
class _RecipeBank {
  static const mineId = 'mine';

  final String id; // 'mine' ou l'identifiant du groupe
  final String label;
  const _RecipeBank(this.id, this.label);

  bool get isMine => id == mineId;
}

class PlanningFormScreen extends ConsumerStatefulWidget {
  final DateTime selectedDate;
  final PlanningSourceType sourceType;
  final String? groupId;
  final String? groupName;

  const PlanningFormScreen({
    super.key,
    required this.selectedDate,
    required this.sourceType,
    this.groupId,
    this.groupName,
  });

  @override
  ConsumerState<PlanningFormScreen> createState() => _PlanningFormScreenState();
}

class _PlanningFormScreenState extends ConsumerState<PlanningFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _planningService = PlanningFirestoreService();
  final _recetteService = RecetteFirestoreService();
  final _authService = AuthService();
  final _profileService = ProfileFirestoreService();

  // Formulaire
  // Banques de recettes disponibles et banques cochées
  final List<_RecipeBank> _banks = [const _RecipeBank(_RecipeBank.mineId, 'Mes recettes')];
  final Set<String> _enabledBanks = {_RecipeBank.mineId};
  final Map<String, String> _recipeBankOf = {}; // recetteId -> libellé de banque
  dynamic _selectedRecipe;
  String _selectedMealType = 'lunch';
  final List<String> _selectedEaters = []; // uid des convives (groupe uniquement)

  List<dynamic> _availableRecipes = [];
  List<GroupMember> _availableProfiles = [];
  bool _isLoading = false;

  final _mealTypes = [
    {'value': 'breakfast', 'label': '🌅 Petit-déjeuner'},
    {'value': 'lunch', 'label': '☀️ Déjeuner'},
    {'value': 'snack', 'label': '🍪 Collation'},
    {'value': 'dinner', 'label': '🌙 Dîner'},
  ];

  @override
  void initState() {
    super.initState();
    // Planning de groupe : la banque du groupe est cochée d'office.
    if (widget.sourceType == PlanningSourceType.group && widget.groupId != null) {
      _enabledBanks.add(widget.groupId!);
    }
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    await _loadBanks();
    await _loadRecipes();
    await _loadProfiles();

    if (mounted) setState(() => _isLoading = false);
  }

  /// Mes groupes = autant de banques de recettes supplémentaires.
  Future<void> _loadBanks() async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) return;
    try {
      final groups = await GroupService().getUserGroups(uid).first;
      for (final g in groups) {
        final id = g['id'] as String;
        if (_banks.any((b) => b.id == id)) continue;
        _banks.add(_RecipeBank(id, (g['name'] ?? 'Groupe') as String));
      }
      // Le groupe du planning doit toujours être proposé.
      final gid = widget.groupId;
      if (gid != null && !_banks.any((b) => b.id == gid)) {
        _banks.add(_RecipeBank(gid, widget.groupName ?? 'Groupe'));
      }
    } catch (e) {
      debugPrint('Erreur chargement des groupes: $e');
    }
  }

  /// Recettes de toutes les banques cochées (sans doublon).
  Future<void> _loadRecipes() async {
    final result = <String, RecetteFirestore>{};
    final bankOf = <String, String>{};

    for (final bank in _banks.where((b) => _enabledBanks.contains(b.id))) {
      try {
        final recipes = bank.isMine
            ? (await _recetteService.getMyRecettes().first)
                .where((r) => r.visibility == RecetteVisibility.private)
                .toList()
            : await _recetteService.getGroupRecettes(bank.id).first;
        for (final r in recipes) {
          result.putIfAbsent(r.id, () => r);
          bankOf.putIfAbsent(r.id, () => bank.label);
        }
      } catch (e) {
        debugPrint('Erreur chargement recettes (${bank.label}): $e');
      }
    }

    final list = result.values.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    if (!mounted) return;
    setState(() {
      _availableRecipes = list;
      _recipeBankOf
        ..clear()
        ..addAll(bankOf);
      // La recette choisie n'est plus proposée : on la désélectionne.
      if (_selectedRecipe != null) {
        // Même recette = nouvelle instance après rechargement (le menu
        // déroulant compare par identité).
        _selectedRecipe = result[(_selectedRecipe as RecetteFirestore).id];
      }
    });
  }

  /// Planning de groupe : les convives se choisissent parmi les membres du
  /// groupe (moi coché par défaut). Planning privé : une seule personne, moi.
  Future<void> _loadProfiles() async {
    if (widget.sourceType == PlanningSourceType.group && widget.groupId != null) {
      try {
        final members = await _profileService.getGroupMembers(widget.groupId!);
        final myUid = _profileService.currentUid;
        setState(() {
          _availableProfiles = members;
          if (_selectedEaters.isEmpty && myUid != null && members.any((m) => m.uid == myUid)) {
            _selectedEaters.add(myUid);
          }
        });
      } catch (e) {
        debugPrint('Erreur chargement membres du groupe: $e');
      }
    } else {
      setState(() => _availableProfiles = []);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Planifier un repas'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Date sélectionnée
            _buildDateCard(),
            const SizedBox(height: 20),

            // Banques de recettes à inclure
            _buildSourceSelector(),
            const SizedBox(height: 20),

            // Sélection de recette
            _buildRecipeSelector(),
            const SizedBox(height: 20),

            // Type de repas
            _buildMealTypeSelector(),
            const SizedBox(height: 20),

            // Sélection des convives
            if (_availableProfiles.isNotEmpty) ...[
              _buildEatersSection(),
              const SizedBox(height: 20),
            ],

            // Bouton de validation
            const SizedBox(height: 20),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildDateCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.blue.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.calendar_today, color: Colors.blue),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Date du repas',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
              Text(
                _formatDate(widget.selectedDate),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSourceSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Banques de recettes',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Cochez celles dans lesquelles piocher',
          style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: _banks.map((bank) {
            final selected = _enabledBanks.contains(bank.id);
            return FilterChip(
              avatar: Icon(
                bank.isMine ? Icons.lock_person : Icons.group,
                size: 18,
                color: bank.isMine ? Colors.blue : Colors.green,
              ),
              label: Text(bank.label),
              selected: selected,
              onSelected: (value) {
                setState(() {
                  if (value) {
                    _enabledBanks.add(bank.id);
                  } else if (_enabledBanks.length > 1) {
                    _enabledBanks.remove(bank.id); // au moins une banque
                  }
                });
                _loadRecipes();
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRecipeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recette *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<dynamic>(
          value: _selectedRecipe,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            prefixIcon: const Icon(Icons.menu_book, color: Color(0xFF10B981)),
          ),
          isExpanded: true,
          hint: Text(_availableRecipes.isEmpty
              ? 'Aucune recette disponible'
              : 'Sélectionnez une recette'),
          items: _availableRecipes.map((recipe) {
            final r = recipe as RecetteFirestore;
            final bank = _recipeBankOf[r.id];
            // On précise la banque quand plusieurs sont cochées
            final label = (_enabledBanks.length > 1 && bank != null)
                ? '${r.name}  ·  $bank'
                : r.name;
            return DropdownMenuItem(
              value: recipe,
              child: Text(label, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: (value) => setState(() => _selectedRecipe = value),
          validator: (value) => value == null ? 'Veuillez sélectionner une recette' : null,
        ),
      ],
    );
  }

  Widget _buildMealTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Type de repas *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _selectedMealType,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            prefixIcon: const Icon(Icons.restaurant, color: Color(0xFF10B981)),
          ),
          items: _mealTypes.map((type) {
            return DropdownMenuItem(
              value: type['value'] as String,
              child: Text(type['label'] as String),
            );
          }).toList(),
          onChanged: (value) => setState(() => _selectedMealType = value!),
        ),
      ],
    );
  }

  Widget _buildEatersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Qui va manger ?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 12),
        // ✅ Clé unique pour forcer reconstruction propre
        EatersSelector(
          key: ValueKey(_availableProfiles.length),
          allProfiles: _availableProfiles,
          selectedProfileIds: _selectedEaters,
          onSelectionChanged: (ids) {
            _selectedEaters.clear();
            _selectedEaters.addAll(ids);
          },
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _submitForm,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
      child: _isLoading
          ? const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      )
          : const Text(
        'Ajouter au planning',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRecipe == null) return;

    setState(() => _isLoading = true);

    try {
      final mealTime = _getMealTime(_selectedMealType);
      final plannedDate = DateTime(
        widget.selectedDate.year,
        widget.selectedDate.month,
        widget.selectedDate.day,
        mealTime.hour,
        mealTime.minute,
      );

      // Privé : pas de convives (= moi). Groupe : les membres cochés.
      final eatersJson = (widget.sourceType == PlanningSourceType.group &&
              _selectedEaters.isNotEmpty)
          ? PortionCalculator.encodeEaterUids(_selectedEaters)
          : null;

      // Toujours une recette cloud (RecetteFirestore)
      var recetteCloud = _selectedRecipe as RecetteFirestore;

      // Repas de groupe : tous les membres doivent pouvoir lire la recette.
      // Si elle n'est pas déjà dans la banque de ce groupe (recette privée ou
      // d'un autre groupe), on utilise la copie du groupe, créée au besoin.
      final gid = widget.groupId;
      if (widget.sourceType == PlanningSourceType.group &&
          gid != null &&
          !(recetteCloud.visibility == RecetteVisibility.group &&
              recetteCloud.groupId == gid)) {
        recetteCloud = await _recipeForGroup(recetteCloud, gid);
      }
      final nutrition = recetteCloud.nutrition ?? {};

      await _planningService.addToPlanning(
        date: plannedDate,
        mealType: _selectedMealType,
        recetteId: recetteCloud.id,
        recetteName: recetteCloud.name,
        eaters: eatersJson,
        visibility: widget.sourceType == PlanningSourceType.group
            ? PlanningVisibility.group
            : PlanningVisibility.private,
        groupId: widget.groupId,
        totalCalories: nutrition['calories'] ?? 0,
        totalProteins: nutrition['proteins'] ?? 0,
        totalFats: nutrition['fats'] ?? 0,
        totalCarbs: nutrition['carbs'] ?? 0,
        totalFibers: nutrition['fibers'] ?? 0,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Repas ajouté au planning !'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Version de [source] disponible dans la banque du groupe [groupId].
  Future<RecetteFirestore> _recipeForGroup(RecetteFirestore source, String groupId) async {
    final inGroup = await _recetteService.getGroupRecettes(groupId).first;
    final wanted = source.name.trim().toLowerCase();
    for (final r in inGroup) {
      if (r.name.trim().toLowerCase() == wanted) return r;
    }

    final newId = await _recetteService.copyToGroup(
      sourceRecetteId: source.id,
      groupId: groupId,
      groupName: widget.groupName,
    );
    return await _recetteService.getRecetteById(newId) ?? source;
  }

  DateTime _getMealTime(String mealType) {
    switch (mealType) {
      case 'breakfast':
        return DateTime(2000, 1, 1, 8, 0);
      case 'lunch':
        return DateTime(2000, 1, 1, 12, 0);
      case 'dinner':
        return DateTime(2000, 1, 1, 19, 0);
      case 'snack':
        return DateTime(2000, 1, 1, 16, 0);
      default:
        return DateTime(2000, 1, 1, 12, 0);
    }
  }

  String _formatDate(DateTime date) {
    final weekdays = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
    final months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    return '${weekdays[date.weekday - 1]} ${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
