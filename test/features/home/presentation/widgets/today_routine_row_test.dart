import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindful/core/theme/glass_theme.dart';
import 'package:mindful/features/habits/domain/habit.dart';
import 'package:mindful/features/habits/domain/habit_action.dart';
import 'package:mindful/features/habits/domain/habit_log.dart';
import 'package:mindful/features/habits/presentation/routine_pill.dart';
import 'package:mindful/features/home/presentation/widgets/today_routine_row.dart';
import 'package:mindful/shared/widgets/tinted_pill.dart';

Habit _habit({
  String color = '#FF6B6B',
  List<HabitAction> actions = const [],
}) => Habit(
  id: 'h1',
  userId: 'u1',
  name: 'Workout',
  icon: '🏃',
  color: color,
  createdAt: DateTime(2026),
  actions: actions,
);

HabitLog _log({String? actionId}) => HabitLog(
  id: 'l1',
  userId: 'u1',
  habitId: 'h1',
  date: DateTime(2026),
  completedActionId: actionId,
);

Widget _row(Habit habit, {HabitLog? log}) => ProviderScope(
  child: MaterialApp(
    theme: ThemeData(extensions: [GlassTheme.dark()]),
    home: Scaffold(body: TodayRoutineRow(item: (habit: habit, todayLog: log))),
  ),
);

const _actions = [
  HabitAction(id: 'a1', label: 'Gym'),
  HabitAction(id: 'a2', label: 'Run'),
];

void main() {
  testWidgets('a routine not logged yet has plain pills but a colored icon', (
    tester,
  ) async {
    await tester.pumpWidget(_row(_habit(actions: _actions)));

    final pills = tester.widgetList<RoutinePill>(find.byType(RoutinePill));
    expect(pills.map((pill) => pill.label), ['Gym', 'Run']);
    expect(pills.any((pill) => pill.selected), isFalse);
    expect(find.byType(TintedPill), findsNothing);
    final icon = tester.widget<Icon>(find.byIcon(Icons.directions_run_rounded));
    expect(icon.color, const Color(0xFFFF6B6B));
  });

  testWidgets('once logged, the icon and the logged action take the '
      "routine's color", (tester) async {
    await tester.pumpWidget(
      _row(
        _habit(actions: _actions),
        log: _log(actionId: 'a2'),
      ),
    );

    final tinted = tester.widget<TintedPill>(find.byType(TintedPill));
    expect(tinted.label, 'Run');
    expect(tinted.color, const Color(0xFFFF6B6B));
    final icon = tester.widget<Icon>(find.byIcon(Icons.directions_run_rounded));
    expect(icon.color, const Color(0xFFFF6B6B));
  });

  testWidgets('an unparseable color falls back to habitAccent', (tester) async {
    await tester.pumpWidget(_row(_habit(color: 'not-a-color'), log: _log()));

    final pill = tester.widget<TintedPill>(find.byType(TintedPill));
    expect(pill.label, 'Done');
    expect(pill.color, GlassTheme.dark().habitAccent);
  });
}
