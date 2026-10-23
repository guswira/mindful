import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as lg;

import '../../../../core/constants/spacing.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/glass_style.dart';
import '../../../../core/theme/glass_style_scope.dart';
import '../../../../core/theme/glass_theme.dart';
import '../../../../core/theme/liquid_glass_presets.dart';

/// The always-visible "this is experimental" notice at the top of [AITab] —
/// an aiAccent-tinted glass card (in the user's [GlassStyle]) rather than
/// the standard GlassCard, per SPEC.md AI Lab Feature Experimental banner.
class ExperimentalBanner extends StatelessWidget {
  const ExperimentalBanner({super.key});

  static const double _radius = 14;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final border = BorderSide(
      color: glass.aiAccent.withValues(alpha: 0.3),
      width: 0.5,
    );
    return switch (GlassStyleScope.of(context)) {
      GlassStyle.liquid => DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: ShapeDecoration(
          shape: RoundedSuperellipseBorder(
            borderRadius: BorderRadius.circular(_radius),
            side: border,
          ),
        ),
        child: lg.GlassCard(
          shape: const lg.LiquidRoundedSuperellipse(borderRadius: _radius),
          settings: LiquidGlassPresets.strongCard.copyWith(
            glassColor: glass.aiAccent.withValues(alpha: 0.08),
          ),
          child: const _BannerContent(),
        ),
      ),
      GlassStyle.frosted => DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_radius),
          border: Border.fromBorderSide(border),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(_radius),
          child: BackdropFilter.grouped(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: ColoredBox(
              color: glass.aiAccent.withValues(alpha: 0.06),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: _BannerContent(),
              ),
            ),
          ),
        ),
      ),
    };
  }
}

class _BannerContent extends StatelessWidget {
  const _BannerContent();

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.science_outlined, color: glass.aiAccent, size: 20),
        const SizedBox(width: Spacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.aiExperimentalTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                context.l10n.aiExperimentalBody,
                style: TextStyle(
                  color: glass.textSecondary,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
