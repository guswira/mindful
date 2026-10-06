import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindful/core/theme/glass_theme.dart';
import 'package:mindful/features/habits/domain/habit.dart';
import 'package:mindful/features/habits/presentation/archived_habits_sheet.dart';
import 'package:mindful/features/habits/presentation/habit_tab.dart';
import 'package:mindful/l10n/generated/app_localizations.dart';

final _archived = Habit(
  id: 'h1',
  userId: 'u1',
  name: 'Meditate',
  icon: '🧘',
  color: '#00FF00',
  createdAt: DateTime(2026, 1, 1),
  archived: true,
);

class _FakeHabitTabController extends HabitTabController {
  final restored = <Habit>[];
  final deleted = <Habit>[];

  @override
  Future<List<HabitTabItem>> build() async => const [];

  @override
  Future<void> restore(Habit habit) async => restored.add(habit);

  @override
  Future<void> delete(Habit habit) async => deleted.add(habit);
}

void main() {
  late _FakeHabitTabController controller;

  Widget buildSheet({List<Habit>? archived}) => ProviderScope(
    overrides: [
      habitTabControllerProvider.overrideWith(() => controller),
      archivedHabitsProvider.overrideWith(
        (ref) async => archived ?? [_archived],
      ),
    ],
    child: MaterialApp(
      theme: ThemeData(extensions: [GlassTheme.dark()]),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(body: ArchivedHabitsSheet()),
    ),
  );

  setUp(() => controller = _FakeHabitTabController());

  testWidgets('lists archived habits and restores one', (tester) async {
    await tester.pumpWidget(buildSheet());
    await tester.pumpAndSettle();

    expect(find.text('Archived routines'), findsOneWidget);
    expect(find.text('Meditate'), findsOneWidget);

    await tester.tap(find.text('Restore'));
    await tester.pumpAndSettle();

    expect(controller.restored, [_archived]);
  });

  testWidgets('deletes an archived habit after confirming', (tester) async {
    await tester.pumpWidget(buildSheet());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Delete habit?'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(controller.deleted, [_archived]);
  });

  testWidgets('shows an empty state once nothing is archived', (tester) async {
    await tester.pumpWidget(buildSheet(archived: const []));
    await tester.pumpAndSettle();

    expect(find.text('No archived routines'), findsOneWidget);
  });
}
