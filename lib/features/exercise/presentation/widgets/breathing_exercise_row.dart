import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/glass_theme.dart';
import '../../../../shared/widgets/tinted_pill.dart';
import '../../domain/breathing_exercise.dart';
import '../../domain/breathing_pattern.dart';
import '../breathing_labels.dart';

/// One breathing exercise as a row in the Mindfulness tab's breathing
/// card: icon, name, step counts and a "Breathe" pill — the same action
/// shape as home's Mindfulness card. The row and the pill both start the
/// exercise; [onEdit] adds an edit button before the pill (Customize).
class BreathingExerciseRow extends StatelessWidget {
  const BreathingExerciseRow({
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
    return Semantics(
      button: true,
      label: '${l10n.breathingStart}: ${l10n.exerciseName(exercise)}',
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onStart,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.patternSummary(pattern),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.labelSmall?.copyWith(
                          color: glass.exerciseAccent,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (onEdit != null)
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    color: glass.textSecondary,
                    tooltip: l10n.customPatternEdit,
                    visualDensity: VisualDensity.compact,
                    onPressed: onEdit,
                  ),
                TintedPill(
                  label: l10n.homeMindfulBreathingAction,
                  color: glass.exerciseAccent,
                  onTap: onStart,
                ),
              ],
            ),
          ),
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
      child: Icon(icon, size: 18, color: color),
    );
  }
}
