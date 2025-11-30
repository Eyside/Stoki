// lib/repositories/planning_repository.dart
import 'package:drift/drift.dart';
import '../database.dart';

class PlanningRepository extends DatabaseAccessor<AppDatabase> {
  final AppDatabase db;
  PlanningRepository(this.db) : super(db);

  @override
  AppDatabase get attachedDatabase => db;

  Future<List<MealPlanningData>> getPlanningForDate(DateTime date) {
    return db.getPlanningForDate(date);
  }

  Future<int> addMealToPlanning({
    required DateTime date,
    required String mealType,
    required int recetteId,
    int servings = 1,
    int? userProfileId,
  }) {
    final companion = MealPlanningCompanion(
      date: Value(date),
      mealType: Value(mealType),
      recetteId: Value(recetteId),
      servings: Value(servings),
      userProfileId: Value(userProfileId),
    );
    return into(db.mealPlanning).insert(companion);
  }

  Future<int> deletePlanning(int id) {
    return (delete(db.mealPlanning)..where((t) => t.id.equals(id))).go();
  }
}