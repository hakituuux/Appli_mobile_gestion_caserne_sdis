import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/equipe.dart';
import '../models/intervention.dart';
import '../providers/app_state.dart';
import '../theme/app_colors.dart';

class InterventionDetailScreen extends StatelessWidget {
  const InterventionDetailScreen({super.key, required this.interventionId});

  final String interventionId;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy HH:mm', 'fr_FR');
    return Consumer<AppState>(
      builder: (context, state, _) {
        final it = state.interventionParId(interventionId);
        if (it == null) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(title: const Text('Détail')),
            body: const Center(
              child: Text('Intervention introuvable.', style: TextStyle(color: AppColors.textSecondary)),
            ),
          );
        }

        final pers = it.personnelEngage(state.personnel.toList());
        final veh = it.vehiculesEngages(state.vehicules.toList());

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(it.type),
            backgroundColor: AppColors.background,
            foregroundColor: AppColors.textPrimary,
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _InfoRow(label: 'Date / heure', value: fmt.format(it.dateHeure)),
              _InfoRow(label: 'Lieu', value: it.lieu),
              _InfoRow(label: 'Statut', value: it.statut.label),
              const SizedBox(height: 8),
              Text(it.resume, style: const TextStyle(color: AppColors.textPrimary, fontSize: 16)),
              const SizedBox(height: 24),
              const Text(
                'Personnel engagé',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              if (pers.isEmpty)
                const Text('—', style: TextStyle(color: AppColors.textSecondary))
              else
                ...pers.map(
                  (p) => ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.person, color: AppColors.textSecondary),
                    title: Text(p.nomComplet, style: const TextStyle(color: AppColors.textPrimary)),
                    subtitle: Text(p.equipe.label, style: const TextStyle(color: AppColors.textSecondary)),
                  ),
                ),
              const SizedBox(height: 24),
              const Text(
                'Véhicules',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              if (veh.isEmpty)
                const Text('—', style: TextStyle(color: AppColors.textSecondary))
              else
                ...veh.map(
                  (v) => ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.local_shipping, color: AppColors.textSecondary),
                    title: Text(v.codification, style: const TextStyle(color: AppColors.textPrimary)),
                    subtitle: Text(v.fonction, style: const TextStyle(color: AppColors.textSecondary)),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
