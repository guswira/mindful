import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The Money tab's period pills (Today | This Week | This Month | All).
/// They filter the entry list (the Recap's AI advice follows the recap's
/// month instead). See SPEC.md Money
/// Flow Feature Money Flow Tab, Period Selector.
enum MoneyPeriod {
  today,
  week,
  month,
  all;

  /// This period's first day → today, both inclusive (weeks start
  /// Monday, like the calendars); null for [all].
  DateTimeRange? rangeEndingAt(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    return switch (this) {
      MoneyPeriod.today => DateTimeRange(start: today, end: today),
      MoneyPeriod.week => DateTimeRange(
        start: today.subtract(Duration(days: today.weekday - 1)),
        end: today,
      ),
      MoneyPeriod.month => DateTimeRange(
        start: DateTime(today.year, today.month, 1),
        end: today,
      ),
      MoneyPeriod.all => null,
    };
  }
}

/// Holds the selected [MoneyPeriod], kept while the app runs.
class MoneyPeriodController extends Notifier<MoneyPeriod> {
  @override
  MoneyPeriod build() => MoneyPeriod.month;

  /// Switches the Money tab to [period].
  void select(MoneyPeriod period) => state = period;
}

/// The Money tab's selected period. Hand-written — see SPEC.md Stack
/// decisions, Code generation.
final moneyPeriodProvider =
    NotifierProvider<MoneyPeriodController, MoneyPeriod>(
      MoneyPeriodController.new,
    );
