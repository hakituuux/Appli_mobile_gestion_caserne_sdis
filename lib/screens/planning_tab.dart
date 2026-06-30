import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_role.dart';
import '../providers/app_state.dart';
import '../theme/app_colors.dart';
import 'planning_equipe_screen.dart';
import 'planning_personnel_screen.dart';

/// Onglet planif : perso seule, ou perso/équipe si chef/admin.
class PlanningTab extends StatefulWidget {
  const PlanningTab({super.key});

  @override
  State<PlanningTab> createState() => _PlanningTabState();
}

class _PlanningTabState extends State<PlanningTab> {
  /// false = perso ; true = équipe (chefs).
  bool _modeEquipe = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final chef = state.user.role == UserRole.chefDeGarde || state.user.role == UserRole.admin;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(
                'Planification',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (chef) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: _PersonnelEquipeToggle(
                  equipeSelected: _modeEquipe,
                  onChanged: (v) => setState(() => _modeEquipe = v),
                ),
              ),
            ],
            Expanded(
              child: chef && _modeEquipe
                  ? const PlanningEquipePanel()
                  : const PlanningPersonnelPanel(),
            ),
          ],
        );
      },
    );
  }
}

class _PersonnelEquipeToggle extends StatelessWidget {
  const _PersonnelEquipeToggle({
    required this.equipeSelected,
    required this.onChanged,
  });

  final bool equipeSelected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: _Seg(
              icon: Icons.person_outline,
              label: 'Personnelle',
              active: !equipeSelected,
              onTap: () => onChanged(false),
            ),
          ),
          Expanded(
            child: _Seg(
              icon: Icons.groups_2_outlined,
              label: 'Équipe',
              active: equipeSelected,
              onTap: () => onChanged(true),
            ),
          ),
        ],
      ),
    );
  }
}

class _Seg extends StatelessWidget {
  const _Seg({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? AppColors.coral : Colors.transparent,
      borderRadius: BorderRadius.circular(26),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(26),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: active ? Colors.white : AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: active ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
