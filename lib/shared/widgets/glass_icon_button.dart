import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as lg;

import '../../core/theme/glass_style.dart';
import '../../core/theme/glass_style_scope.dart';
import '../../core/theme/liquid_glass_presets.dart';

/// Small circular glass button — the home screen's settings gear, the
/// budget card's gear and the breathing session's top bar — in the user's
/// [GlassStyle].
///
/// Liquid: an [lg.GlassButton] that squeezes and stretches toward the
/// finger while pressed and springs back, like iOS 26 bar buttons.
/// Frosted: a blurred translucent circle with a hairline border.
class GlassIconButton extends StatelessWidget {
  const GlassIconButton({
    required this.icon,
    required this.onTap,
    this.size = 38,
    this.iconSize = 18,
    this.iconColor = Colors.white60,
    this.tooltip,
    super.key,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final double iconSize;
  final Color iconColor;

  /// Also the button's screen-reader label.
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final tooltip = this.tooltip;
    final button = switch (GlassStyleScope.of(context)) {
      GlassStyle.liquid => lg.GlassButton(
        icon: Icon(icon),
        onTap: onTap,
        label: tooltip ?? '',
        width: size,
        height: size,
        iconSize: iconSize,
        iconColor: iconColor,
        settings: LiquidGlassPresets.chrome,
      ),
      GlassStyle.frosted => _FrostedIconButton(
        icon: icon,
        onTap: onTap,
        size: size,
        iconSize: iconSize,
        iconColor: iconColor,
      ),
    };
    return tooltip == null ? button : Tooltip(message: tooltip, child: button);
  }
}

class _FrostedIconButton extends StatelessWidget {
  const _FrostedIconButton({
    required this.icon,
    required this.onTap,
    required this.size,
    required this.iconSize,
    required this.iconColor,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final double iconSize;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipOval(
        child: BackdropFilter.grouped(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.08),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.14),
                width: 0.5,
              ),
            ),
            child: Icon(icon, size: iconSize, color: iconColor),
          ),
        ),
      ),
    );
  }
}
