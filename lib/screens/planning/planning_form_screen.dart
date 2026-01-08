// lib/screens/planning/planning_form_screen.dart - VERSION COMPLÈTE CORRIGÉE
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../database.dart';
import '../../models/planning_firestore.dart';
import '../../models/recette_firestore.dart';
import '../../providers.dart';
import '../../repositories/user_profile_repository.dart';
import '../../services/planning_firestore_service.dart';
import '../../services/recette_firestore_service.dart';
import '../../services/auth_service.dart';
import '../../services/group_profile_service.dart';
import '../../widgets/eaters_selector.dart';
import 'group_planning_detail_screen.dart';

enum RecipeSourceType {
  private,
  group,
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
  final _groupProfileService = GroupProfileService();

  late UserProfileRepository _profileRepo;

  // Formulaire
  RecipeSourceType _recipeSource = RecipeSourceType.private;
  dynamic _selectedRecipe;
  String _selectedMealType = 'lunch';
  final List<int> _selectedEaters = []; // ✅ final pour éviter réassignation

  List<dynamic> _availableRecipes = [];
  List<UserProfile> _availableProfiles = [];
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
    final db = ref.read(databaseProvider);
    _profileRepo = UserProfileRepository(db);

    // Définir la source par défaut selon le contexte
    if (widget.sourceType == PlanningSourceType.group) {
      _recipeSource = RecipeSourceType.group;
    }

    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    // Charger les recettes
    await _loadRecipes();

    // Charger les profils
    await _loadProfiles();

    setState(() => _isLoading = false);
  }

  Future<void> _loadRecipes() async {
    if (_recipeSource == RecipeSourceType.private) {
      // Charger mes recettes privées
      final recipes = await _recetteService.getMyRecettes().first;
      setState(() => _availableRecipes = recipes.where((r) =>
      r.visibility == RecetteVisibility.private
      ).toList());
    } else {
      // Charger les recettes du groupe
      if (widget.sourceType == PlanningSourceType.group && widget.groupId != null) {
        final recipes = await _recetteService.getGroupRecettes(widget.groupId!).first;
        setState(() => _availableRecipes = recipes);
      }
    }
  }

  Future<void> _loadProfiles() async {
    if (widget.sourceType == PlanningSourceType.group && widget.groupId != null) {
      final groupProfilesData = await _groupProfileService.getGroupProfiles(widget.groupId!);
      setState(() {
        _availableProfiles = _groupProfileService.convertToUserProfiles(groupProfilesData);
      });
    } else {
      final profiles = await _profileRepo.getAllProfiles();
      setState(() => _availableProfiles = profiles);
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

            // Source de recette (seulement si "Tout")
            if (widget.sourceType == PlanningSourceType.all) ...[
              _buildSourceSelector(),
              const SizedBox(height: 20),
            ],

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
          'Source de recette',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSourceOption(
                RecipeSourceType.private,
                'Mes recettes privées',
                Icons.lock_person,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSourceOption(
                RecipeSourceType.group,
                'Recettes de groupe',
                Icons.group,
                Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSourceOption(
      RecipeSourceType type,
      String label,
      IconData icon,
      Color color,
      ) {
    final isSelected = _recipeSource == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _recipeSource = type;
          _selectedRecipe = null;
        });
        _loadRecipes();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE2E8F0),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? color : const Color(0xFF94A3B8),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
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
            prefixIcon: Icon(
              _recipeSource == RecipeSourceType.private
                  ? Icons.lock_person
                  : Icons.group,
              color: _recipeSource == RecipeSourceType.private
                  ? Colors.blue
                  : Colors.green,
            ),
          ),
          hint: Text(_availableRecipes.isEmpty
              ? 'Aucune recette disponible'
              : 'Sélectionnez une recette'),
          items: _availableRecipes.map((recipe) {
            final name = (recipe as RecetteFirestore).name;
            return DropdownMenuItem(
              value: recipe,
              child: Text(name, overflow: TextOverflow.ellipsis),
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
            // ✅ Mise à jour sans setState
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

      final eatersJson = _selectedEaters.isNotEmpty
          ? EatersHelper.encodeEaters(_selectedEaters)
          : null;

      // Toujours une recette cloud (RecetteFirestore)
      final recetteCloud = _selectedRecipe as RecetteFirestore;
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

// Helper pour encoder/décoder les convives
class EatersHelper {
  static String encodeEaters(List<int> profileIds) {
    return profileIds.join(',');
  }

  static List<int> decodeEaters(String eatersJson) {
    if (eatersJson.isEmpty) return [];
    return eatersJson.split(',').map((s) => int.parse(s)).toList();
  }
}