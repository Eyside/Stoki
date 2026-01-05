// lib/repositories/calorie_tracking_repository.dart
import 'package:drift/drift.dart';
import '../database.dart';

class CalorieTrackingRepository extends DatabaseAccessor<AppDatabase> {
  final AppDatabase db;
  CalorieTrackingRepository(this.db) : super(db);

  @override
  AppDatabase get attachedDatabase => db;

  Future<List<CalorieTrackingData>> getTrackingForDateRange(
      int userProfileId,
      DateTime startDate,
      DateTime endDate,
      ) {
    return db.getCalorieTrackingForDateRange(userProfileId, startDate, endDate);
  }

  Future<int> addTracking({
    required int userProfileId,
    required DateTime date,
    required String mealType,
    required double calories,
    double proteins = 0.0,
    double fats = 0.0,
    double carbs = 0.0,
    double fibers = 0.0,
    int? mealPlanningId,
  }) {
    final companion = CalorieTrackingCompanion(
      userProfileId: Value(userProfileId),
      date: Value(date),
      mealType: Value(mealType),
      calories: Value(calories),
      proteins: Value(proteins),
      fats: Value(fats),
      carbs: Value(carbs),
      fibers: Value(fibers),
      mealPlanningId: Value(mealPlanningId),
    );
    return into(db.calorieTracking).insert(companion);
  }
}