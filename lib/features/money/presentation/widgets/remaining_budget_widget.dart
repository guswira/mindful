import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../money_labels.dart';
import '../money_providers.dart';
import 'budget_progress_tile.dart';

/// Compact home-screen card showing each configured budget's remaining
/// amount — a 2-column grid of the budgets that are set (daily → yearly),
/// or nothing at all if none is. See SPEC.md Money Flow Feature Home
/// Screen integration.
class RemainingBudgetWidget extends ConsumerWidget {
  const RemainingBudgetWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(activeBudgetsProvider).valueOrNull ?? const {};
    if (active.isEmpty) {
      // No budget is set — bail out before watching
      // remainingBudgetProvider, which would otherwise reach into
      // MoneyRepository for no reason.
      return const SizedBox.shrink();
    }

    final remaining =
        ref.watch(remainingBudgetProvider).valueOrNull ?? const {};
    return GestureDetector(
      onTap: () => context.go('/home/money'),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: BudgetTileGrid(
          children: [
            for (final MapEntry(key: type, value: settings) in active.entries)
              BudgetProgressTile(
                label: budgetRemainingLabel(context.l10n, type),
                settings: settings,
                remaining: remaining[type] ?? 0,
              ),
          ],
        ),
      ),
    );
  }
}
