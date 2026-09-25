import 'package:flutter_test/flutter_test.dart';

import 'package:mindful/features/money/domain/entry_type.dart';
import 'package:mindful/features/money/domain/money_entry.dart';
import 'package:mindful/features/money/presentation/money_advice_summary.dart';
import 'package:mindful/shared/models/sync_status.dart';

MoneyEntry _entry(
  String id,
  EntryType type,
  double amount,
  String category,
  DateTime date, {
  String? note,
}) => MoneyEntry(
  id: id,
  userId: 'u1',
  type: type,
  amount: amount,
  category: category,
  note: note,
  date: date,
  createdAt: date,
  updatedAt: date,
  syncStatus: SyncStatus.synced,
);

void main() {
  final entries = [
    _entry('1', EntryType.spending, 30, 'Food', DateTime(2026, 9, 2)),
    _entry(
      '2',
      EntryType.spending,
      50,
      'Transport',
      DateTime(2026, 9, 1),
      note: 'Taxi',
    ),
    _entry('3', EntryType.income, 1000, 'Salary', DateTime(2026, 8, 31)),
    _entry('4', EntryType.spending, 25, 'Food', DateTime(2026, 8, 30)),
  ];

  test('includes totals, per-category, per-month and recent entries', () {
    final summary = buildMoneyAdviceSummary(entries, 'USD');

    expect(summary, contains('Currency: USD'));
    expect(summary, contains('Total spending: 105.00'));
    expect(summary, contains('Total income: 1000.00'));
    expect(summary, contains('- Food: 55.00'));
    expect(summary, contains('- Salary: 1000.00'));
    expect(summary, contains('- 2026-08: 25.00 / 1000.00'));
    expect(summary, contains('- 2026-09: 80.00 / 0.00'));
    expect(summary, contains('- 2026-09-01, spending, Transport, 50.00, Taxi'));
  });

  test('sorts spending categories by amount, largest first', () {
    final summary = buildMoneyAdviceSummary(entries, 'USD');

    expect(
      summary.indexOf('- Food: 55.00'),
      lessThan(summary.indexOf('- Transport: 50.00')),
    );
  });

  test('caps individual entries at moneyAdviceMaxEntries', () {
    final many = [
      for (var i = 0; i < moneyAdviceMaxEntries + 10; i++)
        _entry('$i', EntryType.spending, 1, 'Food', DateTime(2026, 9, 1)),
    ];

    final summary = buildMoneyAdviceSummary(many, 'USD');

    expect(
      RegExp('spending, Food').allMatches(summary).length,
      moneyAdviceMaxEntries,
    );
    expect(summary, contains('Total spending: 210.00'));
  });
}
