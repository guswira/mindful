import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindfull/core/theme/glass_theme.dart';
import 'package:mindfull/features/habits/domain/habit.dart';
import 'package:mindfull/features/habits/domain/habit_action.dart';
import 'package:mindfull/features/habits/domain/habit_log.dart';
import 'package:mindfull/features/habits/presentation/habit_detail_screen.dart';
import 'package:mindfull/features/habits/presentation/habit_providers.dart';

final _habit = Habit(
  id: 'h1',
  userId: 'u1',
  name: 'Workout',
  icon: '🏋️',
  color: '#FF0000',
  createdAt: DateTime(2026, 1, 1),
  actions: const [HabitAction(id: 'a1', label: 'Gym')],
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
  @override
  Future<HabitDetailState> build(String habitId) async =>
      (month: DateTime(2026, 3), logsByDate: {DateTime(2026, 3, 15): _log});
}

void main() {
  Widget buildScreen() => ProviderScope(
    overrides: [
      habitByIdProvider('h1').overrideWith((ref) async => _habit),
      habitDetailControllerProvider(
        'h1',
      ).overrideWith(_FakeHabitDetailController.new),
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

  testWidgets('tapping a logged day shows which action and note', (
    tester,
  ) async {
    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    await tester.tap(find.text('15'));
    await tester.pumpAndSettle();

    expect(find.text('Mar 15, 2026'), findsOneWidget);
    expect(find.text('Gym\nfelt great'), findsOneWidget);
  });
}
