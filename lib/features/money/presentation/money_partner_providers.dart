import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/money_partner_repository.dart';
import '../domain/money_entry.dart';
import '../domain/money_partner.dart';
import 'money_providers.dart';

// Hand-written providers — see SPEC.md Stack decisions, Code generation.

/// The linked partner from the cache, or null when not linked.
final moneyPartnerProvider = FutureProvider<MoneyPartner?>((ref) async {
  final repository = await ref.watch(moneyPartnerRepositoryProvider.future);
  return repository.getPartner();
});

/// The partner's shared spending within the range (inclusive), newest
/// first; null = all of it. Empty when not linked.
final partnerEntriesProvider =
    FutureProvider.family<List<MoneyEntry>, DateTimeRange?>((ref, range) async {
      final repository = await ref.watch(moneyPartnerRepositoryProvider.future);
      return repository.getEntries(range: range);
    });

/// Reloads the partner and their spending from Supabase, then everything
/// that shows them (incl. budgets, which count shared spending). Throws
/// when Supabase is unreachable — the cache stays as it was.
Future<void> refreshMoneyPartner(ProviderContainer container) async {
  final repository = await container.read(
    moneyPartnerRepositoryProvider.future,
  );
  await repository.refresh();
  invalidateMoneyPartner(container);
}

/// Invalidates every provider showing the partner or their spending.
void invalidateMoneyPartner(ProviderContainer container) {
  container
    ..invalidate(moneyPartnerProvider)
    ..invalidate(partnerEntriesProvider)
    ..invalidate(remainingBudgetProvider);
}

/// Whose spending the Money tab's entry list shows while linked.
enum MoneyScope { mine, partner, together }

/// Holds the selected [MoneyScope], kept while the app runs.
class MoneyScopeController extends Notifier<MoneyScope> {
  @override
  MoneyScope build() => MoneyScope.together;

  /// Switches the entry list to [scope].
  void select(MoneyScope scope) => state = scope;
}

/// The Money tab's selected scope (only shown while linked).
final moneyScopeProvider = NotifierProvider<MoneyScopeController, MoneyScope>(
  MoneyScopeController.new,
);
