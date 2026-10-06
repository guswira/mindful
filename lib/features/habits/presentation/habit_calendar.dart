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

/// A full month grid marking each completed day — with a colored dot, or
/// with [labelFor]'s text (e.g. the action performed) when it's given.
/// Tapping any day up to today calls [onDayTap] with the day and its log
/// (null when nothing was logged); future days aren't tappable.
class HabitMonthGrid extends StatelessWidget {
  const HabitMonthGrid({
    required this.month,
    required this.color,
    required this.logsByDate,
    required this.onDayTap,
    this.labelFor,
    super.key,
  });

  final DateTime month;
  final Color color;
  final Map<DateTime, HabitLog> logsByDate;
  final void Function(DateTime date, HabitLog? log) onDayTap;
  final String Function(HabitLog log)? labelFor;

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final leadingBlanks = DateTime(month.year, month.month).weekday - 1;
    final today = DateUtils.dateOnly(DateTime.now());

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
                labelFor: labelFor,
                onTap: DateTime(month.year, month.month, day).isAfter(today)
                    ? null
                    : onDayTap,
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
    required this.labelFor,
    required this.onTap,
  });

  final DateTime date;
  final Color color;
  final HabitLog? log;
  final String Function(HabitLog log)? labelFor;
  final void Function(DateTime date, HabitLog? log)? onTap;

  @override
  Widget build(BuildContext context) {
    final log = this.log;
    final onTap = this.onTap;
    return InkWell(
      onTap: onTap == null ? null : () => onTap(date, log),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('${date.day}', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 2),
          if (log != null)
            switch (labelFor) {
              final labelFor? => _ActionLabel(
                label: labelFor(log),
                color: color,
              ),
              null => Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            },
        ],
      ),
    );
  }
}

/// The action done on a day, as a tiny tinted tag under the day number.
class _ActionLabel extends StatelessWidget {
  const _ActionLabel({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(fontSize: 9, color: color),
      ),
    );
  }
}
