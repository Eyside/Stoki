// lib/models/app_profile.dart
// Profil unique d'un compte (stocké dans Firestore), profil partagé dans un
// groupe et entrée du suivi calorique.

import 'package:cloud_firestore/cloud_firestore.dart';

/// Profil complet d'un compte. Privé : seul le propriétaire le lit.
class AppProfile {
  final String uid;
  final String name;
  final String sex; // 'male' | 'female'
  final int age;
  final double heightCm;
  final double weightKg;
  final double eaterMultiplier; // 0.5 petit, 1 moyen, 1.5 gros
  final String activityLevel;
  final double bmr;
  final double tdee;

  const AppProfile({
    required this.uid,
    required this.name,
    required this.sex,
    required this.age,
    required this.heightCm,
    required this.weightKg,
    required this.eaterMultiplier,
    required this.activityLevel,
    required this.bmr,
    required this.tdee,
  });

  static const Map<String, double> activityFactors = {
    'sedentary': 1.2,
    'light': 1.375,
    'moderate': 1.55,
    'active': 1.725,
    'very_active': 1.9,
  };

  /// BMR (Harris-Benedict révisé).
  static double computeBmr({
    required String sex,
    required int age,
    required double heightCm,
    required double weightKg,
  }) {
    if (sex == 'male') {
      return 88.362 + (13.397 * weightKg) + (4.799 * heightCm) - (5.677 * age);
    }
    return 447.593 + (9.247 * weightKg) + (3.098 * heightCm) - (4.330 * age);
  }

  static double computeTdee(double bmr, String activityLevel) {
    return bmr * (activityFactors[activityLevel] ?? 1.55);
  }

  factory AppProfile.create({
    required String uid,
    required String name,
    required String sex,
    required int age,
    required double heightCm,
    required double weightKg,
    required double eaterMultiplier,
    required String activityLevel,
  }) {
    final bmr = computeBmr(
        sex: sex, age: age, heightCm: heightCm, weightKg: weightKg);
    return AppProfile(
      uid: uid,
      name: name,
      sex: sex,
      age: age,
      heightCm: heightCm,
      weightKg: weightKg,
      eaterMultiplier: eaterMultiplier,
      activityLevel: activityLevel,
      bmr: bmr,
      tdee: computeTdee(bmr, activityLevel),
    );
  }

  factory AppProfile.fromMap(String uid, Map<String, dynamic> data) {
    return AppProfile(
      uid: uid,
      name: (data['name'] ?? 'Moi') as String,
      sex: (data['sex'] ?? 'male') as String,
      age: ((data['age'] ?? 30) as num).toInt(),
      heightCm: ((data['heightCm'] ?? 170) as num).toDouble(),
      weightKg: ((data['weightKg'] ?? 70) as num).toDouble(),
      eaterMultiplier: ((data['eaterMultiplier'] ?? 1.0) as num).toDouble(),
      activityLevel: (data['activityLevel'] ?? 'moderate') as String,
      bmr: ((data['bmr'] ?? 1700) as num).toDouble(),
      tdee: ((data['tdee'] ?? 2000) as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'sex': sex,
        'age': age,
        'heightCm': heightCm,
        'weightKg': weightKg,
        'eaterMultiplier': eaterMultiplier,
        'activityLevel': activityLevel,
        'bmr': bmr,
        'tdee': tdee,
        'updatedAt': FieldValue.serverTimestamp(),
      };
}

/// Ce que les autres membres d'un groupe voient de vous : nom + coefficient.
class GroupMember {
  final String uid;
  final String name;
  final double eaterMultiplier;

  const GroupMember({
    required this.uid,
    required this.name,
    required this.eaterMultiplier,
  });

  factory GroupMember.fromMap(String uid, Map<String, dynamic> data) {
    return GroupMember(
      uid: uid,
      name: (data['name'] ?? 'Membre') as String,
      eaterMultiplier: ((data['eaterMultiplier'] ?? 1.0) as num).toDouble(),
    );
  }
}

/// Une ligne du suivi calorique (privée).
class CalorieEntry {
  final String id;
  final DateTime date;
  final String mealType;
  final double calories;
  final double proteins;
  final double fats;
  final double carbs;
  final double fibers;
  final String? planningId;
  final String? recipeName;

  const CalorieEntry({
    required this.id,
    required this.date,
    required this.mealType,
    required this.calories,
    this.proteins = 0,
    this.fats = 0,
    this.carbs = 0,
    this.fibers = 0,
    this.planningId,
    this.recipeName,
  });

  factory CalorieEntry.fromMap(String id, Map<String, dynamic> data) {
    double d(String k) => ((data[k] ?? 0) as num).toDouble();
    final ts = data['date'];
    return CalorieEntry(
      id: id,
      date: ts is Timestamp ? ts.toDate() : DateTime.now(),
      mealType: (data['mealType'] ?? 'dejeuner') as String,
      calories: d('calories'),
      proteins: d('proteins'),
      fats: d('fats'),
      carbs: d('carbs'),
      fibers: d('fibers'),
      planningId: data['planningId'] as String?,
      recipeName: data['recipeName'] as String?,
    );
  }
}
