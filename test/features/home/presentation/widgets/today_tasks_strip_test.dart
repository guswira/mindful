import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindfull/core/theme/glass_theme.dart';
import 'package:mindfull/features/home/presentation/widgets/today_tasks_strip.dart';
import 'package:mindfull/features/tasks/domain/task.dart';
import 'package:mindfull/features/tasks/presentation/task_tab.dart';

final _now = DateTime.now();
final _today = DateTime(_now.year, _now.month, _now.day);

final _overdueTask = Task(
  id: 't1',
  userId: 'u1',
  name: 'Pay rent',
  createdAt: DateTime(2026, 1, 1),
  updatedAt: DateTime(2026, 1, 1),
  dueDate: _today.subtract(const Duration(days: 2)),
);

final _futureTask = Task(
  id: 't2',
  userId: 'u1',
  name: 'Renew passport',
  createdAt: DateTime(2026, 1, 2),
  updatedAt: DateTime(2026, 1, 2),
  dueDate: _today.add(const Duration(days: 5)),
);

final _completedTodayTask = Task(
  id: 't3',
  userId: 'u1',
  name: 'Already done',
  createdAt: DateTime(2026, 1, 3),
  updatedAt: DateTime(2026, 1, 3),
  dueDate: _today,
  isCompleted: true,
);

class _FakeTaskTabController extends TaskTabController {
  _FakeTaskTabController(this._tasks);

  final List<Task> _tasks;

  @override
  Future<List<Task>> build() async => _tasks;
}

Widget _buildStrip(List<Task> tasks) => ProviderScope(
  overrides: [
    taskTabControllerProvider.overrideWith(() => _FakeTaskTabController(tasks)),
  ],
  child: MaterialApp(
    theme: ThemeData(extensions: [GlassTheme.dark()]),
    home: const Scaffold(body: TodayTasksStrip()),
  ),
);

void main() {
  testWidgets('shows overdue tasks but excludes future and completed ones', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildStrip([_overdueTask, _futureTask, _completedTodayTask]),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pay rent'), findsOneWidget);
    expect(find.text('Renew passport'), findsNothing);
    expect(find.text('Already done'), findsNothing);
  });

  testWidgets('shows the empty state with no tasks due', (tester) async {
    await tester.pumpWidget(_buildStrip(const []));
    await tester.pumpAndSettle();

    expect(find.text('What needs to be done today?'), findsOneWidget);
  });
}
