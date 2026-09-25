import 'package:flutter/material.dart';

import '../../../core/constants/spacing.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/glass_theme.dart';
import '../../../shared/widgets/glass_card.dart';

/// The 4-way protein/carbs/fat/fiber breakdown in [FoodResultSheet].
class MacrosRow extends StatelessWidget {
  const MacrosRow({
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    super.key,
  });

  final double protein;
  final double carbs;
  final double fat;
  final double fiber;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final l10n = context.l10n;
    return Row(
      children: [
        Expanded(
          child: _MacroCard(
            value: protein,
            label: l10n.aiMacroProtein,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: Spacing.sm),
        Expanded(
          child: _MacroCard(
            value: carbs,
            label: l10n.aiMacroCarbs,
            color: glass.journalAccent,
          ),
        ),
        const SizedBox(width: Spacing.sm),
        Expanded(
          child: _MacroCard(
            value: fat,
            label: l10n.aiMacroFat,
            color: glass.moneySpending,
          ),
        ),
        const SizedBox(width: Spacing.sm),
        Expanded(
          child: _MacroCard(
            value: fiber,
            label: l10n.aiMacroFiber,
            color: glass.moneyAccent,
          ),
        ),
      ],
    );
  }
}

class _MacroCard extends StatelessWidget {
  const _MacroCard({
    required this.value,
    required this.label,
    required this.color,
  });

  final double value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return GlassCard(
      borderRadius: 14,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Text(
            '${value}g',
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: Spacing.xs),
          Text(label, style: TextStyle(color: glass.textMuted, fontSize: 10)),
        ],
      ),
    );
  }
}

/// The main-ingredients chip wrap in [FoodResultSheet].
class IngredientsWrap extends StatelessWidget {
  const IngredientsWrap({required this.ingredients, super.key});

  final List<String> ingredients;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return Wrap(
      spacing: Spacing.sm,
      runSpacing: Spacing.sm,
      children: [
        for (final ingredient in ingredients)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: glass.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: glass.cardBorder, width: 0.5),
            ),
            child: Text(
              ingredient,
              style: TextStyle(color: glass.textSecondary, fontSize: 12),
            ),
          ),
      ],
    );
  }
}

/// The health-note callout in [FoodResultSheet].
class HealthNoteCard extends StatelessWidget {
  const HealthNoteCard({required this.note, super.key});

  final String note;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return GlassCard(
      padding: const EdgeInsets.all(12),
      borderRadius: 14,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.tips_and_updates_outlined,
            color: glass.journalAccent,
            size: 16,
          ),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Text(
              note,
              style: TextStyle(
                color: glass.textSecondary,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
