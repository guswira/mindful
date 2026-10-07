import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/spacing.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/glass_theme.dart';
import '../../domain/budget_settings.dart';

/// One budget at a glance: label, what's left, and a thin bar of how much
/// is used. Shared by the home card and the Cashflow tab so both read the
/// same way.
class BudgetProgressTile extends StatelessWidget {
  const BudgetProgressTile({
    required this.label,
    required this.settings,
    required this.remaining,
    this.showTotal = false,
    super.key,
  });

  final String label;
  final BudgetSettings settings;
  final double remaining;

  /// Adds "of IDR 1.000.000" under the bar (Cashflow tab).
  final bool showTotal;

  /// Share of the budget used, 0–1.
  double get _used =>
      ((settings.amount - remaining) / settings.amount).clamp(0.0, 1.0);

  /// Same thresholds as before: calm under 80%, amber to 99%, red when
  /// used up.
  static Color _barColor(GlassTheme glass, double used) => switch (used) {
    >= 1.0 => Colors.redAccent,
    >= 0.8 => glass.accentAmber,
    _ => glass.moneyAccent,
  };

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final format = NumberFormat('#,##0');
    final used = _used;
    final barColor = _barColor(glass, used);
    final amountColor = remaining <= 0 ? Colors.redAccent : glass.moneyAccent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: glass.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            '${settings.currency} ${format.format(remaining)}',
            style: TextStyle(
              color: amountColor,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: Spacing.sm),
        _UsedBar(used: used, color: barColor),
        if (showTotal) ...[
          const SizedBox(height: Spacing.xs),
          Text(
            context.l10n.moneyBudgetOf(
              settings.currency,
              format.format(settings.amount),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: glass.textMuted, fontSize: 11),
          ),
        ],
      ],
    );
  }
}

/// A 4px rounded bar + the used % to its right.
class _UsedBar extends StatelessWidget {
  const _UsedBar({required this.used, required this.color});

  final double used;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: used,
              minHeight: 4,
              color: color,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
            ),
          ),
        ),
        const SizedBox(width: Spacing.sm),
        Text(
          '${(used * 100).round()}%',
          style: TextStyle(color: glass.textMuted, fontSize: 11),
        ),
      ],
    );
  }
}

/// [children] two per row at equal widths; an odd last one keeps its half
/// width.
class BudgetTileGrid extends StatelessWidget {
  const BudgetTileGrid({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < children.length; i += 2) ...[
          if (i > 0) const SizedBox(height: Spacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: children[i]),
              const SizedBox(width: Spacing.lg),
              Expanded(
                child: i + 1 < children.length
                    ? children[i + 1]
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
