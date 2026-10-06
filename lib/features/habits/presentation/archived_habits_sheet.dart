import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/spacing.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/glass_theme.dart';
import '../../../shared/widgets/glass_bottom_sheet.dart';
import '../../../shared/widgets/sheet_header.dart';
import '../../../shared/widgets/tinted_pill.dart';
import '../domain/habit.dart';
import 'habit_manage_actions.dart';
import 'habit_tab.dart';
import 'habit_icon.dart';

/// "Archived (N)" next to the Routines label — hidden while nothing is
/// archived, so archiving is the only way it ever shows up.
class ArchivedHabitsLink extends ConsumerWidget {
  const ArchivedHabitsLink({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(archivedHabitsProvider).valueOrNull?.length ?? 0;
    if (count == 0) {
      return const SizedBox.shrink();
    }
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return GestureDetector(
      onTap: () => showGlassBottomSheet<void>(
        context: context,
        builder: (_) => const ArchivedHabitsSheet(),
      ),
      child: Text(
        context.l10n.habitArchivedLink(count),
        style: TextStyle(fontSize: 13, color: glass.textMuted),
      ),
    );
  }
}

/// Archived habits, each with Restore and Delete. Tapping a row opens its
/// calendar, so old history stays reachable without restoring it.
class ArchivedHabitsSheet extends ConsumerWidget {
  const ArchivedHabitsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits =
        ref.watch(archivedHabitsProvider).valueOrNull ?? const <Habit>[];
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 8, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SheetHeader(
            title: context.l10n.habitArchivedTitle,
            onClose: () => Navigator.pop(context),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12, bottom: Spacing.sm),
            child: Text(
              context.l10n.habitArchivedHint,
              style: TextStyle(fontSize: 13, color: glass.textSecondary),
            ),
          ),
          if (habits.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Spacing.md),
              child: Text(
                context.l10n.habitArchivedEmpty,
                style: TextStyle(fontSize: 14, color: glass.textMuted),
              ),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: habits.length,
                itemBuilder: (context, index) =>
                    _ArchivedHabitRow(habit: habits[index]),
              ),
            ),
        ],
      ),
    );
  }
}

class _ArchivedHabitRow extends ConsumerWidget {
  const _ArchivedHabitRow({required this.habit});

  final Habit habit;

  void _openCalendar(BuildContext context) {
    final router = GoRouter.of(context);
    Navigator.pop(context);
    router.push('/habits/${habit.id}');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return InkWell(
      onTap: () => _openCalendar(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
        child: Row(
          children: [
            HabitIcon.of(habit),
            const SizedBox(width: Spacing.sm),
            Expanded(
              child: Text(
                habit.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
            TintedPill(
              label: context.l10n.habitRestore,
              color: glass.habitAccent,
              onTap: () => restoreHabit(context, ref, habit),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: glass.textSecondary,
              tooltip: context.l10n.commonDelete,
              onPressed: () => deleteHabitWithConfirm(context, ref, habit),
            ),
          ],
        ),
      ),
    );
  }
}
