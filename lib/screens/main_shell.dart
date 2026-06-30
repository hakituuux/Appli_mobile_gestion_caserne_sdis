// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../theme/app_colors.dart';
import 'home_screen.dart';
import 'interventions_screen.dart';
import 'planning_tab.dart';
import 'settings_screen.dart';

/// Coque principale : onglets, pas d’AppBar globale.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = context.read<AppState>();
      if (state.personnel.isEmpty && state.vehicules.isEmpty && !state.loading) {
        state.refresh();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final err = state.lastError;
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (state.loading)
                  const LinearProgressIndicator(
                    minHeight: 3,
                    color: AppColors.coral,
                    backgroundColor: Colors.white12,
                  ),
                if (err != null)
                  Material(
                    color: const Color(0xFF4A1C1C),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.cloud_off, color: Color(0xFFFF8A80), size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              err.replaceFirst('Exception: ', ''),
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                          TextButton(
                            onPressed: state.loading ? null : () => state.refresh(),
                            child: const Text('Réessayer', style: TextStyle(color: AppColors.coral)),
                          ),
                        ],
                      ),
                    ),
                  ),
                Expanded(
                  child: IndexedStack(
                    index: _index,
                    children: const [
                      HomeScreen(),
                      InterventionsScreen(),
                      PlanningTab(),
                      SettingsScreen(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: NavigationBar(
            backgroundColor: const Color(0xFF16161F),
            surfaceTintColor: Colors.transparent,
            shadowColor: Colors.transparent,
            elevation: 0,
            height: 64,
            selectedIndex: _index,
            indicatorColor: AppColors.coral.withOpacity(0.22),
            onDestinationSelected: (i) => setState(() => _index = i),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Accueil',
              ),
              NavigationDestination(
                icon: Icon(Icons.error_outline),
                selectedIcon: Icon(Icons.error),
                label: 'Interventions',
              ),
              NavigationDestination(
                icon: Icon(Icons.calendar_month_outlined),
                selectedIcon: Icon(Icons.calendar_month),
                label: 'Planification',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: 'Paramètres',
              ),
            ],
          ),
        );
      },
    );
  }
}
