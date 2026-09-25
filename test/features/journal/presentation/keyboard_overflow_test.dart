import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindful/core/theme/glass_theme.dart';
import 'package:mindful/features/journal/data/journal_entries_controller.dart';
import 'package:mindful/features/journal/domain/journal_entry.dart';
import 'package:mindful/features/journal/presentation/journal_editor_screen.dart';
import 'package:mindful/features/journal/presentation/journal_editor_widgets.dart';

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

void main() {
  testWidgets('no overflow on a realistic phone with the keyboard open', (
    tester,
  ) async {
    // A common phone size (iPhone-ish, logical 390x844) at 3x DPR.
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          journalEntriesProvider.overrideWith(_FakeJournalEntries.new),
        ],
        child: MaterialApp(
          theme: ThemeData(extensions: [GlassTheme.dark()]),
          home: const JournalEditorScreen(id: 'e1'),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(JournalMoodBar), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);

    // A realistic soft-keyboard height (~300 logical px).
    tester.view.viewInsets = const FakeViewPadding(bottom: 300 * 3);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();

    expect(find.byType(JournalMoodBar), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
  });
}
