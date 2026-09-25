import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../shared/models/sync_status.dart';
import '../../../shared/services/drive_service.dart';
import '../../habits/data/habit_repository.dart';
import '../../journal/data/journal_repository.dart';
import '../../money/data/money_repository.dart';
import '../../tasks/data/task_repository.dart';
import '../data/backup_repository.dart';
import '../data/drive_auth_repository.dart';

part 'backup_settings_controller.g.dart';

/// Everything Settings' Drive backup section shows.
typedef BackupSettingsState = ({
  bool driveConnected,
  DateTime? lastBackupAt,
  bool autoBackupEnabled,
  int pendingRecordsCount,
});

/// Drive connect/disconnect, manual + auto backup, and restore — see
/// SPEC.md Settings > Drive backup/restore sections.
@riverpod
class BackupSettings extends _$BackupSettings {
  @override
  Future<BackupSettingsState> build() async {
    final driveAuth = ref.watch(driveAuthRepositoryProvider);
    final backupRepository = ref.watch(backupRepositoryProvider);
    return (
      driveConnected: await driveAuth.isConnected(),
      lastBackupAt: await backupRepository.lastBackupAt(),
      autoBackupEnabled: await backupRepository.isAutoBackupEnabled(),
      pendingRecordsCount: await _pendingRecordsCount(),
    );
  }

  Future<int> _pendingRecordsCount() async {
    final journalRepository = await ref.read(journalRepositoryProvider.future);
    final habitRepository = await ref.read(habitRepositoryProvider.future);
    final taskRepository = await ref.read(taskRepositoryProvider.future);
    final moneyRepository = await ref.read(moneyRepositoryProvider.future);
    final pendingJournals = journalRepository
        .getAll()
        .where((entry) => entry.syncStatus == SyncStatus.pending)
        .length;
    final pendingLogs = habitRepository
        .getAllLogs()
        .where((log) => log.syncStatus == SyncStatus.pending)
        .length;
    final pendingTasks = taskRepository
        .getAll()
        .where((task) => task.syncStatus == SyncStatus.pending)
        .length;
    final pendingMoneyEntries = moneyRepository
        .getEntries()
        .where((entry) => entry.syncStatus == SyncStatus.pending)
        .length;
    return pendingJournals + pendingLogs + pendingTasks + pendingMoneyEntries;
  }

  /// Requests the Drive scope.
  Future<void> connectDrive() async {
    await ref.read(driveAuthRepositoryProvider).connect();
    ref.invalidateSelf();
    await future;
  }

  /// Revokes the Drive scope.
  Future<void> disconnectDrive() async {
    await ref.read(driveAuthRepositoryProvider).disconnect();
    ref.invalidateSelf();
    await future;
  }

  Future<void> setAutoBackupEnabled(bool enabled) async {
    await ref.read(backupRepositoryProvider).setAutoBackupEnabled(enabled);
    ref.invalidateSelf();
    await future;
  }

  /// Backs up all data to Drive now.
  Future<void> backupNow() async {
    await _withAuthorizedClient(
      (client) => ref.read(backupRepositoryProvider).backupNow(client),
    );
    ref.invalidateSelf();
    await future;
  }

  /// The `YYYY-MM` names of every available backup, newest first.
  Future<List<String>> listBackups() {
    return _withAuthorizedClient(
      (client) => ref.read(backupRepositoryProvider).listBackups(client),
    );
  }

  /// The contents of the backup for [month], for the restore preview.
  Future<BackupContents> previewBackup(String month) {
    return _withAuthorizedClient(
      (client) =>
          ref.read(backupRepositoryProvider).previewBackup(client, month),
    );
  }

  /// Imports the backup for [month] into Supabase, then refreshes the
  /// local cache so the newly-restored records show up immediately.
  Future<BackupImportSummary> importBackup(String month) async {
    final summary = await _withAuthorizedClient(
      (client) =>
          ref.read(backupRepositoryProvider).importBackup(client, month),
    );
    final journalRepository = await ref.read(journalRepositoryProvider.future);
    final habitRepository = await ref.read(habitRepositoryProvider.future);
    final taskRepository = await ref.read(taskRepositoryProvider.future);
    final moneyRepository = await ref.read(moneyRepositoryProvider.future);
    await journalRepository.refresh();
    await habitRepository.refreshFromSupabase();
    await taskRepository.refresh();
    await moneyRepository.refresh();
    return summary;
  }

  Future<T> _withAuthorizedClient<T>(
    Future<T> Function(dynamic client) action,
  ) async {
    final client = await ref
        .read(driveAuthRepositoryProvider)
        .authorizedClient();
    try {
      return await action(client);
    } finally {
      client.close();
    }
  }
}
