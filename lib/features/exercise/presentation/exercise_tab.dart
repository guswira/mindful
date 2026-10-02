import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/spacing.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/glass_theme.dart';
import '../../../shared/widgets/blob_background.dart';
import '../../../shared/widgets/glass_bottom_sheet.dart';
import '../domain/breathing_exercise.dart';
import '../domain/breathing_pattern.dart';
import '../domain/breathing_preferences.dart';
import '../domain/exercise_stats.dart';
import 'custom_pattern_sheet.dart';
import 'exercise_providers.dart';
import 'widgets/breathing_exercise_card.dart';
import 'widgets/exercise_calendar_card.dart';
import 'widgets/exercise_stats_row.dart';

/// The Exercise tab (`/home/exercise`): the breathing exercises, then
/// all-time stats and a practice calendar. See SPEC.md Exercise.
class ExerciseTab extends ConsumerWidget {
  const ExerciseTab({super.key});

  void _start(BuildContext context, BreathingExercise exercise) =>
      context.push('/exercise/breathing/${exercise.name}');

  void _editCustom(BuildContext context, CustomBreathing custom) =>
      showGlassBottomSheet<bool>(
        context: context,
        builder: (_) => CustomPatternSheet(initial: custom),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final custom =
        ref.watch(breathingPreferencesControllerProvider).valueOrNull?.custom ??
        const CustomBreathing();
    final stats =
        ref.watch(exerciseStatsProvider).valueOrNull ?? ExerciseStats.empty;
    const exercises = BreathingExercise.values;
    return Scaffold(
      backgroundColor: glass.background,
      body: RepaintBoundary(
        child: BlobBackground(
          child: SafeArea(
            bottom: false,
            child: CustomScrollView(
              slivers: [
                const SliverPadding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, Spacing.sm),
                  sliver: SliverToBoxAdapter(child: _ExerciseHeader()),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList.separated(
                    itemCount: exercises.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: Spacing.sm),
                    itemBuilder: (context, index) {
                      final exercise = exercises[index];
                      return BreathingExerciseCard(
                        exercise: exercise,
                        pattern: BreathingPattern.forExercise(exercise, custom),
                        onStart: () => _start(context, exercise),
                        onEdit: exercise == BreathingExercise.custom
                            ? () => _editCustom(context, custom)
                            : null,
                      );
                    },
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, Spacing.lg, 20, 88),
                  sliver: SliverList.list(
                    children: [
                      _SectionTitle(context.l10n.exerciseActivitySection),
                      const SizedBox(height: Spacing.sm),
                      ExerciseStatsRow(stats: stats),
                      const SizedBox(height: Spacing.sm),
                      ExerciseCalendarCard(stats: stats),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ExerciseHeader extends StatelessWidget {
  const _ExerciseHeader();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.exerciseTitle,
          style: textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          l10n.exerciseSubtitle,
          style: textTheme.bodyMedium?.copyWith(color: glass.textSecondary),
        ),
        const SizedBox(height: Spacing.lg),
        _SectionTitle(l10n.exerciseBreathingSection),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: Colors.white.withValues(alpha: 0.9),
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
