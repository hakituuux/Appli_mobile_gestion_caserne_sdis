import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

/// Config globale. Même base que l’appli web via l’API (pas de MySQL direct).
/// Détail : docs/INTEGRATION_APPLI_WEB.md
class AppConfig {
  AppConfig._();

  /// true = données locales (démo, clone GitHub) ; false = API web (port 4000).
  static const bool useMockData = true;

  static const int apiPort = 4000;

  /// IP du PC si tel physique : --dart-define=API_HOST=192.168.x.x
  static const String _apiHostOverride = String.fromEnvironment('API_HOST');

  /// Android émulateur → 10.0.2.2 ; desktop/iOS sim → 127.0.0.1 ; tel → API_HOST.
  static String get apiHost {
    if (_apiHostOverride.isNotEmpty) return _apiHostOverride;
    if (kIsWeb) return 'localhost';
    if (Platform.isAndroid) return '10.0.2.2';
    return '127.0.0.1';
  }

  /// URL de base de l’API (situation 2).
  static String get apiBaseUrl => 'http://$apiHost:$apiPort';

  /// Socket.IO prévu plus tard (pas branché pour l’instant).
  static String get realtimeUrl => apiBaseUrl;

  /// OAuth placeholder ; en prod → compte Microsoft SDIS.
  static const String oauthIssuer = 'https://example.invalid';
  static const String oauthClientId = 'mobile-app';
  static const String oauthRedirectUrl = 'fr.herault.sdis:/oauthredirect';
}

