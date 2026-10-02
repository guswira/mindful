import 'package:flutter/material.dart';

import '../../../../core/constants/spacing.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/glass_theme.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../domain/exercise_stats.dart';
import '../breathing_labels.dart';

/// All-time sessions, time spent, and current day streak.
class ExerciseStatsRow extends StatelessWidget {
  const ExerciseStatsRow({required this.stats, super.key});

  final ExerciseStats stats;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        _StatCard(
          value: '${stats.totalSessions}',
          label: l10n.exerciseStatSessions,
        ),
        const SizedBox(width: Spacing.sm),
        _StatCard(
          value: l10n.exerciseDuration(stats.totalTime),
          label: l10n.exerciseStatTimeSpent,
        ),
        const SizedBox(width: Spacing.sm),
        _StatCard(
          value: '${stats.currentStreak}',
          label: l10n.exerciseStatStreak,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final textTheme = Theme.of(context).textTheme;
    return Expanded(
      child: GlassCard(
        borderRadius: 14,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.titleLarge?.copyWith(
                color: glass.exerciseAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: textTheme.bodySmall?.copyWith(color: glass.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
