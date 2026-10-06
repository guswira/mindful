import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindful/features/tasks/data/task_repository.dart';
import 'package:mindful/features/tasks/domain/task.dart';
import 'package:mindful/features/tasks/presentation/task_providers.dart';
import 'package:mindful/features/tasks/presentation/task_tab.dart';
import 'package:mindful/shared/services/widget_service.dart';

/// An in-memory cache; Supabase is "unreachable" so the controller's
/// background refresh never swaps the list.
class _FakeTaskRepository extends Fake implements TaskRepository {
  final Map<String, Task> tasks = {};

  @override
  List<Task> getAll() => tasks.values.toList();

  @override
  Future<List<Task>> refresh() => Future.error(Exception('offline'));

  @override
  Future<void> create(Task task) async => tasks[task.id] = task;

  @override
  Future<void> update(Task task) async => tasks[task.id] = task;
}

Task _task(String name) => Task(
  id: 't1',
  userId: 'u1',
  name: name,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

void main() {
  late _FakeTaskRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = _FakeTaskRepository();
    container = ProviderContainer(
      overrides: [
        taskRepositoryProvider.overrideWith((ref) async => repository),
        // No home widgets in tests — refreshing them is best-effort.
        widgetServiceProvider.overrideWith(
          (ref) => Future.error(Exception('no widgets')),
        ),
      ],
    );
    addTearDown(container.dispose);
    // Keep both alive like the home screen and an open detail sheet do.
    container
      ..listen(taskTabControllerProvider, (_, _) {})
      ..listen(taskByIdProvider('t1'), (_, _) {});
  });

  test('saving a new task reloads the task list everyone watches', () async {
    expect(await container.read(taskTabControllerProvider.future), isEmpty);

    await container
        .read(taskTabControllerProvider.notifier)
        .save(_task('Buy milk'), isNew: true);

    final tasks = await container.read(taskTabControllerProvider.future);
    expect(tasks.map((task) => task.name), ['Buy milk']);
  });

  test('editing a task reloads its detail too', () async {
    repository.tasks['t1'] = _task('Buy milk');
    expect(
      (await container.read(taskByIdProvider('t1').future))?.name,
      'Buy milk',
    );

    await container
        .read(taskTabControllerProvider.notifier)
        .save(_task('Buy oat milk'), isNew: false);

    expect(
      (await container.read(taskByIdProvider('t1').future))?.name,
      'Buy oat milk',
    );
  });
}
