import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindfull/core/theme/glass_theme.dart';
import 'package:mindfull/features/habits/domain/habit.dart';
import 'package:mindfull/features/habits/domain/habit_log.dart';
import 'package:mindfull/features/habits/presentation/habit_tab.dart';
import 'package:mindfull/features/home/presentation/widgets/streak_row.dart';
import 'package:mindfull/features/journal/data/journal_entries_controller.dart';
import 'package:mindfull/features/journal/domain/journal_entry.dart';
import 'package:mindfull/features/tasks/domain/task.dart';
import 'package:mindfull/features/tasks/presentation/task_tab.dart';

final _today = DateTime.now();
final _todayDate = DateTime(_today.year, _today.month, _today.day);

class _FakeJournalEntries extends JournalEntries {
  _FakeJournalEntries(this._entries);
  final List<JournalEntry> _entries;

  @override
  Future<List<JournalEntry>> build() async => _entries;
}

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

void main() {
  testWidgets('shows journal streak, habits done today, and tasks due', (
    tester,
  ) async {
    final entries = [
      JournalEntry(
        id: '1',
        userId: 'u1',
        date: _todayDate,
        body: 'Today',
        createdAt: _todayDate,
        updatedAt: _todayDate,
      ),
      JournalEntry(
        id: '2',
        userId: 'u1',
        date: _todayDate.subtract(const Duration(days: 1)),
        body: 'Yesterday',
        createdAt: _todayDate,
        updatedAt: _todayDate,
      ),
    ];
    final habits = [
      (
        habit: Habit(
          id: 'h1',
          userId: 'u1',
          name: 'Workout',
          icon: '🏋️',
          color: '#FF0000',
          createdAt: _todayDate,
        ),
        todayLog: HabitLog(
          id: 'l1',
          userId: 'u1',
          habitId: 'h1',
          date: _todayDate,
        ),
      ),
      (
        habit: Habit(
          id: 'h2',
          userId: 'u1',
          name: 'Read',
          icon: '📚',
          color: '#00FF00',
          createdAt: _todayDate,
        ),
        todayLog: null,
      ),
    ];
    final tasks = [
      Task(
        id: 't1',
        userId: 'u1',
        name: 'Overdue',
        createdAt: _todayDate,
        updatedAt: _todayDate,
        dueDate: _todayDate.subtract(const Duration(days: 1)),
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          journalEntriesProvider.overrideWith(
            () => _FakeJournalEntries(entries),
          ),
          habitTabControllerProvider.overrideWith(
            () => _FakeHabitTabController(habits),
          ),
          taskTabControllerProvider.overrideWith(
            () => _FakeTaskTabController(tasks),
          ),
        ],
        child: MaterialApp(
          theme: ThemeData(extensions: [GlassTheme.dark()]),
          home: const Scaffold(body: StreakRow()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('2'), findsOneWidget);
    expect(find.text('1/2'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
  });
}
