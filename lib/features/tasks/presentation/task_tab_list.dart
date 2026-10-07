import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/spacing.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/glass_theme.dart';
import '../../../shared/widgets/glass_bottom_sheet.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/group_label.dart';
import '../../../shared/widgets/detail_selection.dart';
import '../../../shared/widgets/intro_card.dart';
import '../../habits/presentation/add_habit_sheet.dart';
import '../domain/task.dart';
import 'add_task_sheet.dart';
import 'open_task_detail.dart';
import 'task_complete_checkbox.dart';
import 'task_due_date_chip.dart';
import 'task_tab.dart';

/// A task's group, in display order.
enum _TaskGroup { today, upcoming, noDate }

_TaskGroup _groupOf(Task task, DateTime today) {
  final dueDate = task.dueDate;
  if (dueDate == null) {
    return _TaskGroup.noDate;
  }
  final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
  return due.isAfter(today) ? _TaskGroup.upcoming : _TaskGroup.today;
}

/// [tasks] split into the open groups (in display order, empty ones
/// dropped) and the completed ones.
({Map<_TaskGroup, List<Task>> open, List<Task> completed}) _groupTasks(
  List<Task> tasks,
) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final completed = <Task>[];
  final open = {for (final group in _TaskGroup.values) group: <Task>[]};
  for (final task in tasks) {
    if (task.isCompleted) {
      completed.add(task);
    } else {
      open[_groupOf(task, today)]!.add(task);
    }
  }
  open.removeWhere((_, groupTasks) => groupTasks.isEmpty);
  return (open: open, completed: completed);
}

/// The Tasks & Routines tab's task sections: [tasks] grouped into glass
/// cards — Today, Upcoming, No date, and a collapsed Completed section. Not
/// scrollable itself — it's one part of the tab's list. See SPEC.md Tasks
/// & Routines.
class TaskSections extends StatelessWidget {
  const TaskSections({required this.tasks, super.key});

  final List<Task> tasks;

  static String _groupLabel(AppLocalizations l10n, _TaskGroup group) =>
      switch (group) {
        _TaskGroup.today => l10n.commonToday,
        _TaskGroup.upcoming => l10n.taskGroupUpcoming,
        _TaskGroup.noDate => l10n.taskGroupNoDate,
      };

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return const _EmptyTasks();
    }

    final (:open, :completed) = _groupTasks(tasks);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final MapEntry(key: group, value: groupTasks) in open.entries) ...[
          GroupLabel(_groupLabel(context.l10n, group)),
          const SizedBox(height: Spacing.sm),
          _TaskGroupCard(tasks: groupTasks),
          const SizedBox(height: Spacing.lg),
        ],
        if (completed.isNotEmpty) _CompletedSection(tasks: completed),
      ],
    );
  }
}

/// Shown instead of the task groups until the first task exists.
class _EmptyTasks extends StatelessWidget {
  const _EmptyTasks();

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GroupLabel(l10n.taskTabTitle),
        const SizedBox(height: Spacing.sm),
        IntroCard(
          icon: Icons.checklist_rounded,
          color: glass.taskAccent,
          title: l10n.taskIntroTitle,
          body: l10n.taskIntroBody,
          actionLabel: l10n.taskIntroAction,
          onAction: () => showGlassBottomSheet(
            context: context,
            builder: (_) => const AddTaskSheet(),
          ),
        ),
      ],
    );
  }
}

class _TaskGroupCard extends StatelessWidget {
  const _TaskGroupCard({required this.tasks});

  final List<Task> tasks;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < tasks.length; i++) ...[
            if (i > 0) const _RowDivider(),
            _TaskRow(task: tasks[i]),
          ],
        ],
      ),
    );
  }
}

class _CompletedSection extends StatefulWidget {
  const _CompletedSection({required this.tasks});

  final List<Task> tasks;

  @override
  State<_CompletedSection> createState() => _CompletedSectionState();
}

class _CompletedSectionState extends State<_CompletedSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.l10n.taskCompletedSection(widget.tasks.length),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: glass.textMuted,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.expand_more,
                        color: glass.textMuted,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            child: _expanded
                ? Column(
                    children: [
                      for (var i = 0; i < widget.tasks.length; i++) ...[
                        const _RowDivider(),
                        _TaskRow(task: widget.tasks[i]),
                      ],
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0.5,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.white.withValues(alpha: 0.07),
    );
  }
}

class _TaskRow extends ConsumerWidget {
  const _TaskRow({required this.task});

  final Task task;

  Future<void> _complete(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(taskTabControllerProvider.notifier).complete(task.id);
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.taskSyncFailed(task.name, '$error')),
        ),
      );
    }
  }

  Future<void> _showActions(BuildContext context, WidgetRef ref) async {
    final action = await showModalBottomSheet<_TaskRowAction>(
      context: context,
      useRootNavigator: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(context.l10n.commonEdit),
              onTap: () => Navigator.pop(context, _TaskRowAction.edit),
            ),
            ListTile(
              leading: const Icon(Icons.repeat),
              title: Text(context.l10n.taskConvertToRoutine),
              onTap: () =>
                  Navigator.pop(context, _TaskRowAction.convertToRoutine),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: Text(context.l10n.commonDelete),
              onTap: () => Navigator.pop(context, _TaskRowAction.delete),
            ),
          ],
        ),
      ),
    );
    if (!context.mounted || action == null) {
      return;
    }

    switch (action) {
      case _TaskRowAction.edit:
        showGlassBottomSheet(
          context: context,
          builder: (_) => AddTaskSheet(task: task),
        );
      case _TaskRowAction.convertToRoutine:
        showGlassBottomSheet(
          context: context,
          builder: (_) => AddHabitSheet(fromTask: task),
        );
      case _TaskRowAction.delete:
        await _delete(context, ref);
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(taskTabControllerProvider.notifier).delete(task.id);
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.taskSyncFailed(task.name, '$error')),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final selected = DetailSelectionScope.isSelected(
      context,
      TaskDetailSelection(task.id),
    );
    return Material(
      // Marks the task shown in the wide-screen detail pane.
      color: selected
          ? glass.taskAccent.withValues(alpha: 0.12)
          : Colors.transparent,
      child: InkWell(
        onTap: () => openTaskDetail(context, task.id),
        onLongPress: () => _showActions(context, ref),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              TaskCompleteCheckbox(
                value: task.isCompleted,
                activeColor: glass.taskAccent,
                onChanged: task.isCompleted
                    ? null
                    : (_) => _complete(context, ref),
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Text(
                  task.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, color: Colors.white),
                ),
              ),
              if (task.dueDate != null) TaskDueDateChip(dueDate: task.dueDate!),
              if (task.reminderAt != null)
                Padding(
                  padding: const EdgeInsets.only(left: Spacing.xs),
                  child: Icon(
                    Icons.notifications_active_outlined,
                    size: 18,
                    color: glass.textMuted,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _TaskRowAction { edit, convertToRoutine, delete }
