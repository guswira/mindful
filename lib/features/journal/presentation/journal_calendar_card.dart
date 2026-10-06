import 'package:flutter/material.dart';

import '../../../core/constants/spacing.dart';
import '../../../core/theme/glass_theme.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/month_calendar.dart';

/// Month calendar for the journal history: days with entries are filled
/// journalAccent, deeper the more entries. Paging and selection state
/// live in the caller, which also filters the list below by them.
class JournalCalendarCard extends StatelessWidget {
  const JournalCalendarCard({
    required this.month,
    required this.today,
    required this.countsByDay,
    required this.selected,
    required this.onMonthChanged,
    required this.onDayTap,
    super.key,
  });

  final DateTime month;
  final DateTime today;
  final Map<DateTime, int> countsByDay;
  final DateTime? selected;

  /// Called with -1 / +1; never offered past [today]'s month.
  final ValueChanged<int> onMonthChanged;
  final ValueChanged<DateTime> onDayTap;

  bool get _isCurrentMonth =>
      month.year == today.year && month.month == today.month;

  double _tint(DateTime day) {
    final count = countsByDay[day] ?? 0;
    return count == 0 ? 0 : (0.3 + 0.15 * (count - 1)).clamp(0.0, 0.75);
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.fromLTRB(12, Spacing.sm, 12, Spacing.md),
      child: Column(
        children: [
          MonthCalendarHeader(
            month: month,
            onPrevious: () => onMonthChanged(-1),
            onNext: _isCurrentMonth ? null : () => onMonthChanged(1),
          ),
          MonthCalendarGrid(
            month: month,
            today: today,
            accent: Theme.of(context).extension<GlassTheme>()!.journalAccent,
            tintFor: _tint,
            selected: selected,
            onDayTap: onDayTap,
          ),
        ],
      ),
    );
  }
}
