import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/spacing.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/glass_theme.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../domain/entry_type.dart';
import '../../domain/money_entry.dart';
import '../../domain/money_partner.dart';
import '../money_partner_providers.dart';
import '../money_period.dart';
import '../money_providers.dart';
import '../partner/money_partner_flow.dart';
import 'money_recap_parts.dart';

/// This month's spending side by side with the linked partner — yours
/// (all of it), theirs (shared) and together. Hidden while not linked;
/// tap → [PartnerSheet]. See SPEC.md Money Flow Feature Linked partner.
class PartnerSpendingCard extends ConsumerWidget {
  const PartnerSpendingCard({super.key});

  static double _spending(List<MoneyEntry>? entries) => (entries ?? const [])
      .where((entry) => entry.type == EntryType.spending)
      .fold(0, (sum, entry) => sum + entry.amount);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final partner = ref.watch(moneyPartnerProvider).valueOrNull;
    if (partner == null) {
      return const SizedBox.shrink();
    }
    final range = MoneyPeriod.month.rangeEndingAt(DateTime.now());
    final mine = _spending(ref.watch(moneyEntriesProvider(range)).valueOrNull);
    final theirs = _spending(
      ref.watch(partnerEntriesProvider(range)).valueOrNull,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.md),
      child: GestureDetector(
        onTap: () => openMoneyPartner(context, partner),
        child: GlassCard(
          child: _Totals(partner: partner, mine: mine, theirs: theirs),
        ),
      ),
    );
  }
}

class _Totals extends StatelessWidget {
  const _Totals({
    required this.partner,
    required this.mine,
    required this.theirs,
  });

  final MoneyPartner partner;
  final double mine;
  final double theirs;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.people_outline, size: 18, color: glass.moneyAccent),
            const SizedBox(width: Spacing.sm),
            Expanded(
              child: Text(
                l10n.moneyTogetherTitle(partner.firstName),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 18, color: glass.textMuted),
          ],
        ),
        const SizedBox(height: Spacing.sm),
        SummaryRow(
          label: l10n.moneyTogetherYou,
          value: mine,
          color: glass.moneySpending,
        ),
        const SizedBox(height: Spacing.xs),
        SummaryRow(
          label: l10n.moneyTogetherPartner(partner.firstName),
          value: theirs,
          color: glass.moneySpending,
        ),
        const SizedBox(height: Spacing.sm),
        SummaryRow(
          label: l10n.moneyTogetherTotal,
          value: mine + theirs,
          color: glass.moneySpending,
          bold: true,
        ),
      ],
    );
  }
}
