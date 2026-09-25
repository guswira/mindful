import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/spacing.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/glass_theme.dart';
import '../../../../shared/widgets/glass_bottom_sheet.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/unsynced_badge.dart';
import '../../domain/entry_type.dart';
import '../../domain/money_entry.dart';
import '../money_detail_sheet.dart';
import '../money_labels.dart';
import '../money_providers.dart';

/// The date range an [EntryList] filters to. Owns its own pill row and
/// filtering state — see SPEC.md Money Flow Feature Money Flow Tab, Entry
/// List.
enum _Period { today, week, month, all }

/// Money entries filtered by a glass pill period selector and grouped by
/// date, newest first. See SPEC.md Money Flow Feature Money Flow Tab,
/// Entry List.
class EntryList extends ConsumerStatefulWidget {
  const EntryList({super.key});

  @override
  ConsumerState<EntryList> createState() => _EntryListState();
}

class _EntryListState extends ConsumerState<EntryList> {
  _Period _period = _Period.month;

  static String _labelFor(AppLocalizations l10n, _Period period) =>
      switch (period) {
        _Period.today => l10n.commonToday,
        _Period.week => l10n.moneyPeriodThisWeek,
        _Period.month => l10n.moneyPeriodThisMonth,
        _Period.all => l10n.moneyPeriodAll,
      };

  DateTimeRange? _rangeFor(_Period period) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return switch (period) {
      _Period.today => DateTimeRange(start: today, end: today),
      _Period.week => DateTimeRange(
        start: today.subtract(Duration(days: today.weekday - 1)),
        end: today,
      ),
      _Period.month => DateTimeRange(
        start: DateTime(today.year, today.month, 1),
        end: today,
      ),
      _Period.all => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final entriesAsync = ref.watch(moneyEntriesProvider(_rangeFor(_period)));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PeriodPillRow(
          selected: _period,
          labelFor: (period) => _labelFor(context.l10n, period),
          onChanged: (period) => setState(() => _period = period),
        ),
        const SizedBox(height: Spacing.sm),
        switch (entriesAsync) {
          AsyncData(:final value) => _GroupedEntries(entries: value),
          AsyncError() => const SizedBox.shrink(),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ],
    );
  }
}

class _PeriodPillRow extends StatelessWidget {
  const _PeriodPillRow({
    required this.selected,
    required this.labelFor,
    required this.onChanged,
  });

  final _Period selected;
  final String Function(_Period) labelFor;
  final ValueChanged<_Period> onChanged;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return Wrap(
      spacing: Spacing.sm,
      runSpacing: Spacing.sm,
      children: [
        for (final period in _Period.values)
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

class _GroupedEntries extends StatelessWidget {
  const _GroupedEntries({required this.entries});

  final List<MoneyEntry> entries;

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
          _DateGroupHeader(group.key),
          const SizedBox(height: Spacing.xs),
          for (final entry in group.value) ...[
            _EntryCard(entry: entry),
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

class _DateGroupHeader extends StatelessWidget {
  const _DateGroupHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return Text(label, style: TextStyle(color: glass.textHint, fontSize: 12));
  }
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({required this.entry});

  final MoneyEntry entry;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final isSpending = entry.type == EntryType.spending;
    final color = isSpending ? glass.moneySpending : glass.moneyAccent;
    return GestureDetector(
      onTap: () => showGlassBottomSheet(
        context: context,
        builder: (_) => MoneyDetailSheet(entry: entry),
      ),
      child: GlassCard(
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: Text(
                categoryEmoji[entry.category] ?? '',
                style: const TextStyle(fontSize: 16),
              ),
            ),
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
                    DateFormat.MMMd().format(entry.date),
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
