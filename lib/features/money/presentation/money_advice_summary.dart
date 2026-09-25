import '../domain/entry_type.dart';
import '../domain/money_entry.dart';

/// How many individual entries go into the prompt, newest first — the
/// per-category and per-month totals above them always cover everything,
/// so capping this only trims detail, and keeps a long history from
/// blowing up the prompt size.
const int moneyAdviceMaxEntries = 200;

/// Plain-text summary of every money [entries] for Gemini's advice prompt:
/// all-time totals, spending and income per category, per-month totals,
/// then the most recent individual entries.
///
/// Categories stay in their stored English names (they're data, not copy);
/// the localized prompt tells Gemini which language to answer in. Numbers
/// and dates are fixed-format rather than following the app locale, so
/// Gemini always reads the same unambiguous shape.
String buildMoneyAdviceSummary(List<MoneyEntry> entries, String currency) {
  final spendingByCategory = <String, double>{};
  final incomeByCategory = <String, double>{};
  final byMonth = <String, (double, double)>{};
  var totalSpending = 0.0;
  var totalIncome = 0.0;
  for (final entry in entries) {
    final key = _month(entry.date);
    final (spent, earned) = byMonth[key] ?? (0.0, 0.0);
    switch (entry.type) {
      case EntryType.spending:
        totalSpending += entry.amount;
        spendingByCategory.update(
          entry.category,
          (value) => value + entry.amount,
          ifAbsent: () => entry.amount,
        );
        byMonth[key] = (spent + entry.amount, earned);
      case EntryType.income:
        totalIncome += entry.amount;
        incomeByCategory.update(
          entry.category,
          (value) => value + entry.amount,
          ifAbsent: () => entry.amount,
        );
        byMonth[key] = (spent, earned + entry.amount);
    }
  }

  String sortedTotals(Map<String, double> totals) {
    final sorted = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return [
      for (final e in sorted) '- ${e.key}: ${_amount(e.value)}',
    ].join('\n');
  }

  final months = byMonth.keys.toList()..sort();
  final recent = entries.take(moneyAdviceMaxEntries);

  return [
    'Currency: $currency',
    'Total spending: ${_amount(totalSpending)}',
    'Total income: ${_amount(totalIncome)}',
    '',
    'Spending by category:',
    sortedTotals(spendingByCategory),
    '',
    'Income by category:',
    sortedTotals(incomeByCategory),
    '',
    'Per month (spending / income):',
    for (final key in months)
      '- $key: ${_amount(byMonth[key]?.$1 ?? 0)} / '
          '${_amount(byMonth[key]?.$2 ?? 0)}',
    '',
    'Most recent entries (date, type, category, amount, note):',
    for (final entry in recent)
      '- ${_day(entry.date)}, ${entry.type.name}, ${entry.category}, '
          '${_amount(entry.amount)}${_noteSuffix(entry.note)}',
  ].join('\n');
}

String _noteSuffix(String? note) =>
    note == null || note.isEmpty ? '' : ', $note';

String _amount(double value) => value.toStringAsFixed(2);

String _month(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}';

String _day(DateTime date) =>
    '${_month(date)}-${date.day.toString().padLeft(2, '0')}';
