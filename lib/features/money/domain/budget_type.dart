import 'package:flutter/material.dart' show DateTimeRange;

/// How often a [BudgetSettings] budget resets — also a spending entry's
/// [MoneyEntry.budgetPeriod]. Declared shortest to longest: the order is
/// what [countsToward] compares.
enum BudgetType {
  daily,
  weekly,
  monthly,
  yearly;

  /// Whether spending with this period counts against a [budget] budget.
  ///
  /// A bill only counts against budgets at least as long as it — a yearly
  /// bill skips the daily, weekly and monthly allowances, a monthly bill
  /// still counts toward the monthly and yearly ones.
  bool countsToward(BudgetType budget) => index <= budget.index;

  /// This period's range containing [now], from its first day through
  /// today (inclusive). Weeks start on Monday, like the app's calendars.
  DateTimeRange rangeEndingToday(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final start = switch (this) {
      BudgetType.daily => today,
      BudgetType.weekly => DateTime(
        today.year,
        today.month,
        today.day - (today.weekday - DateTime.monday),
      ),
      BudgetType.monthly => DateTime(today.year, today.month),
      BudgetType.yearly => DateTime(today.year),
    };
    return DateTimeRange(start: start, end: today);
  }
}
