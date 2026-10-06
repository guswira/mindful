import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindful/core/theme/glass_theme.dart';
import 'package:mindful/features/ai/data/food_scan_repository.dart';
import 'package:mindful/features/ai/domain/food_scan.dart';
import 'package:mindful/features/exercise/presentation/exercise_providers.dart';
import 'package:mindful/features/habits/domain/habit.dart';
import 'package:mindful/features/habits/presentation/add_habit_sheet.dart';
import 'package:mindful/features/habits/presentation/habit_tab.dart';
import 'package:mindful/features/home/presentation/widgets/be_mindful_section.dart';
import 'package:mindful/features/journal/data/journal_entries_controller.dart';
import 'package:mindful/features/journal/domain/journal_entry.dart';
import 'package:mindful/features/money/domain/entry_type.dart';
import 'package:mindful/features/money/domain/money_entry.dart';
import 'package:mindful/features/money/presentation/money_providers.dart';
import 'package:mindful/features/tasks/domain/task.dart';
import 'package:mindful/features/tasks/presentation/task_tab.dart';

final _date = DateTime(2026, 1, 1);

Habit _habit() => Habit(
  id: 'h1',
  userId: 'u1',
  name: 'Workout',
  icon: '🏋️',
  color: '#FF0000',
  createdAt: _date,
);

MoneyEntry _entry(EntryType type) => MoneyEntry(
  id: 'm1',
  userId: 'u1',
  type: type,
  amount: 10,
  category: 'Food',
  date: _date,
  createdAt: _date,
  updatedAt: _date,
);

Task _task() => Task(
  id: 't1',
  userId: 'u1',
  name: 'Pay rent',
  createdAt: _date,
  updatedAt: _date,
);

class _FakeRoutines extends HabitTabController {
  _FakeRoutines(this._items);

  final List<HabitTabItem> _items;

  @override
  Future<List<HabitTabItem>> build() async => _items;
}

class _FakeTasks extends TaskTabController {
  _FakeTasks(this._tasks);

  final List<Task> _tasks;

  @override
  Future<List<Task>> build() async => _tasks;
}

class _FakeJournal extends JournalEntries {
  @override
  Future<List<JournalEntry>> build() async => [];
}

Widget _buildSection({
  List<HabitTabItem> routines = const [],
  List<MoneyEntry> entries = const [],
  List<Task> tasks = const [],
  Future<List<FoodScan>> Function()? scans,
}) => ProviderScope(
  overrides: [
    habitTabControllerProvider.overrideWith(() => _FakeRoutines(routines)),
    moneyEntriesProvider(null).overrideWith((ref) async => entries),
    taskTabControllerProvider.overrideWith(() => _FakeTasks(tasks)),
    recentScansProvider.overrideWith(
      (ref) => scans?.call() ?? Future.value(const <FoodScan>[]),
    ),
    breathingSessionsProvider.overrideWith((ref) async => const []),
    journalEntriesProvider.overrideWith(_FakeJournal.new),
    monthlyBudgetProvider.overrideWith((ref) async => null),
    dailyBudgetProvider.overrideWith((ref) async => null),
  ],
  child: MaterialApp(
    theme: ThemeData(extensions: [GlassTheme.dark()]),
    home: const Scaffold(body: BeMindfulSection()),
  ),
);

void main() {
  testWidgets('a new user sees the intro and the first two steps', (
    tester,
  ) async {
    await tester.pumpWidget(_buildSection());
    await tester.pumpAndSettle();

    expect(find.textContaining('Mindful helps you slow down'), findsOneWidget);
    expect(find.text('Build your first routine'), findsOneWidget);
    expect(find.text('Mindful with spending'), findsOneWidget);
    expect(find.text('Mindful with your time'), findsNothing);
  });

  testWidgets('"Build" opens the add habit sheet', (tester) async {
    await tester.pumpWidget(_buildSection());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Build'));
    await tester.pumpAndSettle();

    expect(find.byType(AddHabitSheet), findsOneWidget);
  });

  testWidgets('after a routine, spending and a task, offers food + breath', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildSection(
        routines: [(habit: _habit(), todayLog: null)],
        entries: [_entry(EntryType.spending)],
        tasks: [_task()],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mindful with the food you eat'), findsOneWidget);
    expect(find.text('Mindful breathing'), findsOneWidget);
  });

  testWidgets('income alone still asks to record spending', (tester) async {
    await tester.pumpWidget(
      _buildSection(
        routines: [(habit: _habit(), todayLog: null)],
        entries: [_entry(EntryType.income)],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Build your first routine'), findsNothing);
    expect(find.text('Mindful with spending'), findsOneWidget);
  });

  testWidgets('food scans failing to load skip that step', (tester) async {
    await tester.pumpWidget(
      _buildSection(
        routines: [(habit: _habit(), todayLog: null)],
        entries: [_entry(EntryType.spending)],
        tasks: [_task()],
        scans: () => Future.error(Exception('offline')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mindful with the food you eat'), findsNothing);
    expect(find.text('Mindful breathing'), findsOneWidget);
    expect(find.text('Mindful with your thoughts'), findsOneWidget);
  });
}
