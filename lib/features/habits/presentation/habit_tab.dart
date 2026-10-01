import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

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

  Future<void> _refreshFromSupabase(HabitRepository repository) async {
    try {
      await repository.refreshFromSupabase();
      ref.invalidateSelf();
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
  /// today. Reuses today's existing log id, if any, instead of minting a
  /// new one on every toggle.
  Future<void> logAction(Habit habit, HabitAction? action) async {
    final repository = await ref.read(habitRepositoryProvider.future);
    final userId = ref.read(currentUserIdProvider);
    final today = DateTime.now();
    final existing = repository.getLog(habit.id, today);
    await repository.saveLog(
      HabitLog(
        id: existing?.id ?? const Uuid().v4(),
        userId: userId,
        habitId: habit.id,
        date: today,
        completedActionId: action?.id,
      ),
    );
    ref.invalidateSelf();
    await refreshWidgetsBestEffort(
      () => ref.read(widgetServiceProvider.future),
    );
  }

  /// Marks [habit] as not done today by deleting today's log. The list and
  /// widgets are refreshed even if the Supabase delete throws, since the
  /// cache has already dropped the log by then; the error is rethrown so
  /// the caller can surface it.
  Future<void> unlog(Habit habit) async {
    final repository = await ref.read(habitRepositoryProvider.future);
    try {
      await repository.deleteLog(habit.id, DateTime.now());
    } finally {
      ref.invalidateSelf();
      await refreshWidgetsBestEffort(
        () => ref.read(widgetServiceProvider.future),
      );
    }
  }
}
