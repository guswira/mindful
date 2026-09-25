import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/supabase_constants.dart';
import '../domain/task.dart';

/// Reads and writes tasks in Supabase. See SPEC.md Supabase schema.
class SupabaseTaskDatasource {
  SupabaseTaskDatasource({SupabaseClient? client}) : _clientOverride = client;

  final SupabaseClient? _clientOverride;

  // Resolved lazily so merely constructing this datasource doesn't require
  // Supabase.initialize() to have already run (e.g. in widget tests).
  SupabaseClient get _client => _clientOverride ?? Supabase.instance.client;

  /// Every task belonging to the signed-in user (RLS-scoped).
  Future<List<Task>> getAll() async {
    final rows = await _client.from(SupabaseConstants.tasksTable).select();
    return [for (final row in rows) Task.fromJson(row)];
  }

  /// The task with [id], or null if it doesn't exist (or isn't the
  /// signed-in user's).
  Future<Task?> getById(String id) async {
    final row = await _client
        .from(SupabaseConstants.tasksTable)
        .select()
        .eq('id', id)
        .maybeSingle();
    return row == null ? null : Task.fromJson(row);
  }

  /// Inserts a new task row.
  Future<void> create(Task task) async {
    await _client.from(SupabaseConstants.tasksTable).insert(task.toJson());
  }

  /// Creates or overwrites [task]'s row.
  Future<void> update(Task task) async {
    await _client.from(SupabaseConstants.tasksTable).upsert(task.toJson());
  }

  /// Deletes the task with [id].
  Future<void> delete(String id) async {
    await _client.from(SupabaseConstants.tasksTable).delete().eq('id', id);
  }

  /// Marks the task with [id] complete.
  Future<void> markComplete(String id) async {
    await _client
        .from(SupabaseConstants.tasksTable)
        .update({'is_completed': true})
        .eq('id', id);
  }
}
