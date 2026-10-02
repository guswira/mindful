import 'package:flutter/material.dart';

import '../../../../core/constants/spacing.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/glass_theme.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/tinted_pill.dart';
import '../../domain/breathing_exercise.dart';
import '../../domain/breathing_pattern.dart';
import '../breathing_labels.dart';

/// One breathing exercise on the Exercise tab: icon, name, what it's for,
/// its step counts, and Start. [onEdit] adds an edit button (Customize).
class BreathingExerciseCard extends StatelessWidget {
  const BreathingExerciseCard({
    required this.exercise,
    required this.pattern,
    required this.onStart,
    this.onEdit,
    super.key,
  });

  final BreathingExercise exercise;
  final BreathingPattern pattern;
  final VoidCallback onStart;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final textTheme = Theme.of(context).textTheme;
    final onEdit = this.onEdit;
    return GestureDetector(
      onTap: onStart,
      behavior: HitTestBehavior.opaque,
      child: GlassCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            _IconSquare(
              icon: exerciseIcon(exercise),
              color: glass.exerciseAccent,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.exerciseName(exercise),
                    style: textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.exerciseDescription(exercise),
                    style: textTheme.bodySmall?.copyWith(
                      color: glass.textSecondary,
                    ),
                  ),
                  const SizedBox(height: Spacing.xs),
                  Text(
                    l10n.patternSummary(pattern),
                    style: textTheme.labelSmall?.copyWith(
                      color: glass.exerciseAccent,
                    ),
                  ),
                ],
              ),
            ),
            if (onEdit != null)
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18),
                color: glass.textSecondary,
                tooltip: l10n.customPatternEdit,
                onPressed: onEdit,
              ),
            const SizedBox(width: Spacing.xs),
            TintedPill(
              label: l10n.breathingStart,
              color: glass.exerciseAccent,
              onTap: onStart,
            ),
          ],
        ),
      ),
    );
  }
}

class _IconSquare extends StatelessWidget {
  const _IconSquare({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 0.5),
      ),
      child: Icon(icon, size: 20, color: color),
    );
  }
}
