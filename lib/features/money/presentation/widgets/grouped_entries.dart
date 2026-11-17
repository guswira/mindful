import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/spacing.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/glass_theme.dart';
import '../../domain/entry_type.dart';
import '../../domain/money_entry.dart';
import '../../domain/money_partner.dart';
import 'entry_card.dart';

/// [entries] grouped by day under a header with the day's totals, newest
/// first. Entries whose owner is [partner] are drawn as theirs.
class GroupedEntries extends StatelessWidget {
  const GroupedEntries({required this.entries, this.partner, super.key});

  final List<MoneyEntry> entries;

  /// The linked partner, if any.
  final MoneyPartner? partner;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      final glass = Theme.of(context).extension<GlassTheme>()!;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: Spacing.lg),
        child: Center(
          child: Text(
            context.l10n.moneyNoEntriesInPeriod,
            style: TextStyle(color: glass.textMuted),
          ),
        ),
      );
    }

    final l10n = context.l10n;
    final groups = <String, List<MoneyEntry>>{};
    for (final entry in entries) {
      groups.putIfAbsent(_groupLabel(l10n, entry.date), () => []).add(entry);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final group in groups.entries) ...[
          _DateGroupHeader(label: group.key, entries: group.value),
          const SizedBox(height: Spacing.xs),
          for (final entry in group.value) ...[
            EntryCard(
              entry: entry,
              owner: entry.userId == partner?.id ? partner : null,
              partnerLinked: partner != null,
            ),
            const SizedBox(height: Spacing.sm),
          ],
          const SizedBox(height: Spacing.xs),
        ],
      ],
    );
  }

  static String _groupLabel(AppLocalizations l10n, DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);
    if (day == today) {
      return l10n.commonToday;
    }
    if (day == today.subtract(const Duration(days: 1))) {
      return l10n.commonYesterday;
    }
    return DateFormat('EEE, MMM d').format(day);
  }
}

/// The day's label, with what was spent (and earned, if anything) that
/// day on the right — every entry, bills included.
class _DateGroupHeader extends StatelessWidget {
  const _DateGroupHeader({required this.label, required this.entries});

  final String label;
  final List<MoneyEntry> entries;

  double _total(EntryType type) => entries
      .where((entry) => entry.type == type)
      .fold(0, (sum, entry) => sum + entry.amount);

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final format = NumberFormat('#,##0.00');
    final spent = _total(EntryType.spending);
    final earned = _total(EntryType.income);
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(color: glass.textHint, fontSize: 12),
          ),
        ),
        if (earned > 0)
          Text(
            '+${format.format(earned)}',
            style: TextStyle(color: glass.moneyAccent, fontSize: 12),
          ),
        if (earned > 0 && spent > 0) const SizedBox(width: Spacing.sm),
        if (spent > 0)
          Text(
            '-${format.format(spent)}',
            style: TextStyle(color: glass.moneySpending, fontSize: 12),
          ),
      ],
    );
  }
}
