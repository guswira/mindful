import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mindful/features/money/data/money_repository.dart';
import 'package:mindful/features/money/domain/budget_settings.dart';
import 'package:mindful/features/money/domain/budget_type.dart';
import 'package:mindful/features/money/domain/entry_type.dart';
import 'package:mindful/features/money/domain/money_entry.dart';

class _MockBox extends Mock implements Box<dynamic> {}

MoneyEntry _entry({
  required String id,
  required EntryType type,
  required double amount,
  required DateTime date,
}) => MoneyEntry(
  id: id,
  userId: 'u1',
  type: type,
  amount: amount,
  category: 'Other',
  date: date,
  createdAt: date,
  updatedAt: date,
);

void main() {
  late _MockBox entriesBox;
  late _MockBox settingsBox;
  late MoneyRepository repository;

  // The current date (truncated) — getPeriodRange/getRemaining always
  // measure against DateTime.now(), so fixture entries are dated "today"
  // rather than a fixed calendar date.
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  setUp(() {
    entriesBox = _MockBox();
    settingsBox = _MockBox();
    repository = MoneyRepository(
      entriesBox: entriesBox,
      settingsBox: settingsBox,
    );
  });

  group('getRemaining', () {
    test('subtracts this period\'s spending but ignores income', () {
      final settings = BudgetSettings(
        id: 'b1',
        userId: 'u1',
        budgetType: BudgetType.monthly,
        amount: 1000,
        currency: 'USD',
        updatedAt: today,
      );
      when(
        () => settingsBox.get('settings_monthly'),
      ).thenReturn(settings.toJson());
      when(() => entriesBox.values).thenReturn([
        _entry(
          id: 'e1',
          type: EntryType.spending,
          amount: 200,
          date: today,
        ).toJson(),
        _entry(
          id: 'e2',
          type: EntryType.income,
          amount: 5000,
          date: today,
        ).toJson(),
      ]);

      // 1000 - 200 spending; the 5000 income is not added back.
      expect(repository.getRemaining(BudgetType.monthly), 800);
    });

    test('returns 0 when that budget type has not been set', () {
      when(() => settingsBox.get('settings_daily')).thenReturn(null);
      when(() => entriesBox.values).thenReturn(const <dynamic>[]);

      expect(repository.getRemaining(BudgetType.daily), 0);
    });
  });
}
