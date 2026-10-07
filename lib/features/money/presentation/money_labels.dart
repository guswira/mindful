import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';
import '../domain/budget_type.dart';
import '../domain/entry_type.dart';

/// Display label for a money [category]. Categories are persisted in
/// English (see `spendingCategories`/`incomeCategories`), so only the label
/// is translated; an unknown value falls back to the raw stored string.
String categoryLabel(AppLocalizations l10n, String category) =>
    switch (category) {
      'Food' => l10n.moneyCategoryFood,
      'Transport' => l10n.moneyCategoryTransport,
      'Shopping' => l10n.moneyCategoryShopping,
      'Health' => l10n.moneyCategoryHealth,
      'Entertainment' => l10n.moneyCategoryEntertainment,
      'Bills' => l10n.moneyCategoryBills,
      'Education' => l10n.moneyCategoryEducation,
      'Travel' => l10n.moneyCategoryTravel,
      'Other' => l10n.moneyCategoryOther,
      'Salary' => l10n.moneyCategorySalary,
      'Freelance' => l10n.moneyCategoryFreelance,
      'Investment' => l10n.moneyCategoryInvestment,
      'Gift' => l10n.moneyCategoryGift,
      _ => category,
    };

/// "Spending" / "Income".
String entryTypeLabel(AppLocalizations l10n, EntryType type) => switch (type) {
  EntryType.spending => l10n.moneyTypeSpending,
  EntryType.income => l10n.moneyTypeIncome,
};

/// "Daily" / "Weekly" / "Monthly" / "Yearly".
String budgetTypeLabel(AppLocalizations l10n, BudgetType type) =>
    switch (type) {
      BudgetType.daily => l10n.moneyBudgetDaily,
      BudgetType.weekly => l10n.moneyBudgetWeekly,
      BudgetType.monthly => l10n.moneyBudgetMonthly,
      BudgetType.yearly => l10n.moneyBudgetYearly,
    };

/// "Daily budget" etc. — a section title on [BudgetSettingsSheet] and the
/// Cashflow tab's "set budget" card.
String budgetTitle(AppLocalizations l10n, BudgetType type) => switch (type) {
  BudgetType.daily => l10n.moneyDailyBudget,
  BudgetType.weekly => l10n.moneyWeeklyBudget,
  BudgetType.monthly => l10n.moneyMonthlyBudget,
  BudgetType.yearly => l10n.moneyYearlyBudget,
};

/// "Daily remaining" etc. — a row on the home screen's budget card.
String budgetRemainingLabel(AppLocalizations l10n, BudgetType type) =>
    switch (type) {
      BudgetType.daily => l10n.moneyDailyRemaining,
      BudgetType.weekly => l10n.moneyWeeklyRemaining,
      BudgetType.monthly => l10n.moneyMonthlyRemaining,
      BudgetType.yearly => l10n.moneyYearlyRemaining,
    };

/// "Save daily" etc. — a section's save pill on [BudgetSettingsSheet].
String budgetSaveLabel(AppLocalizations l10n, BudgetType type) =>
    switch (type) {
      BudgetType.daily => l10n.moneySaveDaily,
      BudgetType.weekly => l10n.moneySaveWeekly,
      BudgetType.monthly => l10n.moneySaveMonthly,
      BudgetType.yearly => l10n.moneySaveYearly,
    };

/// Spending-type chip label for a [MoneyEntry.budgetPeriod] — null is an
/// everyday expense.
String budgetPeriodLabel(AppLocalizations l10n, BudgetType? period) =>
    switch (period) {
      null || BudgetType.daily => l10n.moneySpendingTypeEveryday,
      BudgetType.weekly => l10n.moneySpendingTypeWeekly,
      BudgetType.monthly => l10n.moneySpendingTypeMonthly,
      BudgetType.yearly => l10n.moneySpendingTypeYearly,
    };

/// One line on which budgets a spending entry with [period] counts toward.
String budgetPeriodHint(AppLocalizations l10n, BudgetType? period) =>
    switch (period) {
      null || BudgetType.daily => l10n.moneySpendingTypeEverydayHint,
      BudgetType.weekly => l10n.moneySpendingTypeWeeklyHint,
      BudgetType.monthly => l10n.moneySpendingTypeMonthlyHint,
      BudgetType.yearly => l10n.moneySpendingTypeYearlyHint,
    };

/// Flat icon for a money [category]; a generic one for unknown values.
IconData categoryIcon(String category) => switch (category) {
  'Food' => Icons.restaurant_rounded,
  'Transport' => Icons.directions_car_outlined,
  'Shopping' => Icons.shopping_bag_outlined,
  'Health' => Icons.health_and_safety_outlined,
  'Entertainment' => Icons.movie_outlined,
  'Bills' => Icons.receipt_long_outlined,
  'Education' => Icons.school_outlined,
  'Travel' => Icons.flight_outlined,
  'Salary' => Icons.work_outline_rounded,
  'Freelance' => Icons.laptop_mac_outlined,
  'Investment' => Icons.trending_up_rounded,
  'Gift' => Icons.card_giftcard_outlined,
  _ => Icons.category_outlined,
};
