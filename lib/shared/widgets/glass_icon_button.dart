import 'dart:ui';

import 'package:flutter/material.dart';

/// Small circular glass button — the home screen's settings gear and the
/// "add" buttons on the task and habit tabs all use this.
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
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = GestureDetector(
      onTap: onTap,
      child: ClipOval(
        child: BackdropFilter(
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
    final tooltip = this.tooltip;
    return tooltip == null ? button : Tooltip(message: tooltip, child: button);
  }
}
