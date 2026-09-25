import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/spacing.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/glass_theme.dart';
import '../../../shared/services/notification_service.dart';
import '../../../shared/services/widget_service.dart';
import '../../../shared/widgets/glass_bottom_sheet.dart';
import '../../../shared/widgets/glass_card.dart';
import '../data/habit_repository.dart';
import '../domain/habit.dart';
import '../domain/habit_action.dart';
import 'add_habit_sheet.dart';
import 'habit_tab.dart';

/// [items]' active habits as glass rows, each with its action pills. See
/// SPEC.md Habit Tracker.
class HabitList extends StatelessWidget {
  const HabitList({required this.items, super.key});

  final List<HabitTabItem> items;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    if (items.isEmpty) {
      return Center(
        child: Text(
          context.l10n.habitEmptyList,
          style: TextStyle(color: glass.textMuted),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 88),
      children: [
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

  Future<void> _handleTap(
    BuildContext context,
    WidgetRef ref,
    HabitAction? action,
  ) async {
    try {
      await ref
          .read(habitTabControllerProvider.notifier)
          .logAction(item.habit, action);
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
        await _archive(context, ref, habit);
      case _HabitRowAction.delete:
        await _delete(context, ref, habit);
    }
  }

  Future<void> _archive(
    BuildContext context,
    WidgetRef ref,
    Habit habit,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.habitArchiveConfirmTitle),
        content: Text(context.l10n.habitArchiveConfirmBody(habit.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.commonArchive),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) {
      return;
    }

    final repository = await ref.read(habitRepositoryProvider.future);
    await repository.saveHabit(habit.copyWith(archived: true));
    await _cancelReminder(ref, habit.id);
    ref.invalidate(habitTabControllerProvider);
    await refreshWidgetsBestEffort(
      () => ref.read(widgetServiceProvider.future),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, Habit habit) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.habitDeleteConfirmTitle),
        content: Text(context.l10n.habitDeleteConfirmBody(habit.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.commonDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) {
      return;
    }

    final repository = await ref.read(habitRepositoryProvider.future);
    await _forgetReminder(ref, habit.id);
    await repository.deleteHabit(habit.id);
    ref.invalidate(habitTabControllerProvider);
    await refreshWidgetsBestEffort(
      () => ref.read(widgetServiceProvider.future),
    );
  }

  /// Cancels [habitId]'s reminder, keeping its notification id reserved —
  /// used by "Archive", since the habit still exists and could get a
  /// reminder again later.
  Future<void> _cancelReminder(WidgetRef ref, String habitId) async {
    final notificationService = await ref.read(
      notificationServiceProvider.future,
    );
    await notificationService.cancelHabitReminder(habitId);
  }

  /// Cancels [habitId]'s reminder and frees its notification id block for
  /// reuse — used by "Delete", which removes the habit itself.
  Future<void> _forgetReminder(WidgetRef ref, String habitId) async {
    final notificationService = await ref.read(
      notificationServiceProvider.future,
    );
    await notificationService.forgetHabitReminder(habitId);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habit = item.habit;
    final isDone = item.todayLog != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/habits/${habit.id}'),
        onLongPress: () => _showOptions(context, ref),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Text(habit.icon, style: const TextStyle(fontSize: 20)),
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
                _ActionChip(
                  label: context.l10n.commonDone,
                  selected: isDone,
                  onSelected: () => _handleTap(context, ref, null),
                )
              else
                for (final action in habit.actions)
                  Padding(
                    padding: const EdgeInsets.only(left: Spacing.xs),
                    child: _ActionChip(
                      label: action.label,
                      selected: item.todayLog?.completedActionId == action.id,
                      onSelected: () => _handleTap(context, ref, action),
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

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      showCheckmark: false,
      visualDensity: VisualDensity.compact,
      backgroundColor: glass.cardColor,
      selectedColor: glass.habitAccent.withValues(alpha: 0.18),
      side: BorderSide(
        color: selected
            ? glass.habitAccent.withValues(alpha: 0.25)
            : glass.cardBorder,
        width: 0.5,
      ),
      labelStyle: TextStyle(
        color: selected ? glass.habitAccent : glass.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
