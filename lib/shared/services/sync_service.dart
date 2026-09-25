import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/habits/data/habit_repository.dart';
import '../../features/journal/data/journal_repository.dart';
import '../../features/money/data/money_repository.dart';
import '../../features/tasks/data/task_repository.dart';
import 'widget_service.dart';

part 'sync_service.g.dart';

/// Keeps Hive in sync with Supabase: pulls fresh data on app open, and
/// retries any local writes that previously failed to reach Supabase.
///
/// Neither direction is table-specific — each entry in [pull] mirrors one
/// Supabase table into its own Hive box, and each entry in [retryPending]
/// resends whatever records in one box are still marked
/// `SyncStatus.pending`. Repositories own their own table's shape; this
/// service only owns when syncing happens.
class SyncService {
  SyncService({
    required List<Future<void> Function()> pull,
    required List<Future<void> Function()> retryPending,
    required Future<void> Function() updateWidgetData,
    DateTime Function() now = DateTime.now,
  }) : _pull = pull,
       _retryPending = retryPending,
       _updateWidgetData = updateWidgetData,
       _now = now;

  /// A sync within this long of the previous one is skipped.
  static const Duration minSyncInterval = Duration(minutes: 5);

  final List<Future<void> Function()> _pull;
  final List<Future<void> Function()> _retryPending;
  final Future<void> Function() _updateWidgetData;
  final DateTime Function() _now;

  DateTime? _lastSyncedAt;

  /// Retries pending local writes, pulls fresh data from Supabase, then
  /// refreshes the home/lock screen widgets — called on every app open,
  /// per SPEC.md.
  ///
  /// No-ops if the previous sync completed under [minSyncInterval] ago.
  /// The widget refresh always runs, even if Supabase is unreachable —
  /// the local cache is what the widgets read either way, so a failed
  /// pull shouldn't leave them stuck on stale data.
  Future<void> syncOnOpen() async {
    final lastSyncedAt = _lastSyncedAt;
    if (lastSyncedAt != null &&
        _now().difference(lastSyncedAt) < minSyncInterval) {
      return;
    }

    try {
      for (final retryOne in _retryPending) {
        await retryOne();
      }
      for (final pullOne in _pull) {
        await pullOne();
      }
    } catch (error) {
      // Best-effort: the cache is still shown when Supabase is unreachable.
      debugPrint('Sync on open failed: $error');
    }
    await _updateWidgetData();

    _lastSyncedAt = _now();
  }
}

/// The app-wide [SyncService], wired to the journal and habit repositories.
@Riverpod(keepAlive: true)
Future<SyncService> syncService(Ref ref) async {
  final journalRepository = await ref.watch(journalRepositoryProvider.future);
  final habitRepository = await ref.watch(habitRepositoryProvider.future);
  final taskRepository = await ref.watch(taskRepositoryProvider.future);
  final moneyRepository = await ref.watch(moneyRepositoryProvider.future);
  return SyncService(
    pull: [
      () async {
        await journalRepository.refresh();
      },
      () => habitRepository.refreshFromSupabase(),
      () async {
        await taskRepository.refresh();
      },
      () => moneyRepository.refresh(),
    ],
    retryPending: [
      () => journalRepository.retryPendingEntries(),
      () => habitRepository.retryPendingLogs(),
      () => taskRepository.retryPendingTasks(),
      () => moneyRepository.retryPendingEntries(),
    ],
    updateWidgetData: () =>
        refreshWidgetsBestEffort(() => ref.read(widgetServiceProvider.future)),
  );
}
