// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/personnel_en_intervention.dart';
import '../models/pompier_personnel.dart';
import '../models/vehicle.dart';
import '../providers/app_state.dart';
import '../theme/app_colors.dart';
import '../utils/armement.dart';

Future<void> showPersonnelDisponibleSheet(BuildContext context) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surfaceElevated,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        minChildSize: 0.45,
        maxChildSize: 0.95,
        builder: (context, scroll) {
          return Consumer<AppState>(
            builder: (context, state, _) {
              final disponibles = state.personnelDisponibles;
              final enIntervention = state.personnelEnIntervention;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Personnel disponible',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      controller: scroll,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      children: [
                        if (disponibles.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              'Aucun personnel disponible / sollicitable.',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          )
                        else
                          ...disponibles.map(
                            (p) => _PersonnelRow(
                              p: p,
                              onTap: () {
                                Navigator.pop(context);
                                showPersonnelDetailSheet(context, p);
                              },
                            ),
                          ),
                        if (enIntervention.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const Text(
                            'En intervention',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF8A80),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Engagés sur une intervention en cours — non sollicitables.',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          ),
                          const SizedBox(height: 8),
                          ...enIntervention.map(
                            (e) => _PersonnelEnInterventionRow(entry: e),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      );
    },
  );
}

Future<void> showPersonnelDetailSheet(BuildContext context, PompierPersonnel p) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surfaceElevated,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(ctx).bottom),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.arrow_back, color: AppColors.coral, size: 20),
                    label: const Text('Retour', style: TextStyle(color: AppColors.coral)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.greenSkill.withOpacity(0.25),
                  child: const Icon(Icons.person, size: 44, color: AppColors.textPrimary),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  p.nomComplet,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Center(
                child: Text(
                  p.grade,
                  style: const TextStyle(color: AppColors.coral, fontSize: 15),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Compétences :',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: p.competences
                    .map(
                      (t) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.greenSkill),
                          color: AppColors.background,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check, size: 16, color: AppColors.greenSkill),
                            const SizedBox(width: 4),
                            Text(t, style: const TextStyle(color: AppColors.greenSkill, fontSize: 12)),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 24),
              Consumer<AppState>(
                builder: (context, state, _) {
                  final contrib = vehiculesAvecContribution(p, state.vehicules);
                  if (contrib.isEmpty) {
                    return const Text(
                      'Aucun engin du parc ne requiert directement ces compétences.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Engins concernés par vos compétences :',
                        style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      ...contrib.map(
                        (v) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.local_shipping_outlined, color: Color(0xFF64B5F6)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      v.codification,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Requis : ${v.competencesRequises.join(', ')}',
                                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _PersonnelRow extends StatelessWidget {
  const _PersonnelRow({required this.p, required this.onTap});

  final PompierPersonnel p;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final competences = p.competences;
    const maxShow = 3;
    final shown = competences.take(maxShow).toList();
    final extra = competences.length > maxShow ? competences.length - maxShow : 0;

    return Card(
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.greenSkill.withOpacity(0.2),
                child: Icon(
                  p.id == 'u1' ? Icons.star : Icons.person,
                  color: AppColors.greenSkill,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.nomComplet,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(p.grade, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        ...shown.map(
                          (t) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(t, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                          ),
                        ),
                        if (extra > 0)
                          Text('+$extra', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _PersonnelEnInterventionRow extends StatelessWidget {
  const _PersonnelEnInterventionRow({required this.entry});

  final PersonnelEnIntervention entry;

  @override
  Widget build(BuildContext context) {
    final p = entry.personnel;
    return Card(
      color: const Color(0xFF2A1A1A),
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0x44FF8A80)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: const Color(0x33E53935),
              child: const Icon(Icons.local_fire_department, color: Color(0xFFFF8A80), size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.nomComplet,
                    style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                  Text('${p.grade} · En intervention', style: const TextStyle(color: Color(0xFFFF8A80), fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(
                    '${entry.interventionNumero} — ${entry.typeIntervention}',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                  if (entry.lieu.isNotEmpty)
                    Text(entry.lieu, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showArmementVehiculesSheet(BuildContext context) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surfaceElevated,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.8,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (context, scroll) {
          return Consumer<AppState>(
            builder: (context, state, _) {
              final vehicules = state.vehiculesAuParc;
              final pool = poolCompetences(
                state.personnelDisponibles.isNotEmpty
                    ? state.personnelDisponibles
                    : state.personnel,
              );
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Armement véhicules',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: vehicules.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24),
                              child: Text(
                                'Tous les engins sont engagés en intervention — aucun calcul d’armement au parc.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppColors.textSecondary),
                              ),
                            ),
                          )
                        : ListView.builder(
                            controller: scroll,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: vehicules.length,
                            itemBuilder: (context, i) {
                              final v = vehicules[i];
                              return _VehicleArmementTile(v: v, pool: pool);
                            },
                          ),
                  ),
                ],
              );
            },
          );
        },
      );
    },
  );
}

class _VehicleArmementTile extends StatelessWidget {
  const _VehicleArmementTile({required this.v, required this.pool});

  final Vehicle v;
  final Set<String> pool;

  @override
  Widget build(BuildContext context) {
    final pct = (tauxCouvertureVehicule(v, pool) * 100).round();
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: const BoxDecoration(
                color: AppColors.greenSkill,
                borderRadius: BorderRadius.horizontal(left: Radius.circular(14)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            v.codification,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            v.fonction,
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${v.competencesRequises.length} compétence(s) requise(s)',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: List.generate(
                              v.equipageDots,
                              (_) => Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.greenSkill,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '$pct%',
                      style: const TextStyle(
                        color: AppColors.greenSkill,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
