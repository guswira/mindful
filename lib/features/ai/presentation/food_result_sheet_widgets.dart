import 'package:flutter/material.dart';

import '../../../core/constants/spacing.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/glass_theme.dart';

/// The confidence pill in [FoodResultSheet]'s header — color and label vary
/// by [confidence] ('high' | 'medium' | 'low').
class ConfidenceBadge extends StatelessWidget {
  const ConfidenceBadge({required this.confidence, super.key});

  final String confidence;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final l10n = context.l10n;
    final (color, label) = switch (confidence) {
      'high' => (glass.moneyAccent, l10n.aiConfidenceHigh),
      'low' => (glass.moneySpending, l10n.aiConfidenceLow),
      _ => (glass.accentAmber, l10n.aiConfidenceMedium),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// The large calorie count hero in [FoodResultSheet].
class CalorieHero extends StatelessWidget {
  const CalorieHero({
    required this.calories,
    required this.servingNote,
    super.key,
  });

  final int calories;
  final String? servingNote;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: glass.aiAccent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: glass.aiAccent.withValues(alpha: 0.20),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          Text(
            '$calories',
            style: TextStyle(
              color: glass.aiAccent,
              fontSize: 56,
              fontWeight: FontWeight.bold,
              letterSpacing: -2,
            ),
          ),
          Text(
            context.l10n.aiCaloriesUnit,
            style: TextStyle(
              color: glass.aiAccent.withValues(alpha: 0.6),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            servingNote ?? context.l10n.aiPerServing,
            style: TextStyle(color: glass.textHint, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
