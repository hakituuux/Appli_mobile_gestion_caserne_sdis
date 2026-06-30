import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart';

import 'auth_session.dart';
import '../models/app_user.dart';
import '../models/equipe.dart';
import '../models/user_role.dart';

/// Garde le token en local (rester connecté).
class AuthStore {
  AuthStore({FlutterSecureStorage? storage}) : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _kAccessToken = 'auth_access_token';
  static const _kUserId = 'auth_user_id';
  static const _kUserPrenom = 'auth_user_prenom';
  static const _kUserNom = 'auth_user_nom';
  static const _kUserRole = 'auth_user_role';
  static const _kUserEquipe = 'auth_user_equipe';
  static const _kUserEmail = 'auth_user_email';
  static const _kUserGrade = 'auth_user_grade';
  static const _kPersonnelId = 'auth_personnel_id';
  static const _kAccountUserId = 'auth_account_user_id';
  static const _kCaserneId = 'auth_caserne_id';
  static const _kCaserneCode = 'auth_caserne_code';
  static const _kCaserneName = 'auth_caserne_name';
  static const _kCompetences = 'auth_competences';

  Future<void> save(AuthSession session) async {
    try {
      final u = session.user;
      await _storage.write(key: _kAccessToken, value: session.accessToken);
      await _storage.write(key: _kUserId, value: u.id);
      await _storage.write(key: _kUserPrenom, value: u.prenom);
      await _storage.write(key: _kUserNom, value: u.nom);
      await _storage.write(key: _kUserRole, value: u.role.name);
      await _storage.write(key: _kUserEquipe, value: u.equipe.name);
      await _storage.write(key: _kUserEmail, value: u.email);
      await _storage.write(key: _kUserGrade, value: u.grade);
      await _storage.write(key: _kPersonnelId, value: u.personnelId ?? '');
      await _storage.write(key: _kAccountUserId, value: u.accountUserId ?? '');
      await _storage.write(key: _kCaserneId, value: u.caserneId ?? '');
      await _storage.write(key: _kCaserneCode, value: u.caserneCode ?? '');
      await _storage.write(key: _kCaserneName, value: u.caserneName ?? '');
      await _storage.write(key: _kCompetences, value: u.competences.join('|'));
    } on MissingPluginException {
      // tests : pas de stockage natif dispo
    }
  }

  Future<AuthSession?> restore() async {
    try {
      final token = await _storage.read(key: _kAccessToken);
      if (token == null || token.isEmpty) return null;

      final id = await _storage.read(key: _kUserId);
      final prenom = await _storage.read(key: _kUserPrenom);
      final nom = await _storage.read(key: _kUserNom);
      final roleName = await _storage.read(key: _kUserRole);
      final equipeName = await _storage.read(key: _kUserEquipe);
      final email = await _storage.read(key: _kUserEmail) ?? '';
      final grade = await _storage.read(key: _kUserGrade) ?? '';
      final personnelId = _emptyToNull(await _storage.read(key: _kPersonnelId));
      final accountUserId = _emptyToNull(await _storage.read(key: _kAccountUserId));
      final caserneId = _emptyToNull(await _storage.read(key: _kCaserneId));
      final caserneCode = _emptyToNull(await _storage.read(key: _kCaserneCode));
      final caserneName = _emptyToNull(await _storage.read(key: _kCaserneName));
      final compsRaw = await _storage.read(key: _kCompetences) ?? '';
      final competences = compsRaw.isEmpty
          ? const <String>[]
          : compsRaw.split('|').where((c) => c.isNotEmpty).toList();

      if (id == null || prenom == null || nom == null || roleName == null || equipeName == null) {
        return null;
      }

      final role = UserRole.values.firstWhere((r) => r.name == roleName, orElse: () => UserRole.pompier);
      final eq = Equipe.values.firstWhere((e) => e.name == equipeName, orElse: () => Equipe.A);

      return AuthSession(
        user: AppUser(
          id: id,
          prenom: prenom,
          nom: nom,
          role: role,
          email: email,
          grade: grade,
          equipe: eq,
          competences: competences,
          personnelId: personnelId,
          accountUserId: accountUserId,
          caserneId: caserneId,
          caserneCode: caserneCode,
          caserneName: caserneName,
        ),
        accessToken: token,
      );
    } on MissingPluginException {
      return null;
    }
  }

  String? _emptyToNull(String? value) {
    if (value == null || value.isEmpty) return null;
    return value;
  }

  Future<void> clear() async {
    try {
      for (final key in [
        _kAccessToken,
        _kUserId,
        _kUserPrenom,
        _kUserNom,
        _kUserRole,
        _kUserEquipe,
        _kUserEmail,
        _kUserGrade,
        _kPersonnelId,
        _kAccountUserId,
        _kCaserneId,
        _kCaserneCode,
        _kCaserneName,
        _kCompetences,
      ]) {
        await _storage.delete(key: key);
      }
    } on MissingPluginException {
      // ignore
    }
  }
}
