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

  testWidgets('lays four budgets out two per row', (tester) async {
    await tester.pumpWidget(
      build({
        BudgetType.daily: _budget(BudgetType.daily, 200000),
        BudgetType.weekly: _budget(BudgetType.weekly, 1000000),
        BudgetType.monthly: _budget(BudgetType.monthly, 4000000),
        BudgetType.yearly: _budget(BudgetType.yearly, 45000000),
      }),
    );
    await tester.pumpAndSettle();

    final daily = tester.getTopLeft(find.text('Daily remaining'));
    final weekly = tester.getTopLeft(find.text('Weekly remaining'));
    final monthly = tester.getTopLeft(find.text('Monthly remaining'));
    final yearly = tester.getTopLeft(find.text('Yearly remaining'));
    expect(weekly.dy, daily.dy);
    expect(weekly.dx, greaterThan(daily.dx));
    expect(monthly.dy, greaterThan(daily.dy));
    expect(monthly.dx, daily.dx);
    expect(yearly.dy, monthly.dy);
    expect(find.text('IDR 22,500,000'), findsOneWidget);
    expect(find.text('50%'), findsNWidgets(4));
  });

  testWidgets('shows nothing when no budget is set', (tester) async {
    await tester.pumpWidget(build(const {}));
    await tester.pumpAndSettle();

    expect(find.textContaining('remaining'), findsNothing);
  });
}
