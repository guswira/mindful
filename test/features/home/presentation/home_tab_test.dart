import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindful/core/theme/glass_theme.dart';
import 'package:mindful/features/ai/data/food_scan_repository.dart';
import 'package:mindful/features/exercise/presentation/exercise_providers.dart';
import 'package:mindful/features/habits/presentation/habit_tab.dart';
import 'package:mindful/features/home/presentation/home_tab.dart';
import 'package:mindful/features/home/presentation/widgets/unsynced_banner.dart';
import 'package:mindful/features/journal/data/journal_entries_controller.dart';
import 'package:mindful/features/journal/domain/journal_entry.dart';
import 'package:mindful/features/money/presentation/money_providers.dart';
import 'package:mindful/features/recap/presentation/monthly_recap_providers.dart';
import 'package:mindful/features/tasks/domain/task.dart';
import 'package:mindful/features/plan/presentation/detail_pane.dart';
import 'package:mindful/features/tasks/presentation/task_detail_sheet.dart';
import 'package:mindful/features/tasks/presentation/task_providers.dart';
import 'package:mindful/features/tasks/presentation/task_tab.dart';

class _EmptyTaskTabController extends TaskTabController {
  @override
  Future<List<Task>> build() async => [];
}

final _now = DateTime.now();

final _dueTask = Task(
  id: 't1',
  userId: 'u1',
  name: 'Pay rent',
  createdAt: DateTime(2026, 1, 1),
  updatedAt: DateTime(2026, 1, 1),
  dueDate: DateTime(_now.year, _now.month, _now.day),
);

class _DueTaskTabController extends TaskTabController {
  @override
  Future<List<Task>> build() async => [_dueTask];
}

class _EmptyHabitTabController extends HabitTabController {
  @override
  Future<List<HabitTabItem>> build() async => [];
}

class _EmptyJournalEntries extends JournalEntries {
  @override
  Future<List<JournalEntry>> build() async => [];
}

Widget _buildHome({TaskTabController Function()? tasks}) => ProviderScope(
  overrides: [
    taskTabControllerProvider.overrideWith(
      tasks ?? _EmptyTaskTabController.new,
    ),
    habitTabControllerProvider.overrideWith(_EmptyHabitTabController.new),
    journalEntriesProvider.overrideWith(_EmptyJournalEntries.new),
    hasStalePendingWritesProvider.overrideWith((ref) async => false),
    monthlyRecapBannerMonthProvider.overrideWith((ref) => null),
    // No budget set — RemainingBudgetWidget renders nothing, and
    // this keeps the test from touching MoneyRepository's Hive
    // boxes, which aren't initialized here.
    budgetsProvider.overrideWith((ref) async => const {}),
    moneyEntriesProvider(null).overrideWith((ref) async => const []),
    recentScansProvider.overrideWith((ref) async => const []),
    breathingSessionsProvider.overrideWith((ref) async => const []),
    taskByIdProvider(_dueTask.id).overrideWith((ref) async => _dueTask),
  ],
  child: MaterialApp(
    theme: ThemeData(extensions: [GlassTheme.dark()]),
    home: const HomeTab(),
  ),
);

void main() {
  testWidgets("shows Be mindful, Today's Todo and Mindfulness", (tester) async {
    // The default test surface is only 600 logical pixels tall, so the
    // journal section (near the bottom of the scroll view) would
    // otherwise be built-but-offstage and invisible to `find.text`.
    tester.view.physicalSize = const Size(1080, 4800);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_buildHome());
    await tester.pumpAndSettle();

    expect(find.text('What needs to be done today?'), findsOneWidget);
    expect(find.text('Add todo'), findsOneWidget);
    expect(find.text('Add routine'), findsOneWidget);
    expect(find.text('Mindfulness'), findsOneWidget);
    expect(find.text("Write today's plan"), findsOneWidget);
    expect(find.text('Breathing exercise'), findsOneWidget);
    expect(find.text('Build your first routine'), findsOneWidget);
    expect(find.text('Mindful with spending'), findsOneWidget);
  });

  testWidgets('on a tablet, a tapped task opens in the pane beside Home', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_buildHome(tasks: _DueTaskTabController.new));
    await tester.pumpAndSettle();

    expect(find.byType(DetailPane), findsOneWidget);

    await tester.tap(find.text('Pay rent'));
    await tester.pumpAndSettle();

    expect(find.byType(TaskDetailView), findsOneWidget);
    expect(find.byType(TaskDetailSheet), findsNothing);
  });
}
