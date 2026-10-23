import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as lg;

import '../../core/theme/glass_style.dart';
import '../../core/theme/glass_style_scope.dart';
import '../../core/theme/glass_theme.dart';
import '../../core/theme/liquid_glass_presets.dart';

/// The reusable glass card used for content surfaces throughout the app,
/// drawn in the user's [GlassStyle] (Settings → Glass style).
///
/// Liquid: a refracting, specular-rimmed superellipse (liquid_glass_widgets,
/// standard quality — the single-pass shader that's safe inside scrolling
/// lists). Glass controls nested in it don't refract through it, so pills
/// and icon buttons inside stay crisp.
///
/// Frosted: a blurred, semi-transparent rounded rect with a hairline
/// border, using [BackdropFilter.grouped] so it shares one backdrop read
/// with every other card under the screen's `BlobBackground` group — with
/// a separate read per card, Android drew some cards see-through for a
/// frame while a list of them scrolled.
class GlassCard extends StatelessWidget {
  const GlassCard({
    required this.child,
    this.strong = false,
    this.borderRadius = 18,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    super.key,
  });

  final Widget child;
  final bool strong;
  final double borderRadius;
  final EdgeInsets padding;
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: switch (GlassStyleScope.of(context)) {
        GlassStyle.liquid => lg.GlassCard(
          padding: padding,
          shape: lg.LiquidRoundedSuperellipse(borderRadius: borderRadius),
          settings: strong
              ? LiquidGlassPresets.strongCard
              : LiquidGlassPresets.card,
          // Clipped so content (photo thumbnails, ink splashes) follows the
          // rounded glass edge.
          clipBehavior: Clip.antiAlias,
          child: child,
        ),
        GlassStyle.frosted => _FrostedCard(
          strong: strong,
          borderRadius: borderRadius,
          padding: padding,
          child: child,
        ),
      },
    );
  }
}

class _FrostedCard extends StatelessWidget {
  const _FrostedCard({
    required this.strong,
    required this.borderRadius,
    required this.padding,
    required this.child,
  });

  final bool strong;
  final double borderRadius;
  final EdgeInsets padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final radius = BorderRadius.circular(borderRadius);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(
          color: strong ? glass.strongCardBorder : glass.cardBorder,
          width: 0.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter.grouped(
          filter: ImageFilter.blur(
            sigmaX: strong ? 24 : 20,
            sigmaY: strong ? 24 : 20,
          ),
          child: ColoredBox(
            color: strong ? glass.strongCardColor : glass.cardColor,
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}
