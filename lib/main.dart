import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'api/sdis_api_client.dart';
import 'auth/auth_controller.dart';
import 'auth/auth_store.dart';
import 'config/app_config.dart';
import 'providers/app_state.dart';
import 'repositories/api_repositories.dart';
import 'repositories/repositories.dart';
import 'screens/auth/auth_gate.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);
  runApp(const PompierDispoApp());
}

class PompierDispoApp extends StatelessWidget {
  const PompierDispoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final AppRepositories repos = _buildRepositories();
    return MultiProvider(
      providers: [
        Provider<AppRepositories>.value(value: repos),
        ChangeNotifierProvider<AuthController>(
          create: (_) => AuthController(
            authRepository: repos.auth,
            store: AuthStore(),
          ),
        ),
        ChangeNotifierProxyProvider2<AppRepositories, AuthController, AppState>(
          create: (context) => AppState(
            repositories: repos,
            auth: context.read<AuthController>(),
          ),
          update: (context, r, a, prev) => prev ?? AppState(repositories: r, auth: a),
        ),
      ],
      child: MaterialApp(
        title: 'GESTION PERSO SDIS',
        locale: const Locale('fr', 'FR'),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('fr', 'FR')],
        theme: buildAppTheme(),
        home: const AuthGate(),
      ),
    );
  }
}

AppRepositories _buildRepositories() {
  if (AppConfig.useMockData) {
    final mockInter = MockInterventionsRepository();
    return AppRepositories(
      auth: MockAuthRepository(),
      interventions: mockInter,
      catalog: MockCatalogRepository(),
      planning: MockPlanningRepository(),
      demo: mockInter,
    );
  }
  final client = SdisApiClient();
  return AppRepositories(
    auth: ApiAuthRepository(client),
    interventions: ApiInterventionsRepository(client),
    catalog: ApiCatalogRepository(client),
    planning: ApiPlanningRepository(client),
    disponibilitesEnCours: ApiDisponibilitesEnCoursRepository(client),
  );
}
