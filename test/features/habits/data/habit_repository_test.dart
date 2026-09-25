import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mindful/features/habits/data/habit_repository.dart';
import 'package:mindful/features/habits/data/supabase_habit_datasource.dart';
import 'package:mindful/features/habits/domain/habit.dart';
import 'package:mindful/features/habits/domain/habit_log.dart';
import 'package:mindful/shared/models/sync_status.dart';

class _MockBox extends Mock implements Box<dynamic> {}

class _MockDatasource extends Mock implements SupabaseHabitDatasource {}

final _habit = Habit(
  id: 'h1',
  userId: 'u1',
  name: 'Workout',
  icon: '🏋️',
  color: '#FF0000',
  createdAt: DateTime(2026, 1, 1),
);

final _log = HabitLog(
  id: 'l1',
  userId: 'u1',
  habitId: 'h1',
  date: DateTime(2026, 3, 5),
  completedActionId: 'a1',
);

void main() {
  setUpAll(() {
    registerFallbackValue(_habit);
    registerFallbackValue(_log);
    registerFallbackValue(DateTime(2000));
  });

  late _MockBox habitsBox;
  late _MockBox habitLogsBox;
  late _MockDatasource datasource;
  late HabitRepository repository;

  setUp(() {
    habitsBox = _MockBox();
    habitLogsBox = _MockBox();
    datasource = _MockDatasource();
    repository = HabitRepository(
      habitsBox: habitsBox,
      habitLogsBox: habitLogsBox,
      datasource: datasource,
    );

    when(() => habitsBox.put(any(), any())).thenAnswer((_) async {});
    when(() => habitsBox.delete(any())).thenAnswer((_) async {});
    when(() => habitsBox.clear()).thenAnswer((_) async => 0);
    when(() => habitLogsBox.put(any(), any())).thenAnswer((_) async {});
    when(() => habitLogsBox.delete(any())).thenAnswer((_) async {});
  });

  test('getHabits decodes cached habits, newest first', () {
    final older = _habit.copyWith(id: 'h0', createdAt: DateTime(2025));
    when(() => habitsBox.values).thenReturn([older.toJson(), _habit.toJson()]);

    expect(repository.getHabits(), [_habit, older]);
  });

  test('saveHabit caches the habit, then syncs it to Supabase', () async {
    when(() => datasource.saveHabit(_habit)).thenAnswer((_) async {});

    await repository.saveHabit(_habit);

    verify(
      () => habitsBox.put('h1', any(that: equals(_habit.toJson()))),
    ).called(1);
    verify(() => datasource.saveHabit(_habit)).called(1);
  });

  test('saveHabit rethrows on a Supabase failure', () async {
    when(() => datasource.saveHabit(_habit)).thenThrow(Exception('offline'));

    expect(() => repository.saveHabit(_habit), throwsException);
  });

  test('deleteHabit removes the habit from cache and Supabase', () async {
    when(() => datasource.deleteHabit('h1')).thenAnswer((_) async {});

    await repository.deleteHabit('h1');

    verify(() => habitsBox.delete('h1')).called(1);
    verify(() => datasource.deleteHabit('h1')).called(1);
  });

  test('getLog returns null when nothing is cached for that day', () {
    when(() => habitLogsBox.get(any())).thenReturn(null);

    expect(repository.getLog('h1', DateTime(2026, 3, 5)), isNull);
  });

  test('getLog decodes a cached log', () {
    when(
      () => habitLogsBox.get('h1_2026-03-05T00:00:00.000'),
    ).thenReturn(_log.toJson());

    expect(repository.getLog('h1', DateTime(2026, 3, 5)), _log);
  });

  test(
    'saveLog caches the log under a date-scoped key, then syncs it',
    () async {
      when(() => datasource.saveLog(_log)).thenAnswer((_) async {});

      await repository.saveLog(_log);

      verify(
        () => habitLogsBox.put(
          'h1_2026-03-05T00:00:00.000',
          any(that: equals(_log.toJson())),
        ),
      ).called(1);
      verify(() => datasource.saveLog(_log)).called(1);
    },
  );

  test('saveLog marks the cached log pending on a Supabase failure', () async {
    when(() => datasource.saveLog(_log)).thenThrow(Exception('offline'));

    await repository.saveLog(_log);

    verify(
      () => habitLogsBox.put(
        'h1_2026-03-05T00:00:00.000',
        any(
          that: equals(_log.copyWith(syncStatus: SyncStatus.pending).toJson()),
        ),
      ),
    ).called(1);
  });

  test('refreshFromSupabase replaces the cache with Supabase data', () async {
    when(() => datasource.fetchHabits()).thenAnswer((_) async => [_habit]);
    when(() => datasource.fetchLogs(any())).thenAnswer((_) async => [_log]);

    await repository.refreshFromSupabase();

    verify(() => habitsBox.clear()).called(1);
    verify(
      () => habitsBox.put('h1', any(that: equals(_habit.toJson()))),
    ).called(1);
    verify(
      () => habitLogsBox.put(
        'h1_2026-03-05T00:00:00.000',
        any(that: equals(_log.toJson())),
      ),
    ).called(1);
  });

  test('logsForHabitInMonth fetches the month from Supabase, caches it, and '
      'filters to the given habit', () async {
    final otherHabitLog = HabitLog(
      id: 'l2',
      userId: 'u1',
      habitId: 'h2',
      date: DateTime(2026, 3, 9),
    );
    when(
      () => datasource.fetchLogs(DateTime(2026, 3, 1)),
    ).thenAnswer((_) async => [_log, otherHabitLog]);

    final logs = await repository.logsForHabitInMonth(
      'h1',
      DateTime(2026, 3, 1),
    );

    expect(logs, [_log]);
    verify(
      () => habitLogsBox.put(
        'h1_2026-03-05T00:00:00.000',
        any(that: equals(_log.toJson())),
      ),
    ).called(1);
    verify(
      () => habitLogsBox.put(
        'h2_2026-03-09T00:00:00.000',
        any(that: equals(otherHabitLog.toJson())),
      ),
    ).called(1);
  });

  test('retryPendingLogs resyncs only logs marked pending', () async {
    final pending = _log.copyWith(syncStatus: SyncStatus.pending);
    final synced = _log.copyWith(
      id: 'l2',
      habitId: 'h2',
      syncStatus: SyncStatus.synced,
    );
    when(
      () => habitLogsBox.values,
    ).thenReturn([pending.toJson(), synced.toJson()]);
    when(() => datasource.saveLog(any())).thenAnswer((_) async {});

    await repository.retryPendingLogs();

    verify(
      () => datasource.saveLog(
        any(that: equals(pending.copyWith(syncStatus: SyncStatus.synced))),
      ),
    ).called(1);
    verifyNever(() => datasource.saveLog(any(that: equals(synced))));
  });
}
