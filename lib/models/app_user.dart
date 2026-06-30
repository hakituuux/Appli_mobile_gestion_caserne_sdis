import 'equipe.dart';
import 'user_role.dart';

class AppUser {
  const AppUser({
    required this.id,
    required this.prenom,
    required this.nom,
    required this.role,
    this.email = '',
    this.grade = '',
    this.equipe = Equipe.A,
    this.competences = const [],
    this.accountUserId,
    this.personnelId,
    this.caserneName,
    this.caserneId,
    this.caserneCode,
  });

  /// Id métier (souvent personnel_id API).
  final String id;
  final String prenom;
  final String nom;
  final UserRole role;
  final String email;
  final String grade;
  final Equipe equipe;
  final List<String> competences;
  /// Id compte users (JWT).
  final String? accountUserId;
  final String? personnelId;
  final String? caserneName;
  final String? caserneId;
  final String? caserneCode;

  String get nomComplet => '$prenom $nom';

  AppUser copyWith({
    String? id,
    String? prenom,
    String? nom,
    UserRole? role,
    String? email,
    String? grade,
    Equipe? equipe,
    List<String>? competences,
    String? accountUserId,
    String? personnelId,
    String? caserneName,
    String? caserneId,
    String? caserneCode,
  }) {
    return AppUser(
      id: id ?? this.id,
      prenom: prenom ?? this.prenom,
      nom: nom ?? this.nom,
      role: role ?? this.role,
      email: email ?? this.email,
      grade: grade ?? this.grade,
      equipe: equipe ?? this.equipe,
      competences: competences ?? this.competences,
      accountUserId: accountUserId ?? this.accountUserId,
      personnelId: personnelId ?? this.personnelId,
      caserneName: caserneName ?? this.caserneName,
      caserneId: caserneId ?? this.caserneId,
      caserneCode: caserneCode ?? this.caserneCode,
    );
  }
}
