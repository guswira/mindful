import 'journal_entry.dart';

/// Local midnight of [date].
DateTime _day(DateTime date) => DateTime(date.year, date.month, date.day);

/// How many entries fall on each day, keyed by local midnight.
Map<DateTime, int> journalEntryCountsByDay(List<JournalEntry> entries) {
  final counts = <DateTime, int>{};
  for (final entry in entries) {
    final day = _day(entry.date);
    counts[day] = (counts[day] ?? 0) + 1;
  }
  return counts;
}

/// Entries whose title or body contains [query], case-insensitively. A
/// blank query matches everything.
List<JournalEntry> searchJournalEntries(
  List<JournalEntry> entries,
  String query,
) {
  final lower = query.trim().toLowerCase();
  if (lower.isEmpty) {
    return entries;
  }
  return [
    for (final entry in entries)
      if (entry.body.toLowerCase().contains(lower) ||
          (entry.title?.toLowerCase().contains(lower) ?? false))
        entry,
  ];
}

/// Entries dated within [month] (any day in it works).
List<JournalEntry> journalEntriesInMonth(
  List<JournalEntry> entries,
  DateTime month,
) => [
  for (final entry in entries)
    if (entry.date.year == month.year && entry.date.month == month.month) entry,
];

/// Entries dated on [day].
List<JournalEntry> journalEntriesOnDay(
  List<JournalEntry> entries,
  DateTime day,
) => [
  for (final entry in entries)
    if (_day(entry.date) == _day(day)) entry,
];

/// Flattens [entries] (already newest first) into a header string from
/// [labelFor] at the start of each day, followed by that day's entries.
List<Object> groupJournalEntriesByDay(
  List<JournalEntry> entries,
  String Function(DateTime day) labelFor,
) {
  final items = <Object>[];
  DateTime? currentDay;
  for (final entry in entries) {
    final day = _day(entry.date);
    if (day != currentDay) {
      items.add(labelFor(day));
      currentDay = day;
    }
    items.add(entry);
  }
  return items;
}
