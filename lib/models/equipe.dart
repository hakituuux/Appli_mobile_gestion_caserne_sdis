/// Équipe A / B / C.
enum Equipe {
  A,
  B,
  C,
}

extension EquipeX on Equipe {
  String get label => 'Équipe $name';
}
