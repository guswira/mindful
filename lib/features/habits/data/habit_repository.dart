import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../shared/models/sync_status.dart';
import '../domain/habit.dart';
import '../domain/habit_log.dart';
import 'supabase_habit_datasource.dart';

part 'habit_repository.g.dart';

/// Habit + habit log CRUD, backed by a Hive cache and synced to Supabase.
///
/// Reads and the cache-mutating methods never touch the network by
/// themselves — [saveHabit]/[deleteHabit]/[saveLog]/[deleteLog] write to
/// cache first, then push to Supabase, per SPEC.md's storage strategy.
/// Habits have no `sync_status` column in the schema, so a failed habit
/// sync is surfaced to the caller instead of retried; habit logs do have
/// one, so a failed log sync is swallowed and marked
/// [SyncStatus.pending] for [SyncService] to retry later.
class HabitRepository {
  HabitRepository({
    required Box<dynamic> habitsBox,
    required Box<dynamic> habitLogsBox,
    SupabaseHabitDatasource? datasource,
  }) : _habitsBox = habitsBox,
       _habitLogsBox = habitLogsBox,
       _datasource = datasource ?? SupabaseHabitDatasource();

  /// The Hive box names this repository caches into.
  static const String habitsBoxName = 'habits';
  static const String habitLogsBoxName = 'habit_logs';

  final Box<dynamic> _habitsBox;
  final Box<dynamic> _habitLogsBox;
  final SupabaseHabitDatasource _datasource;

  /// All cached habits, most recently created first. Skips any record
  /// that fails to decode (e.g. cached by an older, incompatible app
  /// version) instead of letting one bad entry take down the whole list.
  List<Habit> getHabits() {
    final habits = <Habit>[];
    for (final value in _habitsBox.values) {
      try {
        habits.add(Habit.fromJson(_asJsonMap(value)));
      } catch (error) {
        debugPrint('Skipping unreadable cached habit: $error');
      }
    }
    habits.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return habits;
  }

  /// Today's active (non-archived) habits — for the home/lock screen
  /// widgets. See SPEC.md Home and Lock Screen Widgets.
  List<Habit> getTodayHabits() =>
      getHabits().where((habit) => !habit.archived).toList();

  /// Today's completion logs, across all habits — for the home/lock screen
  /// widgets. See SPEC.md Home and Lock Screen Widgets.
  List<HabitLog> getTodayLogs() {
    final today = _dateOnly(DateTime.now());
    return getAllLogs().where((log) => _dateOnly(log.date) == today).toList();
  }

  /// Adds or overwrites [habit] in the cache, then syncs it to Supabase.
  /// Throws if the Supabase sync fails — see class doc.
  Future<void> saveHabit(Habit habit) async {
    await _habitsBox.put(habit.id, habit.toJson());
    await _datasource.saveHabit(habit);
  }

  /// Removes the habit with [habitId] from the cache, then Supabase.
  /// Throws if the Supabase sync fails — see class doc.
  Future<void> deleteHabit(String habitId) async {
    await _habitsBox.delete(habitId);
    await _datasource.deleteHabit(habitId);
  }

  /// Every cached completion log, across all habits and months. Skips any
  /// record that fails to decode — see [getHabits].
  List<HabitLog> getAllLogs() {
    final logs = <HabitLog>[];
    for (final value in _habitLogsBox.values) {
      try {
        logs.add(HabitLog.fromJson(_asJsonMap(value)));
      } catch (error) {
        debugPrint('Skipping unreadable cached habit log: $error');
      }
    }
    return logs;
  }

  /// The cached completion log for [habitId] on [date], if any. Null if
  /// nothing is cached, or if what's cached fails to decode.
  HabitLog? getLog(String habitId, DateTime date) {
    final value = _habitLogsBox.get(_logKey(habitId, date));
    if (value == null) {
      return null;
    }
    try {
      return HabitLog.fromJson(_asJsonMap(value));
    } catch (error) {
      debugPrint('Skipping unreadable cached habit log: $error');
      return null;
    }
  }

  /// Adds or overwrites [log] in the cache, then syncs it to Supabase.
  /// Marks it [SyncStatus.pending] in the cache on failure instead of
  /// throwing — see class doc.
  Future<void> saveLog(HabitLog log) async {
    await _habitLogsBox.put(_logKey(log.habitId, log.date), log.toJson());
    try {
      await _datasource.saveLog(log);
    } catch (_) {
      await _habitLogsBox.put(
        _logKey(log.habitId, log.date),
        log.copyWith(syncStatus: SyncStatus.pending).toJson(),
      );
    }
  }

  /// Removes the completion log for [habitId] on [date] from the cache,
  /// then Supabase.
  Future<void> deleteLog(String habitId, DateTime date) async {
    await _habitLogsBox.delete(_logKey(habitId, date));
    await _datasource.deleteLog(habitId, date);
  }

  /// Replaces the cache with habits and this month's logs from Supabase.
  Future<void> refreshFromSupabase() async {
    final habits = await _datasource.fetchHabits();
    await _habitsBox.clear();
    for (final habit in habits) {
      await _habitsBox.put(habit.id, habit.toJson());
    }

    final logs = await _datasource.fetchLogs(DateTime.now());
    for (final log in logs) {
      await _habitLogsBox.put(_logKey(log.habitId, log.date), log.toJson());
    }
  }

  /// Logs for [habitId] in [month], fetched fresh from Supabase and merged
  /// into the cache. Used by the calendar view, which needs arbitrary past
  /// months that [refreshFromSupabase] (current month only) doesn't cache.
  Future<List<HabitLog>> logsForHabitInMonth(
    String habitId,
    DateTime month,
  ) async {
    final logs = await _datasource.fetchLogs(month);
    for (final log in logs) {
      await _habitLogsBox.put(_logKey(log.habitId, log.date), log.toJson());
    }
    return logs.where((log) => log.habitId == habitId).toList();
  }

  /// Retries every habit log still marked [SyncStatus.pending]. Skips any
  /// record that fails to decode — see [getHabits].
  Future<void> retryPendingLogs() async {
    for (final value in _habitLogsBox.values.toList()) {
      HabitLog log;
      try {
        log = HabitLog.fromJson(_asJsonMap(value));
      } catch (error) {
        debugPrint('Skipping unreadable cached habit log: $error');
        continue;
      }
      if (log.syncStatus == SyncStatus.pending) {
        await saveLog(log.copyWith(syncStatus: SyncStatus.synced));
      }
    }
  }

  static String _logKey(String habitId, DateTime date) {
    final day = _dateOnly(date);
    return '${habitId}_${day.toIso8601String()}';
  }

  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  /// Hive returns nested maps/lists with loose (`dynamic`) generics, which
  /// `fromJson` rejects. Round-tripping through `jsonEncode`/`jsonDecode`
  /// re-materializes them with the `Map<String, dynamic>` shape it expects.
  static Map<String, dynamic> _asJsonMap(Object value) =>
      jsonDecode(jsonEncode(value)) as Map<String, dynamic>;
}

/// The Hive box caching habit definitions, keyed by habit id.
@Riverpod(keepAlive: true)
Future<Box<dynamic>> habitsBox(Ref ref) =>
    Hive.openBox<dynamic>(HabitRepository.habitsBoxName);

/// The Hive box caching habit completion logs, keyed by `habitId_date`.
@Riverpod(keepAlive: true)
Future<Box<dynamic>> habitLogsBox(Ref ref) =>
    Hive.openBox<dynamic>(HabitRepository.habitLogsBoxName);

/// The app-wide [HabitRepository], backed by the opened Hive boxes.
@Riverpod(keepAlive: true)
Future<HabitRepository> habitRepository(Ref ref) async {
  final habitsBox = await ref.watch(habitsBoxProvider.future);
  final habitLogsBox = await ref.watch(habitLogsBoxProvider.future);
  return HabitRepository(habitsBox: habitsBox, habitLogsBox: habitLogsBox);
}
