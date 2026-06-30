/// Rôle local (aligné sur l’API).
enum UserRole {
  pompier,
  chefDeGarde,
  admin,
}

extension UserRoleLabels on UserRole {
  String get label {
    switch (this) {
      case UserRole.pompier:
        return 'Pompier';
      case UserRole.chefDeGarde:
        return 'Chef de garde';
      case UserRole.admin:
        return 'Administrateur';
    }
  }

  /// Peut basculer planif équipe / perso.
  bool get peutPlanifierEquipe =>
      this == UserRole.chefDeGarde || this == UserRole.admin;
}
