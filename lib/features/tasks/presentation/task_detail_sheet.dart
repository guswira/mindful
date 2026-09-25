import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/spacing.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/glass_theme.dart';
import '../../../shared/services/widget_service.dart';
import '../../../shared/widgets/tinted_pill.dart';
import '../data/task_repository.dart';
import '../domain/task.dart';
import '../domain/task_checkbox.dart';
import 'task_detail_sheet_actions.dart';
import 'task_detail_sheet_checklist.dart';
import 'task_providers.dart';

export 'task_detail_sheet_actions.dart' show TaskDetailOutcome;

/// Bottom sheet showing a task's due date, reminder and subtasks, with
/// edit/delete via the overflow menu and a "Mark as done" action. See
/// SPEC.md Task Manager and the bottom-sheet design rules.
class TaskDetailSheet extends ConsumerWidget {
  const TaskDetailSheet({required this.taskId, super.key});

  final String taskId;

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
    final repository = await ref.read(taskRepositoryProvider.future);
    await repository.update(updated);
    ref.invalidate(taskByIdProvider(task.id));
  }

  Future<void> _complete(BuildContext context, WidgetRef ref, Task task) async {
    final repository = await ref.read(taskRepositoryProvider.future);
    await cancelTaskReminder(ref, task.id);
    await repository.markComplete(task.id);
    await refreshWidgetsBestEffort(
      () => ref.read(widgetServiceProvider.future),
    );
    HapticFeedback.lightImpact();
    if (context.mounted) {
      Navigator.pop(context);
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
          ? SizedBox(
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
                onPressed: () => showTaskMoreActions(context, ref, task),
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
