import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/glass_theme.dart';
import '../../../../shared/widgets/glass_bottom_sheet.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../data/money_repository.dart';
import '../money_months.dart';
import '../money_providers.dart';
import '../money_recap_history_sheet.dart';
import 'money_month_recap.dart';

/// Collapsible cashflow recap of this month, with a link to earlier
/// months' recaps (each with its own AI advice). See SPEC.md Money Flow
/// Feature Money Flow Tab, Recap Section.
class RecapSection extends ConsumerWidget {
  const RecapSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final now = DateTime.now();
    final historyMonths = _historyMonths(ref, now);

    return GlassCard(
      strong: true,
      padding: EdgeInsets.zero,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            context.l10n.moneyRecapTitle,
            style: TextStyle(
              color: glass.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            DateFormat.yMMMM().format(now),
            style: TextStyle(color: glass.textMuted, fontSize: 12),
          ),
          iconColor: glass.textMuted,
          collapsedIconColor: glass.textMuted,
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            MoneyMonthRecap(
              month: now,
              leading: historyMonths.isEmpty
                  ? null
                  : _HistoryLink(
                      onTap: () => _openHistory(context, historyMonths),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  List<DateTime> _historyMonths(WidgetRef ref, DateTime now) {
    // Watched so a save/delete (which invalidates the whole family)
    // adds or drops a month.
    ref.watch(moneyEntriesProvider(null));
    final repository = ref.watch(moneyRepositoryProvider).valueOrNull;
    if (repository == null) {
      return const [];
    }
    return moneyHistoryMonths(
      repository.getEntries().map((entry) => entry.date),
      now,
    );
  }

  void _openHistory(BuildContext context, List<DateTime> months) {
    showGlassBottomSheet<void>(
      context: context,
      builder: (_) => MoneyRecapHistorySheet(months: months),
    );
  }
}

class _HistoryLink extends StatelessWidget {
  const _HistoryLink({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history_rounded, size: 16, color: glass.textSecondary),
            const SizedBox(width: 4),
            Text(
              context.l10n.moneyRecapHistory,
              style: TextStyle(color: glass.textSecondary, fontSize: 13),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: glass.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
