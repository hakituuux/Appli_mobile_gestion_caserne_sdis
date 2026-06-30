import 'disponibilite_type.dart';
import 'equipe.dart';

/// Où en est le créneau côté planif équipe.
enum SlotEquipeStatut {
  /// Proposé, en attente chef.
  enAttenteValidation,
  /// Validé ou saisi chef.
  valide,
}

extension SlotEquipeStatutX on SlotEquipeStatut {
  String get label => switch (this) {
        SlotEquipeStatut.enAttenteValidation => 'En attente validation',
        SlotEquipeStatut.valide => 'Validé',
      };
}

/// Créneau vue équipe (semaine, filtre A/B/C).
class SlotEquipe {
  SlotEquipe({
    required this.id,
    required this.personnelId,
    required this.personnelNom,
    required this.equipe,
    required this.debut,
    required this.fin,
    required this.type,
    required this.statut,
    this.horsEquipe = false,
    this.provenancePersonnel = false,
  });

  final String id;
  final String personnelId;
  String personnelNom;
  final Equipe equipe;
  DateTime debut;
  DateTime fin;
  DisponibiliteType type;
  SlotEquipeStatut statut;
  /// Saisi à la main (renfort hors équipe).
  bool horsEquipe;
  /// Vient d’une demande pompier.
  bool provenancePersonnel;
}
