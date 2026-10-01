import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/l10n.dart';
import '../../recap/domain/recap_window.dart';
import '../../recap/presentation/monthly_recap_screen.dart';

/// Settings' "Revisit a recap" menu: pick any recent month (this one so
/// far, or one of the [recapRevisitMonths] - 1 before it) and replay its
/// slideshow — the home banner only offers it around month end.
class MonthlyRecapSection extends StatelessWidget {
  const MonthlyRecapSection({super.key});

  Future<void> _pickMonth(BuildContext context) async {
    final month = await showModalBottomSheet<DateTime>(
      context: context,
      builder: (context) => const _MonthPicker(),
    );
    if (month == null || !context.mounted) return;
    await openMonthlyRecap(context, month);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListTile(
      leading: const Icon(Icons.auto_graph_rounded),
      title: Text(l10n.settingsRecapRevisit),
      subtitle: Text(l10n.settingsRecapRevisitSubtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _pickMonth(context),
    );
  }
}

class _MonthPicker extends StatelessWidget {
  const _MonthPicker();

  /// "October 2026 (so far)" for the current month, "September 2026" else.
  static String _label(AppLocalizations l10n, DateTime month, DateTime now) {
    final name = DateFormat.yMMMM().format(month);
    final inProgress = month.year == now.year && month.month == now.month;
    return inProgress ? l10n.settingsRecapSoFar(name) : name;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final now = DateTime.now();
    final months = recapRevisitableMonths(now);
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(
              l10n.settingsRecapPickerTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: months.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(_label(l10n, months[index], now)),
                onTap: () => Navigator.pop(context, months[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
