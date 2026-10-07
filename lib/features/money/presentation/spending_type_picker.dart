import 'package:flutter/material.dart';

import '../../../core/constants/spacing.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/glass_theme.dart';
import '../domain/budget_type.dart';
import 'money_labels.dart';

/// The spending-type chips on [AddMoneySheet] — Everyday / Weekly bill /
/// Monthly bill / Yearly bill — plus a line on which budgets the pick
/// counts toward. Everyday is a null [selected].
class SpendingTypePicker extends StatelessWidget {
  const SpendingTypePicker({
    required this.selected,
    required this.onChanged,
    super.key,
  });

  /// Everyday first; daily isn't offered on its own since it's the same.
  static const List<BudgetType?> options = [
    null,
    BudgetType.weekly,
    BudgetType.monthly,
    BudgetType.yearly,
  ];

  final BudgetType? selected;
  final ValueChanged<BudgetType?> onChanged;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.moneySpendingTypeHeading,
          style: TextStyle(color: glass.textHint, fontSize: 12),
        ),
        const SizedBox(height: Spacing.sm),
        Wrap(
          spacing: Spacing.sm,
          runSpacing: Spacing.sm,
          children: [
            for (final option in options)
              _SpendingTypeChip(
                label: budgetPeriodLabel(l10n, option),
                active: option == selected,
                onTap: () => onChanged(option),
              ),
          ],
        ),
        const SizedBox(height: Spacing.xs),
        Text(
          budgetPeriodHint(l10n, selected),
          style: TextStyle(color: glass.textMuted, fontSize: 12),
        ),
      ],
    );
  }
}

class _SpendingTypeChip extends StatelessWidget {
  const _SpendingTypeChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final color = glass.moneySpending;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active
              ? color.withValues(alpha: 0.18)
              : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active
                ? color.withValues(alpha: 0.25)
                : Colors.white.withValues(alpha: 0.12),
            width: 0.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : glass.textSecondary,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
