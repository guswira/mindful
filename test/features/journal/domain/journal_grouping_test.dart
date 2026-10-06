import 'package:flutter_test/flutter_test.dart';

import 'package:mindful/features/journal/domain/journal_entry.dart';
import 'package:mindful/features/journal/domain/journal_grouping.dart';

JournalEntry _entry(String id, DateTime date, {String body = 'body'}) =>
    JournalEntry(
      id: id,
      userId: 'u1',
      date: date,
      body: body,
      createdAt: date,
      updatedAt: date,
    );

void main() {
  final entries = [
    _entry('a', DateTime(2026, 2, 2, 21), body: 'Evening review'),
    _entry('b', DateTime(2026, 2, 2, 8), body: 'Morning plan'),
    _entry('c', DateTime(2026, 1, 15), body: 'January'),
  ];

  test('counts entries per local day', () {
    expect(journalEntryCountsByDay(entries), {
      DateTime(2026, 2, 2): 2,
      DateTime(2026, 1, 15): 1,
    });
  });

  test('groups by day with one header each', () {
    final items = groupJournalEntriesByDay(entries, (day) => '${day.day}');
    expect(items, ['2', entries[0], entries[1], '15', entries[2]]);
  });

  test('filters by month, day and search query', () {
    expect(journalEntriesInMonth(entries, DateTime(2026, 1)), [entries[2]]);
    expect(journalEntriesOnDay(entries, DateTime(2026, 2, 2)), [
      entries[0],
      entries[1],
    ]);
    expect(searchJournalEntries(entries, 'PLAN'), [entries[1]]);
    expect(searchJournalEntries(entries, '  '), entries);
  });

  test('entries without a type read as Today review', () {
    final json = _entry('x', DateTime(2026, 2, 2)).toJson()..remove('type');
    expect(JournalEntry.fromJson(json).type, JournalType.review);

    json['type'] = 'something-new';
    expect(JournalEntry.fromJson(json).type, JournalType.review);

    json['type'] = 'gratitude';
    expect(JournalEntry.fromJson(json).type, JournalType.gratitude);
  });
}
