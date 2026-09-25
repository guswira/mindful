import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindfull/core/theme/glass_theme.dart';
import 'package:mindfull/features/journal/data/journal_entries_controller.dart';
import 'package:mindfull/features/journal/domain/journal_entry.dart';
import 'package:mindfull/features/journal/presentation/journal_editor_screen.dart';

final _entry = JournalEntry(
  id: 'e1',
  userId: 'u1',
  date: DateTime(2026, 1, 1),
  body: 'Today was good',
  createdAt: DateTime(2026, 1, 1),
  updatedAt: DateTime(2026, 1, 1),
);

class _FakeJournalEntries extends JournalEntries {
  @override
  Future<List<JournalEntry>> build() async => [_entry];
}

Widget _buildScreen() => ProviderScope(
  overrides: [journalEntriesProvider.overrideWith(_FakeJournalEntries.new)],
  child: MaterialApp(
    theme: ThemeData(extensions: [GlassTheme.dark()]),
    home: const JournalEditorScreen(id: 'e1'),
  ),
);

void main() {
  testWidgets('shows the entry body and mood picker fields', (tester) async {
    await tester.pumpWidget(_buildScreen());
    await tester.pumpAndSettle();

    expect(find.text('Today was good'), findsOneWidget);
    for (final mood in Mood.values) {
      expect(find.text(mood.emoji), findsOneWidget);
    }
  });

  testWidgets('autofocuses the body field on open', (tester) async {
    await tester.pumpWidget(_buildScreen());
    await tester.pump();

    final bodyField = tester.widget<TextField>(
      find.widgetWithText(
        TextField,
        "What's on your mind...",
        skipOffstage: false,
      ),
    );
    expect(bodyField.focusNode?.hasFocus, isTrue);
  });

  testWidgets('tapping save with an empty body is a no-op', (tester) async {
    await tester.pumpWidget(_buildScreen());
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, "What's on your mind..."),
      '',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.byType(JournalEditorScreen), findsOneWidget);
  });
}
