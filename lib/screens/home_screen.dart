// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../config/app_config.dart';
import '../data/app_constants.dart';
import '../models/intervention.dart';
import '../models/user_role.dart';
import '../providers/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/dashboard_sheets.dart';
import '../widgets/section_header.dart';

/// Accueil : effectifs, armement, interventions.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy HH:mm', 'fr_FR');
    return Consumer<AppState>(
      builder: (context, state, _) {
        final u = state.user;
        final enCours = state.interventionsEnCours();
        final historique = state.historique7Jours();
        final armementPct = state.armementPct;

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Bonjour,', style: TextStyle(color: AppColors.textSecondary)),
                      Text(
                        u.nomComplet,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        u.caserneName ?? AppConstants.centrePrincipal,
                        style: TextStyle(color: AppColors.textSecondary.withOpacity(0.9), fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.coral.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: AppColors.coral, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        u.role.label,
                        style: const TextStyle(color: AppColors.coral, fontWeight: FontWeight.w600, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (!state.loading && state.personnel.isEmpty && state.vehicules.isEmpty) ...[
              const SizedBox(height: 16),
              _DarkInfoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Données indisponibles',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.lastError != null
                          ? 'La connexion à l’API a échoué. Utilisez « Réessayer » en haut de l’écran.'
                          : AppConfig.useMockData
                              ? 'Aucune donnée locale chargée.'
                              : 'Vérifiez que l’API tourne sur le PC (${AppConfig.apiBaseUrl}) avec `npm run dev` et `npm run seed`, puis tirez pour actualiser ou allez dans Paramètres.',
                      style: TextStyle(color: AppColors.textSecondary.withOpacity(0.95), fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _DashStatCard(
                    icon: Icons.groups,
                    title: 'Disponibles',
                    value: '${state.pompiersDisponibles}',
                    subtitle: 'sur ${state.effectifTheorique}',
                    onTap: () => showPersonnelDisponibleSheet(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DashStatCard(
                    icon: Icons.shield_outlined,
                    title: 'Armement',
                    value: '$armementPct %',
                    subtitle: 'exigences / parc',
                    onTap: () => showArmementVehiculesSheet(context),
                  ),
                ),
              ],
            ),
            const SectionHeader(title: 'Interventions en cours'),
            if (enCours.isEmpty)
              _DarkInfoCard(
                child: Text(
                  'Aucune intervention en cours.',
                  style: TextStyle(color: AppColors.textSecondary.withOpacity(0.9)),
                ),
              )
            else
              ...enCours.map((it) => _HomeInterventionTile(it: it, fmt: fmt)),
            const SectionHeader(title: 'Historique (7 derniers jours)'),
            ...historique.map((it) => _HomeInterventionTile(it: it, fmt: fmt, dense: true)),
          ],
        );
      },
    );
  }
}

class _DashStatCard extends StatelessWidget {
  const _DashStatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppColors.coral, size: 28),
              const SizedBox(height: 10),
              Text(title, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DarkInfoCard extends StatelessWidget {
  const _DarkInfoCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: child,
    );
  }
}

class _HomeInterventionTile extends StatelessWidget {
  const _HomeInterventionTile({
    required this.it,
    required this.fmt,
    this.dense = false,
  });

  final Intervention it;
  final DateFormat fmt;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final enCours = it.statut == StatutIntervention.enCours;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        dense: dense,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Icon(
          enCours ? Icons.warning_amber_rounded : Icons.check_circle_outline,
          color: enCours ? AppColors.coral : AppColors.textSecondary,
        ),
        title: Text(it.type, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        subtitle: Text(
          '${fmt.format(it.dateHeure)} — ${it.lieu}',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: enCours ? AppColors.coral.withOpacity(0.15) : AppColors.greenSkill.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            it.statut.label,
            style: TextStyle(
              fontSize: 11,
              color: enCours ? AppColors.coral : AppColors.greenSkill,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
