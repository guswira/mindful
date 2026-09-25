import 'dart:convert';

import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;

import '../../features/habits/domain/habit.dart';
import '../../features/habits/domain/habit_log.dart';
import '../../features/journal/domain/journal_entry.dart';
import '../../features/money/domain/budget_settings.dart';
import '../../features/money/domain/money_entry.dart';
import '../../features/tasks/domain/task.dart';

/// A single month's backup contents, as read back by [DriveService.importBackup].
typedef BackupContents = ({
  List<JournalEntry> journals,
  List<Habit> habits,
  List<HabitLog> habitLogs,
  List<Task> tasks,
  List<MoneyEntry> moneyEntries,
  List<BudgetSettings> budgetSettings,
});

/// Manual backup and restore of the app's data to the user's Google Drive
/// app folder. Not used for primary storage — see SPEC.md.
///
/// Callers provide an already-authenticated [http.Client] for a session
/// that's been granted [scope], keeping this service unaware of sign-in.
/// [importBackup] only reads the backup's contents back — the "skip if the
/// id already exists" conflict rule is applied by the caller once it has
/// both this data and the current Supabase records to compare against.
class DriveService {
  const DriveService();

  /// OAuth scope required for everything this service does.
  static const String scope = drive.DriveApi.driveFileScope;

  static const String _appFolderName = 'AppFolder';
  static const String _backupsFolderName = 'backups';
  static const String _folderMimeType = 'application/vnd.google-apps.folder';
  static const String _jsonMimeType = 'application/json';

  static const String _journalsFileName = 'journals.json';
  static const String _habitsFileName = 'habits.json';
  static const String _habitLogsFileName = 'habit_logs.json';
  static const String _tasksFileName = 'tasks.json';
  static const String _moneyEntriesFileName = 'money_entries.json';
  static const String _budgetSettingsFileName = 'budget_settings.json';

  /// Writes [journals], [habits], [habitLogs], [tasks], [moneyEntries] and
  /// [budgetSettings] to `/AppFolder/backups/YYYY-MM/`, keyed by [month].
  Future<void> backup(
    http.Client client, {
    required DateTime month,
    required List<JournalEntry> journals,
    required List<Habit> habits,
    required List<HabitLog> habitLogs,
    required List<Task> tasks,
    required List<MoneyEntry> moneyEntries,
    required List<BudgetSettings> budgetSettings,
  }) async {
    final api = drive.DriveApi(client);
    final backupsFolderId = await _ensureBackupsFolder(api);
    final monthFolderId = await _ensureFolder(
      api,
      name: _monthFolderName(month),
      parentId: backupsFolderId,
    );
    await _writeJsonFile(
      api,
      folderId: monthFolderId,
      fileName: _journalsFileName,
      content: {
        'journals': [for (final entry in journals) entry.toJson()],
      },
    );
    await _writeJsonFile(
      api,
      folderId: monthFolderId,
      fileName: _habitsFileName,
      content: {
        'habits': [for (final habit in habits) habit.toJson()],
      },
    );
    await _writeJsonFile(
      api,
      folderId: monthFolderId,
      fileName: _habitLogsFileName,
      content: {
        'logs': [for (final log in habitLogs) log.toJson()],
      },
    );
    await _writeJsonFile(
      api,
      folderId: monthFolderId,
      fileName: _tasksFileName,
      content: {
        'tasks': [for (final task in tasks) task.toJson()],
      },
    );
    await _writeJsonFile(
      api,
      folderId: monthFolderId,
      fileName: _moneyEntriesFileName,
      content: {
        'money_entries': [for (final entry in moneyEntries) entry.toJson()],
      },
    );
    await _writeJsonFile(
      api,
      folderId: monthFolderId,
      fileName: _budgetSettingsFileName,
      content: {
        'budget_settings': [
          for (final settings in budgetSettings) settings.toJson(),
        ],
      },
    );
  }

  /// The `YYYY-MM` names of every backup folder under `/AppFolder/backups/`,
  /// newest first.
  Future<List<String>> listBackups(http.Client client) async {
    final api = drive.DriveApi(client);
    final backupsFolderId = await _ensureBackupsFolder(api);
    final result = await api.files.list(
      q:
          "'$backupsFolderId' in parents and mimeType = '$_folderMimeType' "
          'and trashed = false',
      spaces: 'drive',
      $fields: 'files(name)',
    );
    final names = [
      for (final file in result.files ?? const <drive.File>[])
        if (file.name case final name?) name,
    ];
    names.sort((a, b) => b.compareTo(a));
    return names;
  }

  /// Reads back the journals, habits, habit logs and tasks backed up for
  /// [month]
  /// (a `YYYY-MM` name as returned by [listBackups]). Any file missing from
  /// that backup contributes an empty list.
  Future<BackupContents> importBackup(http.Client client, String month) async {
    final api = drive.DriveApi(client);
    final backupsFolderId = await _ensureBackupsFolder(api);
    final monthFolderId = await _findFolderId(
      api,
      name: month,
      parentId: backupsFolderId,
    );
    if (monthFolderId == null) {
      return (
        journals: <JournalEntry>[],
        habits: <Habit>[],
        habitLogs: <HabitLog>[],
        tasks: <Task>[],
        moneyEntries: <MoneyEntry>[],
        budgetSettings: <BudgetSettings>[],
      );
    }

    final journalsJson = await _readJsonFile(
      api,
      folderId: monthFolderId,
      fileName: _journalsFileName,
    );
    final habitsJson = await _readJsonFile(
      api,
      folderId: monthFolderId,
      fileName: _habitsFileName,
    );
    final habitLogsJson = await _readJsonFile(
      api,
      folderId: monthFolderId,
      fileName: _habitLogsFileName,
    );
    final tasksJson = await _readJsonFile(
      api,
      folderId: monthFolderId,
      fileName: _tasksFileName,
    );
    final moneyEntriesJson = await _readJsonFile(
      api,
      folderId: monthFolderId,
      fileName: _moneyEntriesFileName,
    );
    final budgetSettingsJson = await _readJsonFile(
      api,
      folderId: monthFolderId,
      fileName: _budgetSettingsFileName,
    );

    final journals = journalsJson?['journals'] as List<dynamic>? ?? const [];
    final habits = habitsJson?['habits'] as List<dynamic>? ?? const [];
    final habitLogs = habitLogsJson?['logs'] as List<dynamic>? ?? const [];
    final tasks = tasksJson?['tasks'] as List<dynamic>? ?? const [];
    final moneyEntries =
        moneyEntriesJson?['money_entries'] as List<dynamic>? ?? const [];
    final budgetSettingsList =
        budgetSettingsJson?['budget_settings'] as List<dynamic>? ?? const [];
    return (
      journals: [
        for (final journal in journals)
          JournalEntry.fromJson(journal as Map<String, dynamic>),
      ],
      habits: [
        for (final habit in habits)
          Habit.fromJson(habit as Map<String, dynamic>),
      ],
      habitLogs: [
        for (final log in habitLogs)
          HabitLog.fromJson(log as Map<String, dynamic>),
      ],
      tasks: [
        for (final task in tasks) Task.fromJson(task as Map<String, dynamic>),
      ],
      moneyEntries: [
        for (final entry in moneyEntries)
          MoneyEntry.fromJson(entry as Map<String, dynamic>),
      ],
      budgetSettings: [
        for (final settings in budgetSettingsList)
          BudgetSettings.fromJson(settings as Map<String, dynamic>),
      ],
    );
  }

  Future<String> _ensureBackupsFolder(drive.DriveApi api) async {
    final appFolderId = await _ensureFolder(
      api,
      name: _appFolderName,
      parentId: null,
    );
    return _ensureFolder(api, name: _backupsFolderName, parentId: appFolderId);
  }

  Future<String> _ensureFolder(
    drive.DriveApi api, {
    required String name,
    required String? parentId,
  }) async {
    final existingId = await _findFolderId(api, name: name, parentId: parentId);
    if (existingId != null) {
      return existingId;
    }

    final created = await api.files.create(
      drive.File(
        name: name,
        mimeType: _folderMimeType,
        parents: parentId == null ? null : [parentId],
      ),
      $fields: 'id',
    );
    return created.id!;
  }

  Future<String?> _findFolderId(
    drive.DriveApi api, {
    required String name,
    required String? parentId,
  }) async {
    final parentClause = parentId == null ? '' : " and '$parentId' in parents";
    final result = await api.files.list(
      q:
          "name = '$name' and mimeType = '$_folderMimeType'$parentClause "
          'and trashed = false',
      spaces: 'drive',
      $fields: 'files(id)',
    );
    final matches = result.files ?? const <drive.File>[];
    return matches.isEmpty ? null : matches.first.id;
  }

  Future<void> _writeJsonFile(
    drive.DriveApi api, {
    required String folderId,
    required String fileName,
    required Map<String, dynamic> content,
  }) async {
    final bytes = utf8.encode(jsonEncode(content));
    final media = drive.Media(
      Stream.value(bytes),
      bytes.length,
      contentType: _jsonMimeType,
    );

    final existingId = await _findFileId(
      api,
      folderId: folderId,
      fileName: fileName,
    );
    if (existingId != null) {
      await api.files.update(drive.File(), existingId, uploadMedia: media);
      return;
    }

    await api.files.create(
      drive.File(name: fileName, parents: [folderId], mimeType: _jsonMimeType),
      uploadMedia: media,
    );
  }

  Future<Map<String, dynamic>?> _readJsonFile(
    drive.DriveApi api, {
    required String folderId,
    required String fileName,
  }) async {
    final fileId = await _findFileId(
      api,
      folderId: folderId,
      fileName: fileName,
    );
    if (fileId == null) {
      return null;
    }

    // downloadOptions.fullMedia makes files.get() return the file's raw
    // content instead of its metadata.
    final media =
        await api.files.get(
              fileId,
              downloadOptions: drive.DownloadOptions.fullMedia,
            )
            as drive.Media;
    final bytes = await media.stream.expand((chunk) => chunk).toList();
    return jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
  }

  Future<String?> _findFileId(
    drive.DriveApi api, {
    required String folderId,
    required String fileName,
  }) async {
    final result = await api.files.list(
      q:
          "name = '$fileName' and '$folderId' in parents "
          'and trashed = false',
      spaces: 'drive',
      $fields: 'files(id)',
    );
    final matches = result.files ?? const <drive.File>[];
    return matches.isEmpty ? null : matches.first.id;
  }

  static String _monthFolderName(DateTime month) {
    final year = month.year.toString().padLeft(4, '0');
    final monthNumber = month.month.toString().padLeft(2, '0');
    return '$year-$monthNumber';
  }
}
