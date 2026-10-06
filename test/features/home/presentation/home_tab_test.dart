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
import 'package:mindful/features/tasks/presentation/task_tab.dart';

class _EmptyTaskTabController extends TaskTabController {
  @override
  Future<List<Task>> build() async => [];
}

class _EmptyHabitTabController extends HabitTabController {
  @override
  Future<List<HabitTabItem>> build() async => [];
}

class _EmptyJournalEntries extends JournalEntries {
  @override
  Future<List<JournalEntry>> build() async => [];
}

void main() {
  testWidgets("shows Be mindful, Today's Todo and Mindfulness", (tester) async {
    // The default test surface is only 600 logical pixels tall, so the
    // journal section (near the bottom of the scroll view) would
    // otherwise be built-but-offstage and invisible to `find.text`.
    tester.view.physicalSize = const Size(1080, 4800);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          taskTabControllerProvider.overrideWith(_EmptyTaskTabController.new),
          habitTabControllerProvider.overrideWith(_EmptyHabitTabController.new),
          journalEntriesProvider.overrideWith(_EmptyJournalEntries.new),
          hasStalePendingWritesProvider.overrideWith((ref) async => false),
          monthlyRecapBannerMonthProvider.overrideWith((ref) => null),
          // No budget set — RemainingBudgetWidget renders nothing, and
          // this keeps the test from touching MoneyRepository's Hive
          // boxes, which aren't initialized here.
          monthlyBudgetProvider.overrideWith((ref) async => null),
          dailyBudgetProvider.overrideWith((ref) async => null),
          moneyEntriesProvider(null).overrideWith((ref) async => const []),
          recentScansProvider.overrideWith((ref) async => const []),
          breathingSessionsProvider.overrideWith((ref) async => const []),
        ],
        child: MaterialApp(
          theme: ThemeData(extensions: [GlassTheme.dark()]),
          home: const HomeTab(),
        ),
      ),
    );
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
}
