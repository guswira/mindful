import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/spacing.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/glass_theme.dart';
import '../../../../shared/widgets/glass_bottom_sheet.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/unsynced_badge.dart';
import '../../domain/budget_type.dart';
import '../../domain/entry_type.dart';
import '../../domain/entry_visibility.dart';
import '../../domain/money_entry.dart';
import '../../domain/money_partner.dart';
import '../money_detail_sheet.dart';
import '../money_labels.dart';

/// One money entry in the Money tab's list; tap → [MoneyDetailSheet].
///
/// With [owner] set the entry is the linked partner's: their initial
/// sits on the icon and the date line names them. [partnerLinked] tags
/// this user's own shared spending ("· Shared").
class EntryCard extends StatelessWidget {
  const EntryCard({
    required this.entry,
    this.owner,
    this.partnerLinked = false,
    super.key,
  });

  final MoneyEntry entry;

  /// The partner who recorded [entry]; null for this user's own.
  final MoneyPartner? owner;
  final bool partnerLinked;

  /// "Oct 26", plus the bill type ("Oct 1 · Monthly bill") for spending
  /// that skips the shorter budgets, then who it's with: the partner's
  /// name on theirs, "Shared" on this user's shared spending.
  String _dateLine(AppLocalizations l10n) => [
    DateFormat.MMMd().format(entry.date),
    if (entry.budgetPeriod case final period? when period != BudgetType.daily)
      budgetPeriodLabel(l10n, period),
    if (owner case final owner?)
      owner.firstName
    else if (partnerLinked && entry.visibility == EntryVisibility.shared)
      l10n.moneyVisibilitySharedTag,
  ].join(' · ');

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final isSpending = entry.type == EntryType.spending;
    final color = isSpending ? glass.moneySpending : glass.moneyAccent;
    return GestureDetector(
      onTap: () => showGlassBottomSheet(
        context: context,
        builder: (_) => MoneyDetailSheet(entry: entry, owner: owner),
      ),
      child: GlassCard(
        child: Row(
          children: [
            _CategoryCircle(entry: entry, color: color, owner: owner),
            const SizedBox(width: Spacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    categoryLabel(context.l10n, entry.category),
                    style: TextStyle(
                      color: glass.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (entry.note case final note? when note.isNotEmpty)
                    Text(
                      note,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: glass.textHint, fontSize: 12),
                    ),
                  Text(
                    _dateLine(context.l10n),
                    style: TextStyle(color: glass.textMuted, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(width: Spacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isSpending ? '-' : '+'}${NumberFormat('#,##0.00').format(entry.amount)}',
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: Spacing.xs),
                UnsyncedBadge(syncStatus: entry.syncStatus),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// The 36px category icon circle; a partner's entry gets their initial
/// in a small badge on its corner.
class _CategoryCircle extends StatelessWidget {
  const _CategoryCircle({
    required this.entry,
    required this.color,
    required this.owner,
  });

  final MoneyEntry entry;
  final Color color;
  final MoneyPartner? owner;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final circle = Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        shape: BoxShape.circle,
      ),
      child: Icon(categoryIcon(entry.category), size: 18, color: color),
    );
    final owner = this.owner;
    if (owner == null) {
      return circle;
    }
    return Stack(
      clipBehavior: Clip.none,
      children: [
        circle,
        Positioned(
          right: -4,
          bottom: -4,
          child: Container(
            width: 18,
            height: 18,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: glass.moneyAccent,
              shape: BoxShape.circle,
              border: Border.all(color: glass.background, width: 1.5),
            ),
            child: Text(
              owner.firstName.characters.first.toUpperCase(),
              style: TextStyle(
                color: glass.background,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
