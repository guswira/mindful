import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/spacing.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/glass_theme.dart';
import '../../../shared/widgets/glass_bottom_sheet.dart';
import '../domain/habit.dart';
import '../domain/habit_action_summary.dart';
import '../domain/habit_log.dart';
import 'habit_action_summary_card.dart';
import 'habit_calendar.dart';
import 'habit_day_log_sheet.dart';
import 'habit_detail_screen.dart';
import 'habit_form.dart';

/// A habit's current and longest streak, computed over whichever months are
/// loaded — not necessarily the habit's entire history. See
/// [HabitDetailController].
({int current, int longest}) _computeStreaks(
  Map<DateTime, HabitLog> logsByDate,
) {
  if (logsByDate.isEmpty) {
    return (current: 0, longest: 0);
  }
  final days = logsByDate.keys.toList()..sort();

  var longest = 1;
  var run = 1;
  for (var i = 1; i < days.length; i++) {
    run = days[i].difference(days[i - 1]).inDays == 1 ? run + 1 : 1;
    if (run > longest) {
      longest = run;
    }
  }

  var cursor = DateTime.now();
  cursor = DateTime(cursor.year, cursor.month, cursor.day);
  if (!logsByDate.containsKey(cursor)) {
    cursor = cursor.subtract(const Duration(days: 1));
  }
  var current = 0;
  while (logsByDate.containsKey(cursor)) {
    current++;
    cursor = cursor.subtract(const Duration(days: 1));
  }

  return (current: current, longest: longest);
}

/// Streaks, the swipeable month calendar (tap a day to view/change its
/// log) and this month's per-action and per-tag counts, for a habit that
/// has actions / tags.
/// Shared by [HabitDetailScreen] and [HabitDetailView].
class HabitDetailBody extends ConsumerWidget {
  const HabitDetailBody({
    required this.habit,
    required this.state,
    this.shrinkWrap = false,
    super.key,
  });

  final Habit habit;
  final HabitDetailState state;

  /// Sizes the list to its content — for the detail pane's card, rather
  /// than filling a whole page.
  final bool shrinkWrap;

  Future<void> _changeMonth(WidgetRef ref, int delta) async {
    await ref
        .read(habitDetailControllerProvider(habit.id).notifier)
        .changeMonth(delta);
  }

  /// The action [log] recorded — "Done" for a plain log, "Removed action"
  /// when that action no longer exists on the habit.
  String _actionLabel(BuildContext context, HabitLog log) =>
      switch ((log.completedActionId, actionForLog(habit, log))) {
        (_, final action?) => action.label,
        (null, _) => context.l10n.commonDone,
        _ => context.l10n.habitActionRemoved,
      };

  /// Opens the day sheet and applies whatever the user changed it to.
  Future<void> _openDay(
    BuildContext context,
    WidgetRef ref,
    DateTime date,
    HabitLog? log,
    Color color,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final controller = ref.read(
      habitDetailControllerProvider(habit.id).notifier,
    );
    final update = await showGlassBottomSheet<HabitDayLogUpdate>(
      context: context,
      builder: (_) =>
          HabitDayLogSheet(habit: habit, date: date, log: log, color: color),
    );
    if (update == null) {
      return;
    }
    try {
      await controller.setDayLog(date, update.choice, tags: update.tags);
    } catch (error) {
      debugPrint('Updating ${habit.id} on $date failed: $error');
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.habitSyncFailed(habit.name, '$error'))),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streaks = _computeStreaks(state.logsByDate);
    final habitAccent = Theme.of(context).extension<GlassTheme>()!.habitAccent;
    final color = parseHexColorOr(habit.color, habitAccent);
    final hasActions = habit.actions.isNotEmpty;
    final logs = state.logsByDate.values;
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;
        if (velocity < 0) {
          _changeMonth(ref, 1);
        } else if (velocity > 0) {
          _changeMonth(ref, -1);
        }
      },
      child: ListView(
        shrinkWrap: shrinkWrap,
        padding: const EdgeInsets.all(Spacing.md),
        children: [
          HabitStreakRow(current: streaks.current, longest: streaks.longest),
          const SizedBox(height: Spacing.md),
          HabitMonthHeader(
            month: state.month,
            onPrevious: () => _changeMonth(ref, -1),
            onNext: () => _changeMonth(ref, 1),
          ),
          const SizedBox(height: Spacing.sm),
          HabitMonthGrid(
            month: state.month,
            color: color,
            logsByDate: state.logsByDate,
            labelFor: hasActions ? (log) => _actionLabel(context, log) : null,
            onDayTap: (date, log) => _openDay(context, ref, date, log, color),
          ),
          if (hasActions) ...[
            const SizedBox(height: Spacing.md),
            HabitActionSummaryCard(
              counts: countActionsInMonth(habit, logs, state.month),
              tagsByAction: countTagsByActionInMonth(habit, logs, state.month),
              color: color,
            ),
          ],
          if (habit.tagList.isNotEmpty) ...[
            const SizedBox(height: Spacing.md),
            HabitTagSummaryCard(
              counts: countTagsInMonth(habit, logs, state.month),
              color: color,
            ),
          ],
        ],
      ),
    );
  }
}
