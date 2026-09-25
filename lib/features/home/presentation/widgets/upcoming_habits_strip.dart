import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/glass_theme.dart';
import '../../../../shared/widgets/glass_bottom_sheet.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/tinted_pill.dart';
import '../../../habits/domain/habit_action.dart';
import '../../../habits/presentation/add_habit_sheet.dart';
import '../../../habits/presentation/habit_tab.dart';

/// Today's habits glass section: an empty state when no habits exist yet,
/// a short "all done" note once today's habits are all logged, or rows for
/// the remaining ones. See SPEC.md Home Screen.
class UpcomingHabitsStrip extends ConsumerWidget {
  const UpcomingHabitsStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(habitTabControllerProvider);

    return switch (itemsAsync) {
      AsyncData(:final value) => _HabitsCard(items: value),
      AsyncError() => const SizedBox.shrink(),
      _ => const SizedBox(
        height: 72,
        child: Center(child: CircularProgressIndicator()),
      ),
    };
  }
}

class _HabitsCard extends StatelessWidget {
  const _HabitsCard({required this.items});

  final List<HabitTabItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const _NoHabitsCard();
    }

    final remaining = [
      for (final item in items)
        if (item.todayLog == null) item,
    ];
    if (remaining.isEmpty) {
      return GlassCard(
        child: Text(
          context.l10n.homeHabitsAllDone,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).extension<GlassTheme>()!.textSecondary,
          ),
        ),
      );
    }

    return GlassCard(
      child: Column(
        children: [for (final item in remaining) _HabitRow(item: item)],
      ),
    );
  }
}

class _NoHabitsCard extends StatelessWidget {
  const _NoHabitsCard();

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return GlassCard(
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: glass.habitAccent.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: const Text('🔥', style: TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              context.l10n.homeHabitsEmpty,
              style: TextStyle(fontSize: 14, color: glass.textSecondary),
            ),
          ),
          TintedPill(
            label: context.l10n.homeHabitsStart,
            color: glass.habitAccent,
            onTap: () => showGlassBottomSheet(
              context: context,
              builder: (_) => const AddHabitSheet(),
            ),
          ),
        ],
      ),
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
        SnackBar(content: Text(
          context.l10n.homeSyncFailed(item.habit.name, '$error'),
        )),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habit = item.habit;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(habit.icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              habit.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, color: Colors.white),
            ),
          ),
          if (habit.actions.isEmpty)
            _ActionPill(
              label: context.l10n.commonDone,
              onTap: () => _handleTap(context, ref, null),
            )
          else
            for (final action in habit.actions)
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: _ActionPill(
                  label: action.label,
                  onTap: () => _handleTap(context, ref, action),
                ),
              ),
        ],
      ),
    );
  }
}

/// A not-yet-done habit action — every row here is undone (see
/// [_HabitsCard]'s `remaining` filter), so unlike the Habits tab's own
/// action chips (which also render a habitAccent-tinted "done" state),
/// this one only ever needs the glass/transparent "not done" look.
class _ActionPill extends StatelessWidget {
  const _ActionPill({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: glass.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: glass.cardBorder, width: 0.5),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: glass.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
