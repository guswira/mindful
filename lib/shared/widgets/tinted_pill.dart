import 'package:flutter/material.dart';

import '../../core/theme/glass_style.dart';
import '../../core/theme/glass_style_scope.dart';

/// A small pill-shaped button tinted with an accent color, used for
/// primary actions inside glass cards (e.g. "Add task", "Start").
///
/// Follows the [GlassStyle]. Liquid: tinted liquid glass, drawn without a
/// shader (pills sit inside glass cards, and glass refracting through glass
/// is what liquid_glass_widgets flattens anyway) — a top specular sheen
/// gives it the glass edge, and a press squashes it under the finger and
/// springs back elastically. Frosted: a flat tint and hairline border, no
/// press animation.
///
/// Sizes to its label; given a tight width (e.g. a full-width
/// `SizedBox`) the label and [icon] stay centered.
class TintedPill extends StatefulWidget {
  const TintedPill({
    required this.label,
    required this.color,
    this.onTap,
    this.icon,
    super.key,
  });

  final String label;
  final Color color;
  final VoidCallback? onTap;

  /// Optional leading icon, in [color].
  final IconData? icon;

  @override
  State<TintedPill> createState() => _TintedPillState();
}

class _TintedPillState extends State<TintedPill> {
  bool _pressed = false;

  void _setPressed(bool pressed) {
    if (_pressed == pressed) return;
    setState(() => _pressed = pressed);
  }

  /// Fill + border: a flat tint (frosted), or a sheen gradient that
  /// deepens while pressed (liquid).
  BoxDecoration _decoration(bool liquid) {
    final color = widget.color;
    if (!liquid) {
      return BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 0.5),
      );
    }
    return BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: color.withValues(alpha: _pressed ? 0.45 : 0.3),
        width: 0.5,
      ),
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.alphaBlend(
            Colors.white.withValues(alpha: 0.12),
            color.withValues(alpha: 0.22),
          ),
          color.withValues(alpha: _pressed ? 0.26 : 0.16),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color;
    final icon = widget.icon;
    final liquid = GlassStyleScope.of(context) == GlassStyle.liquid;
    // A pill without onTap stays gesture-free, so a tap on it still
    // reaches the row it sits in.
    final interactive = liquid && widget.onTap != null;
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: interactive ? (_) => _setPressed(true) : null,
      onTapUp: interactive ? (_) => _setPressed(false) : null,
      onTapCancel: interactive ? () => _setPressed(false) : null,
      child: AnimatedScale(
        scale: liquid && _pressed ? 0.94 : 1,
        duration: Duration(milliseconds: _pressed ? 90 : 420),
        curve: _pressed ? Curves.easeOut : Curves.elasticOut,
        child: DecoratedBox(
          decoration: _decoration(liquid),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: color),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: Text(
                    widget.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: color,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
