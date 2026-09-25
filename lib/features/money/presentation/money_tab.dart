import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/glass_theme.dart';
import '../../../shared/widgets/blob_background.dart';
import '../../../shared/widgets/glass_bottom_sheet.dart';
import '../../../shared/widgets/tinted_pill.dart';
import '../domain/entry_type.dart';
import 'add_money_sheet.dart';
import 'widgets/budget_card.dart';
import 'widgets/entry_list.dart';
import 'widgets/recap_section.dart';

/// Budget gauge, quick add buttons, filtered entry list and a spending
/// recap. See SPEC.md Money Flow Feature Money Flow Tab.
class MoneyTab extends StatelessWidget {
  const MoneyTab({super.key});

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return Scaffold(
      backgroundColor: glass.background,
      body: RepaintBoundary(
        child: BlobBackground(
          child: SafeArea(
            bottom: false,
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const _MoneyTabHeader(),
                      const SizedBox(height: 16),
                      const BudgetCard(),
                      const SizedBox(height: 16),
                      const _AddButtonsRow(),
                      const SizedBox(height: 16),
                      const RecapSection(),
                      const SizedBox(height: 16),
                      const EntryList(),
                      const SizedBox(height: 88),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MoneyTabHeader extends StatelessWidget {
  const _MoneyTabHeader();

  @override
  Widget build(BuildContext context) {
    return Text(
      context.l10n.moneyTabTitle,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
}

class _AddButtonsRow extends StatelessWidget {
  const _AddButtonsRow();

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return Row(
      children: [
        Expanded(
          child: Center(
            child: TintedPill(
              label: context.l10n.moneyAddSpending,
              color: glass.moneySpending,
              onTap: () => showGlassBottomSheet(
                context: context,
                builder: (_) => const AddMoneySheet(),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Center(
            child: TintedPill(
              label: context.l10n.moneyAddIncome,
              color: glass.moneyAccent,
              onTap: () => showGlassBottomSheet(
                context: context,
                builder: (_) =>
                    const AddMoneySheet(defaultType: EntryType.income),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
