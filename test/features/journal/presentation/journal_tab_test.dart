import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindful/core/theme/glass_theme.dart';
import 'package:mindful/features/exercise/data/breathing_preferences_repository.dart';
import 'package:mindful/features/exercise/presentation/widgets/breathing_section.dart';
import 'package:mindful/features/journal/data/journal_entries_controller.dart';
import 'package:mindful/features/journal/domain/journal_entry.dart';
import 'package:mindful/features/journal/presentation/journal_prompt_rows.dart';
import 'package:mindful/features/journal/presentation/journal_tab.dart';
import 'package:mindful/features/journal/presentation/journal_tab_list.dart';

import '../../exercise/exercise_fakes.dart';

class _FakeJournalEntries extends JournalEntries {
  _FakeJournalEntries(this._entries);

  final List<JournalEntry> _entries;

  @override
  Future<List<JournalEntry>> build() async => _entries;
}

JournalEntry _entry(String id, DateTime date, String body, JournalType type) =>
    JournalEntry(
      id: id,
      userId: 'u1',
      date: date,
      body: body,
      type: type,
      createdAt: date,
      updatedAt: date,
    );

void main() {
  Widget buildTab(List<JournalEntry> entries) => ProviderScope(
    overrides: [
      journalEntriesProvider.overrideWith(() => _FakeJournalEntries(entries)),
      breathingPreferencesRepositoryProvider.overrideWithValue(
        FakePreferencesRepository(),
      ),
    ],
    child: MaterialApp(
      theme: ThemeData(extensions: [GlassTheme.dark()]),
      home: const JournalTab(),
    ),
  );

  testWidgets("shows only today's entries, then the breathing section", (
    tester,
  ) async {
    final now = DateTime.now();
    await tester.pumpWidget(
      buildTab([
        _entry('1', now, 'Grateful for coffee', JournalType.gratitude),
        _entry(
          '2',
          now.subtract(const Duration(days: 2)),
          'An older review',
          JournalType.review,
        ),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mindfulness'), findsOneWidget);
    expect(find.text("Today's journal"), findsOneWidget);
    expect(find.text('view all'), findsOneWidget);
    expect(find.byType(JournalTodayCard), findsOneWidget);
    expect(find.text('Grateful for coffee'), findsOneWidget);
    expect(find.text('Gratitude'), findsOneWidget);
    expect(find.text('An older review'), findsNothing);
    expect(find.byType(JournalPromptRows), findsNothing);
    expect(find.byType(BreathingSection), findsOneWidget);
  });

  testWidgets(
    'shows the plan / review prompts when nothing was written today',
    (tester) async {
      await tester.pumpWidget(buildTab(const []));
      await tester.pumpAndSettle();

      expect(find.byType(JournalPromptRows), findsOneWidget);
      expect(find.text("Write today's plan"), findsOneWidget);
      expect(find.text('Review today'), findsOneWidget);
      expect(find.byType(JournalTodayCard), findsNothing);
    },
  );
}
