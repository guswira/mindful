import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../domain/task.dart';
import 'task_tab.dart';

/// What the caller should do once [TaskDetailSheet] closes — returned as
/// the sheet's pop result since the follow-up sheet needs to open from the
/// still-mounted caller context, not inside this (about to be disposed)
/// one.
enum TaskDetailOutcome { edit, convertToRoutine }

/// [TaskDetailSheet]'s pop result: the follow-up to open, for the task as
/// it was last shown (subtask toggles included).
typedef TaskDetailResult = ({TaskDetailOutcome outcome, Task task});

enum _MoreAction { edit, convertToRoutine, delete }

/// Shows the overflow "Edit / Convert to routine / Delete" menu for [task]
/// from [TaskDetailSheet] and handles the chosen action. Edit and convert
/// pop [context] (the detail sheet itself) with a [TaskDetailResult], so
/// its caller opens `AddTaskSheet` / `AddHabitSheet` from a context that's
/// still mounted; delete confirms, then deletes and pops the detail sheet
/// directly.
Future<void> showTaskMoreActions(
  BuildContext context,
  WidgetRef ref,
  Task task,
) async {
  final action = await showModalBottomSheet<_MoreAction>(
    context: context,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: Text(context.l10n.commonEdit),
            onTap: () => Navigator.pop(context, _MoreAction.edit),
          ),
          ListTile(
            leading: const Icon(Icons.repeat),
            title: Text(context.l10n.taskConvertToRoutine),
            onTap: () => Navigator.pop(context, _MoreAction.convertToRoutine),
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: Text(
              context.l10n.commonDelete,
              style: const TextStyle(color: Colors.red),
            ),
            onTap: () => Navigator.pop(context, _MoreAction.delete),
          ),
        ],
      ),
    ),
  );
  if (!context.mounted || action == null) {
    return;
  }
  switch (action) {
    case _MoreAction.edit:
      Navigator.pop<TaskDetailResult>(context, (
        outcome: TaskDetailOutcome.edit,
        task: task,
      ));
    case _MoreAction.convertToRoutine:
      Navigator.pop<TaskDetailResult>(context, (
        outcome: TaskDetailOutcome.convertToRoutine,
        task: task,
      ));
    case _MoreAction.delete:
      await _confirmDelete(context, ref, task);
  }
}

Future<void> _confirmDelete(
  BuildContext context,
  WidgetRef ref,
  Task task,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(context.l10n.taskDeleteConfirmTitle),
      content: Text(context.l10n.taskDeleteConfirmBody(task.name)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(context.l10n.commonCancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(context.l10n.commonDelete),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) {
    return;
  }

  await ref.read(taskTabControllerProvider.notifier).delete(task.id);
  if (context.mounted) {
    Navigator.pop(context);
  }
}
