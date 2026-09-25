import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/glass_theme.dart';
import '../../../shared/services/notification_service.dart';
import '../../../shared/services/widget_service.dart';
import '../../../shared/widgets/blob_background.dart';
import '../../../shared/widgets/glass_bottom_sheet.dart';
import '../../../shared/widgets/glass_icon_button.dart';
import '../data/task_repository.dart';
import '../domain/task.dart';
import 'add_task_sheet.dart';
import 'task_tab_list.dart';

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

/// All tasks grouped: Today (due today or overdue), Upcoming, No date, and
/// a collapsed Completed section at the bottom. See SPEC.md Task Manager.
class TaskTab extends ConsumerWidget {
  const TaskTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final tasksAsync = ref.watch(taskTabControllerProvider);

    return Scaffold(
      body: RepaintBoundary(
        child: BlobBackground(
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.l10n.taskTabTitle,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      GlassIconButton(
                        icon: Icons.add,
                        tooltip: context.l10n.taskAddTask,
                        onTap: () => showGlassBottomSheet(
                          context: context,
                          builder: (_) => const AddTaskSheet(),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: switch (tasksAsync) {
                    AsyncData(:final value) => TaskGroupedList(tasks: value),
                    AsyncError(:final error) => Center(
                      child: Text(
                        context.l10n.taskLoadListError('$error'),
                        style: TextStyle(color: glass.textSecondary),
                      ),
                    ),
                    _ => const Center(child: CircularProgressIndicator()),
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
