import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/spacing.dart';
import '../../../core/l10n/l10n.dart';
import '../../../shared/widgets/glass_page_scaffold.dart';
import '../domain/exercise_stats.dart';
import 'exercise_providers.dart';
import 'widgets/exercise_calendar_card.dart';
import 'widgets/exercise_stats_row.dart';

/// Full-page breathing activity (`/exercise/activity`): all-time stats and
/// the practice calendar, opened from the Mindfulness tab's
/// calendar button. See SPEC.md Exercise.
class ExerciseActivityScreen extends ConsumerWidget {
  const ExerciseActivityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats =
        ref.watch(exerciseStatsProvider).valueOrNull ?? ExerciseStats.empty;
    return GlassPageScaffold(
      title: Text(context.l10n.exerciseActivityTitle),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, Spacing.sm, 20, 40),
        children: [
          ExerciseStatsRow(stats: stats),
          const SizedBox(height: Spacing.sm),
          ExerciseCalendarCard(stats: stats),
        ],
      ),
    );
  }
}
