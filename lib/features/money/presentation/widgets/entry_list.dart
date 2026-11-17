import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/spacing.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/glass_theme.dart';
import '../../../../shared/widgets/glass_bottom_sheet.dart';
import '../../../../shared/widgets/intro_card.dart';
import '../../domain/entry_type.dart';
import '../../domain/money_entry.dart';
import '../../domain/money_partner.dart';
import '../add_money_sheet.dart';
import '../money_partner_providers.dart';
import '../money_period.dart';
import '../money_providers.dart';
import 'grouped_entries.dart';

/// Money entries filtered by a glass pill period selector and grouped by
/// date, newest first. See SPEC.md Money Flow Feature Money Flow Tab,
/// Entry List.
class EntryList extends ConsumerWidget {
  const EntryList({super.key});

  static String _labelFor(AppLocalizations l10n, MoneyPeriod period) =>
      switch (period) {
        MoneyPeriod.today => l10n.commonToday,
        MoneyPeriod.week => l10n.moneyPeriodThisWeek,
        MoneyPeriod.month => l10n.moneyPeriodThisMonth,
        MoneyPeriod.all => l10n.moneyPeriodAll,
      };

  static String _scopeLabel(
    AppLocalizations l10n,
    MoneyScope scope,
    MoneyPartner partner,
  ) => switch (scope) {
    MoneyScope.together => l10n.moneyScopeTogether,
    MoneyScope.mine => l10n.moneyScopeMine,
    MoneyScope.partner => partner.firstName,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(moneyPeriodProvider);
    final partner = ref.watch(moneyPartnerProvider).valueOrNull;
    final scope = partner == null
        ? MoneyScope.mine
        : ref.watch(moneyScopeProvider);
    final allEntries = ref.watch(moneyEntriesProvider(null)).valueOrNull;
    // Nothing recorded at all (and no partner's to show) — the intro
    // replaces the pills and an empty list, which would have nothing to
    // filter.
    if (partner == null && allEntries != null && allEntries.isEmpty) {
      return const _SpendingIntro();
    }
    final noSpending =
        allEntries != null &&
        !allEntries.any((entry) => entry.type == EntryType.spending);
    final entriesAsync = _visibleEntries(
      ref,
      period.rangeEndingAt(DateTime.now()),
      scope,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (noSpending) ...[
          const _SpendingIntro(),
          const SizedBox(height: Spacing.md),
        ],
        if (partner != null) ...[
          _PillRow<MoneyScope>(
            values: MoneyScope.values,
            selected: scope,
            labelFor: (scope) => _scopeLabel(context.l10n, scope, partner),
            onChanged: ref.read(moneyScopeProvider.notifier).select,
          ),
          const SizedBox(height: Spacing.sm),
        ],
        _PillRow<MoneyPeriod>(
          values: MoneyPeriod.values,
          selected: period,
          labelFor: (period) => _labelFor(context.l10n, period),
          onChanged: ref.read(moneyPeriodProvider.notifier).select,
        ),
        const SizedBox(height: Spacing.sm),
        switch (entriesAsync) {
          AsyncData(:final value) => GroupedEntries(
            entries: value,
            partner: partner,
          ),
          AsyncError() => const SizedBox.shrink(),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ],
    );
  }

  /// This user's and/or the partner's entries in [range], per [scope],
  /// newest first.
  static AsyncValue<List<MoneyEntry>> _visibleEntries(
    WidgetRef ref,
    DateTimeRange? range,
    MoneyScope scope,
  ) {
    const none = AsyncData<List<MoneyEntry>>([]);
    final mine = scope == MoneyScope.partner
        ? none
        : ref.watch(moneyEntriesProvider(range));
    final theirs = scope == MoneyScope.mine
        ? none
        : ref.watch(partnerEntriesProvider(range));
    return switch ((mine, theirs)) {
      (AsyncData(value: final a), AsyncData(value: final b)) => AsyncData(
        [...a, ...b]..sort(_newestFirst),
      ),
      (AsyncError(:final error, :final stackTrace), _) ||
      (
        _,
        AsyncError(:final error, :final stackTrace),
      ) => AsyncError(error, stackTrace),
      _ => const AsyncLoading(),
    };
  }

  static int _newestFirst(MoneyEntry a, MoneyEntry b) {
    final byDate = b.date.compareTo(a.date);
    return byDate != 0 ? byDate : b.createdAt.compareTo(a.createdAt);
  }
}

/// Shown until the first spending entry is recorded.
class _SpendingIntro extends StatelessWidget {
  const _SpendingIntro();

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final l10n = context.l10n;
    return IntroCard(
      icon: Icons.account_balance_wallet_outlined,
      color: glass.moneyAccent,
      title: l10n.moneySpendingIntroTitle,
      body: l10n.moneySpendingIntroBody,
      actionLabel: l10n.moneySpendingIntroAction,
      onAction: () => showGlassBottomSheet(
        context: context,
        builder: (_) => const AddMoneySheet(),
      ),
    );
  }
}

/// A Wrap of glass pills, one per value; the selected one moneyAccent.
class _PillRow<T> extends StatelessWidget {
  const _PillRow({
    required this.values,
    required this.selected,
    required this.labelFor,
    required this.onChanged,
  });

  final List<T> values;
  final T selected;
  final String Function(T) labelFor;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return Wrap(
      spacing: Spacing.sm,
      runSpacing: Spacing.sm,
      children: [
        for (final period in values)
          GestureDetector(
            onTap: () => onChanged(period),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: period == selected
                    ? glass.moneyAccent.withValues(alpha: 0.18)
                    : Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: period == selected
                      ? glass.moneyAccent.withValues(alpha: 0.25)
                      : Colors.white.withValues(alpha: 0.12),
                  width: 0.5,
                ),
              ),
              child: Text(
                labelFor(period),
                style: TextStyle(
                  color: period == selected
                      ? glass.moneyAccent
                      : glass.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
