import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../shared/services/notification_service.dart';
import '../../../shared/services/widget_service.dart';
import '../data/task_repository.dart';
import '../domain/task.dart';

/// What the caller should do once [TaskDetailSheet] closes — returned as
/// the sheet's pop result since editing needs to happen in the still-
/// mounted caller context, not inside this (about to be disposed) one.
enum TaskDetailOutcome { edit }

enum _MoreAction { edit, delete }

/// Shows the overflow "Edit / Delete" menu for [task] from [TaskDetailSheet]
/// and handles the chosen action. Edit pops [context] (the detail sheet
/// itself) with [TaskDetailOutcome.edit], so its caller opens `AddTaskSheet`
/// in edit mode from a context that's still mounted; delete confirms, then
/// deletes and pops the detail sheet directly.
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
      Navigator.pop(context, TaskDetailOutcome.edit);
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

  final repository = await ref.read(taskRepositoryProvider.future);
  await forgetTaskReminder(ref, task.id);
  await repository.delete(task.id);
  await refreshWidgetsBestEffort(() => ref.read(widgetServiceProvider.future));
  if (context.mounted) {
    Navigator.pop(context);
  }
}

/// Cancels [taskId]'s scheduled reminder, if any, keeping its notification
/// id reserved — used by "Mark as done" in [TaskDetailSheet], since the
/// task still exists and could get a reminder again later.
Future<void> cancelTaskReminder(WidgetRef ref, String taskId) async {
  final notificationService = await ref.read(
    notificationServiceProvider.future,
  );
  await notificationService.cancelTaskReminder(taskId);
}

/// Cancels [taskId]'s scheduled reminder and frees its notification id for
/// reuse — used by "Delete", which removes the task itself.
Future<void> forgetTaskReminder(WidgetRef ref, String taskId) async {
  final notificationService = await ref.read(
    notificationServiceProvider.future,
  );
  await notificationService.forgetTaskReminder(taskId);
}
