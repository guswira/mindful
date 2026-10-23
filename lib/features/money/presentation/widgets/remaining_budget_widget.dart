import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/spacing.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/glass_theme.dart';
import '../../../../shared/widgets/glass_bottom_sheet.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/tinted_pill.dart';
import '../../domain/budget_settings.dart';
import '../../domain/budget_type.dart';
import '../../domain/entry_type.dart';
import '../add_money_sheet.dart';
import '../money_labels.dart';
import '../money_providers.dart';
import 'budget_progress_tile.dart';

/// Compact home-screen card: today's (daily) remaining budget with a
/// "view all" link to the Money tab for the rest, and quick Add spending /
/// Add income buttons below it. Nothing at all if no budget is set. See
/// SPEC.md Money Flow Feature Home Screen integration.
class RemainingBudgetWidget extends ConsumerWidget {
  const RemainingBudgetWidget({super.key});

  /// The budget the card shows: daily, or — without one — the shortest
  /// one that is set (active budgets are ordered daily → yearly).
  static MapEntry<BudgetType, BudgetSettings> _shown(
    Map<BudgetType, BudgetSettings> active,
  ) {
    final daily = active[BudgetType.daily];
    return daily != null
        ? MapEntry(BudgetType.daily, daily)
        : active.entries.first;
  }

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
    final MapEntry(key: type, value: settings) = _shown(active);
    return GestureDetector(
      onTap: () => context.go('/home/money'),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: BudgetProgressTile(
                    label: budgetRemainingLabel(context.l10n, type),
                    settings: settings,
                    remaining: remaining[type] ?? 0,
                  ),
                ),
                const SizedBox(width: Spacing.md),
                const _ViewAllLink(),
              ],
            ),
            const SizedBox(height: Spacing.md),
            const _AddMoneyButtons(),
          ],
        ),
      ),
    );
  }
}

/// "view all ›" — the other budgets, entries and recap live on the Money
/// tab.
class _ViewAllLink extends StatelessWidget {
  const _ViewAllLink();

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).extension<GlassTheme>()!.textMuted;
    return GestureDetector(
      onTap: () => context.go('/home/money'),
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.l10n.commonViewAll,
            style: TextStyle(color: muted, fontSize: 13),
          ),
          Icon(Icons.chevron_right_rounded, color: muted, size: 18),
        ],
      ),
    );
  }
}

/// Add spending / Add income, side by side.
class _AddMoneyButtons extends StatelessWidget {
  const _AddMoneyButtons();

  void _open(BuildContext context, EntryType type) => showGlassBottomSheet(
    context: context,
    builder: (_) => AddMoneySheet(defaultType: type),
  );

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final l10n = context.l10n;
    return Row(
      children: [
        Expanded(
          child: TintedPill(
            label: l10n.writeAddSpending,
            icon: Icons.trending_down_rounded,
            color: glass.moneySpending,
            onTap: () => _open(context, EntryType.spending),
          ),
        ),
        const SizedBox(width: Spacing.sm),
        Expanded(
          child: TintedPill(
            label: l10n.writeAddIncome,
            icon: Icons.trending_up_rounded,
            color: glass.moneyAccent,
            onTap: () => _open(context, EntryType.income),
          ),
        ),
      ],
    );
  }
}
