import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../shared/services/notification_service.dart';
import 'task_repository.dart';

part 'task_reminders_controller.g.dart';

/// Re-schedules every incomplete task's reminder on app start.
///
/// Unlike the journal's reminders (see `JournalReminders`), a task's
/// reminder is otherwise only ever (re)scheduled once, at the moment its
/// Add/Edit sheet is saved — nothing re-arms it afterward. If the OS ever
/// drops a previously scheduled alarm (the app was force-stopped, an OEM
/// battery manager killed it, ...), it would stay silently unscheduled
/// until the user happened to re-open and re-save that exact task. This
/// runs the same reconciliation the journal reminders get, for every task
/// that should currently have one.
///
/// Best-effort: this runs unconditionally at every app start (see
/// router.dart), before anything's confirmed the cache is even reachable —
/// a failure here shouldn't crash startup, just skip reconciling this once.
@riverpod
Future<void> taskReminders(Ref ref) async {
  try {
    final repository = await ref.watch(taskRepositoryProvider.future);
    final service = await ref.watch(notificationServiceProvider.future);
    for (final task in repository.getAll()) {
      if (task.reminderAt != null && !task.isCompleted) {
        await service.scheduleTaskReminder(task);
      }
    }
  } catch (error) {
    debugPrint('Failed to reconcile task reminders: $error');
  }
}
