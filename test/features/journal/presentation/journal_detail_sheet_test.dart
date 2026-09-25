import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindful/core/theme/app_theme.dart';
import 'package:mindful/features/journal/data/journal_entries_controller.dart';
import 'package:mindful/features/journal/domain/journal_entry.dart';
import 'package:mindful/features/journal/presentation/journal_detail_sheet.dart';

final _entry = JournalEntry(
  id: 'e1',
  userId: 'u1',
  date: DateTime(2026, 1, 15),
  title: 'A good day',
  body: 'Today was good',
  mood: Mood.happy,
  createdAt: DateTime(2026, 1, 15),
  updatedAt: DateTime(2026, 1, 15),
);

class _FakeJournalEntries extends JournalEntries {
  @override
  Future<List<JournalEntry>> build() async => [_entry];
}

void main() {
  Widget buildSheet() => ProviderScope(
    overrides: [journalEntriesProvider.overrideWith(_FakeJournalEntries.new)],
    child: MaterialApp(
      theme: AppTheme.dark,
      home: const Scaffold(body: JournalDetailSheet(journalId: 'e1')),
    ),
  );

  testWidgets('shows the date, title, body and mood', (tester) async {
    await tester.pumpWidget(buildSheet());
    await tester.pumpAndSettle();

    expect(find.text('January 15, 2026'), findsOneWidget);
    expect(find.text('A good day'), findsOneWidget);
    expect(find.text('Today was good'), findsOneWidget);
    expect(find.text(Mood.happy.emoji), findsOneWidget);
  });

  testWidgets('the overflow menu offers Edit and Delete', (tester) async {
    await tester.pumpWidget(buildSheet());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
  });
}
