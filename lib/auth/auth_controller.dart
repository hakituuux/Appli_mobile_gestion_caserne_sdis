import 'package:flutter/foundation.dart';



import '../config/app_config.dart';

import '../repositories/api_repositories.dart';

import 'auth_session.dart';

import 'auth_store.dart';

import '../repositories/repositories.dart';



/// Connexion : API web (JWT) ou mock local.

class AuthController extends ChangeNotifier {

  AuthController({

    required AuthRepository authRepository,

    required AuthStore store,

  })  : _authRepository = authRepository,

        _store = store;



  final AuthRepository _authRepository;

  final AuthStore _store;



  AuthSession? _session;

  bool _initializing = false;



  AuthSession? get session => _session;

  bool get isLoggedIn => _session != null;

  bool get initializing => _initializing;



  Future<void> initialize() async {

    if (_initializing) return;

    _initializing = true;

    notifyListeners();

    try {

      final stored = await _store.restore();

      if (stored == null) {

        _session = null;

        return;

      }

      final authRepo = _authRepository;
      if (!AppConfig.useMockData && authRepo is ApiAuthRepository) {

        final refreshed = await authRepo.restoreSession(stored.accessToken);

        if (refreshed == null) {

          await _store.clear();

          _session = null;

        } else {

          _session = refreshed;

          await _store.save(refreshed);

        }

      } else {

        _session = stored;

      }

    } finally {

      _initializing = false;

      notifyListeners();

    }

  }



  Future<void> signIn({String? email, String? password}) async {

    final s = await _authRepository.signIn(email: email, password: password);

    _session = s;

    await _store.save(s);

    notifyListeners();

  }



  Future<void> signOut() async {

    await _authRepository.signOut();

    _session = null;

    await _store.clear();

    notifyListeners();

  }



  /// Mock : bascule de rôle sans refaire un login.

  void setSessionForDemo(AuthSession? session) {

    _session = session;

    notifyListeners();

  }

}


