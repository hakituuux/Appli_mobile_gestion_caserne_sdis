enum DisponibiliteType {
  disponible,
  sollicitable,
  astreinte,
}

extension DisponibiliteTypeX on DisponibiliteType {
  String get label => switch (this) {
        DisponibiliteType.disponible => 'Disponible',
        DisponibiliteType.sollicitable => 'Sollicitable',
        DisponibiliteType.astreinte => 'Astreinte',
      };
}
