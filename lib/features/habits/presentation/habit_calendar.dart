import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/glass_theme.dart';
import 'habit_form.dart';
import '../domain/habit_log.dart';

/// Current and longest streak, side by side, both in habitAccent.
class HabitStreakRow extends StatelessWidget {
  const HabitStreakRow({
    required this.current,
    required this.longest,
    super.key,
  });

  final int current;
  final int longest;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _StreakStat(
          label: context.l10n.habitCurrentStreak,
          value: current,
          color: glass.habitAccent,
        ),
        _StreakStat(
          label: context.l10n.habitLongestStreak,
          value: longest,
          color: glass.habitAccent,
        ),
      ],
    );
  }
}

class _StreakStat extends StatelessWidget {
  const _StreakStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$value',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(color: color),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

/// The displayed month's name, with prev/next controls.
class HabitMonthHeader extends StatelessWidget {
  const HabitMonthHeader({
    required this.month,
    required this.onPrevious,
    required this.onNext,
    super.key,
  });

  final DateTime month;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(icon: const Icon(Icons.chevron_left), onPressed: onPrevious),
        Text(
          DateFormat.yMMMM().format(month),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        IconButton(icon: const Icon(Icons.chevron_right), onPressed: onNext),
      ],
    );
  }
}

/// A full month grid with a colored dot on each completed day. Tapping a
/// completed day calls [onDayTap] with that day's log.
class HabitMonthGrid extends StatelessWidget {
  const HabitMonthGrid({
    required this.month,
    required this.color,
    required this.logsByDate,
    required this.onDayTap,
    super.key,
  });

  final DateTime month;
  final Color color;
  final Map<DateTime, HabitLog> logsByDate;
  final ValueChanged<HabitLog> onDayTap;

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final leadingBlanks = DateTime(month.year, month.month).weekday - 1;

    return Column(
      children: [
        Row(
          children: [
            for (final label in habitWeekdayLabels(context.l10n))
              Expanded(
                child: Center(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
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
              _DayCell(
                date: DateTime(month.year, month.month, day),
                color: color,
                log: logsByDate[DateTime(month.year, month.month, day)],
                onTap: onDayTap,
              ),
          ],
        ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.color,
    required this.log,
    required this.onTap,
  });

  final DateTime date;
  final Color color;
  final HabitLog? log;
  final ValueChanged<HabitLog> onTap;

  @override
  Widget build(BuildContext context) {
    final log = this.log;
    return InkWell(
      onTap: log == null ? null : () => onTap(log),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('${date.day}', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 2),
          if (log != null)
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
        ],
      ),
    );
  }
}
