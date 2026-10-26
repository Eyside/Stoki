import 'package:flutter_test/flutter_test.dart';
import 'package:stoki/utils/portion_calculator.dart';

void main() {
  group('PortionCalculator', () {
    test('un petit mangeur reçoit la moitié de la recette', () {
      final f = PortionCalculator.eaterFactor(multiplier: 0.5, recipeServings: 1);
      expect(f * 1000, 500); // recette de 1000 kcal -> 500 kcal
    });

    test('un gros mangeur reçoit 1,5 fois la recette', () {
      final f = PortionCalculator.eaterFactor(multiplier: 1.5, recipeServings: 1);
      expect(f * 1000, 1500);
    });

    test('recette prévue pour 4 personnes : part divisée par 4', () {
      final f = PortionCalculator.eaterFactor(multiplier: 1.0, recipeServings: 4);
      expect(f * 2000, 500);
    });

    test('portions invalides (0 ou négatif) traitées comme 1', () {
      expect(PortionCalculator.eaterFactor(multiplier: 1.0, recipeServings: 0), 1.0);
      expect(PortionCalculator.eaterFactor(multiplier: 1.0, recipeServings: -2), 1.0);
    });

    test('coefficient invalide traité comme 1', () {
      expect(PortionCalculator.eaterFactor(multiplier: 0, recipeServings: 1), 1.0);
    });

    test('repas pour un petit et un gros mangeur = 2 parts', () {
      final f = PortionCalculator.mealFactor(multipliers: [0.5, 1.5], recipeServings: 1);
      expect(f, 2.0);
    });

    test('sans convive : une personne normale', () {
      expect(PortionCalculator.mealFactor(multipliers: [], recipeServings: 1), 1.0);
    });

    test('lecture des convives', () {
      expect(PortionCalculator.parseEaterIds('1,2,3'), [1, 2, 3]);
      expect(PortionCalculator.parseEaterIds('[1, 2]'), [1, 2]);
      expect(PortionCalculator.parseEaterIds(''), isEmpty);
      expect(PortionCalculator.parseEaterIds(null), isEmpty);
      expect(PortionCalculator.parseEaterIds('a,2'), [2]);
    });
  });
}
