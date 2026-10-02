import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/glass_theme.dart';

/// The reusable frosted glass card used for content surfaces throughout
/// the app — a blurred, semi-transparent container with a hairline border.
///
/// Uses [BackdropFilter.grouped], sharing one backdrop read with every
/// other glass surface under the same [BackdropGroup] (each screen's
/// `BlobBackground` provides one). With a separate read per card, Android's
/// renderer drew some cards see-through for a frame while a list of them
/// scrolled. Outside a group it behaves like a plain [BackdropFilter].
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
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: strong ? glass.strongCardBorder : glass.cardBorder,
          width: 0.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter.grouped(
          filter: ImageFilter.blur(
            sigmaX: strong ? 24 : 20,
            sigmaY: strong ? 24 : 20,
          ),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: strong ? glass.strongCardColor : glass.cardColor,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
