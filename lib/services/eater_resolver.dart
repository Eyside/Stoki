// lib/services/eater_resolver.dart
// Transforme la liste de convives d'un planning ("uidA,uidB") en convives
// avec leur coefficient.
//  - Planning sans convive : seul le propriétaire du planning mange.
//  - Moi : mon profil complet.
//  - Un autre membre : son profil de groupe (nom + coefficient).
//  - Introuvable (membre sans profil, parti du groupe) : ×1, known = false.

import '../models/app_profile.dart';
import '../utils/portion_calculator.dart';
import 'profile_firestore_service.dart';

class EaterResolver {
  final ProfileFirestoreService _profiles;

  EaterResolver(this._profiles);

  Future<List<EaterPortion>> resolve(
    String? eaters, {
    required String ownerId,
    String? groupId,
  }) async {
    var uids = PortionCalculator.parseEaterUids(eaters);
    if (uids.isEmpty) uids = [ownerId];

    final myUid = _profiles.currentUid;
    AppProfile? me;
    var meLoaded = false;
    Map<String, GroupMember>? members;

    final result = <EaterPortion>[];
    for (final uid in uids) {
      if (uid == myUid) {
        if (!meLoaded) {
          me = await _profiles.getMyProfile();
          meLoaded = true;
        }
        if (me != null) {
          result.add(EaterPortion(
            uid: uid,
            name: me.name,
            multiplier: me.eaterMultiplier,
          ));
          continue;
        }
      }

      if (groupId != null) {
        members ??= {
          for (final m in await _profiles.getGroupMembers(groupId)) m.uid: m
        };
        final member = members[uid];
        if (member != null) {
          result.add(EaterPortion(
            uid: uid,
            name: member.name,
            multiplier: member.eaterMultiplier,
          ));
          continue;
        }
      }

      result.add(EaterPortion(
        uid: uid,
        name: 'Convive sans profil',
        multiplier: PortionCalculator.defaultMultiplier,
        known: false,
      ));
    }
    return result;
  }
}
