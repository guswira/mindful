import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../shared/services/notification_service.dart';
import '../../../shared/services/widget_service.dart';
import '../../auth/domain/auth_state.dart';
import '../data/habit_repository.dart';
import '../domain/habit.dart';
import '../domain/habit_action.dart';
import '../domain/habit_log.dart';

part 'habit_tab.g.dart';

/// A habit plus its completion log for today, if any.
typedef HabitTabItem = ({Habit habit, HabitLog? todayLog});

/// Loads today's active habits and their completion status, and logs new
/// completions to the cache (then Supabase, best-effort).
@riverpod
class HabitTabController extends _$HabitTabController {
  @override
  Future<List<HabitTabItem>> build() async {
    final repository = await ref.watch(habitRepositoryProvider.future);
    unawaited(_refreshFromSupabase(repository));
    return _loadToday(repository);
  }

  /// Swaps in the fresh list via [state] rather than `invalidateSelf()`:
  /// re-running [build] would start another refresh, looping forever and
  /// flashing every watcher back to loading on each round trip.
  Future<void> _refreshFromSupabase(HabitRepository repository) async {
    try {
      await repository.refreshFromSupabase();
      state = AsyncData(_loadToday(repository));
    } catch (_) {
      // Best-effort: the cache is still shown when Supabase is unreachable.
    }
  }

  List<HabitTabItem> _loadToday(HabitRepository repository) {
    final today = DateTime.now();
    return [
      for (final habit in repository.getHabits())
        if (!habit.archived)
          (habit: habit, todayLog: repository.getLog(habit.id, today)),
    ];
  }

  /// Logs [habit] as completed via [action] (or plain "done" if null) for
  /// [on] (default today — only the iOS lock screen widget's queued taps
  /// pass an earlier day). Reuses that day's existing log id, if any,
  /// instead of minting a new one on every toggle.
  Future<void> logAction(
    Habit habit,
    HabitAction? action, {
    DateTime? on,
  }) async {
    final repository = await ref.read(habitRepositoryProvider.future);
    final userId = ref.read(currentUserIdProvider);
    final day = on ?? DateTime.now();
    final existing = repository.getLog(habit.id, day);
    await repository.saveLog(
      HabitLog(
        id: existing?.id ?? const Uuid().v4(),
        userId: userId,
        habitId: habit.id,
        date: day,
        completedActionId: action?.id,
      ),
    );
    ref.invalidateSelf();
    await refreshWidgetsBestEffort(
      () => ref.read(widgetServiceProvider.future),
    );
  }

  /// Marks [habit] as not done on [on] (default today) by deleting that
  /// day's log. The list and widgets are refreshed even if the Supabase
  /// delete throws, since the cache has already dropped the log by then;
  /// the error is rethrown so the caller can surface it.
  Future<void> unlog(Habit habit, {DateTime? on}) async {
    final repository = await ref.read(habitRepositoryProvider.future);
    try {
      await repository.deleteLog(habit.id, on ?? DateTime.now());
    } finally {
      ref.invalidateSelf();
      await refreshWidgetsBestEffort(
        () => ref.read(widgetServiceProvider.future),
      );
    }
  }

  /// Hides [habit] from today's list and cancels its reminder, keeping its
  /// history and notification id so [restore] can bring it all back.
  Future<void> archive(Habit habit) => _changeHabit(() async {
    final repository = await ref.read(habitRepositoryProvider.future);
    await repository.saveHabit(habit.copyWith(archived: true));
    final notifications = await ref.read(notificationServiceProvider.future);
    await notifications.cancelHabitReminder(habit.id);
  });

  /// Un-archives [habit] and reschedules its reminder, if it has one.
  Future<void> restore(Habit habit) => _changeHabit(() async {
    final restored = habit.copyWith(archived: false);
    final repository = await ref.read(habitRepositoryProvider.future);
    await repository.saveHabit(restored);
    final notifications = await ref.read(notificationServiceProvider.future);
    await notifications.scheduleHabitReminder(restored);
  });

  /// Permanently deletes [habit] and its history. The reminder is only
  /// forgotten once the delete has gone through, so a failed delete leaves
  /// the habit fully intact.
  Future<void> delete(Habit habit) => _changeHabit(() async {
    final repository = await ref.read(habitRepositoryProvider.future);
    await repository.deleteHabit(habit.id);
    final notifications = await ref.read(notificationServiceProvider.future);
    await notifications.forgetHabitReminder(habit.id);
  });

  /// Runs [change], then reloads the list and widgets even if it threw
  /// part-way (e.g. saved to the cache but the Supabase sync failed). The
  /// error is rethrown so the caller can surface it.
  Future<void> _changeHabit(Future<void> Function() change) async {
    try {
      await change();
    } finally {
      ref.invalidateSelf();
      await refreshWidgetsBestEffort(
        () => ref.read(widgetServiceProvider.future),
      );
    }
  }
}

/// Archived habits, newest first — re-read whenever today's list reloads,
/// so archiving/restoring/deleting moves a habit between the two at once.
@riverpod
Future<List<Habit>> archivedHabits(Ref ref) async {
  ref.watch(habitTabControllerProvider);
  final repository = await ref.watch(habitRepositoryProvider.future);
  return repository.getHabits().where((habit) => habit.archived).toList();
}
