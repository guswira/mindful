import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../shared/services/drive_service.dart';
import '../../habits/data/supabase_habit_datasource.dart';
import '../../habits/domain/habit_log.dart';
import '../../journal/data/supabase_journal_datasource.dart';
import '../../money/data/supabase_money_datasource.dart';
import '../../tasks/data/supabase_task_datasource.dart';

part 'backup_repository.g.dart';

/// How many records a backup import added versus skipped because their id
/// already existed in Supabase.
typedef BackupImportSummary = ({
  int importedJournals,
  int importedHabits,
  int importedHabitLogs,
  int importedTasks,
  int importedMoneyEntries,
  int skippedJournals,
  int skippedHabits,
  int skippedHabitLogs,
  int skippedTasks,
  int skippedMoneyEntries,
});

/// Exports/imports manual Drive backups (see [DriveService]) and tracks
/// when the last one ran. Backup/restore is opt-in and never the primary
/// datastore — see SPEC.md.
class BackupRepository {
  BackupRepository({
    DriveService driveService = const DriveService(),
    FlutterSecureStorage storage = const FlutterSecureStorage(),
    SupabaseJournalDatasource? journalDatasource,
    SupabaseHabitDatasource? habitDatasource,
    SupabaseTaskDatasource? taskDatasource,
    SupabaseMoneyDatasource? moneyDatasource,
  }) : _driveService = driveService,
       _storage = storage,
       _journalDatasource = journalDatasource ?? SupabaseJournalDatasource(),
       _habitDatasource = habitDatasource ?? SupabaseHabitDatasource(),
       _taskDatasource = taskDatasource ?? SupabaseTaskDatasource(),
       _moneyDatasource = moneyDatasource ?? SupabaseMoneyDatasource();

  static const String _lastBackupAtKey = 'drive_last_backup_at';
  static const String _autoBackupEnabledKey = 'drive_auto_backup_enabled';

  final DriveService _driveService;
  final FlutterSecureStorage _storage;
  final SupabaseJournalDatasource _journalDatasource;
  final SupabaseHabitDatasource _habitDatasource;
  final SupabaseTaskDatasource _taskDatasource;
  final SupabaseMoneyDatasource _moneyDatasource;

  /// When the last backup completed, or null if none has yet.
  Future<DateTime?> lastBackupAt() async {
    final value = await _storage.read(key: _lastBackupAtKey);
    return value == null ? null : DateTime.parse(value);
  }

  /// Whether backups should run automatically on the 1st of each month.
  Future<bool> isAutoBackupEnabled() async {
    final value = await _storage.read(key: _autoBackupEnabledKey);
    return value == 'true';
  }

  Future<void> setAutoBackupEnabled(bool enabled) =>
      _storage.write(key: _autoBackupEnabledKey, value: '$enabled');

  /// Backs up every journal, habit, habit log and task to this month's
  /// Drive backup folder.
  Future<void> backupNow(http.Client client) async {
    final journals = await _journalDatasource.fetchAll();
    final habits = await _habitDatasource.fetchHabits();
    final habitLogs = await _allHabitLogs();
    final tasks = await _taskDatasource.getAll();
    final moneyEntries = await _moneyDatasource.getEntries();
    final budgetSettings = await _moneyDatasource.getAllBudgetSettings();
    await _driveService.backup(
      client,
      month: DateTime.now(),
      journals: journals,
      habits: habits,
      habitLogs: habitLogs,
      tasks: tasks,
      moneyEntries: moneyEntries,
      budgetSettings: budgetSettings,
    );
    await _storage.write(
      key: _lastBackupAtKey,
      value: DateTime.now().toIso8601String(),
    );
  }

  /// The `YYYY-MM` names of every available backup, newest first.
  Future<List<String>> listBackups(http.Client client) =>
      _driveService.listBackups(client);

  /// The contents of the backup for [month], for the restore preview.
  Future<BackupContents> previewBackup(http.Client client, String month) =>
      _driveService.importBackup(client, month);

  /// Imports the backup for [month] into Supabase, skipping any record
  /// whose id already exists there.
  Future<BackupImportSummary> importBackup(
    http.Client client,
    String month,
  ) async {
    final contents = await _driveService.importBackup(client, month);
    final existingJournalIds = {
      for (final entry in await _journalDatasource.fetchAll()) entry.id,
    };
    final existingHabitIds = {
      for (final habit in await _habitDatasource.fetchHabits()) habit.id,
    };
    final existingHabitLogIds = {
      for (final log in await _allHabitLogs()) log.id,
    };
    final existingTaskIds = {
      for (final task in await _taskDatasource.getAll()) task.id,
    };
    final existingMoneyEntryIds = {
      for (final entry in await _moneyDatasource.getEntries()) entry.id,
    };

    var importedJournals = 0;
    for (final entry in contents.journals) {
      if (existingJournalIds.contains(entry.id)) {
        continue;
      }
      await _journalDatasource.saveEntry(entry);
      importedJournals++;
    }

    var importedHabits = 0;
    for (final habit in contents.habits) {
      if (existingHabitIds.contains(habit.id)) {
        continue;
      }
      await _habitDatasource.saveHabit(habit);
      importedHabits++;
    }

    var importedHabitLogs = 0;
    for (final log in contents.habitLogs) {
      if (existingHabitLogIds.contains(log.id)) {
        continue;
      }
      await _habitDatasource.saveLog(log);
      importedHabitLogs++;
    }

    var importedTasks = 0;
    for (final task in contents.tasks) {
      if (existingTaskIds.contains(task.id)) {
        continue;
      }
      await _taskDatasource.create(task);
      importedTasks++;
    }

    var importedMoneyEntries = 0;
    for (final entry in contents.moneyEntries) {
      if (existingMoneyEntryIds.contains(entry.id)) {
        continue;
      }
      await _moneyDatasource.createEntry(entry);
      importedMoneyEntries++;
    }

    // Up to one row per BudgetType — skipped per type, not per row, since
    // an imported row's id won't match a same-type row already set
    // locally (each edit keeps its id, but the very first save for a
    // type mints a new one).
    for (final imported in contents.budgetSettings) {
      if (await _moneyDatasource.getBudgetSettings(imported.budgetType) !=
          null) {
        continue;
      }
      await _moneyDatasource.saveBudgetSettings(imported);
    }

    return (
      importedJournals: importedJournals,
      importedHabits: importedHabits,
      importedHabitLogs: importedHabitLogs,
      importedTasks: importedTasks,
      importedMoneyEntries: importedMoneyEntries,
      skippedJournals: contents.journals.length - importedJournals,
      skippedHabits: contents.habits.length - importedHabits,
      skippedHabitLogs: contents.habitLogs.length - importedHabitLogs,
      skippedMoneyEntries: contents.moneyEntries.length - importedMoneyEntries,
      skippedTasks: contents.tasks.length - importedTasks,
    );
  }

  /// Every habit log across the last 12 months — Supabase has no
  /// "fetch all logs ever" query (see [SupabaseHabitDatasource.fetchLogs]),
  /// so backups cover a rolling year rather than full history.
  Future<List<HabitLog>> _allHabitLogs() async {
    final now = DateTime.now();
    final logs = <HabitLog>[];
    for (var i = 0; i < 12; i++) {
      final month = DateTime(now.year, now.month - i);
      logs.addAll(await _habitDatasource.fetchLogs(month));
    }
    return logs;
  }
}

@Riverpod(keepAlive: true)
BackupRepository backupRepository(Ref ref) => BackupRepository();
