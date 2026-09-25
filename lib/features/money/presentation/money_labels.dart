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

/// "Monthly" / "Daily".
String budgetTypeLabel(AppLocalizations l10n, BudgetType type) =>
    switch (type) {
      BudgetType.monthly => l10n.moneyBudgetMonthly,
      BudgetType.daily => l10n.moneyBudgetDaily,
    };
