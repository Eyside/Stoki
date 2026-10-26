// lib/services/eater_resolver.dart
// Transforme la liste de convives d'un planning ("1,2,3") en profils avec
// leur coefficient. Aujourd'hui les profils sont locaux ; quand ils seront
// dans Firestore, seul ce fichier devra changer.

import '../repositories/user_profile_repository.dart';
import '../utils/portion_calculator.dart';

class EaterResolver {
  final UserProfileRepository _profileRepo;

  EaterResolver(this._profileRepo);

  /// Retourne un convive par identifiant. Un profil introuvable sur cet
  /// appareil (ex : repas planifié par un ami) est compté ×1 et marqué
  /// `known: false`.
  Future<List<EaterPortion>> resolve(String? eaters) async {
    final ids = PortionCalculator.parseEaterIds(eaters);
    final result = <EaterPortion>[];

    for (final id in ids) {
      final profile = await _profileRepo.getProfileById(id);
      if (profile == null) {
        result.add(EaterPortion(
          profileId: id,
          name: 'Convive inconnu',
          multiplier: PortionCalculator.defaultMultiplier,
          known: false,
        ));
      } else {
        result.add(EaterPortion(
          profileId: profile.id,
          name: profile.name,
          multiplier: profile.eaterMultiplier,
        ));
      }
    }
    return result;
  }
}
