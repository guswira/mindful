import 'package:flutter/material.dart';

import '../../../../core/constants/spacing.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/glass_theme.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/tinted_pill.dart';

/// The camera/gallery entry point for scanning a food photo, on [AITab].
/// See SPEC.md AI Lab Feature AI Lab Tab, Food Calorie Checker section.
class FoodCheckerCard extends StatelessWidget {
  const FoodCheckerCard({
    required this.onOpenCamera,
    required this.onPickFromGallery,
    super.key,
  });

  final VoidCallback onOpenCamera;
  final VoidCallback onPickFromGallery;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.aiFoodCheckerTitle,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: Spacing.xs),
        Text(
          l10n.aiFoodCheckerSubtitle,
          style: TextStyle(color: glass.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: Spacing.md),
        GlassCard(
          strong: true,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _CameraIcon(color: glass.aiAccent),
              const SizedBox(height: Spacing.md + Spacing.xs),
              Text(
                l10n.aiScanYourFood,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.aiScanYourFoodHint,
                textAlign: TextAlign.center,
                style: TextStyle(color: glass.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: Spacing.lg - 2),
              SizedBox(
                width: double.infinity,
                child: TintedPill(
                  label: l10n.aiCheckFoodCalories,
                  color: glass.aiAccent,
                  onTap: onOpenCamera,
                ),
              ),
              const SizedBox(height: Spacing.sm),
              TextButton(
                onPressed: onPickFromGallery,
                child: Text(
                  l10n.aiChooseFromGallery,
                  style: TextStyle(
                    color: glass.aiAccent.withValues(alpha: 0.7),
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CameraIcon extends StatelessWidget {
  const _CameraIcon({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.20), width: 0.5),
      ),
      child: Icon(Icons.camera_alt_outlined, color: color, size: 38),
    );
  }
}
