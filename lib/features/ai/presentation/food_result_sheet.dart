import 'package:flutter/material.dart';

import '../../../core/constants/spacing.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/glass_theme.dart';
import '../../../shared/widgets/sheet_header.dart';
import '../../../shared/widgets/tinted_pill.dart';
import '../domain/food_analysis.dart';
import 'food_result_macros.dart';
import 'food_result_sheet_widgets.dart';

/// Shows a completed [FoodAnalysis] — calories, macros, ingredients and a
/// health note — with Save/Discard actions. Passing null [onSave] instead
/// shows a single "Dismiss" button, for browsing a scan already saved to
/// history. See SPEC.md AI Lab Feature FoodResultSheet.
class FoodResultSheet extends StatelessWidget {
  const FoodResultSheet({required this.analysis, this.onSave, super.key});

  final FoodAnalysis analysis;
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SheetHeader(
            title: analysis.foodName,
            onClose: () => Navigator.pop(context),
          ),
          if (analysis.servingNote case final note? when note.isNotEmpty)
            Text(
              note,
              style: TextStyle(
                color: glass.textMuted,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          const SizedBox(height: Spacing.sm),
          ConfidenceBadge(confidence: analysis.confidence),
          const SizedBox(height: Spacing.md),
          CalorieHero(
            calories: analysis.calories,
            servingNote: analysis.servingNote,
          ),
          const SizedBox(height: Spacing.md),
          MacrosRow(
            protein: analysis.protein,
            carbs: analysis.carbs,
            fat: analysis.fat,
            fiber: analysis.fiber,
          ),
          if (analysis.ingredients.isNotEmpty) ...[
            const SizedBox(height: Spacing.md),
            Text(
              context.l10n.aiMainIngredients,
              style: TextStyle(color: glass.textMuted, fontSize: 12),
            ),
            const SizedBox(height: Spacing.sm),
            IngredientsWrap(ingredients: analysis.ingredients),
          ],
          if (analysis.healthNote case final note? when note.isNotEmpty) ...[
            const SizedBox(height: Spacing.md),
            HealthNoteCard(note: note),
          ],
          const SizedBox(height: Spacing.md),
          Text(
            context.l10n.aiResultDisclaimer,
            textAlign: TextAlign.center,
            style: TextStyle(color: glass.textHint, fontSize: 11),
          ),
          if (analysis.confidence == 'low') ...[
            const SizedBox(height: Spacing.sm),
            Text(
              context.l10n.aiLowConfidenceWarning,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: glass.moneySpending,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          const SizedBox(height: Spacing.lg),
          _ActionRow(onSave: onSave),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.onSave});

  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    if (onSave == null) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Text(
            context.l10n.aiDismiss,
            style: TextStyle(color: glass.textSecondary),
          ),
        ),
      );
    }
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Text(
              context.l10n.aiDiscard,
              style: TextStyle(color: glass.textSecondary),
            ),
          ),
        ),
        const SizedBox(width: Spacing.sm),
        Expanded(
          child: TintedPill(
            label: context.l10n.aiSaveScan,
            color: glass.aiAccent,
            onTap: onSave,
          ),
        ),
      ],
    );
  }
}
