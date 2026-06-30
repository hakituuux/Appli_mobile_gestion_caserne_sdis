import '../models/app_user.dart';
import '../models/disponibilite_perso.dart';
import '../models/disponibilite_type.dart';
import '../models/equipe.dart';
import '../models/intervention.dart';
import '../models/pompier_personnel.dart';
import '../models/slot_equipe.dart';
import '../models/user_role.dart';
import '../models/vehicle.dart';

/// Jeu de données mock (remplacé par l’API si useMockData = false).
class MockData {
  MockData._();

  /// Compétences communes perso / véhicules.
  static const conducteurVsav = 'Conducteur VSAV';
  static const conducteurFpt = 'Conducteur FPT';
  static const chefAgresSap = 'Chef d\'agrès SAP';
  static const chefAgresInc = 'Chef d\'agrès INC';
  static const equipierSap = 'Équipier SAP';
  static const equipierInc = 'Équipier INC';
  static const permisB = 'Permis B';
  static const permisPl = 'Permis PL';
  static const equipierEpa = 'Équipier échelle';
  static const equipierVsr = 'Équipier secours routier';
  static const operateurRadio = 'Opérateur Radio';

  static AppUser utilisateurDemo() => AppUser(
        id: 'u1',
        prenom: 'Pierre',
        nom: 'Durand',
        role: UserRole.chefDeGarde,
        email: 'pierre.durand@sdis34.fr',
        grade: 'Adjudant',
        equipe: Equipe.A,
        competences: const [
          chefAgresSap,
          chefAgresInc,
          permisB,
          permisPl,
          conducteurVsav,
          conducteurFpt,
          operateurRadio,
        ],
      );

  static const int effectifTheorique = 22;

  static List<PompierPersonnel> personnel = [
    PompierPersonnel(
      id: 'u1',
      nom: 'Durand',
      prenom: 'Pierre',
      equipe: Equipe.A,
      grade: 'Adjudant',
      competences: const [
        chefAgresSap,
        chefAgresInc,
        permisB,
        permisPl,
        conducteurVsav,
        conducteurFpt,
        operateurRadio,
      ],
    ),
    const PompierPersonnel(
      id: 'p1',
      nom: 'Dupont',
      prenom: 'Jean',
      equipe: Equipe.A,
      grade: 'Caporal',
      competences: [equipierSap, permisB, equipierInc],
    ),
    const PompierPersonnel(
      id: 'p2',
      nom: 'Martin',
      prenom: 'Marie',
      equipe: Equipe.A,
      grade: 'Sergent',
      competences: [chefAgresSap, permisB, permisPl, conducteurFpt],
    ),
    const PompierPersonnel(
      id: 'p3',
      nom: 'Bernard',
      prenom: 'Julien',
      equipe: Equipe.A,
      grade: 'Caporal',
      competences: [equipierSap, permisB],
    ),
    const PompierPersonnel(
      id: 'p4',
      nom: 'Garcia',
      prenom: 'Nadia',
      equipe: Equipe.B,
      grade: 'Sergent',
      competences: [equipierInc, permisB, conducteurFpt],
    ),
    const PompierPersonnel(
      id: 'p5',
      nom: 'Petit',
      prenom: 'Marc',
      equipe: Equipe.B,
      grade: 'Sergent-Chef',
      competences: [chefAgresSap, permisPl, equipierEpa],
    ),
    const PompierPersonnel(
      id: 'p6',
      nom: 'Lopez',
      prenom: 'Sarah',
      equipe: Equipe.B,
      grade: 'Lieutenant',
      competences: [chefAgresSap, chefAgresInc, permisB, conducteurVsav],
    ),
    const PompierPersonnel(
      id: 'p7',
      nom: 'Moreau',
      prenom: 'Lucas',
      equipe: Equipe.C,
      grade: 'Sapeur',
      competences: [equipierInc, permisB, equipierVsr],
    ),
    const PompierPersonnel(
      id: 'p8',
      nom: 'Blanc',
      prenom: 'Émilie',
      equipe: Equipe.C,
      grade: 'Adjudant-Chef',
      competences: [chefAgresSap, permisB, conducteurFpt],
    ),
    const PompierPersonnel(
      id: 'p9',
      nom: 'Richard',
      prenom: 'Thomas',
      equipe: Equipe.C,
      grade: 'Sergent-Chef',
      competences: [chefAgresSap, permisPl, equipierEpa],
    ),
  ];

  static List<Vehicle> vehicules = [
    const Vehicle(
      id: 'v1',
      codification: 'VSAV 001',
      fonction: 'Secours à personne',
      immatriculation: 'BT-341-AB',
      equipageDots: 3,
      competencesRequises: [conducteurVsav, equipierSap, permisB],
    ),
    const Vehicle(
      id: 'v2',
      codification: 'VSAV 002',
      fonction: 'Secours à personne',
      immatriculation: 'BT-342-CD',
      equipageDots: 3,
      competencesRequises: [conducteurVsav, equipierSap, permisB],
    ),
    const Vehicle(
      id: 'v3',
      codification: 'FPT 001',
      fonction: 'Incendie',
      immatriculation: 'BT-343-EF',
      equipageDots: 4,
      competencesRequises: [conducteurFpt, chefAgresInc, equipierInc],
    ),
    const Vehicle(
      id: 'v4',
      codification: 'FPT 002',
      fonction: 'Incendie',
      immatriculation: 'BT-344-GH',
      equipageDots: 4,
      competencesRequises: [conducteurFpt, chefAgresInc, equipierInc],
    ),
    const Vehicle(
      id: 'v5',
      codification: 'EPA 001',
      fonction: 'Échelle 30 m',
      immatriculation: 'BT-345-IJ',
      equipageDots: 3,
      competencesRequises: [permisPl, equipierEpa, chefAgresSap],
    ),
    const Vehicle(
      id: 'v6',
      codification: 'VSR 001',
      fonction: 'Secours routier',
      immatriculation: 'BT-346-KL',
      equipageDots: 3,
      competencesRequises: [equipierVsr, permisB, chefAgresSap],
    ),
    const Vehicle(
      id: 'v7',
      codification: 'VLHR 001',
      fonction: 'Renault Master',
      immatriculation: 'BT-347-MN',
      equipageDots: 2,
      competencesRequises: [permisB],
    ),
    const Vehicle(
      id: 'v8',
      codification: 'CCFM 001',
      fonction: 'Iveco Daily',
      immatriculation: 'BT-348-OP',
      equipageDots: 3,
      competencesRequises: [conducteurFpt, equipierInc],
    ),
  ];

  static List<Intervention> interventionsInitiales() {
    final now = DateTime.now();
    return [
      Intervention(
        id: 'i1',
        dateHeure: now.subtract(const Duration(hours: 1)),
        type: 'Incendie',
        statut: StatutIntervention.enCours,
        lieu: '12 Allées Paul Riquet, Béziers',
        resume: 'Feu de cave, extinction en cours.',
        personnelIds: ['p1', 'p2', 'p4'],
        vehiculeIds: ['v3', 'v1'],
      ),
      Intervention(
        id: 'i2',
        dateHeure: now.subtract(const Duration(minutes: 40)),
        type: 'Secours à personne',
        statut: StatutIntervention.enCours,
        lieu: '45 Avenue Jean Moulin, Béziers',
        resume: 'AVP, victime prise en charge.',
        personnelIds: ['p3', 'p5'],
        vehiculeIds: ['v1'],
      ),
      Intervention(
        id: 'i3',
        dateHeure: () {
          final d = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1));
          return DateTime(d.year, d.month, d.day, 10, 15);
        }(),
        type: 'Accident de la route',
        statut: StatutIntervention.terminee,
        lieu: 'RD 612, Sortie Béziers Ouest',
        resume: 'Désincarcération, transfert CH.',
        personnelIds: ['p6', 'p7', 'p8'],
        vehiculeIds: ['v6'],
      ),
      Intervention(
        id: 'i4',
        dateHeure: () {
          final d = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1));
          return DateTime(d.year, d.month, d.day, 8);
        }(),
        type: 'Fuite de gaz',
        statut: StatutIntervention.terminee,
        lieu: '78 Boulevard de Genève, Béziers',
        resume: 'Colmatage, ventilation.',
        personnelIds: ['p4', 'p5', 'p6', 'p9'],
        vehiculeIds: ['v3', 'v4'],
      ),
      Intervention(
        id: 'i5',
        dateHeure: () {
          final d = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 2));
          return DateTime(d.year, d.month, d.day, 22, 30);
        }(),
        type: 'Incendie',
        statut: StatutIntervention.terminee,
        lieu: 'Zone Industrielle La Domitienne, Béziers',
        resume: 'Incendie de stockage maîtrisé.',
        personnelIds: ['p1', 'p2', 'p3', 'p4', 'p8', 'p9'],
        vehiculeIds: ['v3', 'v4', 'v5'],
      ),
    ];
  }

  static List<DisponibilitePerso> mesDisponibilitesInitiales() {
    final now = DateTime.now();
    return [
      DisponibilitePerso(
        id: 'd1',
        debut: now.add(const Duration(days: 1, hours: 8)),
        fin: now.add(const Duration(days: 1, hours: 18)),
        envoyerAuChef: true,
        type: DisponibiliteType.sollicitable,
      ),
      DisponibilitePerso(
        id: 'd2',
        debut: now.add(const Duration(days: 3, hours: 7)),
        fin: now.add(const Duration(days: 3, hours: 19)),
        envoyerAuChef: false,
        type: DisponibiliteType.astreinte,
      ),
    ];
  }

  static List<SlotEquipe> slotsEquipeInitiaux() {
    final now = DateTime.now();
    final startWeek = _startOfWeek(now);
    return [
      SlotEquipe(
        id: 's1',
        personnelId: 'p1',
        personnelNom: 'Jean Dupont',
        equipe: Equipe.A,
        debut: startWeek.add(const Duration(days: 1, hours: 8)),
        fin: startWeek.add(const Duration(days: 1, hours: 14)),
        type: DisponibiliteType.sollicitable,
        statut: SlotEquipeStatut.enAttenteValidation,
        provenancePersonnel: true,
      ),
      SlotEquipe(
        id: 's2',
        personnelId: 'p2',
        personnelNom: 'Marie Martin',
        equipe: Equipe.A,
        debut: startWeek.add(const Duration(days: 2, hours: 18)),
        fin: startWeek.add(const Duration(days: 2, hours: 23)),
        type: DisponibiliteType.astreinte,
        statut: SlotEquipeStatut.enAttenteValidation,
        provenancePersonnel: true,
      ),
      SlotEquipe(
        id: 's3',
        personnelId: 'p4',
        personnelNom: 'Nadia Garcia',
        equipe: Equipe.B,
        debut: startWeek.add(const Duration(days: 3, hours: 8)),
        fin: startWeek.add(const Duration(days: 3, hours: 20)),
        type: DisponibiliteType.disponible,
        statut: SlotEquipeStatut.valide,
        provenancePersonnel: false,
      ),
    ];
  }

  static DateTime _startOfWeek(DateTime d) {
    final day = DateTime(d.year, d.month, d.day);
    return day.subtract(Duration(days: day.weekday - 1));
  }
}
