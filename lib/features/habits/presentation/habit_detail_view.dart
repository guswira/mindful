import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/spacing.dart';
import '../../../core/l10n/l10n.dart';
import '../../../shared/widgets/glass_bottom_sheet.dart';
import '../domain/habit.dart';
import 'add_habit_sheet.dart';
import 'habit_detail_body.dart';
import 'habit_detail_screen.dart';
import 'habit_icon.dart';
import 'habit_providers.dart';

/// A routine's calendar, streaks and action summary in the wide-screen
/// detail pane — [HabitDetailScreen]'s content under a name + edit header
/// instead of an app bar.
class HabitDetailView extends ConsumerWidget {
  const HabitDetailView({required this.habitId, this.notFound, super.key});

  final String habitId;

  /// Shown once [habitId] no longer exists (deleted); a plain "not found"
  /// line by default.
  final Widget? notFound;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitAsync = ref.watch(habitByIdProvider(habitId));
    final detailAsync = ref.watch(habitDetailControllerProvider(habitId));
    return switch ((habitAsync, detailAsync)) {
      (AsyncData(value: final habit?), AsyncData(:final value)) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(habit: habit),
          Flexible(
            child: HabitDetailBody(
              habit: habit,
              state: value,
              shrinkWrap: true,
            ),
          ),
        ],
      ),
      (AsyncData(value: null), _) =>
        notFound ?? Center(child: Text(context.l10n.habitFallbackTitle)),
      (AsyncError(:final error), _) || (_, AsyncError(:final error)) => Center(
        child: Text(context.l10n.habitLoadError('$error')),
      ),
      _ => const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      ),
    };
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.habit});

  final Habit habit;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        HabitIcon.of(habit),
        const SizedBox(width: Spacing.sm),
        Expanded(
          child: Text(
            habit.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.edit_outlined, color: Colors.white70),
          tooltip: context.l10n.commonEdit,
          onPressed: () => showGlassBottomSheet<void>(
            context: context,
            builder: (_) => AddHabitSheet(habit: habit),
          ),
        ),
      ],
    );
  }
}
