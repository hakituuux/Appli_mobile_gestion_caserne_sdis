import '../models/app_user.dart';
import '../models/disponibilite_perso.dart';
import '../models/disponibilite_type.dart';
import '../models/equipe.dart';
import '../models/intervention.dart';
import '../models/pompier_personnel.dart';
import '../models/slot_equipe.dart';
import '../models/user_role.dart';
import '../models/vehicle.dart';

class ApiMappers {
  ApiMappers._();

  static UserRole roleFromApi(String? role) {
    switch (role) {
      case 'encadrement':
      case 'officier':
        return UserRole.chefDeGarde;
      case 'admin_si':
        return UserRole.admin;
      case 'operateur_poste':
      case 'personnel_limite':
      default:
        return UserRole.pompier;
    }
  }

  static Equipe equipeFromApi(String? value) {
    switch (value?.toUpperCase()) {
      case 'B':
        return Equipe.B;
      case 'C':
        return Equipe.C;
      default:
        return Equipe.A;
    }
  }

  static String equipeToApi(Equipe e) => e.name;

  static DisponibiliteType dispoTypeFromApi(String? value) {
    switch (value) {
      case 'sollicitable':
        return DisponibiliteType.sollicitable;
      case 'astreinte':
        return DisponibiliteType.astreinte;
      case 'garde':
      default:
        return DisponibiliteType.disponible;
    }
  }

  static String dispoTypeToApi(DisponibiliteType type) {
    switch (type) {
      case DisponibiliteType.sollicitable:
        return 'sollicitable';
      case DisponibiliteType.astreinte:
        return 'astreinte';
      case DisponibiliteType.disponible:
        return 'garde';
    }
  }

  static SlotEquipeStatut slotStatutFromApi(String? statut) {
    switch (statut) {
      case 'proposee':
        return SlotEquipeStatut.enAttenteValidation;
      case 'validee':
      case 'ajustee':
      default:
        return SlotEquipeStatut.valide;
    }
  }

  static String slotStatutToApi(SlotEquipeStatut statut) {
    switch (statut) {
      case SlotEquipeStatut.enAttenteValidation:
        return 'proposee';
      case SlotEquipeStatut.valide:
        return 'validee';
    }
  }

  static StatutIntervention interventionStatutFromApi(String? statut) {
    if (statut == 'en_cours') return StatutIntervention.enCours;
    return StatutIntervention.terminee;
  }

  static List<String> parseIdCsv(dynamic raw) {
    if (raw == null) return const [];
    final s = raw.toString().trim();
    if (s.isEmpty) return const [];
    return s.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }

  static DateTime parseDateTime(dynamic value) {
    if (value is DateTime) return value;
    return DateTime.parse(value.toString());
  }

  static AppUser userFromMeJson(Map<String, dynamic> json) {
    final personnel = json['personnel'] as Map<String, dynamic>?;
    final role = roleFromApi(json['role'] as String?);
    if (personnel != null) {
      final comps = personnel['competences'];
      return AppUser(
        id: personnel['id'].toString(),
        prenom: personnel['first_name'] as String? ?? '',
        nom: personnel['last_name'] as String? ?? '',
        role: role,
        email: json['email'] as String? ?? '',
        grade: personnel['grade'] as String? ?? '',
        equipe: equipeFromApi(personnel['equipe_garde'] as String?),
        competences: comps is List ? comps.map((e) => e.toString()).toList() : const [],
        accountUserId: json['id']?.toString(),
        personnelId: personnel['id']?.toString(),
        caserneName: personnel['caserne_name'] as String?,
        caserneId: personnel['caserne_id']?.toString(),
        caserneCode: personnel['caserne_code'] as String?,
      );
    }
    return AppUser(
      id: json['id'].toString(),
      prenom: 'Utilisateur',
      nom: 'SDIS',
      role: role,
      email: json['email'] as String? ?? '',
      accountUserId: json['id']?.toString(),
      personnelId: json['personnelId']?.toString(),
    );
  }

  static PompierPersonnel personnelFromJson(Map<String, dynamic> json) {
    final comps = json['competences'];
    return PompierPersonnel(
      id: json['id'].toString(),
      nom: json['last_name'] as String? ?? '',
      prenom: json['first_name'] as String? ?? '',
      equipe: equipeFromApi(json['equipe_garde'] as String?),
      grade: json['grade'] as String? ?? 'Sapeur',
      competences: comps is List ? comps.map((e) => e.toString()).toList() : const [],
    );
  }

  static Vehicle vehicleFromJson(Map<String, dynamic> json) {
    final comps = json['competences_requises'];
    final type = json['type'] as String? ?? '';
    final designation = json['designation'] as String? ?? '';
    final immat = json['immatriculation'] as String? ?? '';
    return Vehicle(
      id: json['id'].toString(),
      codification: designation.isNotEmpty ? designation : (type.isNotEmpty ? type : immat),
      fonction: json['marque_modele'] as String? ?? type,
      immatriculation: immat,
      competencesRequises:
          comps is List ? comps.map((e) => e.toString()).toList() : const [],
      equipageDots: 3,
    );
  }

  static Intervention interventionFromJson(Map<String, dynamic> json) {
    final lieuParts = [
      json['address_line'],
      json['city'],
    ].whereType<String>().where((s) => s.isNotEmpty);
    final resume = (json['contexte'] as String?)?.isNotEmpty == true
        ? json['contexte'] as String
        : (json['deroule'] as String? ?? '');
    return Intervention(
      id: json['id'].toString(),
      dateHeure: parseDateTime(json['started_at']),
      type: json['type_intervention'] as String? ?? 'Intervention',
      statut: interventionStatutFromApi(json['statut'] as String?),
      lieu: lieuParts.join(', '),
      resume: resume,
      personnelIds: parseIdCsv(json['personnel_ids']),
      vehiculeIds: parseIdCsv(json['vehicule_ids']),
    );
  }

  static DisponibilitePerso disponibiliteFromJson(Map<String, dynamic> json) {
    return DisponibilitePerso(
      id: json['id'].toString(),
      debut: parseDateTime(json['debut']),
      fin: parseDateTime(json['fin']),
      envoyerAuChef: json['statut'] == 'proposee',
      type: dispoTypeFromApi(json['type_dispo'] as String?),
    );
  }

  static SlotEquipe slotFromJson(Map<String, dynamic> json) {
    final prenom = json['first_name'] as String? ?? '';
    final nom = json['last_name'] as String? ?? '';
    return SlotEquipe(
      id: json['id'].toString(),
      personnelId: json['personnel_id'].toString(),
      personnelNom: '$prenom $nom'.trim(),
      equipe: equipeFromApi(json['equipe_garde'] as String?),
      debut: parseDateTime(json['debut']),
      fin: parseDateTime(json['fin']),
      type: dispoTypeFromApi(json['type_dispo'] as String?),
      statut: slotStatutFromApi(json['statut'] as String?),
      horsEquipe: json['hors_equipe'] == true || json['hors_equipe'] == 1,
      provenancePersonnel: json['statut'] == 'proposee' || json['statut'] == 'ajustee',
    );
  }

  static String formatDateTimeApi(DateTime dt) {
    final local = dt.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${local.year}-${two(local.month)}-${two(local.day)} '
        '${two(local.hour)}:${two(local.minute)}:${two(local.second)}';
  }
}
