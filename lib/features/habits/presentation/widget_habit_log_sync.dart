import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

import '../../auth/domain/auth_state.dart';
import '../data/habit_repository.dart';
import '../domain/habit.dart';
import '../domain/habit_action.dart';
import 'habit_tab.dart';

/// App Group key the iOS lock screen widget's intents append to. See
/// SPEC.md Home and Lock Screen Widgets.
const pendingWidgetHabitLogsKey = 'pendingHabitLogs';

/// One routine check/uncheck tapped on the iOS lock screen widget while the
/// app wasn't running. The widget extension can't reach Hive or Supabase,
/// so it only records the tap; the app replays it here.
@immutable
class PendingWidgetHabitLog {
  /// Creates a queued tap; [actionLabel] null means plain "done".
  const PendingWidgetHabitLog({
    required this.habitId,
    required this.date,
    this.actionLabel,
    this.undo = false,
  });

  final String habitId;

  /// The local day the tap was for — a tap at 23:59 still logs that day
  /// even if the app only opens the next morning.
  final DateTime date;
  final String? actionLabel;

  /// True for un-checking (deletes that day's log).
  final bool undo;
}

/// Parses the queue the widget extension writes; malformed entries (or a
/// malformed queue) are skipped rather than blocking the rest.
List<PendingWidgetHabitLog> parsePendingWidgetHabitLogs(String? raw) {
  if (raw == null || raw.isEmpty) {
    return const [];
  }
  final Object? decoded;
  try {
    decoded = jsonDecode(raw);
  } on FormatException {
    return const [];
  }
  if (decoded is! List) {
    return const [];
  }
  return [
    for (final item in decoded)
      if (item case {
        'habitId': final String habitId,
        'date': final String date,
      })
        if (DateTime.tryParse(date) case final DateTime day)
          PendingWidgetHabitLog(
            habitId: habitId,
            date: day,
            actionLabel: item['actionLabel'] as String?,
            undo: item['undo'] == true,
          ),
  ];
}

/// [habit]'s action labeled [label], or null (plain "done") if [label] is
/// null or the action has since been renamed/removed.
HabitAction? habitActionByLabel(Habit habit, String? label) {
  for (final action in habit.actions) {
    if (action.label == label) {
      return action;
    }
  }
  return null;
}

Future<void>? _inFlight;

/// Replays the iOS lock screen widget's queued taps once signed in, and
/// again on every resume (the user may tap it while the app is
/// backgrounded). Call once from main(); iOS only.
void listenForWidgetHabitLogs(ProviderContainer container) {
  void applyIfSignedIn() {
    if (container.read(authNotifierProvider) is AuthAuthenticated) {
      unawaited(applyPendingWidgetHabitLogs(container));
    }
  }

  container.listen(
    authNotifierProvider,
    (_, _) => applyIfSignedIn(),
    fireImmediately: true,
  );
  // Registered with the binding, which keeps it alive for the app's life.
  AppLifecycleListener(onResume: applyIfSignedIn);
}

/// Replays and clears the lock screen widget's queued taps. Safe to call
/// repeatedly (app start + every resume): overlapping calls share one run.
Future<void> applyPendingWidgetHabitLogs(ProviderContainer container) =>
    _inFlight ??= _apply(container).whenComplete(() => _inFlight = null);

Future<void> _apply(ProviderContainer container) async {
  try {
    final raw = await HomeWidget.getWidgetData<String>(
      pendingWidgetHabitLogsKey,
    );
    final pending = parsePendingWidgetHabitLogs(raw);
    if (pending.isEmpty) {
      return;
    }
    // Cleared before replaying: a tap made while replaying lands in a fresh
    // queue instead of being wiped with this one.
    await HomeWidget.saveWidgetData<String>(pendingWidgetHabitLogsKey, null);

    final repository = await container.read(habitRepositoryProvider.future);
    final habitsById = {
      for (final habit in repository.getHabits()) habit.id: habit,
    };
    final controller = container.read(habitTabControllerProvider.notifier);
    for (final log in pending) {
      final habit = habitsById[log.habitId];
      if (habit == null) {
        continue;
      }
      try {
        if (log.undo) {
          await controller.unlog(habit, on: log.date);
        } else {
          await controller.logAction(
            habit,
            habitActionByLabel(habit, log.actionLabel),
            on: log.date,
          );
        }
      } catch (error) {
        // No BuildContext for a SnackBar — same as an Android widget unlog.
        debugPrint('Failed to sync widget habit log: $error');
      }
    }
  } catch (error) {
    debugPrint('Failed to apply widget habit logs: $error');
  }
}
