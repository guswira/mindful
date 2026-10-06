import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindful/core/theme/app_theme.dart';
import 'package:mindful/features/habits/domain/habit.dart';
import 'package:mindful/features/habits/presentation/add_habit_sheet.dart';
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
    archivedHabitsProvider.overrideWith((ref) async => const []),
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

  testWidgets('introduces routines and tasks when there is nothing yet', (
    tester,
  ) async {
    await tester.pumpWidget(_buildTab());
    await tester.pumpAndSettle();

    expect(find.text('Routines repeat every day'), findsOneWidget);
    expect(find.text('Add routine'), findsOneWidget);
    expect(find.text('Clear your head, one task at a time'), findsOneWidget);
    expect(find.text('Add task'), findsOneWidget);
  });

  testWidgets('the routines intro opens the add habit sheet', (tester) async {
    await tester.pumpWidget(_buildTab());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add routine'));
    await tester.pumpAndSettle();

    expect(find.byType(AddHabitSheet), findsOneWidget);
  });

  testWidgets('the "+" button offers adding a task or a habit', (tester) async {
    // Non-empty, so the intro cards' own "Add task" pill isn't on screen.
    await tester.pumpWidget(
      _buildTab(habits: [(habit: _habit, todayLog: null)], tasks: [_task]),
    );
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
