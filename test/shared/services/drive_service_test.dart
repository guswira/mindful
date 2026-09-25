import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

import 'package:mindfull/features/habits/domain/habit.dart';
import 'package:mindfull/features/habits/domain/habit_log.dart';
import 'package:mindfull/features/journal/domain/journal_entry.dart';
import 'package:mindfull/features/money/domain/budget_settings.dart';
import 'package:mindfull/features/money/domain/entry_type.dart';
import 'package:mindfull/features/money/domain/money_entry.dart';
import 'package:mindfull/features/tasks/domain/task.dart';
import 'package:mindfull/shared/services/drive_service.dart';

class _MockClient extends Mock implements http.Client {}

class _FakeBaseRequest extends Fake implements http.BaseRequest {}

http.StreamedResponse _jsonResponse(Object body) {
  return http.StreamedResponse(
    Stream.value(utf8.encode(jsonEncode(body))),
    200,
    headers: {'content-type': 'application/json; charset=utf-8'},
  );
}

http.StreamedResponse _noMatch() => _jsonResponse({'files': <Object?>[]});

http.StreamedResponse _created(String id) => _jsonResponse({'id': id});

JournalEntry _journal() => JournalEntry(
  id: 'j1',
  userId: 'u1',
  date: DateTime(2026, 3, 1),
  body: 'hello',
  createdAt: DateTime(2026, 3, 1),
  updatedAt: DateTime(2026, 3, 1),
);

Habit _habit() => Habit(
  id: 'h1',
  userId: 'u1',
  name: 'Run',
  icon: '🏃',
  color: '#ffffff',
  createdAt: DateTime(2026, 3, 1),
);

HabitLog _habitLog() =>
    HabitLog(id: 'l1', userId: 'u1', habitId: 'h1', date: DateTime(2026, 3, 1));

Task _task() => Task(
  id: 't1',
  userId: 'u1',
  name: 'Buy groceries',
  createdAt: DateTime(2026, 3, 1),
  updatedAt: DateTime(2026, 3, 1),
);

MoneyEntry _moneyEntry() => MoneyEntry(
  id: 'm1',
  userId: 'u1',
  type: EntryType.spending,
  amount: 12.5,
  category: 'Food',
  date: DateTime(2026, 3, 1),
  createdAt: DateTime(2026, 3, 1),
  updatedAt: DateTime(2026, 3, 1),
);

BudgetSettings _budgetSettings() => BudgetSettings(
  id: 'b1',
  userId: 'u1',
  updatedAt: DateTime(2026, 3, 1),
  amount: 500,
);

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeBaseRequest());
  });

  late _MockClient client;
  late List<http.BaseRequest> requests;
  const service = DriveService();

  setUp(() {
    client = _MockClient();
    requests = <http.BaseRequest>[];
  });

  void stubResponses(List<http.StreamedResponse> responses) {
    var index = 0;
    when(() => client.send(any())).thenAnswer((invocation) async {
      requests.add(invocation.positionalArguments[0] as http.BaseRequest);
      return responses[index++];
    });
  }

  group('backup', () {
    test(
      'creates the app/backups/month folders and writes six files',
      () async {
        stubResponses([
          _noMatch(), _created('app-1'), // AppFolder
          _noMatch(), _created('backups-1'), // backups
          _noMatch(), _created('month-1'), // 2026-03
          _noMatch(), _created('journals-1'), // journals.json
          _noMatch(), _created('habits-1'), // habits.json
          _noMatch(), _created('logs-1'), // habit_logs.json
          _noMatch(), _created('tasks-1'), // tasks.json
          _noMatch(), _created('money-1'), // money_entries.json
          _noMatch(), _created('budget-1'), // budget_settings.json
        ]);

        await service.backup(
          client,
          month: DateTime(2026, 3, 5),
          journals: [_journal()],
          habits: [_habit()],
          habitLogs: [_habitLog()],
          tasks: [_task()],
          moneyEntries: [_moneyEntry()],
          budgetSettings: [_budgetSettings()],
        );

        expect(requests, hasLength(18));
        expect(requests[4].method, 'GET');
        expect(requests[4].url.queryParameters['q'], contains('2026-03'));
        expect(requests.last.method, 'POST');
        expect(requests.last.url.path, '/upload/drive/v3/files');
      },
    );
  });

  group('listBackups', () {
    test('returns backup folder names newest first', () async {
      stubResponses([
        _noMatch(),
        _created('app-1'),
        _noMatch(),
        _created('backups-1'),
        _jsonResponse({
          'files': [
            {'name': '2026-01'},
            {'name': '2026-03'},
            {'name': '2026-02'},
          ],
        }),
      ]);

      final months = await service.listBackups(client);

      expect(months, ['2026-03', '2026-02', '2026-01']);
    });
  });

  group('importBackup', () {
    test('returns empty lists when the month folder does not exist', () async {
      stubResponses([
        _noMatch(), _created('app-1'),
        _noMatch(), _created('backups-1'),
        _noMatch(), // month folder lookup
      ]);

      final contents = await service.importBackup(client, '2026-03');

      expect(contents.journals, isEmpty);
      expect(contents.habits, isEmpty);
      expect(contents.habitLogs, isEmpty);
      expect(contents.tasks, isEmpty);
      expect(contents.moneyEntries, isEmpty);
      expect(contents.budgetSettings, isEmpty);
    });

    test('parses journals, habits, habit logs, tasks and money data from an '
        'existing backup', () async {
      stubResponses([
        _noMatch(), _created('app-1'),
        _noMatch(), _created('backups-1'),
        _jsonResponse({
          'files': [
            {'id': 'month-1'},
          ],
        }), // month folder found
        _jsonResponse({
          'files': [
            {'id': 'journals-1'},
          ],
        }),
        _jsonResponse({
          'journals': [_journal().toJson()],
        }),
        _jsonResponse({
          'files': [
            {'id': 'habits-1'},
          ],
        }),
        _jsonResponse({
          'habits': [_habit().toJson()],
        }),
        _jsonResponse({
          'files': [
            {'id': 'logs-1'},
          ],
        }),
        _jsonResponse({
          'logs': [_habitLog().toJson()],
        }),
        _jsonResponse({
          'files': [
            {'id': 'tasks-1'},
          ],
        }),
        _jsonResponse({
          'tasks': [_task().toJson()],
        }),
        _jsonResponse({
          'files': [
            {'id': 'money-1'},
          ],
        }),
        _jsonResponse({
          'money_entries': [_moneyEntry().toJson()],
        }),
        _jsonResponse({
          'files': [
            {'id': 'budget-1'},
          ],
        }),
        _jsonResponse({
          'budget_settings': [_budgetSettings().toJson()],
        }),
      ]);

      final contents = await service.importBackup(client, '2026-03');

      expect(contents.journals, [_journal()]);
      expect(contents.habits, [_habit()]);
      expect(contents.habitLogs, [_habitLog()]);
      expect(contents.tasks, [_task()]);
      expect(contents.moneyEntries, [_moneyEntry()]);
      expect(contents.budgetSettings, [_budgetSettings()]);
    });
  });
}
