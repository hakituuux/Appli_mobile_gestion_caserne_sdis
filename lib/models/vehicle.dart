class Vehicle {
  const Vehicle({
    required this.id,
    required this.codification,
    required this.fonction,
    required this.immatriculation,
    required this.competencesRequises,
    this.equipageDots = 3,
  });

  final String id;
  /// Libellé affiché (ex. VSAV 1).
  final String codification;
  final String fonction;
  final String immatriculation;
  /// Nb de compétences requises pour armer l’engin.
  final List<String> competencesRequises;
  final int equipageDots;

  /// Alias rétro sur l’ancien champ type.
  String get type => codification;
}
