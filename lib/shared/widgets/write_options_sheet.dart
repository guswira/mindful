import 'package:flutter/material.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/glass_theme.dart';
import '../../features/habits/presentation/add_habit_sheet.dart';
import '../../features/journal/domain/journal_entry.dart';
import '../../features/journal/presentation/add_journal_sheet.dart';
import '../../features/journal/presentation/journal_labels.dart';
import '../../features/money/domain/entry_type.dart';
import '../../features/money/presentation/add_money_sheet.dart';
import '../../features/tasks/presentation/add_task_sheet.dart';
import 'glass_bottom_sheet.dart';

/// The shell tabs, by [FloatingNavBar] index, whose write menu is narrowed
/// to that tab's own items. Any other tab (Home, AI) or none (the home
/// widget's pencil) gets every item.
abstract final class WriteMenuTab {
  static const int tasks = 1;
  static const int mindfulness = 2;
  static const int money = 3;
  static const int ai = 4;
}

/// The write button's gradient on the tab at [tabIndex]: that tab's
/// accent, fading into a slightly deeper shade of it (yellow → amber,
/// blue → sky). Home keeps the original writeAccent → Color(0xFF0EB8DF).
List<Color> writeButtonGradient(GlassTheme glass, int? tabIndex) {
  final accent = switch (tabIndex) {
    WriteMenuTab.tasks => glass.taskAccent,
    WriteMenuTab.mindfulness => glass.journalAccent,
    WriteMenuTab.money => glass.moneyAccent,
    WriteMenuTab.ai => glass.aiAccent,
    _ => null,
  };
  if (accent == null) {
    return [glass.writeAccent, const Color(0xFF0EB8DF)];
  }
  final hsl = HSLColor.fromColor(accent);
  final end = hsl
      .withHue((hsl.hue - 12) % 360)
      .withLightness((hsl.lightness - 0.10).clamp(0, 1));
  return [accent, end.toColor()];
}

/// One item of the write menu: its icon + accent, label, and the add
/// sheet it opens.
typedef WriteOption = ({
  IconData icon,
  Color color,
  String label,
  Widget sheet,
});

/// The write menu for the tab at [tabIndex] — see SPEC.md Floating Island
/// Nav Bar. Shared by the tap sheet and the long-press arc, in this order.
List<WriteOption> writeOptionsFor(BuildContext context, int? tabIndex) {
  final glass = Theme.of(context).extension<GlassTheme>()!;
  final l10n = context.l10n;
  final WriteOption routine = (
    icon: Icons.calendar_month_outlined,
    color: glass.habitAccent,
    label: l10n.writeNewHabit,
    sheet: const AddHabitSheet(),
  );
  final WriteOption task = (
    icon: Icons.checklist_outlined,
    color: glass.taskAccent,
    label: l10n.writeNewTask,
    sheet: const AddTaskSheet(),
  );
  WriteOption journal(JournalType type, String label) => (
    icon: journalTypeIcon(type),
    color: glass.journalAccent,
    label: label,
    sheet: AddJournalSheet(initialType: type),
  );
  WriteOption money(EntryType type, String label, Color color) => (
    icon: switch (type) {
      EntryType.spending => Icons.trending_down_rounded,
      EntryType.income => Icons.trending_up_rounded,
    },
    color: color,
    label: label,
    sheet: AddMoneySheet(defaultType: type),
  );

  return switch (tabIndex) {
    WriteMenuTab.tasks => [routine, task],
    WriteMenuTab.mindfulness => [
      journal(JournalType.plan, l10n.writeTodayPlan),
      journal(JournalType.review, l10n.writeReviewToday),
      journal(JournalType.gratitude, l10n.writeGratitude),
    ],
    WriteMenuTab.money => [
      money(EntryType.spending, l10n.writeAddSpending, glass.moneySpending),
      money(EntryType.income, l10n.writeAddIncome, glass.moneyAccent),
    ],
    _ => [
      routine,
      task,
      (
        icon: Icons.menu_book_outlined,
        color: glass.journalAccent,
        label: l10n.writeNewJournalEntry,
        sheet: const AddJournalSheet(),
      ),
      (
        icon: Icons.account_balance_wallet_outlined,
        color: glass.moneyAccent,
        label: l10n.writeNewMoneyEntry,
        sheet: const AddMoneySheet(),
      ),
    ],
  };
}

/// Shows the write menu for the tab at [tabIndex] (every item when null)
/// as a modal over [context] — used by `WriteButton` and by the medium
/// widget's pencil button (`mindful://open-write-sheet`). See SPEC.md
/// Floating Island Nav Bar and Home and Lock Screen Widgets.
void showWriteOptionsSheet(BuildContext context, {int? tabIndex}) {
  final options = writeOptionsFor(context, tabIndex);
  showGlassBottomSheet<void>(
    context: context,
    builder: (sheetContext) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final option in options)
          _WriteOptionTile(
            option: option,
            onTap: () => _open(sheetContext, context, option.sheet),
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

class _WriteOptionTile extends StatelessWidget {
  const _WriteOptionTile({required this.option, required this.onTap});

  final WriteOption option;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(option.icon, color: option.color, size: 22),
      title: Text(option.label),
      onTap: onTap,
    );
  }
}
