import 'package:flutter/foundation.dart';
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

/// What [HabitDayLogSheet] pops with on Save: the day's new [choice], and
/// its new tag counts — null when the tags weren't changed.
typedef HabitDayLogUpdate = ({HabitDayChoice choice, Map<String, int>? tags});

/// The most a single tag can be counted on one day.
const habitTagMaxCount = 99;

/// [counts] of [habit]'s current tags as "Heavy · Easy ×3", in the
/// habit's order, or null if none was done. Counts of removed tags are
/// left out.
String? habitTagSummary(
  AppLocalizations l10n,
  Habit habit,
  Map<String, int> counts,
) {
  final parts = [
    for (final tag in habit.tagList)
      if ((counts[tag.id] ?? 0) case final count when count > 0)
        count == 1 ? tag.label : l10n.habitTagTimes(tag.label, count),
  ];
  return parts.isEmpty ? null : parts.join(' · ');
}

/// The choice matching [log] as it is now.
HabitDayChoice habitDayChoiceOf(HabitLog? log) => log == null
    ? habitDayNotDone
    : (done: true, actionId: log.completedActionId);

/// A day on the habit calendar: what was logged, and chips to change it
/// (another action, plain done, or not done) plus, while it's done, a
/// counter per tag ("Easy ×3"). Pops with a [HabitDayLogUpdate] on Save,
/// or null when nothing changed / closed.
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
  late Map<String, int> _tags = {...?widget.log?.tags};

  bool get _showTags => _selected.done && widget.habit.tagList.isNotEmpty;

  void _setTagCount(String tagId, int count) {
    setState(() {
      _tags = {..._tags, tagId: count}..removeWhere((_, n) => n <= 0);
    });
  }

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
    final tagsChanged =
        _selected.done &&
        !mapEquals(_tags, widget.log?.tagCounts ?? const <String, int>{});
    final changed = _selected != habitDayChoiceOf(widget.log) || tagsChanged;
    Navigator.pop<HabitDayLogUpdate>(
      context,
      changed ? (choice: _selected, tags: tagsChanged ? _tags : null) : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final note = widget.log?.note;
    final loggedTags = habitTagSummary(
      l10n,
      widget.habit,
      widget.log?.tagCounts ?? const {},
    );
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
                if (loggedTags != null) ...[
                  const SizedBox(height: Spacing.xs),
                  Text(loggedTags, style: TextStyle(color: widget.color)),
                ],
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
                if (_showTags) ...[
                  const SizedBox(height: Spacing.lg),
                  _Caption(l10n.habitDayTags),
                  for (final tag in widget.habit.tagList)
                    _TagCountRow(
                      label: tag.label,
                      count: _tags[tag.id] ?? 0,
                      color: widget.color,
                      onChanged: (count) => _setTagCount(tag.id, count),
                    ),
                ],
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

/// One tag's label with a − / ×count / + stepper. At 0 the tag isn't on
/// the day's log.
class _TagCountRow extends StatelessWidget {
  const _TagCountRow({
    required this.label,
    required this.count,
    required this.color,
    required this.onChanged,
  });

  final String label;
  final int count;
  final Color color;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final active = count > 0;
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              color: active ? Colors.white : glass.textSecondary,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          color: color,
          tooltip: l10n.habitTagDecrease(label),
          onPressed: active ? () => onChanged(count - 1) : null,
        ),
        SizedBox(
          width: 36,
          child: Text(
            l10n.habitTagCount(count),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: active ? color : glass.textMuted,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          color: color,
          tooltip: l10n.habitTagIncrease(label),
          onPressed: count < habitTagMaxCount
              ? () => onChanged(count + 1)
              : null,
        ),
      ],
    );
  }
}
