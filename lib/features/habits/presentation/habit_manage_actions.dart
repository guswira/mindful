import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../domain/habit.dart';
import 'habit_tab.dart';

/// Asks to confirm, then archives [habit]. See [HabitTabController.archive].
Future<void> archiveHabitWithConfirm(
  BuildContext context,
  WidgetRef ref,
  Habit habit,
) async {
  final l10n = context.l10n;
  final confirmed = await _confirm(
    context,
    title: l10n.habitArchiveConfirmTitle,
    body: l10n.habitArchiveConfirmBody(habit.name),
    action: l10n.commonArchive,
  );
  if (!confirmed || !context.mounted) {
    return;
  }
  await _run(
    context,
    habit,
    () => ref.read(habitTabControllerProvider.notifier).archive(habit),
  );
}

/// Asks to confirm, then permanently deletes [habit] and its history. See
/// [HabitTabController.delete].
Future<void> deleteHabitWithConfirm(
  BuildContext context,
  WidgetRef ref,
  Habit habit,
) async {
  final l10n = context.l10n;
  final confirmed = await _confirm(
    context,
    title: l10n.habitDeleteConfirmTitle,
    body: l10n.habitDeleteConfirmBody(habit.name),
    action: l10n.commonDelete,
  );
  if (!confirmed || !context.mounted) {
    return;
  }
  await _run(
    context,
    habit,
    () => ref.read(habitTabControllerProvider.notifier).delete(habit),
  );
}

/// Brings an archived [habit] back to today's list — no confirmation, since
/// it's trivially undone by archiving again.
Future<void> restoreHabit(BuildContext context, WidgetRef ref, Habit habit) =>
    _run(
      context,
      habit,
      () => ref.read(habitTabControllerProvider.notifier).restore(habit),
    );

Future<bool> _confirm(
  BuildContext context, {
  required String title,
  required String body,
  required String action,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(context.l10n.commonCancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(action),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

/// Runs [change], showing a SnackBar instead of letting a failure (usually
/// Supabase being unreachable) escape as an unhandled async error.
Future<void> _run(
  BuildContext context,
  Habit habit,
  Future<void> Function() change,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final l10n = context.l10n;
  try {
    await change();
  } catch (error) {
    debugPrint('Habit change failed for ${habit.id}: $error');
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.habitSyncFailed(habit.name, '$error'))),
    );
  }
}
