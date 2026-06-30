// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_controller.dart';
import '../config/app_config.dart';
import '../data/app_constants.dart';
import '../models/equipe.dart';
import '../models/user_role.dart';
import '../providers/app_state.dart';
import '../theme/app_colors.dart';

/// Réglages / profil utilisateur.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final u = state.user;
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            const Text(
              'Paramètres',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.coral.withOpacity(0.25),
                    child: const Icon(Icons.star, color: AppColors.coral, size: 36),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    u.nomComplet,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    u.grade.isNotEmpty ? u.grade : '—',
                    style: const TextStyle(color: AppColors.coral, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    u.email.isNotEmpty ? u.email : 'email@sdis34.fr',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.coral,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      u.role.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  _InfoLine(
                    icon: Icons.business,
                    label: 'CASERNE',
                    value: u.caserneName ?? AppConstants.centrePrincipal,
                  ),
                  const Divider(color: Colors.white12, height: 24),
                  _InfoLine(
                    icon: Icons.groups_2_outlined,
                    label: 'ÉQUIPE',
                    value: u.equipe.label,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Mes compétences',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: u.competences
                    .map(
                      (c) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.greenSkillBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check, size: 16, color: AppColors.greenSkill),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                c,
                                style: const TextStyle(
                                  color: AppColors.greenSkill,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            if (AppConfig.useMockData) ...[
              const SizedBox(height: 24),
              const Text(
                'Changer de rôle (Démo)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Testez les différentes vues de l’application',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 12),
              SegmentedButton<UserRole>(
                segments: const [
                  ButtonSegment(value: UserRole.pompier, label: Text('Pompier')),
                  ButtonSegment(value: UserRole.chefDeGarde, label: Text('Chef')),
                  ButtonSegment(value: UserRole.admin, label: Text('Admin')),
                ],
                selected: {u.role},
                onSelectionChanged: (s) => state.setUserRole(s.first),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.coral,
                    side: const BorderSide(color: AppColors.coral),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    state.simulateIncomingIntervention();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Intervention simulée (temps réel).')),
                    );
                  },
                  icon: const Icon(Icons.wifi_tethering),
                  label: const Text('Démo temps réel : simuler une intervention'),
                ),
              ),
            ],
            if (!AppConfig.useMockData) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Connexion API',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppConfig.apiBaseUrl,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'La session est mémorisée sur l’appareil : vous restez connecté après fermeture. '
                      'Utilisez « Déconnexion » pour changer de compte.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                    ),
                    if (state.lastError != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        state.lastError!.replaceFirst('Exception: ', ''),
                        style: const TextStyle(color: Color(0xFFFF8A80), fontSize: 12),
                      ),
                    ],
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: state.loading ? null : () => state.refresh(),
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Recharger les données'),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: Colors.white24),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => context.read<AuthController>().signOut(),
                icon: const Icon(Icons.logout),
                label: const Text('Déconnexion'),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  letterSpacing: 0.5,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
