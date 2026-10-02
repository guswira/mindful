import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/glass_theme.dart';
import '../../../habits/presentation/habit_form.dart';
import '../../domain/exercise_stats.dart';

/// [month]'s days, Monday first, each tinted by how long was spent
/// breathing that day.
class ExerciseCalendarGrid extends StatelessWidget {
  const ExerciseCalendarGrid({
    required this.month,
    required this.today,
    required this.byDay,
    required this.selected,
    required this.onDayTap,
    super.key,
  });

  final DateTime month;

  /// Local midnight today, ringed in the grid.
  final DateTime today;
  final Map<DateTime, DayActivity> byDay;
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
              _DayCell(
                date: DateTime(month.year, month.month, day),
                activity: byDay[DateTime(month.year, month.month, day)],
                isToday: DateTime(month.year, month.month, day) == today,
                isSelected: DateTime(month.year, month.month, day) == selected,
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
    required this.activity,
    required this.isToday,
    required this.isSelected,
    required this.onTap,
  });

  final DateTime date;
  final DayActivity? activity;
  final bool isToday;
  final bool isSelected;
  final ValueChanged<DateTime> onTap;

  /// A day reaches full tint at this much practice.
  static const Duration _fullTint = Duration(minutes: 10);

  double _tint() {
    final activity = this.activity;
    if (activity == null) {
      return 0;
    }
    final share = activity.time.inSeconds / _fullTint.inSeconds;
    return 0.25 + 0.5 * share.clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final tint = _tint();
    final borderColor = isSelected
        ? Colors.white
        : isToday
        ? glass.exerciseAccent
        : Colors.transparent;
    return GestureDetector(
      onTap: () => onTap(date),
      child: Container(
        margin: const EdgeInsets.all(3),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: glass.exerciseAccent.withValues(alpha: tint),
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
