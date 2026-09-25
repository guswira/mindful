import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/spacing.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/glass_theme.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/tinted_pill.dart';
import '../../data/money_repository.dart';
import '../../domain/budget_type.dart';
import '../../domain/entry_type.dart';
import '../../domain/money_entry.dart';
import '../money_advice_flow.dart';
import '../money_labels.dart';
import '../money_providers.dart';

/// Collapsible spending-by-category breakdown, income vs. spending
/// summary, top category — for the current budget period — and an AI
/// advice button covering every entry. See
/// SPEC.md Money Flow Feature Money Flow Tab, Recap Section.
class RecapSection extends ConsumerWidget {
  const RecapSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final l10n = context.l10n;
    final repositoryAsync = ref.watch(moneyRepositoryProvider);
    final repository = repositoryAsync.valueOrNull;
    if (repository == null) {
      return const SizedBox.shrink();
    }

    // The recap always covers the current month, independent of whether
    // a monthly budget is actually set — it's a general spending
    // breakdown, not tied to either budget's own period.
    final range = repository.getPeriodRange(BudgetType.monthly);
    // Watched so the recap refreshes after a save/delete invalidates
    // moneyEntriesProvider, same as the rest of the tab.
    ref.watch(moneyEntriesProvider(range));
    final entries = repository.getEntries(range: range);
    final spendingByCategory = _byCategory(entries, EntryType.spending);
    final totalSpending = repository.getTotalSpending(range: range);
    final totalIncome = repository.getTotalIncome(range: range);
    final net = totalIncome - totalSpending;
    // Advice covers every entry, not just this month's, so it's offered
    // whenever there's any history at all.
    final hasAnyEntries = repository.getEntries().isNotEmpty;

    return GlassCard(
      strong: true,
      padding: EdgeInsets.zero,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            l10n.moneyRecapTitle,
            style: TextStyle(
              color: glass.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          iconColor: glass.textMuted,
          collapsedIconColor: glass.textMuted,
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            if (spendingByCategory.isEmpty)
              Text(
                l10n.moneyRecapNoSpending,
                style: TextStyle(color: glass.textMuted, fontSize: 13),
              )
            else
              _CategoryBarChart(
                byCategory: spendingByCategory,
                total: totalSpending,
              ),
            const SizedBox(height: Spacing.md),
            const Divider(color: Colors.white10, height: 1),
            const SizedBox(height: Spacing.md),
            _SummaryRow(
              label: entryTypeLabel(l10n, EntryType.income),
              value: totalIncome,
              color: glass.moneyAccent,
            ),
            const SizedBox(height: Spacing.xs),
            _SummaryRow(
              label: entryTypeLabel(l10n, EntryType.spending),
              value: totalSpending,
              color: glass.moneySpending,
            ),
            const SizedBox(height: Spacing.sm),
            _SummaryRow(
              label: l10n.moneyRecapNet,
              value: net,
              color: net >= 0 ? glass.moneyAccent : Colors.redAccent,
              bold: true,
            ),
            if (spendingByCategory.isNotEmpty) ...[
              const SizedBox(height: Spacing.sm),
              Text(
                l10n.moneyRecapTopCategory(
                  categoryEmoji[spendingByCategory.first.$1] ?? '',
                  categoryLabel(l10n, spendingByCategory.first.$1),
                ),
                style: TextStyle(color: glass.textMuted, fontSize: 12),
              ),
            ],
            if (hasAnyEntries) ...[
              const SizedBox(height: Spacing.md),
              Align(
                alignment: Alignment.centerLeft,
                child: TintedPill(
                  label: l10n.moneyAdviceButton,
                  color: glass.aiAccent,
                  onTap: () => requestMoneyAdvice(context),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static List<(String, double)> _byCategory(
    List<MoneyEntry> entries,
    EntryType type,
  ) {
    final totals = <String, double>{};
    for (final entry in entries) {
      if (entry.type == type) {
        totals[entry.category] = (totals[entry.category] ?? 0) + entry.amount;
      }
    }
    final sorted = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return [for (final e in sorted) (e.key, e.value)];
  }
}

class _CategoryBarChart extends StatelessWidget {
  const _CategoryBarChart({required this.byCategory, required this.total});

  final List<(String, double)> byCategory;
  final double total;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return Column(
      children: [
        for (final (category, amount) in byCategory) ...[
          _CategoryBarRow(
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

class _CategoryBarRow extends StatelessWidget {
  const _CategoryBarRow({
    required this.category,
    required this.amount,
    required this.ratio,
    required this.color,
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
            Text(
              categoryEmoji[category] ?? '',
              style: const TextStyle(fontSize: 13),
            ),
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
            painter: _BarPainter(ratio: ratio, color: color),
          ),
        ),
      ],
    );
  }
}

class _BarPainter extends CustomPainter {
  const _BarPainter({required this.ratio, required this.color});

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
  bool shouldRepaint(_BarPainter oldDelegate) =>
      oldDelegate.ratio != ratio || oldDelegate.color != color;
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    required this.color,
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
