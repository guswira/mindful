import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/money_repository.dart';
import '../domain/budget_settings.dart';
import '../domain/budget_type.dart';
import '../domain/money_entry.dart';

part 'money_providers.g.dart';

/// Every budget the signed-in user has saved, by period — a period with
/// no row is missing. A saved budget can still be 0; see
/// [activeBudgetsProvider] for the ones that are actually set.
@riverpod
Future<Map<BudgetType, BudgetSettings>> budgets(Ref ref) async {
  final repository = await ref.watch(moneyRepositoryProvider.future);
  return {
    for (final settings in repository.getAllBudgetSettings())
      settings.budgetType: settings,
  };
}

/// The budgets with an amount > 0, shortest period first — the ones the
/// Cashflow tab and home card show.
@riverpod
Future<Map<BudgetType, BudgetSettings>> activeBudgets(Ref ref) async {
  final all = await ref.watch(budgetsProvider.future);
  return {
    for (final type in BudgetType.values)
      if (all[type] case final settings? when settings.amount > 0)
        type: settings,
  };
}

/// The currency every budget is set in. See
/// [MoneyRepository.getCurrency].
@riverpod
Future<String> budgetCurrency(Ref ref) async {
  final repository = await ref.watch(moneyRepositoryProvider.future);
  return repository.getCurrency();
}

/// Money entries within [range] (inclusive), newest first. A null [range]
/// returns every cached entry.
@riverpod
Future<List<MoneyEntry>> moneyEntries(Ref ref, DateTimeRange? range) async {
  final repository = await ref.watch(moneyRepositoryProvider.future);
  return repository.getEntries(range: range);
}

/// Each budget type's remaining amount for its current period (amount −
/// spending + income), 0 for a type that hasn't been set. See
/// [MoneyRepository.getRemaining].
@riverpod
Future<Map<BudgetType, double>> remainingBudget(Ref ref) async {
  final repository = await ref.watch(moneyRepositoryProvider.future);
  return {
    for (final type in BudgetType.values) type: repository.getRemaining(type),
  };
}
