import 'package:flutter/material.dart';

import '../../../core/constants/spacing.dart';
import '../../../core/l10n/l10n.dart';
import '../../../shared/widgets/month_calendar.dart';
import 'widgets/money_month_recap.dart';
import 'widgets/money_spending_calendar.dart';

/// Earlier months' cashflow recaps, one month at a time — a calendar of
/// each day's spending over the recap, with its own AI advice. Opened from the Money tab's Recap "Previous months"
/// link. See SPEC.md Money Flow Feature Money Flow Tab, Recap Section.
class MoneyRecapHistorySheet extends StatefulWidget {
  const MoneyRecapHistorySheet({required this.months, super.key});

  /// The months to page through (each as its 1st), newest first — only
  /// months with entries, so paging never lands on an empty one.
  final List<DateTime> months;

  @override
  State<MoneyRecapHistorySheet> createState() => _MoneyRecapHistorySheetState();
}

class _MoneyRecapHistorySheetState extends State<MoneyRecapHistorySheet> {
  /// Index into [MoneyRecapHistorySheet.months]; 0 = last month with data.
  int _index = 0;

  bool get _hasOlder => _index < widget.months.length - 1;

  void _showOlder() => setState(() => _index++);

  void _showNewer() => setState(() => _index--);

  @override
  Widget build(BuildContext context) {
    final month = widget.months[_index];
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.l10n.moneyRecapHistoryTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: Spacing.sm),
          MonthCalendarHeader(
            month: month,
            onPrevious: _hasOlder ? _showOlder : null,
            onNext: _index > 0 ? _showNewer : null,
          ),
          MoneySpendingCalendar(
            key: ValueKey((#calendar, month)),
            month: month,
          ),
          const SizedBox(height: Spacing.md),
          MoneyMonthRecap(key: ValueKey(month), month: month),
        ],
      ),
    );
  }
}
