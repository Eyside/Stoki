// lib/repositories/frigo_repository.dart
import 'package:drift/drift.dart';
import '../database.dart';

class FrigoRepository extends DatabaseAccessor<AppDatabase> {
  final AppDatabase db;
  FrigoRepository(this.db) : super(db);

  Future<int> addToFrigo({
    required int ingredientId,
    required double quantity,
    required String unit,
    DateTime? bestBefore,
    String? location,
  }) {
    final companion = FrigoCompanion(
      ingredientId: Value(ingredientId),
      quantity: Value(quantity),
      unit: Value(unit),
      bestBefore: Value(bestBefore),
      location: Value(location ?? 'frigo'),
    );
    return into(db.frigo).insert(companion);
  }

  Future<List<FrigoData>> getAllFrigo() => db.getAllFrigo();

  Future<List<Map<String, dynamic>>> getAllFrigoWithIngredients() async {
    final query = select(db.frigo).join([
      leftOuterJoin(db.ingredients, db.ingredients.id.equalsExp(db.frigo.ingredientId)),
    ]);
    final rows = await query.get();
    return rows.map((row) {
      final f = row.readTable(db.frigo);
      final ing = row.readTableOrNull(db.ingredients);
      return {'frigo': f, 'ingredient': ing};
    }).toList();
  }

  Future<int> updateFrigoQuantity({
    required int id,
    required double quantity,
  }) {
    return (update(db.frigo)..where((t) => t.id.equals(id)))
        .write(FrigoCompanion(quantity: Value(quantity)));
  }

  Future<int> deleteFrigoItem(int id) =>
      (delete(db.frigo)..where((t) => t.id.equals(id))).go();
}