import 'pompier_personnel.dart';

/// Pompier sur intervention : pas dispo pour autre chose.
class PersonnelEnIntervention {
  const PersonnelEnIntervention({
    required this.personnel,
    required this.interventionId,
    required this.interventionNumero,
    required this.typeIntervention,
    required this.lieu,
    this.fonctionSurIntervention,
    this.typeDispoDeclare,
  });

  final PompierPersonnel personnel;
  final String interventionId;
  final String interventionNumero;
  final String typeIntervention;
  final String lieu;
  final String? fonctionSurIntervention;
  /// Dispo déclarée en parallèle (garde…), si connue.
  final String? typeDispoDeclare;
}
