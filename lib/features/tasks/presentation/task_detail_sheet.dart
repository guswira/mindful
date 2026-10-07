import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/spacing.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/glass_theme.dart';
import '../../../shared/widgets/glass_bottom_sheet.dart';
import '../../../shared/widgets/tinted_pill.dart';
import '../../habits/presentation/add_habit_sheet.dart';
import '../domain/task.dart';
import '../domain/task_checkbox.dart';
import 'add_task_sheet.dart';
import 'task_detail_sheet_actions.dart';
import 'task_detail_sheet_checklist.dart';
import 'task_providers.dart';
import 'task_tab.dart';

export 'task_detail_sheet_actions.dart'
    show TaskDetailOutcome, TaskDetailResult;

/// Shows [TaskDetailSheet] for [taskId] over [context], then whichever
/// follow-up sheet its overflow menu asked for (edit, or convert to a
/// routine) — used everywhere a task row or reminder opens a task.
Future<void> showTaskDetailSheet(BuildContext context, String taskId) async {
  final result = await showGlassBottomSheet<TaskDetailResult>(
    context: context,
    builder: (_) => TaskDetailSheet(taskId: taskId),
  );
  if (result == null || !context.mounted) {
    return;
  }
  await showTaskFollowUp(context, result);
}

/// Opens the sheet [result] asks for: editing the task, or converting it
/// into a routine.
Future<void> showTaskFollowUp(BuildContext context, TaskDetailResult result) {
  return showGlassBottomSheet<void>(
    context: context,
    builder: (_) => switch (result.outcome) {
      TaskDetailOutcome.edit => AddTaskSheet(task: result.task),
      TaskDetailOutcome.convertToRoutine => AddHabitSheet(
        fromTask: result.task,
      ),
    },
  );
}

/// [TaskDetailView] as a bottom sheet: closes once the task is done or
/// deleted, and pops with the follow-up its overflow menu asked for. See
/// SPEC.md Task Manager and the bottom-sheet design rules.
class TaskDetailSheet extends StatelessWidget {
  const TaskDetailSheet({required this.taskId, super.key});

  final String taskId;

  @override
  Widget build(BuildContext context) {
    return TaskDetailView(
      taskId: taskId,
      onFollowUp: (result) => Navigator.pop<TaskDetailResult>(context, result),
      onCompleted: () => Navigator.pop(context),
      onDeleted: () => Navigator.pop(context),
    );
  }
}

/// A task's due date, reminder and subtasks, with edit/convert-to-routine/
/// delete via the overflow menu and a "Mark as done" action.
///
/// Doesn't close itself — it reports through the callbacks instead, so it
/// works both inside [TaskDetailSheet] and in the Tasks & Routines tab's
/// detail pane on wide screens, which stays open.
class TaskDetailView extends ConsumerWidget {
  const TaskDetailView({
    required this.taskId,
    required this.onFollowUp,
    required this.onCompleted,
    required this.onDeleted,
    this.notFound,
    super.key,
  });

  final String taskId;

  /// Edit or convert to a routine was picked from the overflow menu.
  final ValueChanged<TaskDetailResult> onFollowUp;

  /// The task was marked done.
  final VoidCallback onCompleted;

  /// The task was deleted.
  final VoidCallback onDeleted;

  /// Shown when [taskId] no longer exists (deleted, or converted to a
  /// routine); a plain "Task not found" by default.
  final Widget? notFound;

  Future<void> _toggleCheckbox(
    WidgetRef ref,
    Task task,
    TaskCheckbox checkbox,
  ) async {
    final updated = task.copyWith(
      updatedAt: DateTime.now(),
      checkboxes: [
        for (final existing in task.checkboxes)
          if (existing.id == checkbox.id)
            existing.copyWith(isChecked: !existing.isChecked)
          else
            existing,
      ],
    );
    await ref
        .read(taskTabControllerProvider.notifier)
        .save(updated, isNew: false);
  }

  Future<void> _complete(BuildContext context, WidgetRef ref, Task task) async {
    await ref.read(taskTabControllerProvider.notifier).complete(task.id);
    HapticFeedback.lightImpact();
    if (context.mounted) {
      onCompleted();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskAsync = ref.watch(taskByIdProvider(taskId));
    return taskAsync.when(
      loading: () => const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => SizedBox(
        height: 120,
        child: Center(child: Text(context.l10n.taskLoadError('$error'))),
      ),
      data: (task) => task == null
          ? notFound ??
                SizedBox(
                  height: 120,
                  child: Center(child: Text(context.l10n.taskNotFound)),
                )
          : _buildDetail(context, ref, task),
    );
  }

  Widget _buildDetail(BuildContext context, WidgetRef ref, Task task) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  task.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () => showTaskMoreActions(
                  context,
                  ref,
                  task,
                  onFollowUp: onFollowUp,
                  onDeleted: onDeleted,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          if (task.dueDate != null)
            TaskDetailRow(
              icon: Icons.calendar_today_outlined,
              text: DateFormat.yMMMd().format(task.dueDate!),
            ),
          if (task.reminderAt != null)
            TaskDetailRow(
              icon: Icons.notifications_none,
              text: DateFormat.jm().format(task.reminderAt!),
            ),
          if (task.checkboxes.isNotEmpty) ...[
            const SizedBox(height: Spacing.md),
            TaskChecklist(
              checkboxes: task.checkboxes,
              onToggle: (checkbox) => _toggleCheckbox(ref, task, checkbox),
            ),
          ],
          const SizedBox(height: Spacing.lg),
          if (!task.isCompleted)
            SizedBox(
              width: double.infinity,
              child: TintedPill(
                label: context.l10n.taskMarkAsDone,
                color: glass.taskAccent,
                onTap: () => _complete(context, ref, task),
              ),
            ),
        ],
      ),
    );
  }
}
