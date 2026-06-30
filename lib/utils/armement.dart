import '../models/pompier_personnel.dart';
import '../models/vehicle.dart';

/// Taux d’armement : compétences du personnel vs exigences des engins au parc.

Set<String> poolCompetences(Iterable<PompierPersonnel> personnel) {
  final s = <String>{};
  for (final p in personnel) {
    s.addAll(p.competences);
  }
  return s;
}

/// Couverture d’un engin (0 à 1).
double tauxCouvertureVehicule(Vehicle v, Set<String> competencesDisponibles) {
  final reqs = v.competencesRequises;
  if (reqs.isEmpty) return 1;
  var ok = 0;
  for (final r in reqs) {
    if (competencesDisponibles.contains(r)) ok++;
  }
  return ok / reqs.length;
}

/// % global sur tout le parc disponible.
int pourcentageArmementCaserne(
  Iterable<PompierPersonnel> personnel,
  Iterable<Vehicle> vehiculesAuParc,
) {
  final pool = poolCompetences(personnel);
  var total = 0;
  var ok = 0;
  for (final v in vehiculesAuParc) {
    for (final r in v.competencesRequises) {
      total++;
      if (pool.contains(r)) ok++;
    }
  }
  if (total == 0) return 100;
  return ((ok / total) * 100).round();
}

/// Engins qu’on peut au moins partiellement armer.
List<Vehicle> vehiculesAvecContribution(PompierPersonnel p, Iterable<Vehicle> vehicules) {
  final set = p.competences.toSet();
  return vehicules
      .where((v) => v.competencesRequises.any((c) => set.contains(c)))
      .toList();
}
