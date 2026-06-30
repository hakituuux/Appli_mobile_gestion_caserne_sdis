// ignore_for_file: deprecated_member_use

/// Liste des interventions (en cours + historique).

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/intervention.dart';
import '../providers/app_state.dart';
import '../theme/app_colors.dart';
import 'intervention_detail_screen.dart';

enum _FiltreInter { toutes, enCours, terminees }

class InterventionsScreen extends StatefulWidget {
  const InterventionsScreen({super.key});

  @override
  State<InterventionsScreen> createState() => _InterventionsScreenState();
}

class _InterventionsScreenState extends State<InterventionsScreen> {
  _FiltreInter _filtre = _FiltreInter.toutes;

  @override
  Widget build(BuildContext context) {
    final fmtDate = DateFormat('dd/MM', 'fr_FR');
    final fmtTime = DateFormat.Hm('fr_FR');

    return Consumer<AppState>(
      builder: (context, state, _) {
        final all = List<Intervention>.from(state.interventions)
          ..sort((a, b) => b.dateHeure.compareTo(a.dateHeure));

        final enCours = all.where((i) => i.statut == StatutIntervention.enCours).length;
        final term = all.where((i) => i.statut == StatutIntervention.terminee).length;

        final list = switch (_filtre) {
          _FiltreInter.toutes => all,
          _FiltreInter.enCours => all.where((i) => i.statut == StatutIntervention.enCours).toList(),
          _FiltreInter.terminees => all.where((i) => i.statut == StatutIntervention.terminee).toList(),
        };

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(
                'Interventions',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '${all.length} intervention(s)',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  _FilterChip(
                    label: 'Toutes (${all.length})',
                    selected: _filtre == _FiltreInter.toutes,
                    onTap: () => setState(() => _filtre = _FiltreInter.toutes),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'En cours ($enCours)',
                    selected: _filtre == _FiltreInter.enCours,
                    onTap: () => setState(() => _filtre = _FiltreInter.enCours),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Terminées ($term)',
                    selected: _filtre == _FiltreInter.terminees,
                    onTap: () => setState(() => _filtre = _FiltreInter.terminees),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: list.isEmpty
                  ? const Center(
                      child: Text('Aucune intervention.', style: TextStyle(color: AppColors.textSecondary)),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      itemCount: list.length,
                      itemBuilder: (context, i) {
                        final it = list[i];
                        final enC = it.statut == StatutIntervention.enCours;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Material(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => InterventionDetailScreen(interventionId: it.id),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: enC
                                            ? AppColors.coral.withOpacity(0.2)
                                            : AppColors.surfaceElevated,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        it.type.toLowerCase().contains('secours')
                                            ? Icons.medical_services_outlined
                                            : Icons.local_fire_department,
                                        color: enC ? AppColors.coral : AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            it.type,
                                            style: const TextStyle(
                                              color: AppColors.textPrimary,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            it.lieu,
                                            style: const TextStyle(
                                              color: AppColors.textSecondary,
                                              fontSize: 13,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            children: [
                                              const Icon(Icons.calendar_today, size: 14, color: AppColors.textSecondary),
                                              const SizedBox(width: 4),
                                              Text(fmtDate.format(it.dateHeure), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                              const SizedBox(width: 12),
                                              const Icon(Icons.schedule, size: 14, color: AppColors.textSecondary),
                                              const SizedBox(width: 4),
                                              Text(fmtTime.format(it.dateHeure), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                              const SizedBox(width: 12),
                                              const Icon(Icons.groups, size: 14, color: AppColors.textSecondary),
                                              const SizedBox(width: 4),
                                              Text('${it.personnelIds.length}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: enC
                                                ? const Color(0xFF3D2A1F)
                                                : AppColors.greenSkillBg,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            it.statut.label,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: enC ? AppColors.coral : AppColors.greenSkill,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.coral : AppColors.surface,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
