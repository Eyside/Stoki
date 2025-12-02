// lib/repositories/planning_repository.dart
import 'package:drift/drift.dart';
import '../database.dart';

class PlanningRepository extends DatabaseAccessor<AppDatabase> {
  final AppDatabase db;
  PlanningRepository(this.db) : super(db);

  @override
  AppDatabase get attachedDatabase => db;

  /// Récupère le planning pour une date donnée
  Future<List<MealPlanningData>> getPlanningForDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return (select(db.mealPlanning)
      ..where((p) => p.date.isBiggerOrEqualValue(startOfDay))
      ..where((p) => p.date.isSmallerThanValue(endOfDay))
      ..orderBy([(p) => OrderingTerm.asc(p.date)])
    ).get();
  }

  /// Récupère le planning pour une plage de dates
  Future<List<MealPlanningData>> getPlanningForDateRange(
      DateTime startDate,
      DateTime endDate,
      ) {
    return (select(db.mealPlanning)
      ..where((p) => p.date.isBiggerOrEqualValue(startDate))
      ..where((p) => p.date.isSmallerOrEqualValue(endDate))
      ..orderBy([(p) => OrderingTerm.asc(p.date)])
    ).get();
  }

  /// Ajoute un repas au planning
  Future<int> addMealToPlanning({
    required DateTime date,
    required String mealType,
    required int recetteId,
    int servings = 1,
    String? eaters,
  }) async {
    final companion = MealPlanningCompanion(
      date: Value(date),
      mealType: Value(mealType),
      recetteId: Value(recetteId),
      servings: Value(servings),
      eaters: Value(eaters),
      createdAt: Value(DateTime.now()),
    );

    return into(db.mealPlanning).insert(companion);
  }

  /// Met à jour un repas du planning
  Future<bool> updatePlanning(
      int planningId, {
        DateTime? date,
        String? mealType,
        int? recetteId,
        int? servings,
        String? eaters,
        String? notes,
      }) async {
    final result = await (update(db.mealPlanning)..where((p) => p.id.equals(planningId)))
        .write(
      MealPlanningCompanion(
        date: date != null ? Value(date) : const Value.absent(),
        mealType: mealType != null ? Value(mealType) : const Value.absent(),
        recetteId: recetteId != null ? Value(recetteId) : const Value.absent(),
        servings: servings != null ? Value(servings) : const Value.absent(),
        eaters: eaters != null ? Value(eaters) : const Value.absent(),
        notes: notes != null ? Value(notes) : const Value.absent(),
      ),
    );

    return result > 0;
  }

  /// Supprime un repas du planning
  Future<bool> deletePlanning(int planningId) async {
    final result = await (delete(db.mealPlanning)..where((p) => p.id.equals(planningId))).go();
    return result > 0;
  }

  /// Récupère un planning par ID
  Future<MealPlanningData?> getPlanningById(int id) {
    return (select(db.mealPlanning)..where((p) => p.id.equals(id))).getSingleOrNull();
  }

  /// Récupère tous les repas planifiés d'une recette
  Future<List<MealPlanningData>> getPlanningByRecetteId(int recetteId) {
    return (select(db.mealPlanning)
      ..where((p) => p.recetteId.equals(recetteId))
      ..orderBy([(p) => OrderingTerm.desc(p.date)])
    ).get();
  }

  /// Récupère le planning d'un utilisateur spécifique
  Future<List<MealPlanningData>> getPlanningByUserProfile(int userProfileId) {
    return (select(db.mealPlanning)
      ..where((p) => p.userProfileId.equals(userProfileId))
      ..orderBy([(p) => OrderingTerm.desc(p.date)])
    ).get();
  }

  /// Récupère le planning d'un groupe
  Future<List<MealPlanningData>> getPlanningByGroup(int groupId) {
    return (select(db.mealPlanning)
      ..where((p) => p.groupId.equals(groupId))
      ..orderBy([(p) => OrderingTerm.desc(p.date)])
    ).get();
  }

  /// Compte le nombre de repas planifiés pour une date
  Future<int> countMealsForDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final query = selectOnly(db.mealPlanning)
      ..addColumns([db.mealPlanning.id.count()])
      ..where(db.mealPlanning.date.isBiggerOrEqualValue(startOfDay))
      ..where(db.mealPlanning.date.isSmallerThanValue(endOfDay));

    final result = await query.getSingle();
    return result.read(db.mealPlanning.id.count()) ?? 0;
  }

  /// Copie le planning d'un jour vers un autre jour
  Future<void> copyDayPlanning(DateTime sourceDate, DateTime targetDate) async {
    final sourcePlannings = await getPlanningForDate(sourceDate);

    for (final planning in sourcePlannings) {
      await addMealToPlanning(
        date: DateTime(
          targetDate.year,
          targetDate.month,
          targetDate.day,
          planning.date.hour,
          planning.date.minute,
        ),
        mealType: planning.mealType,
        recetteId: planning.recetteId ?? 0,
        servings: planning.servings,
        eaters: planning.eaters,
      );
    }
  }

  /// Supprime tous les repas d'une date
  Future<int> clearDayPlanning(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return await (delete(db.mealPlanning)
      ..where((p) => p.date.isBiggerOrEqualValue(startOfDay))
      ..where((p) => p.date.isSmallerThanValue(endOfDay))
    ).go();
  }
}