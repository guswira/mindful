import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/money_repository.dart';
import '../domain/budget_settings.dart';
import '../domain/budget_type.dart';
import '../domain/money_entry.dart';

part 'money_providers.g.dart';

/// The signed-in user's monthly budget, or null if it hasn't been set.
@riverpod
Future<BudgetSettings?> monthlyBudget(Ref ref) async {
  final repository = await ref.watch(moneyRepositoryProvider.future);
  return repository.getBudgetSettings(BudgetType.monthly);
}

/// The signed-in user's daily budget, or null if it hasn't been set.
@riverpod
Future<BudgetSettings?> dailyBudget(Ref ref) async {
  final repository = await ref.watch(moneyRepositoryProvider.future);
  return repository.getBudgetSettings(BudgetType.daily);
}

/// The currency both budgets are set in. See
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
