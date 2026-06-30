import 'equipe.dart';

class PompierPersonnel {
  const PompierPersonnel({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.equipe,
    this.grade = 'Sapeur',
    this.competences = const [],
  });

  final String id;
  final String nom;
  final String prenom;
  final Equipe equipe;
  final String grade;
  /// Compétences utiles pour l’armement.
  final List<String> competences;

  String get nomComplet => '$prenom $nom';
}
