import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/glass_theme.dart';
import '../../features/habits/presentation/habit_form.dart';

/// Month title between previous/next chevrons. [onNext] null disables
/// paging forward (callers stop at the current month).
class MonthCalendarHeader extends StatelessWidget {
  const MonthCalendarHeader({
    required this.month,
    required this.onPrevious,
    required this.onNext,
    super.key,
  });

  final DateTime month;
  final VoidCallback onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          tooltip: l10n.exerciseCalendarPrevious,
          onPressed: onPrevious,
        ),
        Expanded(
          child: Text(
            DateFormat.yMMMM().format(month),
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.white),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          tooltip: l10n.exerciseCalendarNext,
          onPressed: onNext,
        ),
      ],
    );
  }
}

/// [month]'s days, Monday first, each filled with [accent] at the alpha
/// [tintFor] returns for it (0 = no fill). [today] is ringed in [accent],
/// [selected] in white.
class MonthCalendarGrid extends StatelessWidget {
  const MonthCalendarGrid({
    required this.month,
    required this.today,
    required this.accent,
    required this.tintFor,
    required this.selected,
    required this.onDayTap,
    super.key,
  });

  final DateTime month;

  /// Local midnight today.
  final DateTime today;
  final Color accent;

  /// Fill alpha for a local-midnight date, 0–1.
  final double Function(DateTime day) tintFor;
  final DateTime? selected;
  final ValueChanged<DateTime> onDayTap;

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final leadingBlanks = DateTime(month.year, month.month).weekday - 1;
    final labelStyle = Theme.of(context).textTheme.labelSmall;
    return Column(
      children: [
        Row(
          children: [
            for (final label in habitWeekdayLabels(context.l10n))
              Expanded(
                child: Center(child: Text(label, style: labelStyle)),
              ),
          ],
        ),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (var i = 0; i < leadingBlanks; i++) const SizedBox.shrink(),
            for (var day = 1; day <= daysInMonth; day++)
              _dayCell(DateTime(month.year, month.month, day)),
          ],
        ),
      ],
    );
  }

  Widget _dayCell(DateTime date) => _DayCell(
    date: date,
    accent: accent,
    tint: tintFor(date),
    isToday: date == today,
    isSelected: date == selected,
    onTap: onDayTap,
  );
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.accent,
    required this.tint,
    required this.isToday,
    required this.isSelected,
    required this.onTap,
  });

  final DateTime date;
  final Color accent;
  final double tint;
  final bool isToday;
  final bool isSelected;
  final ValueChanged<DateTime> onTap;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final borderColor = isSelected
        ? Colors.white
        : isToday
        ? accent
        : Colors.transparent;
    return GestureDetector(
      onTap: () => onTap(date),
      child: Container(
        margin: const EdgeInsets.all(3),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: accent.withValues(alpha: tint),
          border: Border.all(color: borderColor),
        ),
        child: Text(
          '${date.day}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: tint > 0 ? Colors.white : glass.textSecondary,
          ),
        ),
      ),
    );
  }
}
