// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/disponibilite_type.dart';
import '../models/equipe.dart';
import '../models/pompier_personnel.dart';
import '../models/slot_equipe.dart';
import '../providers/app_state.dart';
import '../theme/app_colors.dart';
import '../utils/date_utils.dart';

/// Planif équipe : filtres A/B/C, semaine, créneaux par pompier.
class PlanningEquipePanel extends StatefulWidget {
  const PlanningEquipePanel({super.key});

  @override
  State<PlanningEquipePanel> createState() => _PlanningEquipePanelState();
}

class _PlanningEquipePanelState extends State<PlanningEquipePanel> {
  DateTime _focusedDay = DateTime.now();
  Equipe _equipe = Equipe.A;

  @override
  Widget build(BuildContext context) {
    final weekStart = startOfWeek(_focusedDay);
    final dfDay = DateFormat('d MMM', 'fr_FR');
    final dfTime = DateFormat.Hm('fr_FR');

    return Consumer<AppState>(
      builder: (context, state, _) {
        final roster = state.personnel.where((p) => p.equipe == _equipe).toList();

        return Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: Equipe.values.map((e) {
                      final sel = _equipe == e;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Material(
                          color: sel ? AppColors.coral : AppColors.surface,
                          borderRadius: BorderRadius.circular(24),
                          child: InkWell(
                            onTap: () => setState(() => _equipe = e),
                            borderRadius: BorderRadius.circular(24),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                              child: Text(
                                e.label,
                                style: TextStyle(
                                  color: sel ? Colors.white : AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TableCalendar<void>(
                    firstDay: DateTime.utc(2024, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    calendarFormat: CalendarFormat.week,
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    locale: 'fr_FR',
                    selectedDayPredicate: (d) => isSameDay(d, _focusedDay),
                    onDaySelected: (selected, focused) {
                      setState(() => _focusedDay = focused);
                    },
                    onPageChanged: (focused) => setState(() => _focusedDay = focused),
                    calendarStyle: CalendarStyle(
                      defaultTextStyle: const TextStyle(color: AppColors.textPrimary),
                      weekendTextStyle: const TextStyle(color: AppColors.textSecondary),
                      todayDecoration: BoxDecoration(
                        color: AppColors.coral.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: const BoxDecoration(
                        color: AppColors.coral,
                        shape: BoxShape.circle,
                      ),
                      selectedTextStyle: const TextStyle(color: Colors.white),
                    ),
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                      leftChevronIcon: Icon(Icons.chevron_left, color: AppColors.textPrimary),
                      rightChevronIcon: Icon(Icons.chevron_right, color: AppColors.textPrimary),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Semaine du ${dfDay.format(weekStart)}',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 12),
                ...roster.map((p) => _PersonnelEquipeCard(
                      p: p,
                      weekStart: weekStart,
                      dfDay: dfDay,
                      dfTime: dfTime,
                      onEditSlot: (s) => _openSlotEditor(context, state, s),
                    )),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.coral,
                    side: const BorderSide(color: AppColors.coral, style: BorderStyle.solid),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => _openManualAdd(context, state),
                  icon: const Icon(Icons.person_add_alt_outlined),
                  label: const Text('Ajouter un membre hors équipe'),
                ),
              ],
            ),
            Positioned(
              right: 16,
              bottom: 16,
              child: FloatingActionButton(
                backgroundColor: AppColors.coral,
                onPressed: () => _openManualAdd(context, state),
                child: const Icon(Icons.add),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openSlotEditor(BuildContext context, AppState state, SlotEquipe slot) async {
    DisponibiliteType type = slot.type;
    DateTime debut = slot.debut;
    DateTime fin = slot.fin;

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSt) {
            return AlertDialog(
              backgroundColor: AppColors.surfaceElevated,
              title: Text(slot.personnelNom, style: const TextStyle(color: AppColors.textPrimary)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ListTile(
                      title: const Text('Début', style: TextStyle(color: AppColors.textSecondary)),
                      subtitle: Text(
                        DateFormat('dd/MM/yyyy HH:mm', 'fr_FR').format(debut),
                        style: const TextStyle(color: AppColors.textPrimary),
                      ),
                      onTap: () async {
                        final picked = await _pickDateTime(ctx, debut);
                        if (picked != null) setSt(() => debut = picked);
                      },
                    ),
                    ListTile(
                      title: const Text('Fin', style: TextStyle(color: AppColors.textSecondary)),
                      subtitle: Text(
                        DateFormat('dd/MM/yyyy HH:mm', 'fr_FR').format(fin),
                        style: const TextStyle(color: AppColors.textPrimary),
                      ),
                      onTap: () async {
                        final picked = await _pickDateTime(ctx, fin);
                        if (picked != null) setSt(() => fin = picked);
                      },
                    ),
                    const Text('Type', style: TextStyle(color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      children: DisponibiliteType.values.map((t) {
                        final sel = type == t;
                        return ChoiceChip(
                          label: Text(t.label),
                          selected: sel,
                          onSelected: (_) => setSt(() => type = t),
                          selectedColor: AppColors.coral.withOpacity(0.3),
                          labelStyle: TextStyle(color: sel ? AppColors.textPrimary : AppColors.textSecondary),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Annuler'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: AppColors.coral),
                  onPressed: () async {
                    if (!fin.isAfter(debut)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('La fin doit être après le début.')),
                      );
                      return;
                    }
                    try {
                      await state.updateSlotEquipe(
                        slot.id,
                        debut: debut,
                        fin: fin,
                        type: type,
                        statut: SlotEquipeStatut.valide,
                      );
                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Créneau mis à jour.')),
                      );
                    } catch (e) {
                      if (!ctx.mounted) return;
                      final msg = e.toString().replaceFirst('Exception: ', '');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(msg)),
                      );
                    }
                  },
                  child: const Text('Valider'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _openManualAdd(BuildContext context, AppState state) async {
    final roster = state.personnel.where((p) => p.equipe == _equipe).toList();
    PompierPersonnel? selectedPers = roster.isNotEmpty ? roster.first : null;
    Equipe eq = _equipe;
    DisponibiliteType type = DisponibiliteType.disponible;
    var horsEquipe = false;
    var debut = DateTime.now();
    var fin = DateTime.now().add(const Duration(hours: 8));

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSt) {
            return AlertDialog(
              backgroundColor: AppColors.surfaceElevated,
              title: const Text('Disponibilité manuelle', style: TextStyle(color: AppColors.textPrimary)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (roster.isEmpty)
                      const Text(
                        'Aucun agent dans cette équipe.',
                        style: TextStyle(color: AppColors.textSecondary),
                      )
                    else
                      DropdownMenu<PompierPersonnel>(
                        initialSelection: selectedPers,
                        label: const Text('Personnel'),
                        dropdownMenuEntries: roster
                            .map(
                              (p) => DropdownMenuEntry<PompierPersonnel>(
                                value: p,
                                label: p.nomComplet,
                              ),
                            )
                            .toList(),
                        onSelected: (v) => setSt(() => selectedPers = v),
                      ),
                    const SizedBox(height: 12),
                    DropdownMenu<Equipe>(
                      initialSelection: eq,
                      label: const Text('Équipe affichée'),
                      dropdownMenuEntries: Equipe.values
                          .map((e) => DropdownMenuEntry<Equipe>(value: e, label: e.label))
                          .toList(),
                      onSelected: (v) => setSt(() => eq = v ?? Equipe.A),
                    ),
                    CheckboxListTile(
                      title: const Text('Hors équipe (renfort)', style: TextStyle(color: AppColors.textPrimary)),
                      value: horsEquipe,
                      onChanged: (v) => setSt(() => horsEquipe = v ?? false),
                    ),
                    ListTile(
                      title: const Text('Début', style: TextStyle(color: AppColors.textSecondary)),
                      subtitle: Text(
                        DateFormat('dd/MM/yyyy HH:mm', 'fr_FR').format(debut),
                        style: const TextStyle(color: AppColors.textPrimary),
                      ),
                      onTap: () async {
                        final p = await _pickDateTime(ctx, debut);
                        if (p != null) setSt(() => debut = p);
                      },
                    ),
                    ListTile(
                      title: const Text('Fin', style: TextStyle(color: AppColors.textSecondary)),
                      subtitle: Text(
                        DateFormat('dd/MM/yyyy HH:mm', 'fr_FR').format(fin),
                        style: const TextStyle(color: AppColors.textPrimary),
                      ),
                      onTap: () async {
                        final p = await _pickDateTime(ctx, fin);
                        if (p != null) setSt(() => fin = p);
                      },
                    ),
                    const Text('Type', style: TextStyle(color: AppColors.textSecondary)),
                    Wrap(
                      spacing: 6,
                      children: DisponibiliteType.values.map((t) {
                        final sel = type == t;
                        return ChoiceChip(
                          label: Text(t.label),
                          selected: sel,
                          onSelected: (_) => setSt(() => type = t),
                          selectedColor: AppColors.coral.withOpacity(0.3),
                          labelStyle: TextStyle(color: sel ? AppColors.textPrimary : AppColors.textSecondary),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: AppColors.coral),
                  onPressed: () async {
                    if (selectedPers == null) return;
                    if (!fin.isAfter(debut)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('La fin doit être après le début.')),
                      );
                      return;
                    }
                    try {
                      await state.addSlotEquipeManuel(
                        personnelNom: selectedPers!.nomComplet,
                        personnelId: selectedPers!.id,
                        equipe: eq,
                        debut: debut,
                        fin: fin,
                        type: type,
                        horsEquipe: horsEquipe,
                      );
                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Créneau enregistré.')),
                      );
                    } catch (e) {
                      if (!ctx.mounted) return;
                      final msg = e.toString().replaceFirst('Exception: ', '');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(msg)),
                      );
                    }
                  },
                  child: const Text('Ajouter'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<DateTime?> _pickDateTime(BuildContext context, DateTime initial) async {
    final d = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2024),
      lastDate: DateTime(2035),
      locale: const Locale('fr', 'FR'),
    );
    if (d == null) return null;
    if (!context.mounted) return null;
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (t == null) return null;
    return DateTime(d.year, d.month, d.day, t.hour, t.minute);
  }
}

class _PersonnelEquipeCard extends StatelessWidget {
  const _PersonnelEquipeCard({
    required this.p,
    required this.weekStart,
    required this.dfDay,
    required this.dfTime,
    required this.onEditSlot,
  });

  final PompierPersonnel p;
  final DateTime weekStart;
  final DateFormat dfDay;
  final DateFormat dfTime;
  final void Function(SlotEquipe) onEditSlot;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final slots = state.slotsPourPersonnelEtSemaine(p.id, weekStart);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.nomComplet,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          p.grade,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.coral.withOpacity(0.2),
                      foregroundColor: AppColors.coral,
                    ),
                    onPressed: () {
                      /* même flux que saisie manuelle ciblée — simplifié : snack */
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Ajout rapide : utilisez le bouton + en bas.')),
                      );
                    },
                    icon: const Icon(Icons.add, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (slots.isEmpty)
                Text(
                  'Aucune disponibilité envoyée',
                  style: TextStyle(
                    color: AppColors.textSecondary.withOpacity(0.85),
                    fontStyle: FontStyle.italic,
                  ),
                )
              else
                ...slots.map((s) {
                  final pending = s.statut == SlotEquipeStatut.enAttenteValidation;
                  return Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border(
                        left: BorderSide(
                          color: pending ? AppColors.disponible : AppColors.textSecondary,
                          width: 3,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${dfDay.format(s.debut)}   ${dfTime.format(s.debut)} – ${dfTime.format(s.fin)}',
                                style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                              ),
                            ),
                            if (pending)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.yellowAst.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'En attente',
                                  style: TextStyle(color: AppColors.yellowAst, fontSize: 11),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          s.type.label,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                        if (pending) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.check_circle, color: AppColors.disponible),
                                onPressed: () {
                                  context.read<AppState>().validerSlot(s.id);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.cancel, color: AppColors.coral),
                                onPressed: () {},
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit, color: Color(0xFF64B5F6)),
                                onPressed: () => onEditSlot(s),
                              ),
                            ],
                          ),
                        ] else
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () => onEditSlot(s),
                              icon: const Icon(Icons.edit, size: 18, color: AppColors.coral),
                              label: const Text('Modifier', style: TextStyle(color: AppColors.coral)),
                            ),
                          ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }
}
