// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/disponibilite_perso.dart';
import '../models/disponibilite_type.dart';
import '../providers/app_state.dart';
import '../theme/app_colors.dart';

/// Planif perso : calendrier, créneaux du jour, ajout dispo.
class PlanningPersonnelPanel extends StatefulWidget {
  const PlanningPersonnelPanel({super.key});

  @override
  State<PlanningPersonnelPanel> createState() => _PlanningPersonnelPanelState();
}

class _PlanningPersonnelPanelState extends State<PlanningPersonnelPanel> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  List<DisponibilitePerso> _forDay(List<DisponibilitePerso> all, DateTime day) {
    return all.where((d) => _sameDay(d.debut, day)).toList()
      ..sort((a, b) => a.debut.compareTo(b.debut));
  }

  @override
  Widget build(BuildContext context) {
    final dfDayLong = DateFormat('EEEE d MMMM', 'fr_FR');

    return Consumer<AppState>(
      builder: (context, state, _) {
        final all = List.of(state.mesDisponibilites);
        final daySlots = _forDay(all, _selectedDay);

        return Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TableCalendar<DisponibilitePerso>(
                    firstDay: DateTime.utc(2024, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    locale: 'fr_FR',
                    calendarFormat: CalendarFormat.month,
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    selectedDayPredicate: (d) => isSameDay(d, _selectedDay),
                    eventLoader: (day) => _forDay(all, day),
                    onDaySelected: (sel, foc) {
                      setState(() {
                        _selectedDay = sel;
                        _focusedDay = foc;
                      });
                    },
                    onPageChanged: (f) => setState(() => _focusedDay = f),
                    calendarStyle: CalendarStyle(
                      defaultTextStyle: const TextStyle(color: AppColors.textPrimary),
                      weekendTextStyle: const TextStyle(color: AppColors.textSecondary),
                      outsideTextStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.35)),
                      todayDecoration: BoxDecoration(
                        color: AppColors.coral.withOpacity(0.25),
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: const BoxDecoration(
                        color: AppColors.coral,
                        shape: BoxShape.circle,
                      ),
                      todayTextStyle: const TextStyle(color: AppColors.textPrimary),
                      selectedTextStyle: const TextStyle(color: Colors.white),
                      markersMaxCount: 3,
                      markerDecoration: const BoxDecoration(color: Colors.transparent),
                    ),
                    calendarBuilders: CalendarBuilders(
                      markerBuilder: (context, day, events) {
                        if (events.isEmpty) return null;
                        final list = events.cast<DisponibilitePerso>();
                        return Positioned(
                          bottom: 4,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: list.take(3).map((d) {
                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 1),
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: _typeColor(d.type),
                                  shape: BoxShape.circle,
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      },
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      leftChevronIcon: const Icon(Icons.chevron_left, color: AppColors.textPrimary),
                      rightChevronIcon: const Icon(Icons.chevron_right, color: AppColors.textPrimary),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _LegendDot(color: AppColors.disponible, label: 'Disponible'),
                    const SizedBox(width: 12),
                    _LegendDot(color: AppColors.purpleSol, label: 'Sollicitable'),
                    const SizedBox(width: 12),
                    _LegendDot(color: AppColors.yellowAst, label: 'Astreinte'),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _capFirst(dfDayLong.format(_selectedDay)),
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.coral,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () => _openNouvelleDispo(context, state, _selectedDay),
                            icon: const Icon(Icons.add, size: 20),
                            label: const Text('Ajouter'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (daySlots.isEmpty)
                        Text(
                          'Aucun créneau ce jour.',
                          style: TextStyle(color: AppColors.textSecondary.withOpacity(0.9), fontStyle: FontStyle.italic),
                        )
                      else
                        ...daySlots.map(
                          (d) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Text(
                                  DateFormat.Hm('fr_FR').format(d.debut),
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                ),
                                const Text(' — ', style: TextStyle(color: AppColors.textSecondary)),
                                Text(
                                  DateFormat.Hm('fr_FR').format(d.fin),
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _typeColor(d.type).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    d.type.label,
                                    style: TextStyle(color: _typeColor(d.type), fontSize: 11),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              right: 16,
              bottom: 16,
              child: FloatingActionButton(
                backgroundColor: AppColors.coral,
                onPressed: () => _openNouvelleDispo(context, state, _selectedDay),
                child: const Icon(Icons.add),
              ),
            ),
          ],
        );
      },
    );
  }

  Color _typeColor(DisponibiliteType t) {
    return switch (t) {
      DisponibiliteType.disponible => AppColors.disponible,
      DisponibiliteType.sollicitable => AppColors.purpleSol,
      DisponibiliteType.astreinte => AppColors.yellowAst,
    };
  }

  Future<void> _openNouvelleDispo(BuildContext context, AppState state, DateTime day) async {
    var debut = DateTime(day.year, day.month, day.day, 8);
    var fin = DateTime(day.year, day.month, day.day, 20);
    var type = DisponibiliteType.disponible;
    var envoyer = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(ctx).viewPadding.bottom + 20,
          ),
          child: StatefulBuilder(
            builder: (ctx, setSt) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Nouvelle disponibilité',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  Center(
                    child: Text(
                      _capFirst(DateFormat('EEEE d MMMM y', 'fr_FR').format(day)),
                      style: const TextStyle(color: AppColors.coral, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _TimeBox(
                          label: 'Début',
                          time: debut,
                          onTap: () async {
                            final t = await showTimePicker(
                              context: ctx,
                              initialTime: TimeOfDay.fromDateTime(debut),
                            );
                            if (t != null) {
                              setSt(() {
                                debut = DateTime(day.year, day.month, day.day, t.hour, t.minute);
                              });
                            }
                          },
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(Icons.arrow_forward, color: AppColors.textSecondary),
                      ),
                      Expanded(
                        child: _TimeBox(
                          label: 'Fin',
                          time: fin,
                          onTap: () async {
                            final t = await showTimePicker(
                              context: ctx,
                              initialTime: TimeOfDay.fromDateTime(fin),
                            );
                            if (t != null) {
                              setSt(() {
                                fin = DateTime(day.year, day.month, day.day, t.hour, t.minute);
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Type de disponibilité',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: DisponibiliteType.values.map((t) {
                      final sel = type == t;
                      final c = _typeColor(t);
                      return OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: sel ? c : Colors.white24, width: sel ? 2 : 1),
                          backgroundColor: sel ? c.withOpacity(0.15) : null,
                          foregroundColor: AppColors.textPrimary,
                        ),
                        onPressed: () => setSt(() => type = t),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 8),
                            Text(t.label),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Envoyer au chef de garde', style: TextStyle(color: AppColors.textPrimary)),
                    secondary: const Icon(Icons.send_outlined, color: Color(0xFF64B5F6)),
                    value: envoyer,
                    activeThumbColor: AppColors.coral,
                    onChanged: (v) => setSt(() => envoyer = v),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.coral,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () async {
                      if (!fin.isAfter(debut)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('La fin doit être après le début.')),
                        );
                        return;
                      }
                      try {
                        await state.addDisponibilitePerso(
                          debut: debut,
                          fin: fin,
                          envoyerAuChef: envoyer,
                          type: type,
                        );
                        if (!ctx.mounted) return;
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Disponibilité enregistrée.')),
                        );
                      } catch (e) {
                        if (!ctx.mounted) return;
                        final msg = e.toString().replaceFirst('Exception: ', '');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(msg)),
                        );
                      }
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Ajouter'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

String _capFirst(String s) {
  if (s.isEmpty) return s;
  return s[0].toUpperCase() + s.substring(1);
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
      ],
    );
  }
}

class _TimeBox extends StatelessWidget {
  const _TimeBox({
    required this.label,
    required this.time,
    required this.onTap,
  });

  final String label;
  final DateTime time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        const SizedBox(height: 6),
        Material(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              child: Center(
                child: Text(
                  DateFormat.Hm('fr_FR').format(time),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
