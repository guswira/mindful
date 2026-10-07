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
  BudgetType? budgetPeriod,
}) => MoneyEntry(
  id: id,
  userId: 'u1',
  type: type,
  amount: amount,
  category: 'Other',
  budgetPeriod: budgetPeriod,
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

    test('a bill only counts toward budgets at least as long as it', () {
      for (final type in BudgetType.values) {
        final settings = BudgetSettings(
          id: 'b-${type.name}',
          userId: 'u1',
          budgetType: type,
          amount: 1000,
          currency: 'USD',
          updatedAt: today,
        );
        when(
          () => settingsBox.get('settings_${type.name}'),
        ).thenReturn(settings.toJson());
      }
      when(() => entriesBox.values).thenReturn([
        for (final (i, (period, amount)) in [
          (null, 10.0),
          (BudgetType.weekly, 20.0),
          (BudgetType.monthly, 40.0),
          (BudgetType.yearly, 80.0),
        ].indexed)
          _entry(
            id: 'e$i',
            type: EntryType.spending,
            amount: amount,
            date: today,
            budgetPeriod: period,
          ).toJson(),
      ]);

      // Everyday spending only.
      expect(repository.getRemaining(BudgetType.daily), 990);
      // + the weekly bill.
      expect(repository.getRemaining(BudgetType.weekly), 970);
      // + the monthly bill, but not the yearly one.
      expect(repository.getRemaining(BudgetType.monthly), 930);
      // Everything.
      expect(repository.getRemaining(BudgetType.yearly), 850);
    });

    test('returns 0 when that budget type has not been set', () {
      when(() => settingsBox.get('settings_daily')).thenReturn(null);
      when(() => entriesBox.values).thenReturn(const <dynamic>[]);

      expect(repository.getRemaining(BudgetType.daily), 0);
    });
  });
}
