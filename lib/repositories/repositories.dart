// ignore_for_file: unused_field

import 'dart:async';

import '../auth/auth_session.dart';
import '../data/mock_data.dart';
import '../models/disponibilite_perso.dart';
import '../models/disponibilite_type.dart';
import '../models/equipe.dart';
import '../models/intervention.dart';
import '../models/pompier_personnel.dart';
import '../models/slot_equipe.dart';
import '../models/user_role.dart';
import '../models/vehicle.dart';
import '../utils/disponibilite_overlap.dart';

// --- Contrats (interfaces) ---

abstract interface class AuthRepository {
  Future<AuthSession> signIn({String? email, String? password});

  Future<void> signOut();
}

enum InterventionEventType { created, updated, deleted }

class InterventionEvent {
  const InterventionEvent({required this.type, required this.intervention});
  final InterventionEventType type;
  final Intervention intervention;
}

abstract interface class InterventionsRepository {
  Future<List<Intervention>> fetchAll({required String accessToken, int? caserneId});

  /// Flux interventions (Socket.IO côté Node, à terme).
  Stream<InterventionEvent> watch({required String accessToken});

  /// Créer une intervention (démo / admin).
  Future<Intervention> create({
    required String accessToken,
    required String type,
    required String lieu,
    required String resume,
  });
}

abstract interface class CatalogRepository {
  Future<List<PompierPersonnel>> fetchPersonnel({required String accessToken, int? caserneId});
  Future<List<Vehicle>> fetchVehicules({required String accessToken, int? caserneId});
}

abstract interface class PlanningRepository {
  Future<List<DisponibilitePerso>> fetchMesDisponibilites({required String accessToken});
  Future<List<SlotEquipe>> fetchSlotsEquipe({required String accessToken, int? caserneId});

  Future<DisponibilitePerso> addDisponibilitePerso({
    required String accessToken,
    required DateTime debut,
    required DateTime fin,
    required bool envoyerAuChef,
    required DisponibiliteType type,
    String? personnelId,
  });

  Future<void> updateSlotEquipe({
    required String accessToken,
    required String slotId,
    DateTime? debut,
    DateTime? fin,
    DisponibiliteType? type,
    SlotEquipeStatut? statut,
  });

  Future<SlotEquipe> addSlotEquipeManuel({
    required String accessToken,
    required String personnelNom,
    required Equipe equipe,
    required DateTime debut,
    required DateTime fin,
    required DisponibiliteType type,
    required bool horsEquipe,
    String? personnelId,
  });
}

/// Point d’entrée des repos (mock ou API selon config).
class AppRepositories {
  const AppRepositories({
    required this.auth,
    required this.interventions,
    required this.catalog,
    required this.planning,
    this.demo,
    this.disponibilitesEnCours,
  });

  final AuthRepository auth;
  final InterventionsRepository interventions;
  final CatalogRepository catalog;
  final PlanningRepository planning;

  /// Démo : simule du temps réel sans serveur.
  final DemoTools? demo;

  /// Repo dispos « en cours » quand on est sur l’API.
  final dynamic disponibilitesEnCours;
}

/// Interface démo sans backend.
abstract interface class DemoTools {
  void simulateIncomingIntervention();
}

// --- Implémentations mock ---

class MockAuthRepository implements AuthRepository {
  MockAuthRepository({this.role = UserRole.chefDeGarde});

  final UserRole role;

  @override
  Future<AuthSession> signIn({String? email, String? password}) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    final u = MockData.utilisateurDemo().copyWith(role: role);
    return AuthSession(
      user: u,
      accessToken: 'mock_access_token',
      refreshToken: 'mock_refresh_token',
      expiresAt: DateTime.now().add(const Duration(days: 30)),
    );
  }

  @override
  Future<void> signOut() async {}
}

class MockCatalogRepository implements CatalogRepository {
  @override
  Future<List<PompierPersonnel>> fetchPersonnel({required String accessToken, int? caserneId}) async {
    return List<PompierPersonnel>.from(MockData.personnel);
  }

  @override
  Future<List<Vehicle>> fetchVehicules({required String accessToken, int? caserneId}) async {
    return List<Vehicle>.from(MockData.vehicules);
  }
}

class MockPlanningRepository implements PlanningRepository {
  final _mes = List<DisponibilitePerso>.from(MockData.mesDisponibilitesInitiales());
  final _slots = List<SlotEquipe>.from(MockData.slotsEquipeInitiaux());

  void _assertNoOverlap({
    required String personnelId,
    required DateTime debut,
    required DateTime fin,
    String? excludeSlotId,
    String? excludeDispoId,
  }) {
    for (final d in _mes) {
      if (excludeDispoId != null && d.id == excludeDispoId) continue;
      if (disponibiliteRangesOverlap(debut, fin, d.debut, d.fin)) {
        throw Exception(disponibiliteOverlapMessage(d.type));
      }
    }
    for (final s in _slots) {
      if (excludeSlotId != null && s.id == excludeSlotId) continue;
      if (s.personnelId != personnelId) continue;
      if (disponibiliteRangesOverlap(debut, fin, s.debut, s.fin)) {
        throw Exception(disponibiliteOverlapMessage(s.type));
      }
    }
  }

  @override
  Future<List<DisponibilitePerso>> fetchMesDisponibilites({required String accessToken}) async {
    return List<DisponibilitePerso>.from(_mes);
  }

  @override
  Future<List<SlotEquipe>> fetchSlotsEquipe({required String accessToken, int? caserneId}) async {
    return List<SlotEquipe>.from(_slots);
  }

  @override
  Future<DisponibilitePerso> addDisponibilitePerso({
    required String accessToken,
    required DateTime debut,
    required DateTime fin,
    required bool envoyerAuChef,
    required DisponibiliteType type,
    String? personnelId,
  }) async {
    final pid = personnelId ?? 'u1';
    _assertNoOverlap(personnelId: pid, debut: debut, fin: fin);
    final id = 'dp_${DateTime.now().millisecondsSinceEpoch}';
    final d = DisponibilitePerso(
      id: id,
      debut: debut,
      fin: fin,
      envoyerAuChef: envoyerAuChef,
      type: type,
    );
    _mes.add(d);
    if (envoyerAuChef) {
      _slots.add(
        SlotEquipe(
          id: 'slot_$id',
          personnelId: 'u1',
          personnelNom: 'Pierre Durand',
          equipe: Equipe.A,
          debut: debut,
          fin: fin,
          type: type,
          statut: SlotEquipeStatut.enAttenteValidation,
          provenancePersonnel: true,
        ),
      );
    }
    return d;
  }

  @override
  Future<void> updateSlotEquipe({
    required String accessToken,
    required String slotId,
    DateTime? debut,
    DateTime? fin,
    DisponibiliteType? type,
    SlotEquipeStatut? statut,
  }) async {
    final i = _slots.indexWhere((s) => s.id == slotId);
    if (i < 0) return;
    final s = _slots[i];
    final nextDebut = debut ?? s.debut;
    final nextFin = fin ?? s.fin;
    if (!nextFin.isAfter(nextDebut)) {
      throw Exception('La fin doit être après le début.');
    }
    _assertNoOverlap(
      personnelId: s.personnelId,
      debut: nextDebut,
      fin: nextFin,
      excludeSlotId: slotId,
    );
    if (debut != null) s.debut = debut;
    if (fin != null) s.fin = fin;
    if (type != null) s.type = type;
    if (statut != null) s.statut = statut;
  }

  @override
  Future<SlotEquipe> addSlotEquipeManuel({
    required String accessToken,
    required String personnelNom,
    required Equipe equipe,
    required DateTime debut,
    required DateTime fin,
    required DisponibiliteType type,
    required bool horsEquipe,
    String? personnelId,
  }) async {
    final pid = personnelId ?? 'ext_${DateTime.now().millisecondsSinceEpoch}';
    if (!fin.isAfter(debut)) {
      throw Exception('La fin doit être après le début.');
    }
    _assertNoOverlap(personnelId: pid, debut: debut, fin: fin);
    final id = 'sm_${DateTime.now().millisecondsSinceEpoch}';
    final s = SlotEquipe(
      id: id,
      personnelId: pid,
      personnelNom: personnelNom,
      equipe: equipe,
      debut: debut,
      fin: fin,
      type: type,
      statut: SlotEquipeStatut.valide,
      horsEquipe: horsEquipe,
      provenancePersonnel: false,
    );
    _slots.add(s);
    return s;
  }
}

class MockInterventionsRepository implements InterventionsRepository, DemoTools {
  MockInterventionsRepository() {
    _current = List<Intervention>.from(MockData.interventionsInitiales());
  }

  late List<Intervention> _current;
  final _controller = StreamController<InterventionEvent>.broadcast();

  @override
  Future<List<Intervention>> fetchAll({required String accessToken, int? caserneId}) async {
    return List<Intervention>.from(_current);
  }

  @override
  Stream<InterventionEvent> watch({required String accessToken}) => _controller.stream;

  @override
  Future<Intervention> create({
    required String accessToken,
    required String type,
    required String lieu,
    required String resume,
  }) async {
    final it = Intervention(
      id: 'i_${DateTime.now().millisecondsSinceEpoch}',
      dateHeure: DateTime.now(),
      type: type,
      statut: StatutIntervention.enCours,
      lieu: lieu,
      resume: resume,
      personnelIds: const ['p1', 'p2'],
      vehiculeIds: const ['v1'],
    );
    _current.insert(0, it);
    _controller.add(InterventionEvent(type: InterventionEventType.created, intervention: it));
    return it;
  }

  @override
  void simulateIncomingIntervention() {
    // fait comme si une nouvelle intervention arrivait du serveur
    create(
      accessToken: 'mock_access_token',
      type: 'Secours à personne',
      lieu: 'Centre-ville, Béziers',
      resume: 'Démo temps réel (intervention ajoutée).',
    );
  }

  void dispose() {
    _controller.close();
  }
}
