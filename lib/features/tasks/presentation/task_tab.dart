import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../shared/services/notification_service.dart';
import '../../../shared/services/widget_service.dart';
import '../data/task_repository.dart';
import '../domain/task.dart';

part 'task_tab.g.dart';

/// Loads all tasks and marks completions, refreshed from Supabase in the
/// background. See SPEC.md Task Manager.
@riverpod
class TaskTabController extends _$TaskTabController {
  @override
  Future<List<Task>> build() async {
    final repository = await ref.watch(taskRepositoryProvider.future);
    unawaited(_refreshFromSupabase(repository));
    return repository.getAll();
  }

  Future<void> _refreshFromSupabase(TaskRepository repository) async {
    try {
      await repository.refresh();
      ref.invalidateSelf();
    } catch (_) {
      // Best-effort: the cache is still shown when Supabase is unreachable.
    }
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
    ref.invalidateSelf();
    await refreshWidgetsBestEffort(
      () => ref.read(widgetServiceProvider.future),
    );
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
    ref.invalidateSelf();
    await refreshWidgetsBestEffort(
      () => ref.read(widgetServiceProvider.future),
    );
  }
}
