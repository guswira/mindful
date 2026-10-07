import 'package:flutter_test/flutter_test.dart';

import 'package:mindful/features/money/domain/budget_type.dart';

void main() {
  test('a bill counts toward budgets at least as long as it', () {
    expect(BudgetType.daily.countsToward(BudgetType.daily), isTrue);
    expect(BudgetType.monthly.countsToward(BudgetType.daily), isFalse);
    expect(BudgetType.monthly.countsToward(BudgetType.weekly), isFalse);
    expect(BudgetType.monthly.countsToward(BudgetType.monthly), isTrue);
    expect(BudgetType.monthly.countsToward(BudgetType.yearly), isTrue);
    expect(BudgetType.yearly.countsToward(BudgetType.monthly), isFalse);
    expect(BudgetType.yearly.countsToward(BudgetType.yearly), isTrue);
  });

  test('periods run from their first day through today', () {
    // Thursday, October 8 2026.
    final now = DateTime(2026, 10, 8, 15, 30);
    final today = DateTime(2026, 10, 8);

    expect(BudgetType.daily.rangeEndingToday(now).start, today);
    expect(
      BudgetType.weekly.rangeEndingToday(now).start,
      DateTime(2026, 10, 5),
    );
    expect(BudgetType.monthly.rangeEndingToday(now).start, DateTime(2026, 10));
    expect(BudgetType.yearly.rangeEndingToday(now).start, DateTime(2026));
    for (final type in BudgetType.values) {
      expect(type.rangeEndingToday(now).end, today);
    }
  });

  test('a week starting on Monday crosses month boundaries', () {
    // Saturday, August 1 2026 → Monday, July 27.
    final range = BudgetType.weekly.rangeEndingToday(DateTime(2026, 8, 1));
    expect(range.start, DateTime(2026, 7, 27));
  });
}
