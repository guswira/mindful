import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/spacing.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/glass_theme.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../domain/budget_settings.dart';
import '../../domain/budget_type.dart';
import '../money_providers.dart';

/// Compact home-screen card showing each configured budget's remaining
/// amount — a row per budget that's been set, or nothing at all if
/// neither has. See SPEC.md Money Flow Feature Home Screen integration.
class RemainingBudgetWidget extends ConsumerWidget {
  const RemainingBudgetWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthly = ref.watch(monthlyBudgetProvider).valueOrNull;
    final daily = ref.watch(dailyBudgetProvider).valueOrNull;
    final hasMonthly = monthly != null && monthly.amount > 0;
    final hasDaily = daily != null && daily.amount > 0;
    if (!hasMonthly && !hasDaily) {
      // Neither budget is set — bail out before watching
      // remainingBudgetProvider, which would otherwise reach into
      // MoneyRepository for no reason.
      return const SizedBox.shrink();
    }

    final remaining =
        ref.watch(remainingBudgetProvider).valueOrNull ?? const {};
    final rows = [
      if (monthly != null && hasMonthly)
        (
          type: BudgetType.monthly,
          settings: monthly,
          remaining: remaining[BudgetType.monthly] ?? 0,
        ),
      if (daily != null && hasDaily)
        (
          type: BudgetType.daily,
          settings: daily,
          remaining: remaining[BudgetType.daily] ?? 0,
        ),
    ];

    return GestureDetector(
      onTap: () => context.go('/home/money'),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            for (var i = 0; i < rows.length; i++) ...[
              if (i > 0) ...[
                const SizedBox(height: Spacing.sm),
                const Divider(color: Colors.white10, height: 1),
                const SizedBox(height: Spacing.sm),
              ],
              _BudgetRow(
                label: switch (rows[i].type) {
                  BudgetType.monthly => context.l10n.moneyMonthlyRemaining,
                  BudgetType.daily => context.l10n.moneyDailyRemaining,
                },
                settings: rows[i].settings,
                remaining: rows[i].remaining,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BudgetRow extends StatelessWidget {
  const _BudgetRow({
    required this.label,
    required this.settings,
    required this.remaining,
  });

  final String label;
  final BudgetSettings settings;
  final double remaining;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final progress = ((settings.amount - remaining) / settings.amount).clamp(
      0.0,
      1.0,
    );
    final color = remaining <= 0 ? Colors.redAccent : glass.moneyAccent;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: glass.textHint, fontSize: 12),
              ),
              Text(
                '${settings.currency} ${NumberFormat('#,##0').format(remaining)}',
                style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: Spacing.sm),
        SizedBox(
          width: 36,
          height: 36,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: progress,
                color: color,
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                strokeWidth: 3,
              ),
              Text(
                '${(progress * 100).round()}%',
                style: TextStyle(color: glass.textMuted, fontSize: 8),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
