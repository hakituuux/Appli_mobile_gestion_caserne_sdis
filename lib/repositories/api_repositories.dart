import 'dart:async';

import 'package:dio/dio.dart';

import '../api/api_mappers.dart';
import '../api/sdis_api_client.dart';
import '../auth/auth_session.dart';
import '../models/disponibilite_perso.dart';
import '../models/disponibilite_type.dart';
import '../models/equipe.dart';
import '../models/intervention.dart';
import '../models/pompier_personnel.dart';
import '../models/personnel_en_intervention.dart';
import '../models/slot_equipe.dart';
import '../models/vehicle.dart';
import 'repositories.dart';

class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository(this._client);

  final SdisApiClient _client;

  @override
  Future<AuthSession> signIn({String? email, String? password}) async {
    if (email == null || password == null || email.isEmpty || password.isEmpty) {
      throw ArgumentError('Email et mot de passe requis');
    }
    try {
      final loginRes = await _client.post(
        '/auth/login',
        data: {'email': email.trim().toLowerCase(), 'password': password},
      );
      final token = loginRes.data['token'] as String;
      _client.setAccessToken(token);

      final meRes = await _client.get('/auth/me');
      final user = ApiMappers.userFromMeJson(meRes.data as Map<String, dynamic>);

      return AuthSession(
        user: user,
        accessToken: token,
        expiresAt: DateTime.now().add(const Duration(hours: 8)),
      );
    } on DioException catch (e) {
      throw Exception(SdisApiClient.apiErrorMessage(e));
    }
  }

  @override
  Future<void> signOut() async {
    _client.setAccessToken(null);
  }

  /// Relance la session avec le token en mémoire.
  Future<AuthSession?> restoreSession(String token) async {
    _client.setAccessToken(token);
    try {
      final meRes = await _client.get('/auth/me');
      final user = ApiMappers.userFromMeJson(meRes.data as Map<String, dynamic>);
      return AuthSession(
        user: user,
        accessToken: token,
        expiresAt: DateTime.now().add(const Duration(hours: 8)),
      );
    } on DioException {
      _client.setAccessToken(null);
      return null;
    }
  }
}

class ApiCatalogRepository implements CatalogRepository {
  ApiCatalogRepository(this._client);

  final SdisApiClient _client;

  @override
  Future<List<PompierPersonnel>> fetchPersonnel({
    required String accessToken,
    int? caserneId,
  }) async {
    _client.setAccessToken(accessToken);
    try {
      final params = <String, dynamic>{'limit': 200, 'with_competences': 'true'};
      if (caserneId != null) params['caserne_id'] = caserneId;
      final res = await _client.get('/personnels', queryParameters: params);
      final data = res.data['data'] as List<dynamic>? ?? [];
      return data
          .map((e) => ApiMappers.personnelFromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(SdisApiClient.apiErrorMessage(e));
    }
  }

  @override
  Future<List<Vehicle>> fetchVehicules({
    required String accessToken,
    int? caserneId,
  }) async {
    _client.setAccessToken(accessToken);
    try {
      final params = <String, dynamic>{'group_all': 'true'};
      if (caserneId != null) params['caserne_id'] = caserneId;
      final res = await _client.get('/vehicules', queryParameters: params);
      final data = res.data['data'] as List<dynamic>? ?? [];
      return data
          .where((v) => (v as Map)['statut'] != 'hors_service')
          .map((e) => ApiMappers.vehicleFromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(SdisApiClient.apiErrorMessage(e));
    }
  }
}

class ApiPlanningRepository implements PlanningRepository {
  ApiPlanningRepository(this._client);

  final SdisApiClient _client;

  @override
  Future<List<DisponibilitePerso>> fetchMesDisponibilites({
    required String accessToken,
  }) async {
    _client.setAccessToken(accessToken);
    try {
      final now = DateTime.now();
      final from = now.subtract(const Duration(days: 60));
      final to = now.add(const Duration(days: 180));
      final res = await _client.get(
        '/disponibilites',
        queryParameters: {
          'limit': 200,
          'from': ApiMappers.formatDateTimeApi(from),
          'to': ApiMappers.formatDateTimeApi(to),
        },
      );
      final data = res.data['data'] as List<dynamic>? ?? [];
      return data
          .map((e) => ApiMappers.disponibiliteFromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(SdisApiClient.apiErrorMessage(e));
    }
  }

  @override
  Future<List<SlotEquipe>> fetchSlotsEquipe({
    required String accessToken,
    int? caserneId,
  }) async {
    _client.setAccessToken(accessToken);
    try {
      final now = DateTime.now();
      final from = now.subtract(const Duration(days: 14));
      final to = now.add(const Duration(days: 60));
      final params = <String, dynamic>{
        'limit': 500,
        'from': ApiMappers.formatDateTimeApi(from),
        'to': ApiMappers.formatDateTimeApi(to),
      };
      if (caserneId != null) params['caserne_id'] = caserneId;
      final res = await _client.get('/disponibilites', queryParameters: params);
      final data = res.data['data'] as List<dynamic>? ?? [];
      return data
          .where((e) {
            final statut = (e as Map)['statut'];
            return statut != 'refusee';
          })
          .map((e) => ApiMappers.slotFromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(SdisApiClient.apiErrorMessage(e));
    }
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
    _client.setAccessToken(accessToken);
    final pid = int.tryParse(personnelId ?? '');
    if (pid == null) {
      throw Exception('Aucun personnel lié au compte — impossible de saisir une disponibilité.');
    }
    try {
      final res = await _client.post(
        '/disponibilites',
        data: {
          'personnel_id': pid,
          'debut': ApiMappers.formatDateTimeApi(debut),
          'fin': ApiMappers.formatDateTimeApi(fin),
          'type_dispo': ApiMappers.dispoTypeToApi(type),
          'statut': envoyerAuChef ? 'proposee' : 'validee',
        },
      );
      final id = res.data['id'].toString();
      return DisponibilitePerso(
        id: id,
        debut: debut,
        fin: fin,
        envoyerAuChef: envoyerAuChef,
        type: type,
      );
    } on DioException catch (e) {
      throw Exception(SdisApiClient.apiErrorMessage(e));
    }
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
    _client.setAccessToken(accessToken);
    final body = <String, dynamic>{};
    if (debut != null) body['debut'] = ApiMappers.formatDateTimeApi(debut);
    if (fin != null) body['fin'] = ApiMappers.formatDateTimeApi(fin);
    if (type != null) body['type_dispo'] = ApiMappers.dispoTypeToApi(type);
    if (statut != null) body['statut'] = ApiMappers.slotStatutToApi(statut);
    try {
      await _client.patch('/disponibilites/$slotId', data: body);
    } on DioException catch (e) {
      throw Exception(SdisApiClient.apiErrorMessage(e));
    }
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
    _client.setAccessToken(accessToken);
    final pid = int.tryParse(personnelId ?? '');
    if (pid == null) {
      throw Exception('personnel_id requis pour ajouter un créneau équipe.');
    }
    try {
      final res = await _client.post(
        '/disponibilites',
        data: {
          'personnel_id': pid,
          'debut': ApiMappers.formatDateTimeApi(debut),
          'fin': ApiMappers.formatDateTimeApi(fin),
          'type_dispo': ApiMappers.dispoTypeToApi(type),
          'statut': 'validee',
          'hors_equipe': horsEquipe,
          'commentaire': 'Saisie chef — $personnelNom',
        },
      );
      return SlotEquipe(
        id: res.data['id'].toString(),
        personnelId: personnelId!,
        personnelNom: personnelNom,
        equipe: equipe,
        debut: debut,
        fin: fin,
        type: type,
        statut: SlotEquipeStatut.valide,
        horsEquipe: horsEquipe,
        provenancePersonnel: false,
      );
    } on DioException catch (e) {
      throw Exception(SdisApiClient.apiErrorMessage(e));
    }
  }
}

class ApiInterventionsRepository implements InterventionsRepository {
  ApiInterventionsRepository(this._client);

  final SdisApiClient _client;
  final _controller = StreamController<InterventionEvent>.broadcast();
  Timer? _pollTimer;
  List<Intervention> _lastSnapshot = const [];
  String? _lastToken;
  int? _caserneId;

  @override
  Future<List<Intervention>> fetchAll({
    required String accessToken,
    int? caserneId,
  }) async {
    _caserneId = caserneId;
    _client.setAccessToken(accessToken);
    try {
      final params = <String, dynamic>{'limit': 100};
      if (caserneId != null) params['caserne_id'] = caserneId;
      final res = await _client.get('/interventions', queryParameters: params);
      final data = res.data['data'] as List<dynamic>? ?? [];
      final list = data
          .map((e) => ApiMappers.interventionFromJson(e as Map<String, dynamic>))
          .toList();
      _lastSnapshot = list;
      return list;
    } on DioException catch (e) {
      throw Exception(SdisApiClient.apiErrorMessage(e));
    }
  }

  @override
  Stream<InterventionEvent> watch({required String accessToken}) {
    if (_lastToken != accessToken) {
      _pollTimer?.cancel();
      _lastToken = accessToken;
      _lastSnapshot = const [];
    }
    _pollTimer ??= Timer.periodic(const Duration(seconds: 30), (_) => _poll(accessToken));
    _poll(accessToken);
    return _controller.stream;
  }

  Future<void> _poll(String accessToken) async {
    try {
      final list = await fetchAll(accessToken: accessToken, caserneId: _caserneId);
      final oldIds = _lastSnapshot.map((i) => i.id).toSet();
      for (final i in list) {
        if (!oldIds.contains(i.id)) {
          _controller.add(InterventionEvent(type: InterventionEventType.created, intervention: i));
        }
      }
      final newById = {for (final i in list) i.id: i};
      for (final old in _lastSnapshot) {
        final updated = newById[old.id];
        if (updated != null &&
            (updated.statut != old.statut || updated.resume != old.resume)) {
          _controller.add(
            InterventionEvent(type: InterventionEventType.updated, intervention: updated),
          );
        }
      }
      _lastSnapshot = list;
    } catch (_) {
      // erreur de poll : on ignore
    }
  }

  @override
  Future<Intervention> create({
    required String accessToken,
    required String type,
    required String lieu,
    required String resume,
  }) async {
    throw UnimplementedError('Création intervention réservée à l’appli web.');
  }

  void dispose() {
    _pollTimer?.cancel();
    _controller.close();
  }
}

/// Réponse de /disponibilites/en-cours.
class DisponibilitesEnCoursResult {
  const DisponibilitesEnCoursResult({
    required this.disponibles,
    required this.enIntervention,
  });

  final List<PompierPersonnel> disponibles;
  final List<PersonnelEnIntervention> enIntervention;
}

class ApiDisponibilitesEnCoursRepository {
  ApiDisponibilitesEnCoursRepository(this._client);

  final SdisApiClient _client;

  Future<DisponibilitesEnCoursResult> fetch({
    required String accessToken,
    int? caserneId,
  }) async {
    _client.setAccessToken(accessToken);
    try {
      final params = <String, dynamic>{};
      if (caserneId != null) params['caserne_id'] = caserneId;
      final res = await _client.get('/disponibilites/en-cours', queryParameters: params);
      final body = res.data as Map<String, dynamic>;
      final dispoList = body['disponibles'] as List<dynamic>? ?? body['data'] as List<dynamic>? ?? [];
      final engagedList = body['en_intervention'] as List<dynamic>? ?? [];

      PompierPersonnel mapPersonnel(Map<String, dynamic> m) {
        return PompierPersonnel(
          id: m['personnel_id'].toString(),
          nom: m['last_name'] as String? ?? '',
          prenom: m['first_name'] as String? ?? '',
          equipe: ApiMappers.equipeFromApi(m['equipe_garde'] as String?),
          grade: m['grade'] as String? ?? 'Sapeur',
          competences: const [],
        );
      }

      final seen = <String>{};
      final disponibles = <PompierPersonnel>[];
      for (final row in dispoList) {
        final m = row as Map<String, dynamic>;
        final id = m['personnel_id'].toString();
        if (seen.contains(id)) continue;
        seen.add(id);
        disponibles.add(mapPersonnel(m));
      }

      final enIntervention = engagedList.map((row) {
        final m = row as Map<String, dynamic>;
        final dispo = m['disponibilite'] as Map<String, dynamic>?;
        final adresse = m['intervention_adresse'] as String? ?? '';
        final ville = m['intervention_ville'] as String? ?? '';
        return PersonnelEnIntervention(
          personnel: mapPersonnel(m),
          interventionId: m['intervention_id'].toString(),
          interventionNumero: m['intervention_numero'] as String? ?? '',
          typeIntervention: m['type_intervention'] as String? ?? 'Intervention',
          lieu: [adresse, ville].where((s) => s.isNotEmpty).join(', '),
          fonctionSurIntervention: m['fonction_sur_intervention'] as String?,
          typeDispoDeclare: dispo?['type_dispo'] as String?,
        );
      }).toList();

      return DisponibilitesEnCoursResult(
        disponibles: disponibles,
        enIntervention: enIntervention,
      );
    } on DioException catch (e) {
      throw Exception(SdisApiClient.apiErrorMessage(e));
    }
  }
}
