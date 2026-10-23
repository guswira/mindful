import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindful/core/theme/app_theme.dart';
import 'package:mindful/features/money/domain/budget_settings.dart';
import 'package:mindful/features/money/domain/budget_type.dart';
import 'package:mindful/features/money/presentation/money_providers.dart';
import 'package:mindful/features/money/presentation/widgets/remaining_budget_widget.dart';

BudgetSettings _budget(BudgetType type, double amount) => BudgetSettings(
  id: type.name,
  userId: 'u1',
  budgetType: type,
  amount: amount,
  currency: 'IDR',
  updatedAt: DateTime(2026, 1, 1),
);

void main() {
  Widget build(Map<BudgetType, BudgetSettings> budgets) => ProviderScope(
    overrides: [
      activeBudgetsProvider.overrideWith((ref) async => budgets),
      remainingBudgetProvider.overrideWith(
        (ref) async => {
          for (final MapEntry(key: type, value: b) in budgets.entries)
            type: b.amount / 2,
        },
      ),
    ],
    child: MaterialApp(
      theme: AppTheme.dark,
      home: const Scaffold(body: RemainingBudgetWidget()),
    ),
  );

  testWidgets('shows only the daily budget, with a link to the rest', (
    tester,
  ) async {
    await tester.pumpWidget(
      build({
        BudgetType.daily: _budget(BudgetType.daily, 200000),
        BudgetType.weekly: _budget(BudgetType.weekly, 1000000),
        BudgetType.monthly: _budget(BudgetType.monthly, 4000000),
        BudgetType.yearly: _budget(BudgetType.yearly, 45000000),
      }),
    );
    await tester.pumpAndSettle();

    expect(find.text('Daily remaining'), findsOneWidget);
    expect(find.text('IDR 100,000'), findsOneWidget);
    expect(find.text('Weekly remaining'), findsNothing);
    expect(find.text('Monthly remaining'), findsNothing);
    expect(find.text('Yearly remaining'), findsNothing);
    expect(find.text('view all'), findsOneWidget);
  });

  testWidgets('without a daily budget, shows the shortest one set', (
    tester,
  ) async {
    await tester.pumpWidget(
      build({
        BudgetType.monthly: _budget(BudgetType.monthly, 4000000),
        BudgetType.yearly: _budget(BudgetType.yearly, 45000000),
      }),
    );
    await tester.pumpAndSettle();

    expect(find.text('Monthly remaining'), findsOneWidget);
    expect(find.text('Yearly remaining'), findsNothing);
  });

  testWidgets('has Add spending and Add income buttons side by side', (
    tester,
  ) async {
    await tester.pumpWidget(
      build({BudgetType.daily: _budget(BudgetType.daily, 200000)}),
    );
    await tester.pumpAndSettle();

    final spending = tester.getCenter(find.text('Add spending'));
    final income = tester.getCenter(find.text('Add income'));
    expect(income.dy, spending.dy);
    expect(income.dx, greaterThan(spending.dx));
    // Below the budget.
    expect(
      spending.dy,
      greaterThan(tester.getCenter(find.text('Daily remaining')).dy),
    );
  });

  testWidgets('shows nothing when no budget is set', (tester) async {
    await tester.pumpWidget(build(const {}));
    await tester.pumpAndSettle();

    expect(find.textContaining('remaining'), findsNothing);
    expect(find.text('Add spending'), findsNothing);
  });
}
