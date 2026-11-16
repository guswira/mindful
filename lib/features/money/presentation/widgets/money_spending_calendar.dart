import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/spacing.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/glass_theme.dart';
import '../../../../shared/widgets/month_calendar.dart';
import '../../data/money_repository.dart';
import '../money_months.dart';
import '../money_providers.dart';

/// [month]'s days tinted by how much was spent on each; tapping a day
/// shows its total spending below the grid (tap again to clear). Used by
/// the cashflow history sheet.
class MoneySpendingCalendar extends ConsumerStatefulWidget {
  const MoneySpendingCalendar({required this.month, super.key});

  /// Any day of the month to show.
  final DateTime month;

  @override
  ConsumerState<MoneySpendingCalendar> createState() =>
      _MoneySpendingCalendarState();
}

class _MoneySpendingCalendarState extends ConsumerState<MoneySpendingCalendar> {
  DateTime? _selected;

  void _toggleDay(DateTime day) =>
      setState(() => _selected = day == _selected ? null : day);

  Map<DateTime, double> _dailySpending() {
    final range = moneyMonthRange(widget.month, DateTime.now());
    // Watched so a save/delete (which invalidates the family) repaints.
    ref.watch(moneyEntriesProvider(range));
    final repository = ref.watch(moneyRepositoryProvider).valueOrNull;
    if (repository == null) {
      return const {};
    }
    return moneyDailySpending(
      repository.getEntries(range: range),
      widget.month,
    );
  }

  /// 25% → 75% alpha relative to the month's biggest day; 0 = none spent.
  static double _tint(double spent, double maxSpent) =>
      spent <= 0 || maxSpent <= 0 ? 0 : 0.25 + 0.5 * (spent / maxSpent);

  String _summary(AppLocalizations l10n, Map<DateTime, double> byDay) {
    final selected = _selected;
    if (selected == null) {
      return l10n.moneyRecapDayHint;
    }
    final date = DateFormat.MMMd().format(selected);
    final spent = byDay[selected];
    if (spent == null) {
      return l10n.moneyRecapDayEmpty(date);
    }
    return l10n.moneyRecapDaySpent(
      date,
      NumberFormat('#,##0.00').format(spent),
    );
  }

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final byDay = _dailySpending();
    final maxSpent = byDay.values.fold<double>(0, math.max);
    return Column(
      children: [
        MonthCalendarGrid(
          month: DateTime(widget.month.year, widget.month.month),
          today: DateUtils.dateOnly(DateTime.now()),
          accent: glass.moneySpending,
          tintFor: (day) => _tint(byDay[day] ?? 0, maxSpent),
          selected: _selected,
          onDayTap: _toggleDay,
        ),
        const SizedBox(height: Spacing.sm),
        Text(
          _summary(context.l10n, byDay),
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: glass.textSecondary),
        ),
      ],
    );
  }
}
