import 'package:flutter_test/flutter_test.dart';

import 'package:mindful/features/recap/domain/recap_window.dart';

void main() {
  group('recapMonthForBanner', () {
    test('offers the current month in its last 3 days', () {
      expect(recapMonthForBanner(DateTime(2026, 9, 28)), DateTime(2026, 9));
      expect(recapMonthForBanner(DateTime(2026, 9, 30)), DateTime(2026, 9));
      expect(recapMonthForBanner(DateTime(2026, 2, 26)), DateTime(2026, 2));
    });

    test('keeps offering the previous month through the 3rd', () {
      expect(recapMonthForBanner(DateTime(2026, 10, 1)), DateTime(2026, 9));
      expect(recapMonthForBanner(DateTime(2026, 10, 3)), DateTime(2026, 9));
      expect(recapMonthForBanner(DateTime(2027, 1, 3)), DateTime(2026, 12));
    });

    test('is null mid-month', () {
      expect(recapMonthForBanner(DateTime(2026, 10, 4)), isNull);
      expect(recapMonthForBanner(DateTime(2026, 9, 27)), isNull);
      expect(recapMonthForBanner(DateTime(2026, 2, 25)), isNull);
    });
  });

  test('the revisit menu offers this month and the 11 before it', () {
    final months = recapRevisitableMonths(DateTime(2026, 3, 15));
    expect(months, hasLength(12));
    expect(months.first, DateTime(2026, 3));
    expect(months.last, DateTime(2025, 4));
  });

  test('month keys round-trip and reject garbage', () {
    expect(recapMonthKey(DateTime(2026, 3)), '2026-03');
    expect(parseRecapMonthKey('2026-03'), DateTime(2026, 3));
    expect(parseRecapMonthKey('2026-13'), isNull);
    expect(parseRecapMonthKey('march'), isNull);
    expect(parseRecapMonthKey(null), isNull);
  });
}
