import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mindful/features/tasks/data/supabase_task_datasource.dart';
import 'package:mindful/features/tasks/data/task_repository.dart';
import 'package:mindful/features/tasks/domain/task.dart';
import 'package:mindful/shared/models/sync_status.dart';

class _MockBox extends Mock implements Box<dynamic> {}

class _MockDatasource extends Mock implements SupabaseTaskDatasource {}

final _task = Task(
  id: 't1',
  userId: 'u1',
  name: 'Buy groceries',
  createdAt: DateTime(2026, 1, 1),
  updatedAt: DateTime(2026, 1, 1),
);

void main() {
  setUpAll(() {
    registerFallbackValue(_task);
  });

  late _MockBox box;
  late _MockDatasource datasource;
  late TaskRepository repository;

  setUp(() {
    box = _MockBox();
    datasource = _MockDatasource();
    repository = TaskRepository(cacheBox: box, datasource: datasource);

    when(() => box.put(any(), any())).thenAnswer((_) async {});
    when(() => box.delete(any())).thenAnswer((_) async {});
    when(() => box.clear()).thenAnswer((_) async => 0);
  });

  test('getAll decodes cached tasks', () {
    when(() => box.values).thenReturn([_task.toJson()]);

    expect(repository.getAll(), [_task]);
  });

  test('getById returns null when nothing is cached', () {
    when(() => box.get('missing')).thenReturn(null);

    expect(repository.getById('missing'), isNull);
  });

  test('getById decodes a cached task', () {
    when(() => box.get('t1')).thenReturn(_task.toJson());

    expect(repository.getById('t1'), _task);
  });

  test('create caches the task, then inserts it in Supabase', () async {
    when(() => datasource.create(_task)).thenAnswer((_) async {});

    await repository.create(_task);

    verify(() => box.put('t1', any(that: equals(_task.toJson())))).called(1);
    verify(() => datasource.create(_task)).called(1);
  });

  test('create marks the cached task pending on a Supabase failure', () async {
    when(() => datasource.create(_task)).thenThrow(Exception('offline'));

    await repository.create(_task);

    verify(
      () => box.put(
        't1',
        any(
          that: equals(_task.copyWith(syncStatus: SyncStatus.pending).toJson()),
        ),
      ),
    ).called(1);
  });

  test('update caches the task, then upserts it in Supabase', () async {
    final edited = _task.copyWith(name: 'Buy more groceries');
    when(() => datasource.update(edited)).thenAnswer((_) async {});

    await repository.update(edited);

    verify(() => box.put('t1', any(that: equals(edited.toJson())))).called(1);
    verify(() => datasource.update(edited)).called(1);
  });

  test('markComplete no-ops when the task is not cached', () async {
    when(() => box.get('missing')).thenReturn(null);

    await repository.markComplete('missing');

    verifyNever(() => box.put(any(), any()));
    verifyNever(() => datasource.markComplete(any()));
  });

  test(
    'markComplete marks the cached task complete, then syncs via markComplete',
    () async {
      when(() => box.get('t1')).thenReturn(_task.toJson());
      when(() => datasource.markComplete('t1')).thenAnswer((_) async {});

      await repository.markComplete('t1');

      final putCall = verify(
        () => box.put('t1', captureAny(that: isA<Map<dynamic, dynamic>>())),
      )..called(1);
      final cached = Task.fromJson(
        Map<String, dynamic>.from(putCall.captured.single as Map),
      );
      expect(cached.isCompleted, isTrue);
      verify(() => datasource.markComplete('t1')).called(1);
    },
  );

  test('delete removes the task from cache and Supabase', () async {
    when(() => datasource.delete('t1')).thenAnswer((_) async {});

    await repository.delete('t1');

    verify(() => box.delete('t1')).called(1);
    verify(() => datasource.delete('t1')).called(1);
  });

  test('refresh replaces the cache with Supabase data', () async {
    when(() => datasource.getAll()).thenAnswer((_) async => [_task]);
    when(() => box.values).thenReturn([_task.toJson()]);

    final tasks = await repository.refresh();

    verify(() => box.clear()).called(1);
    verify(() => box.put('t1', any(that: equals(_task.toJson())))).called(1);
    expect(tasks, [_task]);
  });

  test('retryPendingTasks resyncs only tasks marked pending', () async {
    final pending = _task.copyWith(syncStatus: SyncStatus.pending);
    final synced = _task.copyWith(id: 't2', syncStatus: SyncStatus.synced);
    when(() => box.values).thenReturn([pending.toJson(), synced.toJson()]);
    when(() => datasource.update(any())).thenAnswer((_) async {});

    await repository.retryPendingTasks();

    verify(
      () => datasource.update(
        any(that: equals(pending.copyWith(syncStatus: SyncStatus.synced))),
      ),
    ).called(1);
    verifyNever(() => datasource.update(any(that: equals(synced))));
  });
}
