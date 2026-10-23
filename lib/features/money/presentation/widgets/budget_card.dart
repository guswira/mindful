import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/spacing.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/glass_theme.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/glass_icon_button.dart';
import '../../../../shared/widgets/intro_card.dart';
import '../../domain/budget_type.dart';
import '../budget_settings_sheet.dart';
import '../money_labels.dart';
import '../money_providers.dart';
import 'budget_progress_tile.dart';

/// One card for every configured budget (daily → yearly), two per row,
/// with a single gear to open the settings and a link to set the periods
/// that aren't yet — or an IntroCard explaining budgets if none is. Only
/// the first [collapsedCount] budgets show until expanded, so the card
/// doesn't push the entries off screen. See SPEC.md Money Flow Feature
/// Money Flow Tab, Budget Card.
class BudgetCard extends ConsumerStatefulWidget {
  const BudgetCard({super.key});

  /// Budgets shown before "Show more" — one row of the grid.
  static const collapsedCount = 2;

  @override
  ConsumerState<BudgetCard> createState() => _BudgetCardState();
}

class _BudgetCardState extends ConsumerState<BudgetCard> {
  bool _expanded = false;

  void _toggleExpanded() => setState(() => _expanded = !_expanded);

  @override
  Widget build(BuildContext context) {
    final saved = ref.watch(budgetsProvider).valueOrNull ?? const {};
    final active = ref.watch(activeBudgetsProvider).valueOrNull ?? const {};
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final l10n = context.l10n;

    void openSettings() => showBudgetSettingsSheet(context, settings: saved);

    if (active.isEmpty) {
      return IntroCard(
        icon: Icons.track_changes_rounded,
        color: glass.moneyAccent,
        title: l10n.moneyBudgetIntroTitle,
        body: l10n.moneyBudgetIntroBody,
        actionLabel: l10n.moneySetBudget,
        onAction: openSettings,
      );
    }

    final remaining =
        ref.watch(remainingBudgetProvider).valueOrNull ?? const {};
    final entries = active.entries.toList();
    final hiddenCount = entries.length - BudgetCard.collapsedCount;
    final visible = _expanded || hiddenCount <= 0
        ? entries
        : entries.take(BudgetCard.collapsedCount);
    final unset = [
      for (final type in BudgetType.values)
        if (!active.containsKey(type)) budgetTypeLabel(l10n, type),
    ];

    return GlassCard(
      strong: true,
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BudgetCardHeader(onSettings: openSettings),
          const SizedBox(height: Spacing.sm),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(right: 4),
              child: BudgetTileGrid(
                children: [
                  for (final MapEntry(key: type, value: settings) in visible)
                    BudgetProgressTile(
                      label: budgetTypeLabel(l10n, type),
                      settings: settings,
                      remaining: remaining[type] ?? 0,
                      showTotal: true,
                    ),
                ],
              ),
            ),
          ),
          if (hiddenCount > 0) ...[
            const SizedBox(height: Spacing.sm),
            _ExpandToggle(
              label: _expanded
                  ? l10n.moneyBudgetShowLess
                  : l10n.moneyBudgetShowMore(hiddenCount),
              expanded: _expanded,
              onTap: _toggleExpanded,
            ),
          ],
          if (unset.isNotEmpty) ...[
            const SizedBox(height: Spacing.md),
            _SetMoreLink(periods: unset.join(' · '), onTap: openSettings),
          ],
        ],
      ),
    );
  }
}

/// "Budget" title + the card's one settings gear.
class _BudgetCardHeader extends StatelessWidget {
  const _BudgetCardHeader({required this.onSettings});

  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            context.l10n.moneyBudgetHeading,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        GlassIconButton(
          icon: Icons.settings_outlined,
          size: 32,
          iconSize: 16,
          tooltip: context.l10n.moneyBudgetSettingsTooltip,
          onTap: onSettings,
        ),
      ],
    );
  }
}

/// "Show 2 more" / "Show less" under the tile grid.
class _ExpandToggle extends StatelessWidget {
  const _ExpandToggle({
    required this.label,
    required this.expanded,
    required this.onTap,
  });

  final String label;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                color: glass.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: Spacing.xs),
            Icon(
              expanded ? Icons.expand_less : Icons.expand_more,
              size: 18,
              color: glass.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

/// "+ Weekly · Yearly" — sets the periods that have no budget yet.
class _SetMoreLink extends StatelessWidget {
  const _SetMoreLink({required this.periods, required this.onTap});

  final String periods;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Icon(Icons.add_rounded, size: 16, color: glass.moneyAccent),
          const SizedBox(width: Spacing.xs),
          Flexible(
            child: Text(
              periods,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: glass.moneyAccent,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
