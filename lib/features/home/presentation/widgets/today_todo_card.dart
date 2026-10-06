import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/spacing.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/glass_theme.dart';
import '../../../../shared/widgets/dashed_border_container.dart';
import '../../../../shared/widgets/glass_bottom_sheet.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/tinted_pill.dart';
import '../../../habits/presentation/add_habit_sheet.dart';
import '../../../habits/presentation/habit_tab.dart';
import '../../../tasks/domain/task.dart';
import '../../../tasks/presentation/add_task_sheet.dart';
import '../../../tasks/presentation/task_tab.dart';
import 'today_routine_row.dart';
import 'today_task_row.dart';

const int _maxTasksShown = 3;

/// Incomplete tasks due today or earlier.
List<Task> dueTodayOrOverdue(List<Task> tasks, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  return [
    for (final task in tasks)
      if (task.dueDate case final due?
          when !task.isCompleted &&
              !DateTime(due.year, due.month, due.day).isAfter(today))
        task,
  ];
}

/// Routines not yet logged today.
List<HabitTabItem> remainingRoutines(List<HabitTabItem> items) => [
  for (final item in items)
    if (item.todayLog == null) item,
];

/// Home's "Today's Todo" glass card: up to 3 due tasks, then today's
/// routines not logged yet, then Add todo / Add routine. Done items leave
/// the card — they're only listed (and undone) on the Tasks & Routines
/// tab. Each half loads on its own — one failing or loading never hides
/// the other. See SPEC.md Home Screen.
class TodayTodoCard extends ConsumerWidget {
  const TodayTodoCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(taskTabControllerProvider);
    final routinesAsync = ref.watch(habitTabControllerProvider);
    // Only the first load shows the spinner — a reload keeps the previous
    // value, so swapping it out would make the card (and everything below
    // it) jump.
    if (!tasksAsync.hasValue &&
        !routinesAsync.hasValue &&
        tasksAsync.isLoading &&
        routinesAsync.isLoading) {
      return const SizedBox(
        height: 96,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final routines = routinesAsync.valueOrNull ?? const <HabitTabItem>[];
    return GlassCard(
      child: _TodoContent(
        tasks: dueTodayOrOverdue(
          tasksAsync.valueOrNull ?? const [],
          DateTime.now(),
        ).take(_maxTasksShown).toList(),
        hasRoutines: routines.isNotEmpty,
        routines: remainingRoutines(routines),
      ),
    );
  }
}

class _TodoContent extends StatelessWidget {
  const _TodoContent({
    required this.tasks,
    required this.routines,
    required this.hasRoutines,
  });

  final List<Task> tasks;

  /// Today's routines not logged yet.
  final List<HabitTabItem> routines;

  /// Whether any routine exists today, logged or not — tells "All done!"
  /// apart from "nothing to do".
  final bool hasRoutines;

  bool get _isEmpty => tasks.isEmpty && routines.isEmpty;

  bool get _allDone => _isEmpty && hasRoutines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_isEmpty) _EmptyNote(allDone: _allDone),
        for (final task in tasks) TodayTaskRow(task: task),
        if (tasks.isNotEmpty && routines.isNotEmpty) const _Divider(),
        for (final item in routines) TodayRoutineRow(item: item),
        const SizedBox(height: 12),
        // The Column is start-aligned, so on its own the Wrap shrinks to
        // its pills and sits left — WrapAlignment.end only lays out runs
        // within that shrunk width.
        const Align(alignment: Alignment.centerRight, child: _AddButtons()),
      ],
    );
  }
}

/// Dashed prompt when nothing is due; "All done!" once today's routines
/// are all logged too.
class _EmptyNote extends StatelessWidget {
  const _EmptyNote({required this.allDone});

  final bool allDone;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final l10n = context.l10n;
    return DashedBorderContainer(
      color: Colors.white.withValues(alpha: 0.15),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (allDone) ...[
              Icon(
                Icons.celebration_outlined,
                size: 16,
                color: glass.habitAccent,
              ),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                allDone ? l10n.homeHabitsAllDone : l10n.homeTasksEmpty,
                style: TextStyle(fontSize: 14, color: glass.textHint),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0.5,
      margin: const EdgeInsets.only(bottom: Spacing.sm),
      color: Colors.white.withValues(alpha: 0.07),
    );
  }
}

class _AddButtons extends StatelessWidget {
  const _AddButtons();

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final l10n = context.l10n;
    // Wraps rather than overflowing on narrow screens / long labels.
    return Wrap(
      alignment: WrapAlignment.end,
      spacing: Spacing.sm,
      runSpacing: Spacing.sm,
      children: [
        TintedPill(
          label: l10n.homeAddTodo,
          color: glass.taskAccent,
          onTap: () => showGlassBottomSheet(
            context: context,
            builder: (_) => const AddTaskSheet(),
          ),
        ),
        TintedPill(
          label: l10n.homeAddRoutine,
          color: glass.habitAccent,
          onTap: () => showGlassBottomSheet(
            context: context,
            builder: (_) => const AddHabitSheet(),
          ),
        ),
      ],
    );
  }
}
