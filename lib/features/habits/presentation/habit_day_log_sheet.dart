import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/spacing.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/glass_theme.dart';
import '../../../shared/widgets/sheet_header.dart';
import '../../../shared/widgets/tinted_pill.dart';
import '../domain/habit.dart';
import '../domain/habit_log.dart';

/// What a day's log should become: not done, plain "done" (`actionId`
/// null), or done via a specific action.
typedef HabitDayChoice = ({bool done, String? actionId});

/// The "not done" choice — no log for that day.
const HabitDayChoice habitDayNotDone = (done: false, actionId: null);

/// The choices offered for a day of [habit] currently logged as [log]:
/// "Not done", then each action — or plain "Done" for a habit without
/// actions. A log the current actions can't express (plain "done" on a
/// habit that has actions now, or an action since removed) stays on the
/// list so the sheet can still show it selected.
List<HabitDayChoice> habitDayChoices(Habit habit, HabitLog? log) {
  final current = log?.completedActionId;
  final hasCurrentAction = habit.actions.any((a) => a.id == current);
  return [
    habitDayNotDone,
    if (habit.actions.isEmpty || (log != null && current == null))
      (done: true, actionId: null),
    for (final action in habit.actions) (done: true, actionId: action.id),
    if (current != null && !hasCurrentAction) (done: true, actionId: current),
  ];
}

/// The choice matching [log] as it is now.
HabitDayChoice habitDayChoiceOf(HabitLog? log) => log == null
    ? habitDayNotDone
    : (done: true, actionId: log.completedActionId);

/// A day on the habit calendar: what was logged, and chips to change it
/// (another action, plain done, or not done). Pops with the new
/// [HabitDayChoice] on Save, or null when nothing changed / closed.
class HabitDayLogSheet extends StatefulWidget {
  const HabitDayLogSheet({
    required this.habit,
    required this.date,
    required this.log,
    required this.color,
    super.key,
  });

  final Habit habit;
  final DateTime date;
  final HabitLog? log;

  /// The habit's own color, for the selected chip and Save.
  final Color color;

  @override
  State<HabitDayLogSheet> createState() => _HabitDayLogSheetState();
}

class _HabitDayLogSheetState extends State<HabitDayLogSheet> {
  late HabitDayChoice _selected = habitDayChoiceOf(widget.log);

  String _label(HabitDayChoice choice) {
    final l10n = context.l10n;
    if (!choice.done) {
      return l10n.habitDayNotDone;
    }
    final actionId = choice.actionId;
    if (actionId == null) {
      return l10n.commonDone;
    }
    for (final action in widget.habit.actions) {
      if (action.id == actionId) {
        return action.label;
      }
    }
    return l10n.habitActionRemoved;
  }

  void _save() {
    final changed = _selected != habitDayChoiceOf(widget.log);
    Navigator.pop(context, changed ? _selected : null);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final note = widget.log?.note;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 8, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SheetHeader(
            title: DateFormat.yMMMEd().format(widget.date),
            onClose: () => Navigator.pop(context),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Caption(l10n.habitDayLoggedAs),
                Text(
                  _label(habitDayChoiceOf(widget.log)),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (note != null) ...[
                  const SizedBox(height: Spacing.xs),
                  Text(note, style: TextStyle(color: glass.textSecondary)),
                ],
                const SizedBox(height: Spacing.lg),
                _Caption(l10n.habitDayChangeTo),
                const SizedBox(height: Spacing.sm),
                Wrap(
                  spacing: Spacing.sm,
                  runSpacing: Spacing.sm,
                  children: [
                    for (final choice in habitDayChoices(
                      widget.habit,
                      widget.log,
                    ))
                      _ChoiceChip(
                        label: _label(choice),
                        color: widget.color,
                        isSelected: choice == _selected,
                        onTap: () => setState(() => _selected = choice),
                      ),
                  ],
                ),
                const SizedBox(height: Spacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: TintedPill(
                    label: l10n.commonSave,
                    color: widget.color,
                    onTap: _save,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Caption extends StatelessWidget {
  const _Caption(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.labelMedium?.copyWith(color: glass.textMuted),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return Semantics(
      selected: isSelected,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.18)
                : Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? color.withValues(alpha: 0.5)
                  : glass.cardBorder,
              width: 0.5,
            ),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: isSelected ? color : glass.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
