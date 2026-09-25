import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../shared/models/sync_status.dart';
import '../domain/task.dart';
import 'supabase_task_datasource.dart';

part 'task_repository.g.dart';

/// Task CRUD backed by a Hive cache, synced to Supabase through
/// [SupabaseTaskDatasource]. Writes go to cache first (optimistic), then
/// to Supabase, per SPEC.md's storage strategy: a write that fails to
/// reach Supabase stays in the cache marked [SyncStatus.pending].
class TaskRepository {
  TaskRepository({
    required Box<dynamic> cacheBox,
    SupabaseTaskDatasource? datasource,
  }) : _cacheBox = cacheBox,
       _datasource = datasource ?? SupabaseTaskDatasource();

  /// The Hive box name this repository caches into.
  static const String boxName = 'tasks';

  final Box<dynamic> _cacheBox;
  final SupabaseTaskDatasource _datasource;

  /// All cached tasks. Skips any record that fails to decode (e.g. cached
  /// by an older, incompatible app version) instead of letting one bad
  /// entry take down the whole list.
  List<Task> getAll() {
    final tasks = <Task>[];
    for (final value in _cacheBox.values) {
      try {
        tasks.add(_decode(value));
      } catch (error) {
        debugPrint('Skipping unreadable cached task: $error');
      }
    }
    return tasks;
  }

  /// The cached task with [id], or null if it isn't cached or fails to
  /// decode.
  Task? getById(String id) {
    final value = _cacheBox.get(id);
    if (value == null) {
      return null;
    }
    try {
      return _decode(value);
    } catch (error) {
      debugPrint('Skipping unreadable cached task: $error');
      return null;
    }
  }

  /// Tasks due today, complete or not — for the home/lock screen widgets.
  /// See SPEC.md Home and Lock Screen Widgets.
  List<Task> getDueToday() {
    final today = _dateOnly(DateTime.now());
    return getAll()
        .where(
          (task) => task.dueDate != null && _dateOnly(task.dueDate!) == today,
        )
        .toList();
  }

  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  /// Replaces the cache with the current state of Supabase.
  Future<List<Task>> refresh() async {
    final tasks = await _datasource.getAll();
    await _cacheBox.clear();
    for (final task in tasks) {
      await _cacheBox.put(task.id, task.toJson());
    }
    return getAll();
  }

  /// Caches a new [task], then inserts it in Supabase.
  Future<void> create(Task task) =>
      _writeOptimistic(task, () => _datasource.create(task));

  /// Caches edits to an existing [task], then upserts it in Supabase.
  Future<void> update(Task task) =>
      _writeOptimistic(task, () => _datasource.update(task));

  /// Marks the task with [id] complete in the cache, then Supabase.
  /// No-ops if [id] isn't cached.
  Future<void> markComplete(String id) async {
    final task = getById(id);
    if (task == null) {
      return;
    }
    final completed = task.copyWith(
      isCompleted: true,
      updatedAt: DateTime.now(),
    );
    await _writeOptimistic(completed, () => _datasource.markComplete(id));
  }

  /// Deletes the task with [id] from cache and Supabase.
  Future<void> delete(String id) async {
    await _cacheBox.delete(id);
    await _datasource.delete(id);
  }

  /// Retries every task still marked [SyncStatus.pending].
  Future<void> retryPendingTasks() async {
    for (final task in getAll()) {
      if (task.syncStatus == SyncStatus.pending) {
        await update(task.copyWith(syncStatus: SyncStatus.synced));
      }
    }
  }

  /// Caches [task], then runs [sync]. Marks the cached copy
  /// [SyncStatus.pending] instead of throwing if [sync] fails.
  Future<void> _writeOptimistic(Task task, Future<void> Function() sync) async {
    await _cacheBox.put(task.id, task.toJson());
    try {
      await sync();
    } catch (_) {
      await _cacheBox.put(
        task.id,
        task.copyWith(syncStatus: SyncStatus.pending).toJson(),
      );
    }
  }

  /// Hive returns nested maps/lists with loose (`dynamic`) generics, which
  /// `fromJson` rejects. Round-tripping through `jsonEncode`/`jsonDecode`
  /// re-materializes them with the `Map<String, dynamic>` shape it expects.
  Task _decode(Object value) =>
      Task.fromJson(jsonDecode(jsonEncode(value)) as Map<String, dynamic>);
}

/// The Hive box caching tasks, keyed by task id.
@Riverpod(keepAlive: true)
Future<Box<dynamic>> tasksBox(Ref ref) =>
    Hive.openBox<dynamic>(TaskRepository.boxName);

/// The app-wide [TaskRepository], backed by the opened Hive box.
@Riverpod(keepAlive: true)
Future<TaskRepository> taskRepository(Ref ref) async {
  final box = await ref.watch(tasksBoxProvider.future);
  return TaskRepository(cacheBox: box);
}
