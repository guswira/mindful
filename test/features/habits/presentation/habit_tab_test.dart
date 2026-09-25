import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindful/core/theme/glass_theme.dart';
import 'package:mindful/features/habits/domain/habit.dart';
import 'package:mindful/features/habits/domain/habit_action.dart';
import 'package:mindful/features/habits/domain/habit_log.dart';
import 'package:mindful/features/habits/presentation/habit_tab.dart';

final _habitWithActions = Habit(
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

final _habitNoActions = Habit(
  id: 'h2',
  userId: 'u1',
  name: 'Meditate',
  icon: '🧘',
  color: '#00FF00',
  createdAt: DateTime(2026, 1, 2),
);

class _FakeHabitTabController extends HabitTabController {
  @override
  Future<List<HabitTabItem>> build() async => [
    (habit: _habitWithActions, todayLog: null),
    (habit: _habitNoActions, todayLog: null),
  ];

  @override
  Future<void> logAction(Habit habit, HabitAction? action) async {
    final current = state.value ?? const <HabitTabItem>[];
    state = AsyncData([
      for (final item in current)
        if (item.habit.id == habit.id)
          (
            habit: item.habit,
            todayLog: HabitLog(
              id: 'log-${habit.id}',
              userId: 'u1',
              habitId: habit.id,
              date: DateTime.now(),
              completedActionId: action?.id,
            ),
          )
        else
          item,
    ]);
  }
}

Widget _buildTab() => ProviderScope(
  overrides: [
    habitTabControllerProvider.overrideWith(_FakeHabitTabController.new),
  ],
  child: MaterialApp(
    theme: ThemeData(extensions: [GlassTheme.dark()]),
    home: const HabitTab(),
  ),
);

void main() {
  testWidgets('shows today\'s habits with their action buttons', (
    tester,
  ) async {
    await tester.pumpWidget(_buildTab());
    await tester.pumpAndSettle();

    expect(find.text('Workout'), findsOneWidget);
    expect(find.text('Meditate'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Gym'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Run'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Done'), findsOneWidget);
  });

  testWidgets('tapping an action marks it done', (tester) async {
    await tester.pumpWidget(_buildTab());
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ChoiceChip, 'Gym'));
    await tester.pumpAndSettle();

    final chip = tester.widget<ChoiceChip>(
      find.widgetWithText(ChoiceChip, 'Gym'),
    );
    expect(chip.selected, isTrue);
  });

  testWidgets('tapping "Done" on a habit with no actions marks it done', (
    tester,
  ) async {
    await tester.pumpWidget(_buildTab());
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ChoiceChip, 'Done'));
    await tester.pumpAndSettle();

    final chip = tester.widget<ChoiceChip>(
      find.widgetWithText(ChoiceChip, 'Done'),
    );
    expect(chip.selected, isTrue);
  });

  testWidgets('long-pressing a habit row offers Edit, Archive and Delete', (
    tester,
  ) async {
    await tester.pumpWidget(_buildTab());
    await tester.pumpAndSettle();

    await tester.longPress(find.text('Workout'));
    await tester.pumpAndSettle();

    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Archive'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
  });
}
