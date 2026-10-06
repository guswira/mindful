import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindful/core/theme/glass_theme.dart';
import 'package:mindful/features/journal/data/journal_entries_controller.dart';
import 'package:mindful/features/journal/domain/journal_entry.dart';
import 'package:mindful/features/journal/presentation/journal_calendar_card.dart';
import 'package:mindful/features/journal/presentation/journal_history_screen.dart';

class _FakeJournalEntries extends JournalEntries {
  _FakeJournalEntries(this._entries);

  final List<JournalEntry> _entries;

  @override
  Future<List<JournalEntry>> build() async => _entries;
}

JournalEntry _entry(String id, DateTime date, String body) => JournalEntry(
  id: id,
  userId: 'u1',
  date: date,
  body: body,
  createdAt: date,
  updatedAt: date,
);

void main() {
  final entries = [
    _entry('1', DateTime(2026, 2, 2), 'Stuck inside all day'),
    _entry('2', DateTime(2026, 2, 1), 'A good day at the beach'),
    _entry('3', DateTime(2026, 1, 15), 'January thoughts'),
  ];

  Widget buildScreen() => ProviderScope(
    overrides: [
      journalEntriesProvider.overrideWith(() => _FakeJournalEntries(entries)),
    ],
    child: MaterialApp(
      theme: ThemeData(extensions: [GlassTheme.dark()]),
      home: JournalHistoryScreen(now: DateTime(2026, 2, 10)),
    ),
  );

  // The list sits under the calendar — give it room to be built.
  Future<void> pumpScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();
  }

  testWidgets("lists the month's entries grouped by day", (tester) async {
    await pumpScreen(tester);

    expect(find.text('February 2026'), findsOneWidget);
    expect(find.text('Mon, Feb 2'), findsOneWidget);
    expect(find.text('Sun, Feb 1'), findsOneWidget);
    expect(find.text('Stuck inside all day'), findsOneWidget);
    expect(find.text('A good day at the beach'), findsOneWidget);
    expect(find.text('January thoughts'), findsNothing);
  });

  testWidgets('tapping a day narrows the list to it', (tester) async {
    await pumpScreen(tester);

    await tester.tap(
      find.descendant(
        of: find.byType(JournalCalendarCard),
        matching: find.text('2'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Stuck inside all day'), findsOneWidget);
    expect(find.text('A good day at the beach'), findsNothing);
  });

  testWidgets('paging back shows the previous month', (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.byTooltip('Previous month'));
    await tester.pumpAndSettle();

    expect(find.text('January 2026'), findsOneWidget);
    expect(find.text('January thoughts'), findsOneWidget);
    expect(find.text('Stuck inside all day'), findsNothing);
  });

  testWidgets('a search query looks across every month', (tester) async {
    await pumpScreen(tester);

    await tester.enterText(find.byType(TextField), 'thoughts');
    await tester.pumpAndSettle();

    expect(find.byType(JournalCalendarCard), findsNothing);
    expect(find.text('January thoughts'), findsOneWidget);
    expect(find.text('A good day at the beach'), findsNothing);
  });
}
