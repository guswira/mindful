import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/spacing.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/glass_theme.dart';
import '../../../../shared/widgets/glass_bottom_sheet.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../data/food_scan_repository.dart';
import '../../domain/food_analysis.dart';
import '../food_result_sheet.dart';
import 'food_scan_card.dart';

/// The "Recent scans" list on [AITab] — read-only, tapping a card reopens
/// [FoodResultSheet] with no save/discard actions. See SPEC.md AI Lab
/// Feature AI Lab Tab, Scan history section.
class RecentScansSection extends ConsumerWidget {
  const RecentScansSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final scansAsync = ref.watch(recentScansProvider);
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.aiRecentScans,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: Spacing.md - 4),
        switch (scansAsync) {
          AsyncData(:final value) when value.isEmpty => GlassCard(
            child: Center(
              child: Text(
                l10n.aiNoScansYet,
                textAlign: TextAlign.center,
                style: TextStyle(color: glass.textMuted, fontSize: 14),
              ),
            ),
          ),
          AsyncData(:final value) => Column(
            children: [
              for (final scan in value) ...[
                FoodScanCard(
                  scan: scan,
                  onTap: () => showGlassBottomSheet<void>(
                    context: context,
                    builder: (_) => FoodResultSheet(
                      analysis: FoodAnalysis(
                        foodName: scan.foodName ?? l10n.aiUnknownFood,
                        calories: scan.calories ?? 0,
                        protein: scan.protein ?? 0,
                        carbs: scan.carbs ?? 0,
                        fat: scan.fat ?? 0,
                        fiber: scan.fiber ?? 0,
                        confidence: scan.confidence ?? 'medium',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: Spacing.sm),
              ],
            ],
          ),
          AsyncError() => Center(
            child: Text(
              l10n.aiLoadScansFailed,
              style: TextStyle(color: glass.textMuted),
            ),
          ),
          _ => Center(child: CircularProgressIndicator(color: glass.aiAccent)),
        },
      ],
    );
  }
}
