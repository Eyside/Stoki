# Stoki

Application Flutter (Android et iOS) de gestion des recettes, du stock alimentaire
(frigo, placard), de la planification des repas, de la liste de courses et du suivi
calorique, pour soi et en groupe (amis, vacances).

## Fonctions

- **Recettes** : construites à partir d'ingrédients ; la nutrition est la somme des
  ingrédients. Banques privées et banques de groupe.
- **Stock** : privé ou de groupe, ajout manuel ou par scan de code-barres
  (Open Food Facts), transfert d'un stock à l'autre.
- **Planning** : repas privés ou de groupe, avec les convives. « Cuisiner » déduit du
  ou des stocks choisis ; « Consommer » ajoute sa part au suivi calorique.
- **Liste de courses** : planning moins stock, plus ajouts manuels.
- **Suivi calorique** : par jour, semaine et mois, selon le profil (BMR/TDEE) et le
  type de mangeur (petit 0,5 / moyen 1 / gros 1,5).
- **Groupes** : un compte = un profil ; les membres ne voient que le prénom et le
  coefficient des autres.

## Règle des portions

Une recette représente une personne « normale » (×1). Chaque convive reçoit la
recette multipliée par son coefficient, divisée par les portions de la recette.

## Technique

- Flutter, Riverpod, Firebase Auth et Firestore (cloud d'abord).
- Règles de sécurité : `firestore.rules` (à publier dans la console Firebase).
- La base locale Drift (`lib/database.dart`) est un héritage, en cours d'abandon.
- Tests : `flutter test` (règle des portions).

## Lancer

```
flutter pub get
flutter analyze
flutter test
flutter run
```

JDK 17 ou 21 requis pour Android (Gradle 8.14).
