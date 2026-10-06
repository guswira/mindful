import 'package:flutter/material.dart';

import '../../../../core/theme/glass_theme.dart';
import '../../../../shared/widgets/month_calendar.dart';
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

  /// A day reaches full tint at this much practice.
  static const Duration _fullTint = Duration(minutes: 10);

  double _tint(DateTime day) {
    final activity = byDay[day];
    if (activity == null) {
      return 0;
    }
    final share = activity.time.inSeconds / _fullTint.inSeconds;
    return 0.25 + 0.5 * share.clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return MonthCalendarGrid(
      month: month,
      today: today,
      accent: Theme.of(context).extension<GlassTheme>()!.exerciseAccent,
      tintFor: _tint,
      selected: selected,
      onDayTap: onDayTap,
    );
  }
}
