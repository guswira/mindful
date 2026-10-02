import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindful/core/theme/glass_theme.dart';
import 'package:mindful/features/exercise/data/breathing_preferences_repository.dart';
import 'package:mindful/features/exercise/data/breathing_session_repository.dart';
import 'package:mindful/features/exercise/domain/breathing_preferences.dart';
import 'package:mindful/features/exercise/presentation/custom_pattern_sheet.dart';
import 'package:mindful/features/exercise/presentation/exercise_tab.dart';
import 'package:mindful/features/exercise/presentation/widgets/breathing_exercise_card.dart';
import 'package:mindful/features/exercise/presentation/widgets/exercise_stats_row.dart';

import '../exercise_fakes.dart';

void main() {
  late FakeBox box;
  late FakePreferencesRepository preferences;

  setUp(() {
    box = FakeBox();
    preferences = FakePreferencesRepository(
      const BreathingPreferences(
        custom: CustomBreathing(inhale: 3, hold: 0, exhale: 5),
      ),
    );
  });

  Widget buildTab() => ProviderScope(
    overrides: [
      breathingPreferencesRepositoryProvider.overrideWithValue(preferences),
      breathingSessionRepositoryProvider.overrideWith(
        (ref) async => BreathingSessionRepository(
          box: box,
          datasource: FakeBreathingDatasource(),
        ),
      ),
    ],
    child: MaterialApp(
      theme: ThemeData(extensions: [GlassTheme.dark()]),
      home: const ExerciseTab(),
    ),
  );

  testWidgets('lists the five breathing exercises', (tester) async {
    await tester.pumpWidget(buildTab());
    await tester.pumpAndSettle();

    expect(find.byType(BreathingExerciseCard), findsNWidgets(5));
    expect(find.text('Box Breathing'), findsOneWidget);
    expect(find.text('Inhale 4s · Hold 7s · Release 8s'), findsOneWidget);
    expect(find.text('Inhale 3s · Release 5s'), findsOneWidget);
  });

  testWidgets('shows totals from saved sessions', (tester) async {
    final now = DateTime.now();
    for (final (id, seconds) in [('a', 300), ('b', 120)]) {
      await box.put(
        id,
        testSession(id: id, startedAt: now, seconds: seconds).toJson(),
      );
    }

    await tester.pumpWidget(buildTab());
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.byType(ExerciseStatsRow), 200);

    final stats = find.byType(ExerciseStatsRow);
    expect(
      find.descendant(of: stats, matching: find.text('2')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: stats, matching: find.text('7m')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: stats, matching: find.text('1')),
      findsOneWidget,
    );
  });

  testWidgets('editing Customize saves the new counts', (tester) async {
    await tester.pumpWidget(buildTab());
    await tester.pumpAndSettle();

    final edit = find.byIcon(Icons.edit_outlined);
    await tester.scrollUntilVisible(edit, 200);
    // scrollUntilVisible jumps without laying out a new frame.
    await tester.pump();
    await tester.tap(edit);
    await tester.pumpAndSettle();
    expect(find.byType(CustomPatternSheet), findsOneWidget);

    await tester.tap(find.byTooltip('Increase Inhale'));
    await tester.pump();
    await tester.tap(find.text('Save pattern'));
    await tester.pumpAndSettle();

    expect(preferences.stored.custom.inhale, 4);
    expect(find.text('Inhale 4s · Release 5s'), findsOneWidget);
  });
}
