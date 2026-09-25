import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindful/core/theme/app_theme.dart';
import 'package:mindful/features/tasks/domain/task.dart';
import 'package:mindful/features/tasks/domain/task_checkbox.dart';
import 'package:mindful/features/tasks/presentation/task_detail_sheet.dart';
import 'package:mindful/features/tasks/presentation/task_providers.dart';
import 'package:mindful/shared/widgets/tinted_pill.dart';

final _task = Task(
  id: 't1',
  userId: 'u1',
  name: 'Buy groceries',
  createdAt: DateTime(2026, 1, 1),
  updatedAt: DateTime(2026, 1, 1),
  checkboxes: const [
    TaskCheckbox(id: 'c1', label: 'Milk'),
    TaskCheckbox(id: 'c2', label: 'Eggs', isChecked: true),
  ],
);

void main() {
  Widget buildSheet(Task? task) => ProviderScope(
    overrides: [taskByIdProvider('t1').overrideWith((ref) async => task)],
    child: MaterialApp(
      theme: AppTheme.dark,
      home: const Scaffold(body: TaskDetailSheet(taskId: 't1')),
    ),
  );

  testWidgets('shows the task name, subtasks and a "Mark as done" pill', (
    tester,
  ) async {
    await tester.pumpWidget(buildSheet(_task));
    await tester.pumpAndSettle();

    expect(find.text('Buy groceries'), findsOneWidget);
    expect(find.text('Subtasks'), findsOneWidget);
    expect(find.text('Milk'), findsOneWidget);
    expect(find.text('Eggs'), findsOneWidget);
    expect(find.widgetWithText(TintedPill, 'Mark as done'), findsOneWidget);
  });

  testWidgets('hides "Mark as done" once the task is completed', (
    tester,
  ) async {
    await tester.pumpWidget(buildSheet(_task.copyWith(isCompleted: true)));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TintedPill, 'Mark as done'), findsNothing);
  });

  testWidgets('the overflow menu offers Edit and Delete', (tester) async {
    await tester.pumpWidget(buildSheet(_task));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
  });

  testWidgets('shows a not-found message for an unknown task', (tester) async {
    await tester.pumpWidget(buildSheet(null));
    await tester.pumpAndSettle();

    expect(find.text('Task not found'), findsOneWidget);
  });
}
