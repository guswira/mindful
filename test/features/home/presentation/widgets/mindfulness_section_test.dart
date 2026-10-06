import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindful/core/theme/glass_theme.dart';
import 'package:mindful/features/exercise/data/breathing_preferences_repository.dart';
import 'package:mindful/features/exercise/presentation/breathing_picker_sheet.dart';
import 'package:mindful/features/home/presentation/widgets/mindfulness_section.dart';
import 'package:mindful/features/journal/presentation/add_journal_sheet.dart';

import '../../../exercise/exercise_fakes.dart';

Widget _buildSection() => ProviderScope(
  overrides: [
    breathingPreferencesRepositoryProvider.overrideWithValue(
      FakePreferencesRepository(),
    ),
  ],
  child: MaterialApp(
    theme: ThemeData(extensions: [GlassTheme.dark()]),
    home: const Scaffold(body: MindfulnessSection()),
  ),
);

void main() {
  testWidgets('shows plan, review and breathing prompts', (tester) async {
    await tester.pumpWidget(_buildSection());

    expect(find.text("Write today's plan"), findsOneWidget);
    expect(find.text('Review today'), findsOneWidget);
    expect(find.text('Breathing exercise'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);
    expect(find.text('Reflect'), findsOneWidget);
    expect(find.text('Breathe'), findsOneWidget);
  });

  testWidgets('"Start" opens the journal sheet on Plan', (tester) async {
    await tester.pumpWidget(_buildSection());

    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();

    expect(find.byType(AddJournalSheet), findsOneWidget);
    expect(find.text('What do you want to get done today?'), findsOneWidget);
  });

  testWidgets('"Breathe" opens the breathing exercise picker', (tester) async {
    await tester.pumpWidget(_buildSection());

    await tester.tap(find.text('Breathe'));
    await tester.pumpAndSettle();

    expect(find.byType(BreathingPickerSheet), findsOneWidget);
    expect(find.text('Box Breathing'), findsOneWidget);
  });
}
