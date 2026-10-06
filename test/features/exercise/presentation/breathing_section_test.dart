import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindful/core/theme/glass_theme.dart';
import 'package:mindful/features/exercise/data/breathing_preferences_repository.dart';
import 'package:mindful/features/exercise/domain/breathing_preferences.dart';
import 'package:mindful/features/exercise/presentation/custom_pattern_sheet.dart';
import 'package:mindful/features/exercise/presentation/widgets/breathing_exercise_row.dart';
import 'package:mindful/features/exercise/presentation/widgets/breathing_section.dart';

import '../exercise_fakes.dart';

void main() {
  late FakePreferencesRepository preferences;

  setUp(() {
    preferences = FakePreferencesRepository(
      const BreathingPreferences(
        custom: CustomBreathing(inhale: 3, hold: 0, exhale: 5),
      ),
    );
  });

  Widget buildSection() => ProviderScope(
    overrides: [
      breathingPreferencesRepositoryProvider.overrideWithValue(preferences),
    ],
    child: MaterialApp(
      theme: ThemeData(extensions: [GlassTheme.dark()]),
      home: const Scaffold(
        body: SingleChildScrollView(child: BreathingSection()),
      ),
    ),
  );

  testWidgets('shows three exercises, then expands to all on Show all', (
    tester,
  ) async {
    await tester.pumpWidget(buildSection());
    await tester.pumpAndSettle();

    expect(find.text('Breathing exercise'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.byType(BreathingExerciseRow), findsNWidgets(3));
    expect(find.text('Box Breathing'), findsOneWidget);
    expect(find.text('Inhale 4s · Hold 7s · Release 8s'), findsOneWidget);
    expect(find.text('Inhale 3s · Release 5s'), findsNothing);

    await tester.tap(find.text('Show all (2 more)'));
    await tester.pumpAndSettle();

    expect(find.byType(BreathingExerciseRow), findsNWidgets(5));
    expect(find.text('Inhale 3s · Release 5s'), findsOneWidget);

    await tester.tap(find.text('Show less'));
    await tester.pumpAndSettle();
    expect(find.byType(BreathingExerciseRow), findsNWidgets(3));
  });

  testWidgets('editing Customize saves the new counts', (tester) async {
    await tester.pumpWidget(buildSection());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Show all (2 more)'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.edit_outlined));
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
