// lib/repositories/user_profile_repository.dart (AVEC AUTO-SYNCHRONISATION)
import 'package:drift/drift.dart';
import '../database.dart';
import 'package:uuid/uuid.dart';
import '../services/group_profile_service.dart';

class UserProfileRepository extends DatabaseAccessor<AppDatabase> {
  final AppDatabase db;
  final GroupProfileService? _groupProfileService;

  UserProfileRepository(this.db, {GroupProfileService? groupProfileService})
      : _groupProfileService = groupProfileService,
        super(db);

  @override
  AppDatabase get attachedDatabase => db;

  /// Récupère tous les profils
  Future<List<UserProfile>> getAllProfiles() {
    return select(db.userProfiles).get();
  }

  /// Récupère le profil actif
  Future<UserProfile?> getActiveProfile() {
    return db.getActiveProfile();
  }

  /// Récupère un profil par ID
  Future<UserProfile?> getProfileById(int id) {
    return (select(db.userProfiles)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Crée un nouveau profil (SANS synchronisation automatique)
  Future<int> createProfile({
    required String name,
    required String sex,
    required int age,
    required double heightCm,
    required double weightKg,
    double eaterMultiplier = 1.0,
    String activityLevel = 'moderate',
    bool setAsActive = false,
  }) async {
    // Calculer BMR et TDEE
    final bmr = calculateBMR(
      sex: sex,
      age: age,
      weightKg: weightKg,
      heightCm: heightCm,
    );

    final tdee = calculateTDEE(
      bmr: bmr,
      activityLevel: activityLevel,
    );

    final companion = UserProfilesCompanion(
      name: Value(name),
      userId: Value(const Uuid().v4()),
      sex: Value(sex),
      age: Value(age),
      heightCm: Value(heightCm),
      weightKg: Value(weightKg),
      eaterMultiplier: Value(eaterMultiplier),
      activityLevel: Value(activityLevel),
      bmr: Value(bmr),
      tdee: Value(tdee),
      isActive: const Value(false),
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    );

    final profileId = await into(db.userProfiles).insert(companion);
    print('✅ Profil créé (ID: $profileId) - À ajouter manuellement aux groupes');

    return profileId;
  }

  /// Met à jour un profil (synchronisation manuelle dans les groupes)
  Future<bool> updateProfile(
      int profileId, {
        String? name,
        String? sex,
        int? age,
        double? heightCm,
        double? weightKg,
        double? eaterMultiplier,
        String? activityLevel,
      }) async {
    // Récupérer le profil actuel
    final currentProfile = await getProfileById(profileId);
    if (currentProfile == null) return false;

    // Construire les nouvelles valeurs
    final newSex = sex ?? currentProfile.sex;
    final newAge = age ?? currentProfile.age;
    final newHeightCm = heightCm ?? currentProfile.heightCm;
    final newWeightKg = weightKg ?? currentProfile.weightKg;
    final newActivityLevel = activityLevel ?? currentProfile.activityLevel;

    // Recalculer BMR et TDEE
    final bmr = calculateBMR(
      sex: newSex,
      age: newAge,
      weightKg: newWeightKg,
      heightCm: newHeightCm,
    );

    final tdee = calculateTDEE(
      bmr: bmr,
      activityLevel: newActivityLevel,
    );

    // Mettre à jour dans la base
    final result = await (update(db.userProfiles)..where((t) => t.id.equals(profileId)))
        .write(
      UserProfilesCompanion(
        name: name != null ? Value(name) : const Value.absent(),
        sex: sex != null ? Value(sex) : const Value.absent(),
        age: age != null ? Value(age) : const Value.absent(),
        heightCm: heightCm != null ? Value(heightCm) : const Value.absent(),
        weightKg: weightKg != null ? Value(weightKg) : const Value.absent(),
        eaterMultiplier:
        eaterMultiplier != null ? Value(eaterMultiplier) : const Value.absent(),
        activityLevel: activityLevel != null ? Value(activityLevel) : const Value.absent(),
        bmr: Value(bmr),
        tdee: Value(tdee),
        updatedAt: Value(DateTime.now()),
      ),
    );

    // ✅ SYNCHRONISATION MANUELLE si nécessaire
    if (result > 0 && _groupProfileService != null) {
      final updatedProfile = await getProfileById(profileId);
      if (updatedProfile != null) {
        try {
          // Synchroniser uniquement dans les groupes où ce profil existe déjà
          await _groupProfileService!.syncProfileToAllGroups(updatedProfile);
          print('✅ Modifications du profil synchronisées dans les groupes');
        } catch (e) {
          print('⚠️ Erreur synchronisation: $e');
        }
      }
    }

    return result > 0;
  }

  /// Définit un profil comme actif (OBSOLÈTE - Gardé pour compatibilité)
  /// Note: La notion de "profil actif" n'est plus utilisée
  Future<void> setActiveProfile(int profileId) async {
    // Désactiver tous les profils
    await setAllProfilesInactive();

    // Activer le profil sélectionné
    await (update(db.userProfiles)..where((t) => t.id.equals(profileId)))
        .write(const UserProfilesCompanion(isActive: Value(true)));

    print('⚠️ setActiveProfile() est obsolète - tous les profils sont synchronisés automatiquement');
  }

  /// Désactive tous les profils
  Future<void> setAllProfilesInactive() async {
    await (update(db.userProfiles)..where((t) => t.isActive.equals(true)))
        .write(const UserProfilesCompanion(isActive: Value(false)));
  }

  /// Supprime un profil
  Future<bool> deleteProfile(int profileId) async {
    final result = await (delete(db.userProfiles)..where((t) => t.id.equals(profileId))).go();
    return result > 0;
  }

  /// Calcule le BMR (Basal Metabolic Rate) selon la formule Harris-Benedict
  double calculateBMR({
    required String sex,
    required int age,
    required double weightKg,
    required double heightCm,
  }) {
    if (sex == 'male') {
      return 88.362 + (13.397 * weightKg) + (4.799 * heightCm) - (5.677 * age);
    } else {
      return 447.593 + (9.247 * weightKg) + (3.098 * heightCm) - (4.330 * age);
    }
  }

  /// Calcule le TDEE (Total Daily Energy Expenditure)
  double calculateTDEE({
    required double bmr,
    required String activityLevel,
  }) {
    final activityFactors = {
      'sedentary': 1.2,
      'light': 1.375,
      'moderate': 1.55,
      'active': 1.725,
      'very_active': 1.9,
    };

    return bmr * (activityFactors[activityLevel] ?? 1.55);
  }

  /// Calcule le total des portions pour une liste d'IDs de profils
  Future<double> calculateTotalPortions(List<int> profileIds) async {
    if (profileIds.isEmpty) return 0.0;

    final profiles = await (select(db.userProfiles)
      ..where((t) => t.id.isIn(profileIds)))
        .get();

    double total = 0;
    for (final profile in profiles) {
      total += profile.eaterMultiplier;
    }
    return total;
  }

  /// Récupère les profils d'une liste d'IDs
  Future<List<UserProfile>> getProfilesByIds(List<int> profileIds) {
    if (profileIds.isEmpty) return Future.value([]);
    return (select(db.userProfiles)..where((t) => t.id.isIn(profileIds))).get();
  }
}