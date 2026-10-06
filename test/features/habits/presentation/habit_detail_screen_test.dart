import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindful/core/theme/glass_theme.dart';
import 'package:mindful/features/habits/domain/habit.dart';
import 'package:mindful/features/habits/domain/habit_action.dart';
import 'package:mindful/features/habits/domain/habit_log.dart';
import 'package:mindful/features/habits/presentation/habit_day_log_sheet.dart';
import 'package:mindful/features/habits/presentation/habit_detail_screen.dart';
import 'package:mindful/features/habits/presentation/habit_providers.dart';

final _habit = Habit(
  id: 'h1',
  userId: 'u1',
  name: 'Workout',
  icon: '🏋️',
  color: '#FF0000',
  createdAt: DateTime(2026, 1, 1),
  actions: const [
    HabitAction(id: 'a1', label: 'Gym'),
    HabitAction(id: 'a2', label: 'Run'),
  ],
);

final _log = HabitLog(
  id: 'log1',
  userId: 'u1',
  habitId: 'h1',
  date: DateTime(2026, 3, 15),
  completedActionId: 'a1',
  note: 'felt great',
);

class _FakeHabitDetailController extends HabitDetailController {
  final List<(DateTime, HabitDayChoice)> changes = [];

  @override
  Future<HabitDetailState> build(String habitId) async =>
      (month: DateTime(2026, 3), logsByDate: {DateTime(2026, 3, 15): _log});

  @override
  Future<void> setDayLog(DateTime date, HabitDayChoice choice) async =>
      changes.add((date, choice));
}

void main() {
  late _FakeHabitDetailController controller;

  setUp(() => controller = _FakeHabitDetailController());

  Widget buildScreen() => ProviderScope(
    overrides: [
      habitByIdProvider('h1').overrideWith((ref) async => _habit),
      habitDetailControllerProvider('h1').overrideWith(() => controller),
    ],
    child: MaterialApp(
      theme: ThemeData(extensions: [GlassTheme.dark()]),
      home: const HabitDetailScreen(id: 'h1'),
    ),
  );

  testWidgets('shows the habit name, month and streak counts', (tester) async {
    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    expect(find.text('Workout'), findsOneWidget);
    expect(find.text('March 2026'), findsOneWidget);
    expect(find.text('Current streak'), findsOneWidget);
    expect(find.text('Longest streak'), findsOneWidget);
  });

  testWidgets('tapping a logged day shows its action and changes it', (
    tester,
  ) async {
    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    await tester.tap(find.text('15'));
    await tester.pumpAndSettle();

    expect(find.byType(HabitDayLogSheet), findsOneWidget);
    expect(find.text('Sun, Mar 15, 2026'), findsOneWidget);
    expect(find.text('Logged as'), findsOneWidget);
    expect(find.text('felt great'), findsOneWidget);
    expect(find.text('Not done'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(HabitDayLogSheet),
        matching: find.text('Run'),
      ),
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.byType(HabitDayLogSheet), findsNothing);
    expect(controller.changes, [
      (DateTime(2026, 3, 15), (done: true, actionId: 'a2')),
    ]);
  });

  testWidgets('an unlogged past day can be logged', (tester) async {
    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    await tester.tap(find.text('10'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(HabitDayLogSheet),
        matching: find.text('Gym'),
      ),
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(controller.changes, [
      (DateTime(2026, 3, 10), (done: true, actionId: 'a1')),
    ]);
  });

  testWidgets('saving without a change does nothing', (tester) async {
    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    await tester.tap(find.text('15'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(controller.changes, isEmpty);
  });

  testWidgets('shows the action on its day and a monthly action summary', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    // Once on the 15th's cell, once in the summary.
    expect(find.text('Gym'), findsNWidgets(2));
    expect(find.text('Actions this month'), findsOneWidget);
    expect(find.text('1 time'), findsOneWidget);
  });
}
