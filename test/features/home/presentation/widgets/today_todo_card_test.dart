import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindful/core/theme/glass_theme.dart';
import 'package:mindful/features/habits/domain/habit.dart';
import 'package:mindful/features/habits/domain/habit_log.dart';
import 'package:mindful/features/habits/presentation/habit_tab.dart';
import 'package:mindful/features/home/presentation/widgets/today_todo_card.dart';
import 'package:mindful/features/tasks/domain/task.dart';
import 'package:mindful/features/tasks/presentation/add_task_sheet.dart';
import 'package:mindful/features/tasks/presentation/task_tab.dart';

final _now = DateTime.now();
final _today = DateTime(_now.year, _now.month, _now.day);

Task _task(String id, String name, DateTime due, {bool done = false}) => Task(
  id: id,
  userId: 'u1',
  name: name,
  createdAt: DateTime(2026, 1, 1),
  updatedAt: DateTime(2026, 1, 1),
  dueDate: due,
  isCompleted: done,
);

Habit _habit(String id, String name) => Habit(
  id: id,
  userId: 'u1',
  name: name,
  icon: '🏋️',
  color: '#FF0000',
  createdAt: DateTime(2026, 1, 1),
);

HabitLog _log(String habitId) =>
    HabitLog(id: 'l$habitId', userId: 'u1', habitId: habitId, date: _now);

class _FakeTasks extends TaskTabController {
  _FakeTasks(this._tasks);

  final List<Task> _tasks;

  @override
  Future<List<Task>> build() async => _tasks;
}

class _FakeRoutines extends HabitTabController {
  _FakeRoutines(this._items);

  final List<HabitTabItem> _items;

  @override
  Future<List<HabitTabItem>> build() async => _items;
}

Widget _buildCard(List<Task> tasks, List<HabitTabItem> routines) =>
    ProviderScope(
      overrides: [
        taskTabControllerProvider.overrideWith(() => _FakeTasks(tasks)),
        habitTabControllerProvider.overrideWith(() => _FakeRoutines(routines)),
      ],
      child: MaterialApp(
        theme: ThemeData(extensions: [GlassTheme.dark()]),
        home: const Scaffold(body: TodayTodoCard()),
      ),
    );

void main() {
  testWidgets('lists due tasks first, then routines not logged yet', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildCard(
        [
          _task('t1', 'Pay rent', _today.subtract(const Duration(days: 2))),
          _task('t2', 'Renew passport', _today.add(const Duration(days: 5))),
          _task('t3', 'Already done', _today, done: true),
        ],
        [
          (habit: _habit('h1', 'Workout'), todayLog: null),
          (habit: _habit('h2', 'Meditate'), todayLog: _log('h2')),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pay rent'), findsOneWidget);
    expect(find.text('Workout'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Pay rent')).dy,
      lessThan(tester.getTopLeft(find.text('Workout')).dy),
    );
    expect(find.text('Renew passport'), findsNothing);
    expect(find.text('Already done'), findsNothing);
    // Done items only show on the Tasks & Routines tab.
    expect(find.text('Meditate'), findsNothing);
    expect(find.text('Add todo'), findsOneWidget);
    expect(find.text('Add routine'), findsOneWidget);
  });

  testWidgets('shows the empty prompt with nothing due', (tester) async {
    await tester.pumpWidget(_buildCard(const [], const []));
    await tester.pumpAndSettle();

    expect(find.text('What needs to be done today?'), findsOneWidget);
  });

  testWidgets('says all done once every routine is logged', (tester) async {
    await tester.pumpWidget(
      _buildCard(const [], [
        (habit: _habit('h2', 'Meditate'), todayLog: _log('h2')),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.text('All done!'), findsOneWidget);
    expect(find.text('Meditate'), findsNothing);
  });

  testWidgets('"Add todo" opens the add task sheet', (tester) async {
    await tester.pumpWidget(_buildCard(const [], const []));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add todo'));
    await tester.pumpAndSettle();

    expect(find.byType(AddTaskSheet), findsOneWidget);
  });
}
