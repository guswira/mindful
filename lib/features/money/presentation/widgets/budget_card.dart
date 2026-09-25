import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/spacing.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/glass_theme.dart';
import '../../../../shared/widgets/dashed_border_container.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/glass_icon_button.dart';
import '../../../../shared/widgets/tinted_pill.dart';
import '../../data/money_repository.dart';
import '../../domain/budget_settings.dart';
import '../../domain/budget_type.dart';
import '../../domain/entry_type.dart';
import '../../domain/money_entry.dart';
import '../budget_settings_sheet.dart';
import '../money_labels.dart';
import '../money_providers.dart';

/// Monthly and daily budget gauges side by side — a ghost "set budget"
/// card stands in for whichever one hasn't been configured yet, and a
/// single full-width prompt replaces both if neither has. See SPEC.md
/// Money Flow Feature Money Flow Tab, Budget Card.
class BudgetCard extends ConsumerWidget {
  const BudgetCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthly = ref.watch(monthlyBudgetProvider).valueOrNull;
    final daily = ref.watch(dailyBudgetProvider).valueOrNull;
    final monthlySet = monthly != null && monthly.amount > 0 ? monthly : null;
    final dailySet = daily != null && daily.amount > 0 ? daily : null;
    final l10n = context.l10n;

    void openSettings() => showBudgetSettingsSheet(
      context,
      monthlySettings: monthly,
      dailySettings: daily,
    );

    if (monthlySet == null && dailySet == null) {
      return GlassCard(
        strong: true,
        child: _EmptyBudgetRow(onSetBudget: openSettings),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: monthlySet != null
              ? _BudgetGaugeCard(
                  type: BudgetType.monthly,
                  label: budgetTypeLabel(l10n, BudgetType.monthly),
                  settings: monthlySet,
                  onTap: openSettings,
                )
              : _SetBudgetGhostCard(
                  title: l10n.moneyMonthlyBudget,
                  pillLabel: l10n.moneySetMonthly,
                  onTap: openSettings,
                ),
        ),
        const SizedBox(width: Spacing.sm),
        Expanded(
          child: dailySet != null
              ? _BudgetGaugeCard(
                  type: BudgetType.daily,
                  label: budgetTypeLabel(l10n, BudgetType.daily),
                  settings: dailySet,
                  onTap: openSettings,
                )
              : _SetBudgetGhostCard(
                  title: l10n.moneyDailyBudget,
                  pillLabel: l10n.moneySetDaily,
                  onTap: openSettings,
                ),
        ),
      ],
    );
  }
}

class _EmptyBudgetRow extends StatelessWidget {
  const _EmptyBudgetRow({required this.onSetBudget});

  final VoidCallback onSetBudget;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return Row(
      children: [
        Expanded(
          child: Text(
            context.l10n.moneyEmptyBudgetPrompt,
            style: TextStyle(color: glass.textSecondary, fontSize: 14),
          ),
        ),
        const SizedBox(width: Spacing.sm),
        TintedPill(
          label: context.l10n.moneySetBudget,
          color: glass.moneyAccent,
          onTap: onSetBudget,
        ),
      ],
    );
  }
}

/// A dashed placeholder standing in for a budget type that hasn't been
/// configured yet, on the other side of the [Row] from the one that has.
class _SetBudgetGhostCard extends StatelessWidget {
  const _SetBudgetGhostCard({
    required this.title,
    required this.pillLabel,
    required this.onTap,
  });

  /// e.g. "Monthly budget".
  final String title;

  /// e.g. "Set Monthly".
  final String pillLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return GestureDetector(
      onTap: onTap,
      child: DashedBorderContainer(
        padding: const EdgeInsets.symmetric(
          vertical: Spacing.md,
          horizontal: Spacing.sm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: TextStyle(color: glass.textMuted, fontSize: 12)),
            const SizedBox(height: Spacing.sm),
            TintedPill(
              label: pillLabel,
              color: glass.moneyAccent,
              onTap: onTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetGaugeCard extends ConsumerWidget {
  const _BudgetGaugeCard({
    required this.type,
    required this.label,
    required this.settings,
    required this.onTap,
  });

  final BudgetType type;
  final String label;
  final BudgetSettings settings;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final l10n = context.l10n;
    final repository = ref.watch(moneyRepositoryProvider).valueOrNull;
    if (repository == null) {
      return const SizedBox.shrink();
    }

    final range = repository.getPeriodRange(type);
    final entries =
        ref.watch(moneyEntriesProvider(range)).valueOrNull ?? const [];
    final spent = _sum(entries, EntryType.spending);
    // Income is only reflected in the recap, not in a budget's remaining
    // amount — see MoneyRepository.getRemaining.
    final remaining = settings.amount - spent;
    final progress = (spent / settings.amount).clamp(0.0, 1.0);
    final gaugeColor = progress >= 1.0
        ? Colors.redAccent
        : progress >= 0.8
        ? glass.accentAmber
        : glass.moneyAccent;

    return GlassCard(
      strong: true,
      padding: const EdgeInsets.all(12),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: glass.textHint, fontSize: 12),
              ),
              const SizedBox(height: Spacing.xs),
              Text(
                '${settings.currency} ${NumberFormat('#,##0').format(spent)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                l10n.moneyBudgetOf(
                  settings.currency,
                  NumberFormat('#,##0').format(settings.amount),
                ),
                style: TextStyle(color: glass.textMuted, fontSize: 11),
              ),
              const SizedBox(height: Spacing.sm),
              Center(
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: progress,
                        color: gaugeColor,
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        strokeWidth: 4,
                      ),
                      Text(
                        progress >= 1.0
                            ? l10n.moneyGaugeOver
                            : '${(100 - progress * 100).round()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Spacing.sm),
              Text(
                l10n.moneyAmountLeft(
                  settings.currency,
                  NumberFormat('#,##0').format(remaining),
                ),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: remaining < 0 ? Colors.redAccent : glass.moneyAccent,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: GlassIconButton(
              icon: Icons.settings_outlined,
              size: 28,
              iconSize: 14,
              onTap: onTap,
            ),
          ),
        ],
      ),
    );
  }

  static double _sum(List<MoneyEntry> entries, EntryType type) {
    var total = 0.0;
    for (final entry in entries) {
      if (entry.type == type) {
        total += entry.amount;
      }
    }
    return total;
  }
}
