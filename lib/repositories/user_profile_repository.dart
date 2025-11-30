// lib/repositories/user_profile_repository.dart
import 'package:drift/drift.dart';
import '../database.dart';

class UserProfileRepository extends DatabaseAccessor<AppDatabase> {
  final AppDatabase db;
  UserProfileRepository(this.db) : super(db);

  @override
  AppDatabase get attachedDatabase => db;

  Future<List<UserProfile>> getAllProfiles() {
    return select(db.userProfiles).get();
  }

  Future<UserProfile?> getActiveProfile() {
    return db.getActiveProfile();
  }

  Future<int> createProfile({
    required String name,
    required String sex,
    required int age,
    required double heightCm,
    required double weightKg,
    double eaterMultiplier = 1.0,
    String activityLevel = 'moderate',
  }) {
    final companion = UserProfilesCompanion(
      name: Value(name),
      userId: Value(DateTime.now().millisecondsSinceEpoch.toString()),
      sex: Value(sex),
      age: Value(age),
      heightCm: Value(heightCm),
      weightKg: Value(weightKg),
      eaterMultiplier: Value(eaterMultiplier),
      activityLevel: Value(activityLevel),
      isActive: const Value(true),
    );
    return into(db.userProfiles).insert(companion);
  }
}