import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindful/core/theme/app_theme.dart';
import 'package:mindful/features/habits/domain/habit.dart';
import 'package:mindful/features/habits/presentation/habit_tab.dart';
import 'package:mindful/features/plan/presentation/plan_tab.dart';
import 'package:mindful/features/tasks/domain/task.dart';
import 'package:mindful/features/tasks/presentation/task_tab.dart';

final _habit = Habit(
  id: 'h1',
  userId: 'u1',
  name: 'Meditate',
  icon: '🧘',
  color: '#00FF00',
  createdAt: DateTime(2026, 1, 1),
);

final _task = Task(
  id: 't1',
  userId: 'u1',
  name: 'Read a book',
  createdAt: DateTime(2026, 1, 1),
  updatedAt: DateTime(2026, 1, 1),
);

class _FakeHabitTabController extends HabitTabController {
  _FakeHabitTabController(this._items);

  final List<HabitTabItem> _items;

  @override
  Future<List<HabitTabItem>> build() async => _items;
}

class _FakeTaskTabController extends TaskTabController {
  _FakeTaskTabController(this._tasks);

  final List<Task> _tasks;

  @override
  Future<List<Task>> build() async => _tasks;
}

Widget _buildTab({
  List<HabitTabItem> habits = const [],
  List<Task> tasks = const [],
}) => ProviderScope(
  overrides: [
    habitTabControllerProvider.overrideWith(
      () => _FakeHabitTabController(habits),
    ),
    taskTabControllerProvider.overrideWith(() => _FakeTaskTabController(tasks)),
  ],
  child: MaterialApp(theme: AppTheme.dark, home: const PlanTab()),
);

void main() {
  testWidgets('shows routines and tasks on the same page', (tester) async {
    await tester.pumpWidget(
      _buildTab(habits: [(habit: _habit, todayLog: null)], tasks: [_task]),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tasks & Routines'), findsOneWidget);
    expect(find.text('Routines'), findsOneWidget);
    expect(find.text('Meditate'), findsOneWidget);
    expect(find.text('No date'), findsOneWidget);
    expect(find.text('Read a book'), findsOneWidget);
  });

  testWidgets('shows both empty states when there is nothing yet', (
    tester,
  ) async {
    await tester.pumpWidget(_buildTab());
    await tester.pumpAndSettle();

    expect(find.text('No habits yet'), findsOneWidget);
    expect(find.text('No tasks yet'), findsOneWidget);
  });

  testWidgets('the "+" button offers adding a task or a habit', (tester) async {
    await tester.pumpWidget(_buildTab());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.text('Add task'), findsOneWidget);
    expect(find.text('Add habit'), findsOneWidget);
  });

  testWidgets('long-pressing a task offers converting it to a routine', (
    tester,
  ) async {
    await tester.pumpWidget(_buildTab(tasks: [_task]));
    await tester.pumpAndSettle();

    await tester.longPress(find.text('Read a book'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Convert to routine'));
    await tester.pumpAndSettle();

    expect(find.text('Save routine'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField).first).controller?.text,
      'Read a book',
    );
  });
}
