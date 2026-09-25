import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindfull/core/theme/glass_theme.dart';
import 'package:mindfull/features/tasks/domain/task.dart';
import 'package:mindfull/features/tasks/presentation/task_tab.dart';

final _now = DateTime.now();
final _today = DateTime(_now.year, _now.month, _now.day);

final _todayTask = Task(
  id: 't1',
  userId: 'u1',
  name: 'Buy groceries',
  createdAt: DateTime(2026, 1, 1),
  updatedAt: DateTime(2026, 1, 1),
  dueDate: _today,
);

final _upcomingTask = Task(
  id: 't2',
  userId: 'u1',
  name: 'Renew passport',
  createdAt: DateTime(2026, 1, 2),
  updatedAt: DateTime(2026, 1, 2),
  dueDate: _today.add(const Duration(days: 5)),
);

final _noDateTask = Task(
  id: 't3',
  userId: 'u1',
  name: 'Read a book',
  createdAt: DateTime(2026, 1, 3),
  updatedAt: DateTime(2026, 1, 3),
);

final _completedTask = Task(
  id: 't4',
  userId: 'u1',
  name: 'Old task',
  createdAt: DateTime(2026, 1, 4),
  updatedAt: DateTime(2026, 1, 4),
  isCompleted: true,
);

class _FakeTaskTabController extends TaskTabController {
  @override
  Future<List<Task>> build() async => [
    _todayTask,
    _upcomingTask,
    _noDateTask,
    _completedTask,
  ];

  @override
  Future<void> complete(String taskId) async {
    final current = state.value ?? const <Task>[];
    state = AsyncData([
      for (final task in current)
        if (task.id == taskId) task.copyWith(isCompleted: true) else task,
    ]);
  }
}

Widget _buildTab() => ProviderScope(
  overrides: [
    taskTabControllerProvider.overrideWith(_FakeTaskTabController.new),
  ],
  child: MaterialApp(
    theme: ThemeData(extensions: [GlassTheme.dark()]),
    home: const TaskTab(),
  ),
);

void main() {
  testWidgets(
    'groups tasks into Today, Upcoming, No date and a collapsed Completed '
    'section',
    (tester) async {
      await tester.pumpWidget(_buildTab());
      await tester.pumpAndSettle();

      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Buy groceries'), findsOneWidget);
      expect(find.text('Upcoming'), findsOneWidget);
      expect(find.text('Renew passport'), findsOneWidget);
      expect(find.text('No date'), findsOneWidget);
      expect(find.text('Read a book'), findsOneWidget);
      expect(find.text('Completed (1)'), findsOneWidget);
      expect(find.text('Old task'), findsNothing);
    },
  );

  testWidgets('tapping a checkbox marks the task complete', (tester) async {
    await tester.pumpWidget(_buildTab());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();

    expect(find.text('Completed (2)'), findsOneWidget);
  });
}
