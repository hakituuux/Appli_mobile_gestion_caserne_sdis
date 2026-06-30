import '../models/disponibilite_type.dart';

/// true si deux plages se chevauchent (bords exclus).
bool disponibiliteRangesOverlap(DateTime debutA, DateTime finA, DateTime debutB, DateTime finB) {
  return debutA.isBefore(finB) && debutB.isBefore(finA);
}

String disponibiliteOverlapMessage(DisponibiliteType existingType) {
  return 'Ce créneau chevauche une disponibilité existante (${existingType.label}) pour ce personnel.';
}
