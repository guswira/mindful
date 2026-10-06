import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../shared/services/notification_service.dart';
import '../../../shared/services/widget_service.dart';
import '../data/task_repository.dart';
import '../domain/task.dart';
import 'task_providers.dart';

part 'task_tab.g.dart';

/// Loads all tasks, refreshed from Supabase in the background, and owns
/// every task write — each one reloads this list (Home's Today's Todo, the
/// Tasks & Routines tab, Be Mindful), the task's [taskByIdProvider] and
/// the home/lock screen widgets. See SPEC.md Task Manager.
@riverpod
class TaskTabController extends _$TaskTabController {
  @override
  Future<List<Task>> build() async {
    final repository = await ref.watch(taskRepositoryProvider.future);
    unawaited(_refreshFromSupabase(repository));
    return repository.getAll();
  }

  /// Swaps in the fresh list via [state] rather than `invalidateSelf()`:
  /// re-running [build] would start another refresh, looping forever and
  /// flashing every watcher back to loading on each round trip.
  Future<void> _refreshFromSupabase(TaskRepository repository) async {
    try {
      state = AsyncData(await repository.refresh());
    } catch (_) {
      // Best-effort: the cache is still shown when Supabase is unreachable.
    }
  }

  /// Creates [task] ([isNew]) or overwrites it in the cache, then Supabase.
  /// Its reminder is the caller's to (re)schedule.
  Future<void> save(Task task, {required bool isNew}) async {
    final repository = await ref.read(taskRepositoryProvider.future);
    await (isNew ? repository.create(task) : repository.update(task));
    await _changed(task.id);
  }

  /// Marks [taskId] complete in the cache, then Supabase, and cancels its
  /// reminder — it's done, so it shouldn't still fire. Keeps its
  /// notification id reserved, unlike [delete], since the task itself
  /// still exists and could get a reminder again later.
  Future<void> complete(String taskId) async {
    final repository = await ref.read(taskRepositoryProvider.future);
    final notificationService = await ref.read(
      notificationServiceProvider.future,
    );
    await notificationService.cancelTaskReminder(taskId);
    await repository.markComplete(taskId);
    await _changed(taskId);
  }

  /// Cancels and forgets [taskId]'s reminder, then deletes it from the
  /// cache and Supabase.
  Future<void> delete(String taskId) async {
    final repository = await ref.read(taskRepositoryProvider.future);
    final notificationService = await ref.read(
      notificationServiceProvider.future,
    );
    await notificationService.forgetTaskReminder(taskId);
    await repository.delete(taskId);
    await _changed(taskId);
  }

  /// Reloads everything that shows [taskId] after a write.
  Future<void> _changed(String taskId) async {
    ref
      ..invalidateSelf()
      ..invalidate(taskByIdProvider(taskId));
    await refreshWidgetsBestEffort(
      () => ref.read(widgetServiceProvider.future),
    );
  }
}
