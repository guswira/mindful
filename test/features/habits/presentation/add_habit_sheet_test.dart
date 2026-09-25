import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindful/core/theme/app_theme.dart';
import 'package:mindful/features/habits/domain/habit.dart';
import 'package:mindful/features/habits/domain/habit_action.dart';
import 'package:mindful/features/habits/presentation/add_habit_sheet.dart';
import 'package:mindful/features/habits/presentation/add_habit_sheet_actions.dart';
import 'package:mindful/shared/widgets/shake_widget.dart';
import 'package:mindful/shared/widgets/tinted_pill.dart';

final _habit = Habit(
  id: 'h1',
  userId: 'u1',
  name: 'Workout',
  icon: '🏋️',
  color: '#14E6AA',
  createdAt: DateTime(2026, 1, 1),
  actions: const [HabitAction(id: 'a1', label: 'Gym')],
);

void main() {
  Widget buildSheet({Habit? habit}) => ProviderScope(
    child: MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(body: AddHabitSheet(habit: habit)),
    ),
  );

  testWidgets('shows the name field, sections and "Add habit" pill', (
    tester,
  ) async {
    await tester.pumpWidget(buildSheet());

    expect(find.text('Build new habit'), findsOneWidget);
    expect(find.text('Habit name...'), findsOneWidget);
    expect(find.text('Icon'), findsOneWidget);
    expect(find.text('Color'), findsOneWidget);
    expect(find.text('Reminder'), findsOneWidget);
    expect(find.text('Custom actions'), findsOneWidget);
    expect(find.widgetWithText(TintedPill, 'Add habit'), findsOneWidget);
  });

  testWidgets(
    'tapping "Add habit" with an empty name is a no-op and shakes the field',
    (tester) async {
      await tester.pumpWidget(buildSheet());

      final pillFinder = find.widgetWithText(TintedPill, 'Add habit');
      await tester.ensureVisible(pillFinder);
      await tester.tap(pillFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final transform = tester.widget<Transform>(
        find.descendant(
          of: find.byType(ShakeWidget),
          matching: find.byType(Transform),
        ),
      );
      expect(transform.transform.getTranslation().x, isNot(0));

      await tester.pumpAndSettle();
      expect(find.byType(AddHabitSheet), findsOneWidget);
    },
  );

  testWidgets('toggling the reminder switch reveals the repeat-day chips', (
    tester,
  ) async {
    await tester.pumpWidget(buildSheet());

    expect(find.text('Repeat on'), findsNothing);

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(find.text('Repeat on'), findsOneWidget);
    expect(find.text('Mon'), findsOneWidget);
  });

  testWidgets(
    'pre-fills the name and actions, showing "Save changes" when editing',
    (tester) async {
      await tester.pumpWidget(buildSheet(habit: _habit));

      expect(find.text('Edit habit'), findsOneWidget);
      expect(find.text('Workout'), findsOneWidget);
      expect(find.byType(HabitActionsInlineEditor), findsOneWidget);
      expect(find.widgetWithText(TintedPill, 'Save changes'), findsOneWidget);
      expect(find.widgetWithText(TintedPill, 'Add habit'), findsNothing);
    },
  );
}
