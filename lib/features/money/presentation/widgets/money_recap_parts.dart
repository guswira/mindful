import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/spacing.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/glass_theme.dart';
import '../money_labels.dart';

/// Spending per category as labelled bars, largest first.
class CategoryBarChart extends StatelessWidget {
  const CategoryBarChart({
    required this.byCategory,
    required this.total,
    super.key,
  });

  final List<(String, double)> byCategory;
  final double total;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return Column(
      children: [
        for (final (category, amount) in byCategory) ...[
          CategoryBarRow(
            category: category,
            amount: amount,
            ratio: total <= 0 ? 0 : (amount / total).clamp(0.0, 1.0),
            color: glass.moneySpending,
          ),
          const SizedBox(height: Spacing.sm),
        ],
      ],
    );
  }
}

/// One category: icon, name, amount, its share ([ratio]) and its bar.
class CategoryBarRow extends StatelessWidget {
  const CategoryBarRow({
    required this.category,
    required this.amount,
    required this.ratio,
    required this.color,
    super.key,
  });

  final String category;
  final double amount;
  final double ratio;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(categoryIcon(category), size: 14, color: glass.textSecondary),
            const SizedBox(width: Spacing.xs),
            Expanded(
              child: Text(
                categoryLabel(context.l10n, category),
                style: TextStyle(color: glass.textSecondary, fontSize: 13),
              ),
            ),
            Text(
              NumberFormat('#,##0.00').format(amount),
              style: TextStyle(color: glass.textSecondary, fontSize: 13),
            ),
            const SizedBox(width: Spacing.xs),
            Text(
              '${(ratio * 100).round()}%',
              style: TextStyle(color: glass.textMuted, fontSize: 11),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: CustomPaint(
            size: const Size(double.infinity, 4),
            painter: BarPainter(ratio: ratio, color: color),
          ),
        ),
      ],
    );
  }
}

/// A 4px track with [ratio] of it filled — stronger the bigger the share.
class BarPainter extends CustomPainter {
  const BarPainter({required this.ratio, required this.color});

  final double ratio;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final trackPaint = Paint()..color = Colors.white.withValues(alpha: 0.08);
    canvas.drawRect(Offset.zero & size, trackPaint);
    final barPaint = Paint()
      ..color = color.withValues(alpha: 0.5 + 0.5 * ratio);
    canvas.drawRect(
      Offset.zero & Size(size.width * ratio, size.height),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(BarPainter oldDelegate) =>
      oldDelegate.ratio != ratio || oldDelegate.color != color;
}

/// A label on the left, an amount on the right in [color].
class SummaryRow extends StatelessWidget {
  const SummaryRow({
    required this.label,
    required this.value,
    required this.color,
    super.key,
    this.bold = false,
  });

  final String label;
  final double value;
  final Color color;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: glass.textSecondary,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          NumberFormat('#,##0.00').format(value),
          style: TextStyle(
            color: color,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
