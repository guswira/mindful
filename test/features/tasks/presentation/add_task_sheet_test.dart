import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindfull/core/theme/app_theme.dart';
import 'package:mindfull/features/tasks/domain/task.dart';
import 'package:mindfull/features/tasks/presentation/add_task_sheet.dart';
import 'package:mindfull/features/tasks/presentation/add_task_sheet_subtasks.dart';
import 'package:mindfull/shared/widgets/shake_widget.dart';
import 'package:mindfull/shared/widgets/tinted_pill.dart';

final _task = Task(
  id: 't1',
  userId: 'u1',
  name: 'Buy groceries',
  createdAt: DateTime(2026, 1, 1),
  updatedAt: DateTime(2026, 1, 1),
);

void main() {
  Widget buildSheet({Task? task}) => ProviderScope(
    child: MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(body: AddTaskSheet(task: task)),
    ),
  );

  testWidgets('shows name field, due date, reminder and subtasks rows', (
    tester,
  ) async {
    await tester.pumpWidget(buildSheet());

    expect(find.text('What to do'), findsOneWidget);
    expect(find.text('What needs to be done?'), findsOneWidget);
    expect(find.text('Add due date'), findsOneWidget);
    expect(find.text('Add reminder'), findsOneWidget);
    expect(find.text('Add subtasks'), findsOneWidget);
    expect(find.byType(Switch), findsOneWidget);
    expect(find.widgetWithText(TintedPill, 'Add task'), findsOneWidget);
  });

  testWidgets(
    'tapping "Add task" with an empty name is a no-op and shakes the field',
    (tester) async {
      await tester.pumpWidget(buildSheet());

      await tester.tap(find.widgetWithText(TintedPill, 'Add task'));
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
      expect(find.byType(AddTaskSheet), findsOneWidget);
    },
  );

  testWidgets('toggling "Add subtasks" reveals the inline subtask editor', (
    tester,
  ) async {
    await tester.pumpWidget(buildSheet());

    expect(find.byType(SubtasksEditor), findsNothing);

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(find.byType(SubtasksEditor), findsOneWidget);

    await tester.tap(find.text('+ Add subtask'));
    await tester.pump();

    expect(find.widgetWithText(TextField, 'Subtask...'), findsOneWidget);
  });

  testWidgets('pre-fills the name and shows "Save changes" when editing', (
    tester,
  ) async {
    await tester.pumpWidget(buildSheet(task: _task));

    expect(find.text('Buy groceries'), findsOneWidget);
    expect(find.widgetWithText(TintedPill, 'Save changes'), findsOneWidget);
    expect(find.widgetWithText(TintedPill, 'Add task'), findsNothing);
  });
}
