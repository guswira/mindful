import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindfull/core/theme/glass_theme.dart';
import 'package:mindfull/features/journal/data/journal_entries_controller.dart';
import 'package:mindfull/features/journal/domain/journal_entry.dart';
import 'package:mindfull/features/journal/presentation/journal_tab.dart';

class _FakeJournalEntries extends JournalEntries {
  _FakeJournalEntries(this._entries);

  final List<JournalEntry> _entries;

  @override
  Future<List<JournalEntry>> build() async => _entries;
}

void main() {
  testWidgets('groups entries by month, in the order given', (tester) async {
    final entries = [
      JournalEntry(
        id: '1',
        userId: 'u1',
        date: DateTime(2026, 2, 1),
        body: 'February thoughts',
        createdAt: DateTime(2026, 2, 1),
        updatedAt: DateTime(2026, 2, 1),
      ),
      JournalEntry(
        id: '2',
        userId: 'u1',
        date: DateTime(2026, 1, 15),
        body: 'January thoughts',
        createdAt: DateTime(2026, 1, 15),
        updatedAt: DateTime(2026, 1, 15),
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          journalEntriesProvider.overrideWith(
            () => _FakeJournalEntries(entries),
          ),
        ],
        child: MaterialApp(
          theme: ThemeData(extensions: [GlassTheme.dark()]),
          home: const JournalTab(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('February 2026'), findsOneWidget);
    expect(find.text('January 2026'), findsOneWidget);
    expect(find.text('February thoughts'), findsOneWidget);
    expect(find.text('January thoughts'), findsOneWidget);
  });

  testWidgets('filters entries as the search query changes', (tester) async {
    final entries = [
      JournalEntry(
        id: '1',
        userId: 'u1',
        date: DateTime(2026, 2, 1),
        body: 'A good day at the beach',
        createdAt: DateTime(2026, 2, 1),
        updatedAt: DateTime(2026, 2, 1),
      ),
      JournalEntry(
        id: '2',
        userId: 'u1',
        date: DateTime(2026, 2, 2),
        body: 'Stuck inside all day',
        createdAt: DateTime(2026, 2, 2),
        updatedAt: DateTime(2026, 2, 2),
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          journalEntriesProvider.overrideWith(
            () => _FakeJournalEntries(entries),
          ),
        ],
        child: MaterialApp(
          theme: ThemeData(extensions: [GlassTheme.dark()]),
          home: const JournalTab(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'beach');
    await tester.pumpAndSettle();

    expect(find.text('A good day at the beach'), findsOneWidget);
    expect(find.text('Stuck inside all day'), findsNothing);
  });
}
