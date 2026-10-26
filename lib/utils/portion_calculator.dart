// lib/utils/portion_calculator.dart
// Règle unique de calcul des portions de Stoki :
//
//   Une recette représente UNE personne « normale » (coefficient 1).
//   Chaque convive reçoit la recette multipliée par son coefficient :
//   petit mangeur = 0,5 / moyen = 1 / gros mangeur = 1,5.
//
//   Si la recette est prévue pour plusieurs personnes (champ « Portions »),
//   la part d'un convive est : coefficient ÷ portions.

/// Un convive d'un repas, avec son coefficient d'appétit.
class EaterPortion {
  /// Identifiant du profil (local pour l'instant). Null si inconnu.
  final int? profileId;
  final String name;

  /// 0.5 (petit) / 1.0 (moyen) / 1.5 (gros)
  final double multiplier;

  /// false si le profil n'a pas été retrouvé sur cet appareil.
  final bool known;

  const EaterPortion({
    required this.profileId,
    required this.name,
    required this.multiplier,
    this.known = true,
  });
}

class PortionCalculator {
  /// Coefficient par défaut quand aucun convive n'est renseigné ou connu.
  static const double defaultMultiplier = 1.0;

  /// Part d'UN convive par rapport à la recette de base.
  static double eaterFactor({
    required double multiplier,
    required int recipeServings,
  }) {
    final servings = recipeServings <= 0 ? 1 : recipeServings;
    final m = multiplier > 0 ? multiplier : defaultMultiplier;
    return m / servings;
  }

  /// Part TOTALE d'un repas (somme des parts de tous les convives).
  /// Sans convive : une personne normale (×1).
  static double mealFactor({
    required Iterable<double> multipliers,
    required int recipeServings,
  }) {
    final list = multipliers.toList();
    if (list.isEmpty) {
      return eaterFactor(
        multiplier: defaultMultiplier,
        recipeServings: recipeServings,
      );
    }
    var total = 0.0;
    for (final m in list) {
      total += eaterFactor(multiplier: m, recipeServings: recipeServings);
    }
    return total;
  }

  /// Lit la liste d'identifiants de convives enregistrée dans le planning.
  /// Accepte "1,2,3" (format actuel) et "[1,2,3]" (ancien format JSON).
  static List<int> parseEaterIds(String? eaters) {
    if (eaters == null) return [];
    final cleaned = eaters.replaceAll('[', '').replaceAll(']', '').trim();
    if (cleaned.isEmpty) return [];
    final ids = <int>[];
    for (final part in cleaned.split(',')) {
      final id = int.tryParse(part.trim());
      if (id != null) ids.add(id);
    }
    return ids;
  }
}
