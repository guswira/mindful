import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/spacing.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/glass_theme.dart';
import '../../../shared/widgets/glass_bottom_sheet.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/group_label.dart';
import '../../../shared/widgets/intro_card.dart';
import '../domain/habit_action.dart';
import 'add_habit_sheet.dart';
import 'archived_habits_sheet.dart';
import 'habit_manage_actions.dart';
import 'habit_tab.dart';
import 'habit_icon.dart';
import 'routine_pill.dart';

/// The Tasks & Routines tab's routines section: a label plus [items]'
/// active habits as glass rows, each with its action pills. Not scrollable
/// itself — it's one section of the tab's list. See SPEC.md Tasks &
/// Routines.
class RoutineSection extends StatelessWidget {
  const RoutineSection({required this.items, super.key});

  final List<HabitTabItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GroupLabel(context.l10n.habitTabTitle),
            const ArchivedHabitsLink(),
          ],
        ),
        const SizedBox(height: Spacing.sm),
        if (items.isEmpty)
          const _RoutinesIntro()
        else
          GlassCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  if (i > 0) const _RowDivider(),
                  _HabitRow(item: items[i]),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

/// Shown instead of the list until the first routine exists.
class _RoutinesIntro extends StatelessWidget {
  const _RoutinesIntro();

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final l10n = context.l10n;
    return IntroCard(
      icon: Icons.eco_outlined,
      color: glass.habitAccent,
      title: l10n.habitIntroTitle,
      body: l10n.habitIntroBody,
      actionLabel: l10n.habitIntroAction,
      onAction: () => showGlassBottomSheet(
        context: context,
        builder: (_) => const AddHabitSheet(),
      ),
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0.5,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.white.withValues(alpha: 0.07),
    );
  }
}

class _HabitRow extends ConsumerWidget {
  const _HabitRow({required this.item});

  final HabitTabItem item;

  /// Toggles today's log: tapping the chip that's already selected undoes
  /// it, any other chip logs (or switches to) that action.
  Future<void> _handleTap(
    BuildContext context,
    WidgetRef ref,
    HabitAction? action, {
    required bool selected,
  }) async {
    final controller = ref.read(habitTabControllerProvider.notifier);
    try {
      if (selected) {
        await controller.unlog(item.habit);
      } else {
        await controller.logAction(item.habit, action);
      }
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n.habitSyncFailed(item.habit.name, '$error'),
          ),
        ),
      );
    }
  }

  Future<void> _showOptions(BuildContext context, WidgetRef ref) async {
    final habit = item.habit;
    final action = await showModalBottomSheet<_HabitRowAction>(
      context: context,
      useRootNavigator: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(context.l10n.commonEdit),
              onTap: () => Navigator.pop(context, _HabitRowAction.edit),
            ),
            ListTile(
              leading: const Icon(Icons.archive_outlined),
              title: Text(context.l10n.commonArchive),
              onTap: () => Navigator.pop(context, _HabitRowAction.archive),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: Text(
                context.l10n.commonDelete,
                style: const TextStyle(color: Colors.red),
              ),
              onTap: () => Navigator.pop(context, _HabitRowAction.delete),
            ),
          ],
        ),
      ),
    );
    if (!context.mounted || action == null) {
      return;
    }

    switch (action) {
      case _HabitRowAction.edit:
        showGlassBottomSheet(
          context: context,
          builder: (_) => AddHabitSheet(habit: habit),
        );
      case _HabitRowAction.archive:
        await archiveHabitWithConfirm(context, ref, habit);
      case _HabitRowAction.delete:
        await deleteHabitWithConfirm(context, ref, habit);
    }
  }

  bool _isActionSelected(HabitAction action) =>
      item.todayLog?.completedActionId == action.id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habit = item.habit;
    final isDone = item.todayLog != null;
    final color = routineColorOf(context, habit);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/habits/${habit.id}'),
        onLongPress: () => _showOptions(context, ref),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
              if (habit.actions.isEmpty)
                RoutinePill(
                  label: context.l10n.commonDone,
                  color: color,
                  selected: isDone,
                  onTap: () => _handleTap(context, ref, null, selected: isDone),
                )
              else
                for (final action in habit.actions)
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: RoutinePill(
                      label: action.label,
                      color: color,
                      selected: _isActionSelected(action),
                      onTap: () => _handleTap(
                        context,
                        ref,
                        action,
                        selected: _isActionSelected(action),
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _HabitRowAction { edit, archive, delete }
