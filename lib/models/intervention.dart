import 'pompier_personnel.dart';
import 'vehicle.dart';

enum StatutIntervention {
  enCours,
  terminee,
}

extension StatutInterventionX on StatutIntervention {
  String get label => this == StatutIntervention.enCours ? 'En cours' : 'Terminé';
}

/// Une intervention (mock ou API).
class Intervention {
  const Intervention({
    required this.id,
    required this.dateHeure,
    required this.type,
    required this.statut,
    required this.lieu,
    required this.resume,
    required this.personnelIds,
    required this.vehiculeIds,
  });

  final String id;
  final DateTime dateHeure;
  final String type;
  final StatutIntervention statut;
  final String lieu;
  final String resume;
  final List<String> personnelIds;
  final List<String> vehiculeIds;

  List<PompierPersonnel> personnelEngage(
    List<PompierPersonnel> registre,
  ) {
    return registre.where((p) => personnelIds.contains(p.id)).toList();
  }

  List<Vehicle> vehiculesEngages(List<Vehicle> registre) {
    return registre.where((v) => vehiculeIds.contains(v.id)).toList();
  }
}
