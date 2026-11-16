import 'package:flutter/material.dart' show DateTimeRange;

/// [month]'s first day → its last day, both inclusive — or → today for
/// the month still in progress, so "this month" never counts future-dated
/// entries.
DateTimeRange moneyMonthRange(DateTime month, DateTime now) {
  final start = DateTime(month.year, month.month);
  final today = DateTime(now.year, now.month, now.day);
  final lastDay = DateTime(month.year, month.month + 1, 0);
  return DateTimeRange(
    start: start,
    end: lastDay.isAfter(today) ? today : lastDay,
  );
}

/// The months before [now]'s that have at least one entry dated in them
/// (each as its 1st), newest first — the pages of the cashflow history.
List<DateTime> moneyHistoryMonths(Iterable<DateTime> entryDates, DateTime now) {
  final current = DateTime(now.year, now.month);
  final months = {
    for (final date in entryDates) DateTime(date.year, date.month),
  }..removeWhere((month) => !month.isBefore(current));
  return months.toList()..sort((a, b) => b.compareTo(a));
}
