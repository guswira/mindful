import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/spacing.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/glass_theme.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../domain/food_scan.dart';

/// One row in [AITab]'s recent-scans list — tapping shows the full result
/// read-only. See SPEC.md AI Lab Feature AI Lab Tab, Scan history section.
class FoodScanCard extends StatelessWidget {
  const FoodScanCard({required this.scan, this.onTap, super.key});

  final FoodScan scan;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: glass.aiAccent.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('🍽', style: TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: Spacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    scan.foodName ?? context.l10n.aiUnknownFood,
                    style: TextStyle(
                      color: glass.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    DateFormat('EEE, MMM d · h:mm a').format(scan.scannedAt),
                    style: TextStyle(color: glass.textMuted, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(width: Spacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${scan.calories ?? '—'}',
                  style: TextStyle(
                    color: glass.aiAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  context.l10n.aiKcal,
                  style: TextStyle(color: glass.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
