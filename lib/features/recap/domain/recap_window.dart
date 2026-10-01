/// How many days before a month ends the home banner starts offering that
/// month's recap.
const int recapDaysBeforeMonthEnd = 3;

/// How many days into a new month the home banner keeps offering the
/// previous month's recap.
const int recapDaysIntoNewMonth = 3;

/// The month (its 1st) the home banner should offer a recap for at [now],
/// or null outside the month-end/early-month window.
///
/// The last [recapDaysBeforeMonthEnd] days offer the current month (so
/// far); the first [recapDaysIntoNewMonth] days offer the month just ended.
DateTime? recapMonthForBanner(DateTime now) {
  final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
  if (now.day > daysInMonth - recapDaysBeforeMonthEnd) {
    return DateTime(now.year, now.month);
  }
  if (now.day <= recapDaysIntoNewMonth) {
    return DateTime(now.year, now.month - 1);
  }
  return null;
}

/// The most recent finished month at [now] — what an invalid recap route
/// falls back to.
DateTime previousMonth(DateTime now) => DateTime(now.year, now.month - 1);

/// How many months Settings' "Revisit a recap" picker offers.
const int recapRevisitMonths = 12;

/// The months Settings can reopen, newest first: this month (so far),
/// then the [recapRevisitMonths] - 1 before it.
List<DateTime> recapRevisitableMonths(DateTime now) => [
  for (var i = 0; i < recapRevisitMonths; i++)
    DateTime(now.year, now.month - i),
];

/// `yyyy-MM`, used as the recap route parameter.
String recapMonthKey(DateTime month) =>
    '${month.year.toString().padLeft(4, '0')}-'
    '${month.month.toString().padLeft(2, '0')}';

/// Parses [recapMonthKey]'s format; null for anything else.
DateTime? parseRecapMonthKey(String? key) {
  final match = RegExp(r'^(\d{4})-(\d{2})$').firstMatch(key ?? '');
  if (match == null) return null;
  // Both groups are non-optional, so they're always set once matched.
  final month = int.parse(match.group(2)!);
  if (month < 1 || month > 12) return null;
  return DateTime(int.parse(match.group(1)!), month);
}
