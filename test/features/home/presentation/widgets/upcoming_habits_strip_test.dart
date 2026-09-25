import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindfull/core/theme/glass_theme.dart';
import 'package:mindfull/features/habits/domain/habit.dart';
import 'package:mindfull/features/habits/domain/habit_log.dart';
import 'package:mindfull/features/habits/presentation/habit_tab.dart';
import 'package:mindfull/features/home/presentation/widgets/upcoming_habits_strip.dart';

final _notDoneHabit = Habit(
  id: 'h1',
  userId: 'u1',
  name: 'Workout',
  icon: '🏋️',
  color: '#FF0000',
  createdAt: DateTime(2026, 1, 1),
);

final _doneHabit = Habit(
  id: 'h2',
  userId: 'u1',
  name: 'Meditate',
  icon: '🧘',
  color: '#00FF00',
  createdAt: DateTime(2026, 1, 2),
);

class _FakeHabitTabController extends HabitTabController {
  _FakeHabitTabController(this._items);

  final List<HabitTabItem> _items;

  @override
  Future<List<HabitTabItem>> build() async => _items;
}

Widget _buildStrip(List<HabitTabItem> items) => ProviderScope(
  overrides: [
    habitTabControllerProvider.overrideWith(
      () => _FakeHabitTabController(items),
    ),
  ],
  child: MaterialApp(
    theme: ThemeData(extensions: [GlassTheme.dark()]),
    home: const Scaffold(body: UpcomingHabitsStrip()),
  ),
);

void main() {
  testWidgets('shows not-yet-done habits but excludes completed ones', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildStrip([
        (habit: _notDoneHabit, todayLog: null),
        (
          habit: _doneHabit,
          todayLog: HabitLog(
            id: 'l1',
            userId: 'u1',
            habitId: 'h2',
            date: DateTime.now(),
          ),
        ),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.text('Workout'), findsOneWidget);
    expect(find.text('Meditate'), findsNothing);
  });

  testWidgets('shows the all-done note once every habit is logged', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildStrip([
        (
          habit: _doneHabit,
          todayLog: HabitLog(
            id: 'l1',
            userId: 'u1',
            habitId: 'h2',
            date: DateTime.now(),
          ),
        ),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.text('All done! 🎉'), findsOneWidget);
  });

  testWidgets('shows the empty state with no habits at all', (tester) async {
    await tester.pumpWidget(_buildStrip(const []));
    await tester.pumpAndSettle();

    expect(find.text('Build your first habit'), findsOneWidget);
  });
}
