import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../shared/widgets/detail_selection.dart';
import '../../../habits/domain/habit_action.dart';
import '../../../habits/presentation/habit_tab.dart';
import '../../../habits/presentation/habit_icon.dart';
import '../../../habits/presentation/open_routine_detail.dart';
import '../../../habits/presentation/routine_pill.dart';
import 'today_task_row.dart' show todayRowLeadingGap, todayRowLeadingWidth;

/// One of today's routines: icon (always in the routine's own color), name
/// and one pill per action (or "Done"). Home only lists routines not logged
/// yet, so tapping a pill logs it and the row leaves the card; a logged
/// item (shown tinted, tap to undo) only appears on the Tasks & Routines
/// tab. Tapping the rest of the row opens its calendar
/// ([openRoutineDetail]).
class TodayRoutineRow extends ConsumerWidget {
  const TodayRoutineRow({required this.item, super.key});

  final HabitTabItem item;

  bool get _isDone => item.todayLog != null;

  bool _isSelected(HabitAction action) =>
      item.todayLog?.completedActionId == action.id;

  Future<void> _handleTap(
    BuildContext context,
    WidgetRef ref,
    HabitAction? action, {
    required bool selected,
  }) async {
    final controller = ref.read(habitTabControllerProvider.notifier);
    try {
      if (selected) {
        await controller.unlog(item.habit);
      } else {
        await controller.logAction(item.habit, action);
      }
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.homeSyncFailed(item.habit.name, '$error')),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habit = item.habit;
    final color = routineColorOf(context, habit);
    // Marks the routine shown in the detail pane.
    final selected = DetailSelectionScope.isSelected(
      context,
      RoutineDetailSelection(habit.id),
    );
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => openRoutineDetail(context, habit.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            SizedBox(
              width: todayRowLeadingWidth,
              child: Center(
                child: HabitIcon(icon: habit.icon, color: color),
              ),
            ),
            const SizedBox(width: todayRowLeadingGap),
            Expanded(
              child: Text(
                habit.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: selected ? color : Colors.white,
                ),
              ),
            ),
            if (habit.actions.isEmpty)
              RoutinePill(
                label: context.l10n.commonDone,
                color: color,
                selected: _isDone,
                onTap: () => _handleTap(context, ref, null, selected: _isDone),
              )
            else
              for (final action in habit.actions)
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: RoutinePill(
                    label: action.label,
                    color: color,
                    selected: _isSelected(action),
                    onTap: () => _handleTap(
                      context,
                      ref,
                      action,
                      selected: _isSelected(action),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
