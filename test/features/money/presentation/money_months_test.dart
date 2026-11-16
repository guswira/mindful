import 'package:flutter_test/flutter_test.dart';

import 'package:mindful/features/money/presentation/money_months.dart';

void main() {
  final now = DateTime(2026, 11, 9, 15, 30);

  group('moneyMonthRange', () {
    test('a past month covers every day of it', () {
      final range = moneyMonthRange(DateTime(2026, 2, 14), now);
      expect(range.start, DateTime(2026, 2));
      expect(range.end, DateTime(2026, 2, 28));
    });

    test('the month in progress ends today', () {
      final range = moneyMonthRange(now, now);
      expect(range.start, DateTime(2026, 11));
      expect(range.end, DateTime(2026, 11, 9));
    });
  });

  group('moneyHistoryMonths', () {
    test('earlier months with entries, newest first, deduplicated', () {
      final months = moneyHistoryMonths([
        DateTime(2026, 9, 3),
        DateTime(2026, 11, 2),
        DateTime(2025, 12, 31),
        DateTime(2026, 9, 28),
      ], now);
      expect(months, [DateTime(2026, 9), DateTime(2025, 12)]);
    });

    test('nothing before this month → empty', () {
      expect(moneyHistoryMonths([DateTime(2026, 11, 1)], now), isEmpty);
    });
  });
}
