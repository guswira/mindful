import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/spacing.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/glass_theme.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../domain/exercise_stats.dart';
import '../breathing_labels.dart';
import 'exercise_calendar_grid.dart';

/// Month-by-month calendar of breathing practice. Tapping a day shows its
/// sessions and time below the grid; otherwise it shows the month's
/// totals. Can't page past the current month.
class ExerciseCalendarCard extends StatefulWidget {
  const ExerciseCalendarCard({required this.stats, this.now, super.key});

  final ExerciseStats stats;

  /// Overrides the current time (tests).
  final DateTime? now;

  @override
  State<ExerciseCalendarCard> createState() => _ExerciseCalendarCardState();
}

class _ExerciseCalendarCardState extends State<ExerciseCalendarCard> {
  late final DateTime _today = DateUtils.dateOnly(widget.now ?? DateTime.now());
  late DateTime _month = DateTime(_today.year, _today.month);
  DateTime? _selected;

  bool get _isCurrentMonth =>
      _month.year == _today.year && _month.month == _today.month;

  void _changeMonth(int delta) => setState(() {
    _month = DateTime(_month.year, _month.month + delta);
    _selected = null;
  });

  void _toggleDay(DateTime day) =>
      setState(() => _selected = day == _selected ? null : day);

  String _summary(AppLocalizations l10n) {
    final selected = _selected;
    if (selected == null) {
      final month = widget.stats.monthActivity(_month);
      return l10n.exerciseCalendarMonth(
        month.sessions,
        l10n.exerciseDuration(month.time),
      );
    }
    final date = DateFormat.MMMd().format(selected);
    final day = widget.stats.byDay[selected];
    if (day == null) {
      return l10n.exerciseCalendarDayEmpty(date);
    }
    return l10n.exerciseCalendarDay(
      date,
      day.sessions,
      l10n.exerciseDuration(day.time),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final textTheme = Theme.of(context).textTheme;
    return GlassCard(
      padding: const EdgeInsets.fromLTRB(12, Spacing.sm, 12, Spacing.md),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                tooltip: l10n.exerciseCalendarPrevious,
                onPressed: () => _changeMonth(-1),
              ),
              Expanded(
                child: Text(
                  DateFormat.yMMMM().format(_month),
                  textAlign: TextAlign.center,
                  style: textTheme.titleMedium?.copyWith(color: Colors.white),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                tooltip: l10n.exerciseCalendarNext,
                onPressed: _isCurrentMonth ? null : () => _changeMonth(1),
              ),
            ],
          ),
          ExerciseCalendarGrid(
            month: _month,
            today: _today,
            byDay: widget.stats.byDay,
            selected: _selected,
            onDayTap: _toggleDay,
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            _summary(l10n),
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(color: glass.textSecondary),
          ),
        ],
      ),
    );
  }
}
