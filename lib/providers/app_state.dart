import 'dart:async';

import 'package:flutter/foundation.dart';

import '../auth/auth_controller.dart';
import '../auth/auth_session.dart';
import '../models/app_user.dart';
import '../models/disponibilite_perso.dart';
import '../models/disponibilite_type.dart';
import '../models/equipe.dart';
import '../models/intervention.dart';
import '../models/personnel_en_intervention.dart';
import '../models/pompier_personnel.dart';
import '../models/slot_equipe.dart';
import '../models/user_role.dart';
import '../models/vehicle.dart';
import '../repositories/api_repositories.dart';
import '../repositories/repositories.dart';
import '../utils/armement.dart';

/// Données globales de l’app (chargées via l’API).
class AppState extends ChangeNotifier {
  AppState({
    required AppRepositories repositories,
    required AuthController auth,
  })  : _repositories = repositories,
        _auth = auth {
    _wireAuth();
  }

  final AppRepositories _repositories;
  final AuthController _auth;

  List<Intervention> _interventions = const [];
  List<PompierPersonnel> _personnel = const [];
  List<PompierPersonnel> _personnelDisponibles = const [];
  List<PersonnelEnIntervention> _personnelEnIntervention = const [];
  List<Vehicle> _vehicules = const [];
  List<DisponibilitePerso> _mesDisponibilites = const [];
  List<SlotEquipe> _slotsEquipe = const [];

  StreamSubscription<InterventionEvent>? _interventionsSub;
  late final VoidCallback _onAuthChanged;
  bool _authListenerInstalled = false;

  bool _loading = false;
  String? _lastError;

  bool get loading => _loading;
  String? get lastError => _lastError;

  String get accessToken => _auth.session?.accessToken ?? '';

  AppUser get user => _auth.session!.user;

  List<Intervention> get interventions => List.unmodifiable(_interventions);
  List<PompierPersonnel> get personnel => List.unmodifiable(_personnel);
  List<PompierPersonnel> get personnelDisponibles => List.unmodifiable(_personnelDisponibles);
  List<PersonnelEnIntervention> get personnelEnIntervention => List.unmodifiable(_personnelEnIntervention);
  List<Vehicle> get vehicules => List.unmodifiable(_vehicules);
  List<DisponibilitePerso> get mesDisponibilites => List.unmodifiable(_mesDisponibilites);
  List<SlotEquipe> get slotsEquipe => List.unmodifiable(_slotsEquipe);

  int get pompiersDisponibles => _personnelDisponibles.length;
  int get effectifTheorique => _personnel.isEmpty ? 22 : _personnel.length;

  Set<String> get idVehiculesEngagesInterventionEnCours {
    final s = <String>{};
    for (final i in interventionsEnCours()) {
      s.addAll(i.vehiculeIds);
    }
    return s;
  }

  List<Vehicle> get vehiculesAuParc {
    final engaged = idVehiculesEngagesInterventionEnCours;
    return _vehicules
        .where((v) => !engaged.contains(v.id))
        .toList();
  }

  int get armementPct {
    final auParc = vehiculesAuParc;
    if (auParc.isEmpty) return 100;
    final pool = _personnelDisponibles.isNotEmpty ? _personnelDisponibles : _personnel;
    return pourcentageArmementCaserne(pool, auParc);
  }

  String? get _personnelIdCourant => user.personnelId ?? user.id;

  /// Caserne du user : filtre personnel, engins, interventions.
  int? get _caserneIdFiltre {
    final id = user.caserneId;
    if (id == null || id.isEmpty) return null;
    return int.tryParse(id);
  }

  bool get _scopeParCaserne => user.role != UserRole.admin;

  void setUserRole(UserRole role) {
    final s = _auth.session;
    if (s == null) return;
    _auth.setSessionForDemo(
      AuthSession(
        user: s.user.copyWith(role: role),
        accessToken: s.accessToken,
        refreshToken: s.refreshToken,
        expiresAt: s.expiresAt,
      ),
    );
    notifyListeners();
  }

  PompierPersonnel? personnelParId(String id) {
    try {
      return _personnel.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> addDisponibilitePerso({
    required DateTime debut,
    required DateTime fin,
    required bool envoyerAuChef,
    DisponibiliteType type = DisponibiliteType.disponible,
  }) {
    return _addDisponibilitePersoAsync(debut, fin, envoyerAuChef, type);
  }

  Future<void> _addDisponibilitePersoAsync(
    DateTime debut,
    DateTime fin,
    bool envoyerAuChef,
    DisponibiliteType type,
  ) async {
    try {
      final d = await _repositories.planning.addDisponibilitePerso(
        accessToken: accessToken,
        debut: debut,
        fin: fin,
        envoyerAuChef: envoyerAuChef,
        type: type,
        personnelId: _personnelIdCourant,
      );
      _mesDisponibilites = List.of(_mesDisponibilites)..add(d);
      _slotsEquipe = await _repositories.planning.fetchSlotsEquipe(
      accessToken: accessToken,
      caserneId: _caserneIdFiltre,
    );
      _lastError = null;
      notifyListeners();
    } catch (e) {
      _lastError = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateSlotEquipe(
    String id, {
    DateTime? debut,
    DateTime? fin,
    DisponibiliteType? type,
    SlotEquipeStatut? statut,
  }) {
    return _updateSlotEquipeAsync(id, debut: debut, fin: fin, type: type, statut: statut);
  }

  Future<void> _updateSlotEquipeAsync(
    String id, {
    DateTime? debut,
    DateTime? fin,
    DisponibiliteType? type,
    SlotEquipeStatut? statut,
  }) async {
    try {
      await _repositories.planning.updateSlotEquipe(
        accessToken: accessToken,
        slotId: id,
        debut: debut,
        fin: fin,
        type: type,
        statut: statut,
      );
      _slotsEquipe = await _repositories.planning.fetchSlotsEquipe(
        accessToken: accessToken,
        caserneId: _caserneIdFiltre,
      );
      _lastError = null;
      notifyListeners();
    } catch (e) {
      _lastError = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void validerSlot(String id) {
    updateSlotEquipe(id, statut: SlotEquipeStatut.valide);
  }

  Future<void> addSlotEquipeManuel({
    required String personnelNom,
    required Equipe equipe,
    required DateTime debut,
    required DateTime fin,
    required DisponibiliteType type,
    bool horsEquipe = false,
    String? personnelId,
  }) {
    return _addSlotEquipeManuelAsync(
      personnelNom: personnelNom,
      equipe: equipe,
      debut: debut,
      fin: fin,
      type: type,
      horsEquipe: horsEquipe,
      personnelId: personnelId,
    );
  }

  Future<void> _addSlotEquipeManuelAsync({
    required String personnelNom,
    required Equipe equipe,
    required DateTime debut,
    required DateTime fin,
    required DisponibiliteType type,
    required bool horsEquipe,
    String? personnelId,
  }) async {
    try {
      final slot = await _repositories.planning.addSlotEquipeManuel(
        accessToken: accessToken,
        personnelNom: personnelNom,
        equipe: equipe,
        debut: debut,
        fin: fin,
        type: type,
        horsEquipe: horsEquipe,
        personnelId: personnelId,
      );
      _slotsEquipe = List.of(_slotsEquipe)..add(slot);
      _lastError = null;
      notifyListeners();
    } catch (e) {
      _lastError = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  List<Intervention> interventionsEnCours() =>
      _interventions.where((i) => i.statut == StatutIntervention.enCours).toList();

  List<Intervention> historique7Jours() {
    final limite = DateTime.now().subtract(const Duration(days: 7));
    return _interventions.where((i) => i.dateHeure.isAfter(limite)).toList()
      ..sort((a, b) => b.dateHeure.compareTo(a.dateHeure));
  }

  Intervention? interventionParId(String id) {
    try {
      return _interventions.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  List<SlotEquipe> slotsPourPersonnelEtSemaine(String personnelId, DateTime semaineDebut) {
    final fin = semaineDebut.add(const Duration(days: 7));
    return _slotsEquipe.where((s) {
      if (s.personnelId != personnelId) return false;
      return s.debut.isBefore(fin) && !s.fin.isBefore(semaineDebut);
    }).toList()
      ..sort((a, b) => a.debut.compareTo(b.debut));
  }

  List<SlotEquipe> slotsPourEquipeEtSemaine(Equipe equipe, DateTime semaineDebut) {
    final fin = semaineDebut.add(const Duration(days: 7));
    return _slotsEquipe.where((s) {
      if (s.equipe != equipe) return false;
      return s.debut.isBefore(fin) && !s.fin.isBefore(semaineDebut);
    }).toList()
      ..sort((a, b) => a.debut.compareTo(b.debut));
  }

  void simulateIncomingIntervention() {
    _repositories.demo?.simulateIncomingIntervention();
  }

  Future<void> refresh() => _loadAll();

  Future<void> _loadDisponiblesEnCours() async {
    final repo = _repositories.disponibilitesEnCours;
    if (repo is ApiDisponibilitesEnCoursRepository) {
      final result = await repo.fetch(
        accessToken: accessToken,
        caserneId: _caserneIdFiltre,
      );
      _personnelDisponibles = result.disponibles.map((p) {
        final full = personnelParId(p.id);
        return full ?? p;
      }).toList();
      _personnelEnIntervention = result.enIntervention.map((e) {
        final full = personnelParId(e.personnel.id);
        if (full == null) return e;
        return PersonnelEnIntervention(
          personnel: full,
          interventionId: e.interventionId,
          interventionNumero: e.interventionNumero,
          typeIntervention: e.typeIntervention,
          lieu: e.lieu,
          fonctionSurIntervention: e.fonctionSurIntervention,
          typeDispoDeclare: e.typeDispoDeclare,
        );
      }).toList();
    } else {
      final engagedIds = <String>{};
      for (final i in interventionsEnCours()) {
        engagedIds.addAll(i.personnelIds);
      }
      _personnelEnIntervention = [];
      for (final id in engagedIds) {
        final p = personnelParId(id);
        if (p == null) continue;
        Intervention? inter;
        for (final i in interventionsEnCours()) {
          if (i.personnelIds.contains(id)) {
            inter = i;
            break;
          }
        }
        if (inter == null) continue;
        _personnelEnIntervention = [
          ..._personnelEnIntervention,
          PersonnelEnIntervention(
            personnel: p,
            interventionId: inter.id,
            interventionNumero: inter.id,
            typeIntervention: inter.type,
            lieu: inter.lieu,
          ),
        ];
      }
      _personnelDisponibles =
          _personnel.where((p) => !engagedIds.contains(p.id)).toList();
    }
  }

  Future<void> _loadAll() async {
    if (_loading) return;
    _loading = true;
    _lastError = null;
    notifyListeners();
    try {
      final caserneId = _caserneIdFiltre;
      if (_scopeParCaserne && caserneId == null) {
        _lastError =
            'Caserne d\'affectation introuvable pour ce compte. Déconnectez-vous puis reconnectez-vous.';
        return;
      }
      _personnel = await _repositories.catalog.fetchPersonnel(
        accessToken: accessToken,
        caserneId: caserneId,
      );
      _vehicules = await _repositories.catalog.fetchVehicules(
        accessToken: accessToken,
        caserneId: caserneId,
      );
      _interventions = await _repositories.interventions.fetchAll(
        accessToken: accessToken,
        caserneId: caserneId,
      );
      _mesDisponibilites = await _repositories.planning.fetchMesDisponibilites(accessToken: accessToken);
      _slotsEquipe = await _repositories.planning.fetchSlotsEquipe(
      accessToken: accessToken,
      caserneId: _caserneIdFiltre,
    );
      await _loadDisponiblesEnCours();

      _interventionsSub?.cancel();
      _interventionsSub = _repositories.interventions.watch(accessToken: accessToken).listen((evt) {
        if (evt.type == InterventionEventType.created) {
          _interventions = [evt.intervention, ..._interventions];
        } else if (evt.type == InterventionEventType.updated) {
          final idx = _interventions.indexWhere((i) => i.id == evt.intervention.id);
          if (idx >= 0) {
            final copy = List<Intervention>.from(_interventions);
            copy[idx] = evt.intervention;
            _interventions = copy;
          }
        } else if (evt.type == InterventionEventType.deleted) {
          _interventions = _interventions.where((i) => i.id != evt.intervention.id).toList();
        }
        notifyListeners();
      });
    } catch (e) {
      _lastError = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void _wireAuth() {
    _onAuthChanged = () {
      if (_auth.isLoggedIn && !_auth.initializing) {
        _loadAll();
      } else if (!_auth.isLoggedIn) {
        _interventionsSub?.cancel();
        _interventionsSub = null;
        _interventions = const [];
        _personnel = const [];
        _personnelDisponibles = const [];
        _personnelEnIntervention = const [];
        _vehicules = const [];
        _mesDisponibilites = const [];
        _slotsEquipe = const [];
        notifyListeners();
      }
    };
    if (!_authListenerInstalled) {
      _auth.addListener(_onAuthChanged);
      _authListenerInstalled = true;
      if (_auth.isLoggedIn && !_auth.initializing) {
        Future.microtask(_loadAll);
      }
    }
  }

  @override
  void dispose() {
    _interventionsSub?.cancel();
    if (_authListenerInstalled) {
      _auth.removeListener(_onAuthChanged);
    }
    super.dispose();
  }
}
