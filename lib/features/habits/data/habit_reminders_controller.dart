import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../shared/services/notification_service.dart';
import 'habit_repository.dart';

part 'habit_reminders_controller.g.dart';

/// Re-schedules every active habit's reminder on app start.
///
/// Unlike the journal's reminders (see `JournalReminders`), a habit's
/// reminder is otherwise only ever (re)scheduled once, at the moment its
/// Add/Edit sheet is saved — nothing re-arms it afterward. If the OS ever
/// drops a previously scheduled alarm (the app was force-stopped, an OEM
/// battery manager killed it, ...), it would stay silently unscheduled
/// until the user happened to re-open and re-save that exact habit. This
/// runs the same reconciliation the journal reminders get, for every habit
/// that should currently have one.
///
/// Best-effort: this runs unconditionally at every app start (see
/// router.dart), before anything's confirmed the cache is even reachable —
/// a failure here shouldn't crash startup, just skip reconciling this once.
@riverpod
Future<void> habitReminders(Ref ref) async {
  try {
    final repository = await ref.watch(habitRepositoryProvider.future);
    final service = await ref.watch(notificationServiceProvider.future);
    for (final habit in repository.getHabits()) {
      final hasReminder =
          habit.reminderTime != null && habit.reminderDays.isNotEmpty;
      if (!habit.archived && hasReminder) {
        await service.scheduleHabitReminder(habit);
      }
    }
  } catch (error) {
    debugPrint('Failed to reconcile habit reminders: $error');
  }
}
