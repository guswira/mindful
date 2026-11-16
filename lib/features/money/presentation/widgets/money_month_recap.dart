import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/spacing.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/glass_theme.dart';
import '../../../../shared/widgets/tinted_pill.dart';
import '../../data/money_repository.dart';
import '../../domain/entry_type.dart';
import '../../domain/money_entry.dart';
import '../money_advice_flow.dart';
import '../money_labels.dart';
import '../money_months.dart';
import '../money_providers.dart';
import 'money_recap_parts.dart';

/// One month's cashflow recap: spending by category, income vs.
/// spending, net, top category, and an AI advice button for that month
/// (only when it has entries). Shared by the Money tab's [RecapSection]
/// (this month) and the cashflow history sheet (earlier months). See
/// SPEC.md Money Flow Feature Money Flow Tab, Recap Section.
class MoneyMonthRecap extends ConsumerWidget {
  const MoneyMonthRecap({required this.month, this.leading, super.key});

  /// Any day of the month to recap.
  final DateTime month;

  /// Shown at the start of the AI advice row (e.g. the history link).
  final Widget? leading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final l10n = context.l10n;
    final repository = ref.watch(moneyRepositoryProvider).valueOrNull;
    if (repository == null) {
      return const SizedBox.shrink();
    }
    final range = moneyMonthRange(month, DateTime.now());
    // Watched so the recap refreshes after a save/delete invalidates
    // moneyEntriesProvider, same as the rest of the tab.
    ref.watch(moneyEntriesProvider(range));
    final entries = repository.getEntries(range: range);
    final spendingByCategory = _byCategory(entries, EntryType.spending);
    final totalSpending = repository.getTotalSpending(range: range);
    final totalIncome = repository.getTotalIncome(range: range);
    final net = totalIncome - totalSpending;
    final showAdvice = entries.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (spendingByCategory.isEmpty)
          Text(
            l10n.moneyRecapNoSpending,
            style: TextStyle(color: glass.textMuted, fontSize: 13),
          )
        else
          CategoryBarChart(
            byCategory: spendingByCategory,
            total: totalSpending,
          ),
        const SizedBox(height: Spacing.md),
        const Divider(color: Colors.white10, height: 1),
        const SizedBox(height: Spacing.md),
        SummaryRow(
          label: entryTypeLabel(l10n, EntryType.income),
          value: totalIncome,
          color: glass.moneyAccent,
        ),
        const SizedBox(height: Spacing.xs),
        SummaryRow(
          label: entryTypeLabel(l10n, EntryType.spending),
          value: totalSpending,
          color: glass.moneySpending,
        ),
        const SizedBox(height: Spacing.sm),
        SummaryRow(
          label: l10n.moneyRecapNet,
          value: net,
          color: net >= 0 ? glass.moneyAccent : Colors.redAccent,
          bold: true,
        ),
        if (spendingByCategory.isNotEmpty) ...[
          const SizedBox(height: Spacing.sm),
          Text(
            l10n.moneyRecapTopCategory(
              categoryLabel(l10n, spendingByCategory.first.$1),
            ),
            style: TextStyle(color: glass.textMuted, fontSize: 12),
          ),
        ],
        if (leading != null || showAdvice) ...[
          const SizedBox(height: Spacing.md),
          Row(
            children: [
              ?leading,
              const Spacer(),
              if (showAdvice)
                TintedPill(
                  label: l10n.moneyAdviceButton,
                  icon: Icons.auto_awesome_outlined,
                  color: glass.aiAccent,
                  onTap: () => requestMoneyAdvice(context, month: month),
                ),
            ],
          ),
        ],
      ],
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
