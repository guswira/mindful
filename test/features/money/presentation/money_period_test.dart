import 'package:flutter_test/flutter_test.dart';

import 'package:mindful/features/money/presentation/money_period.dart';

void main() {
  // A Thursday.
  final now = DateTime(2026, 10, 22, 15, 30);

  test('today is just today', () {
    final range = MoneyPeriod.today.rangeEndingAt(now);
    expect(range?.start, DateTime(2026, 10, 22));
    expect(range?.end, DateTime(2026, 10, 22));
  });

  test('week starts on Monday', () {
    expect(MoneyPeriod.week.rangeEndingAt(now)?.start, DateTime(2026, 10, 19));
  });

  test('month starts on the 1st', () {
    expect(MoneyPeriod.month.rangeEndingAt(now)?.start, DateTime(2026, 10, 1));
  });

  test('all has no range', () {
    expect(MoneyPeriod.all.rangeEndingAt(now), isNull);
  });
}
