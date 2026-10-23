import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../shared/widgets/glass_bottom_sheet.dart';
import '../../../shared/widgets/glass_page_scaffold.dart';
import 'add_habit_sheet.dart';
import 'habit_providers.dart';
import 'habit_detail_body.dart';
import 'habit_detail_controller.dart';

/// Monthly calendar of a habit's completions, with streaks and a
/// swipe-to-change-month gesture.
class HabitDetailScreen extends ConsumerWidget {
  const HabitDetailScreen({required this.id, super.key});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitAsync = ref.watch(habitByIdProvider(id));
    final detailAsync = ref.watch(habitDetailControllerProvider(id));

    final habit = habitAsync.value;
    return GlassPageScaffold(
      title: Text(habit?.name ?? context.l10n.habitFallbackTitle),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_outlined, color: Colors.white70),
          onPressed: habit == null
              ? null
              : () => showGlassBottomSheet(
                  context: context,
                  builder: (_) => AddHabitSheet(habit: habit),
                ),
        ),
      ],
      body: switch ((habitAsync, detailAsync)) {
        (AsyncData(value: final habit?), AsyncData(:final value)) =>
          HabitDetailBody(habit: habit, state: value),
        (AsyncError(:final error), _) || (_, AsyncError(:final error)) =>
          Center(child: Text(context.l10n.habitLoadError('$error'))),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}
