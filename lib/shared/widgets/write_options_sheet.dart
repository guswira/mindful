import 'package:flutter/material.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/glass_theme.dart';
import '../../features/habits/presentation/add_habit_sheet.dart';
import '../../features/journal/presentation/add_journal_sheet.dart';
import '../../features/money/presentation/add_money_sheet.dart';
import '../../features/tasks/presentation/add_task_sheet.dart';
import 'glass_bottom_sheet.dart';

/// Shows the write sheet's 4 options (journal/task/habit/money) as a modal
/// over [context] — used by `WriteButton` and by the medium widget's
/// pencil button (`mindful://open-write-sheet`). See SPEC.md Floating
/// Island Nav Bar, Home and Lock Screen Widgets, and Money Flow Feature
/// Write menu.
///
/// Each option reuses its tab's nav bar icon and accent color so the menu
/// reads as the same feature the user would land on in the nav.
void showWriteOptionsSheet(BuildContext context) {
  final glass = Theme.of(context).extension<GlassTheme>()!;
  final l10n = context.l10n;
  showGlassBottomSheet<void>(
    context: context,
    builder: (sheetContext) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _WriteOption(
          icon: Icons.menu_book_outlined,
          color: glass.journalAccent,
          label: l10n.writeNewJournalEntry,
          onTap: () => _open(sheetContext, context, const AddJournalSheet()),
        ),
        _WriteOption(
          icon: Icons.checklist_outlined,
          color: glass.taskAccent,
          label: l10n.writeNewTask,
          onTap: () => _open(sheetContext, context, const AddTaskSheet()),
        ),
        _WriteOption(
          icon: Icons.calendar_month_outlined,
          color: glass.habitAccent,
          label: l10n.writeNewHabit,
          onTap: () => _open(sheetContext, context, const AddHabitSheet()),
        ),
        _WriteOption(
          icon: Icons.account_balance_wallet_outlined,
          color: glass.moneyAccent,
          label: l10n.writeNewMoneyEntry,
          onTap: () => _open(sheetContext, context, const AddMoneySheet()),
        ),
      ],
    ),
  );
}

/// Closes the write sheet, then opens [sheet] over the original [context]
/// (the write sheet's own context is gone once it's popped).
void _open(BuildContext sheetContext, BuildContext context, Widget sheet) {
  Navigator.pop(sheetContext);
  showGlassBottomSheet<void>(context: context, builder: (_) => sheet);
}

class _WriteOption extends StatelessWidget {
  const _WriteOption({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color, size: 22),
      title: Text(label),
      onTap: onTap,
    );
  }
}
