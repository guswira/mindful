import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/supabase_constants.dart';
import '../domain/habit.dart';
import '../domain/habit_log.dart';

/// Reads and writes habit definitions and completion logs in Supabase. See
/// SPEC.md Supabase schema.
class SupabaseHabitDatasource {
  SupabaseHabitDatasource({SupabaseClient? client}) : _clientOverride = client;

  final SupabaseClient? _clientOverride;

  // Resolved lazily so merely constructing this datasource doesn't require
  // Supabase.initialize() to have already run (e.g. in widget tests).
  SupabaseClient get _client => _clientOverride ?? Supabase.instance.client;

  /// Every habit belonging to the signed-in user (RLS-scoped).
  Future<List<Habit>> fetchHabits() async {
    final rows = await _client.from(SupabaseConstants.habitsTable).select();
    return [for (final row in rows) Habit.fromJson(row)];
  }

  /// Creates or overwrites [habit]'s row.
  Future<void> saveHabit(Habit habit) async {
    await _client.from(SupabaseConstants.habitsTable).upsert(habit.toJson());
  }

  /// Deletes the habit with [habitId], and its logs (`habit_logs.habit_id`
  /// references `habits` — deletion is handled by the schema's cascade, if
  /// configured; otherwise logs are pruned separately by the caller).
  Future<void> deleteHabit(String habitId) async {
    await _client
        .from(SupabaseConstants.habitsTable)
        .delete()
        .eq('id', habitId);
  }

  /// All completion logs within [month] for the signed-in user.
  Future<List<HabitLog>> fetchLogs(DateTime month) async {
    final start = DateTime(month.year, month.month);
    final end = DateTime(month.year, month.month + 1);
    final rows = await _client
        .from(SupabaseConstants.habitLogsTable)
        .select()
        .gte('date', start.toIso8601String())
        .lt('date', end.toIso8601String());
    return [for (final row in rows) HabitLog.fromJson(row)];
  }

  /// Creates or overwrites [log]'s row, matching on the `habit_id`+`date`
  /// unique constraint rather than `id` — re-logging the same habit on the
  /// same day updates that day's row instead of violating the constraint.
  Future<void> saveLog(HabitLog log) async {
    await _client
        .from(SupabaseConstants.habitLogsTable)
        .upsert(log.toJson(), onConflict: 'habit_id,date');
  }

  /// Removes the completion log for [habitId] on [date], if any.
  Future<void> deleteLog(String habitId, DateTime date) async {
    await _client
        .from(SupabaseConstants.habitLogsTable)
        .delete()
        .eq('habit_id', habitId)
        .eq('date', date.toIso8601String());
  }
}
