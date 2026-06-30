import 'disponibilite_type.dart';

/// Créneau perso saisi par le pompier.
class DisponibilitePerso {
  DisponibilitePerso({
    required this.id,
    required this.debut,
    required this.fin,
    required this.envoyerAuChef,
    this.type = DisponibiliteType.disponible,
  });

  final String id;
  DateTime debut;
  DateTime fin;
  bool envoyerAuChef;
  DisponibiliteType type;
}
