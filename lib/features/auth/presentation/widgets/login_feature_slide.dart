import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/spacing.dart';
import '../../../../core/theme/glass_theme.dart';

/// One feature shown in the login screen's carousel.
@immutable
class LoginFeature {
  const LoginFeature({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });

  /// Flat outlined icon, drawn in [color] — the same family as the nav bar.
  final IconData icon;

  /// The feature's accent from [GlassTheme], so the slide matches its tab.
  final Color color;
  final String title;
  final String body;
}

/// A carousel slide: an animated icon badge over the feature's title and
/// a short description.
///
/// [offset] is how far this slide is from the centered one (0 = centered,
/// ±1 = a full page away) and is read mid-swipe, so the slide parallaxes,
/// shrinks and fades with the finger instead of only after the page snaps.
class LoginFeatureSlide extends StatelessWidget {
  const LoginFeatureSlide({
    required this.feature,
    required this.offset,
    required this.idle,
    super.key,
  });

  final LoginFeature feature;
  final double offset;

  /// Looping 0→1→0 value that drives the badge's breathing and orbit.
  final Animation<double> idle;

  double get _distance => offset.abs().clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return Opacity(
      opacity: 1 - _distance * 0.8,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.translate(
              offset: Offset(offset * 80, 0),
              child: Transform.scale(
                scale: 1 - _distance * 0.3,
                child: _AnimatedBadge(feature: feature, idle: idle),
              ),
            ),
            const SizedBox(height: 40),
            Transform.translate(
              offset: Offset(offset * 40, 0),
              child: Text(
                feature.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: Spacing.sm),
            Transform.translate(
              offset: Offset(offset * 20, 0),
              child: Text(
                feature.body,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: glass.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedBadge extends StatelessWidget {
  const _AnimatedBadge({required this.feature, required this.idle});

  final LoginFeature feature;
  final Animation<double> idle;

  static const double _size = 180;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: _size,
      child: AnimatedBuilder(
        animation: idle,
        builder: (context, child) => CustomPaint(
          painter: _OrbitPainter(color: feature.color, t: idle.value),
          child: child,
        ),
        child: Center(
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 1,
              end: 1.06,
            ).animate(CurvedAnimation(parent: idle, curve: Curves.easeInOut)),
            child: _Badge(feature: feature),
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.feature});

  final LoginFeature feature;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 104,
      height: 104,
      decoration: BoxDecoration(
        color: feature.color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: feature.color.withValues(alpha: 0.35),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: feature.color.withValues(alpha: 0.25),
            blurRadius: 40,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Icon(feature.icon, size: 48, color: feature.color),
    );
  }
}

/// A faint ring around the badge with three accent dots circling it, and a
/// second ring that swells and fades with the badge's breath.
class _OrbitPainter extends CustomPainter {
  _OrbitPainter({required this.color, required this.t});

  final Color color;

  /// Idle value, 0→1→0.
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 6;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5
        ..color = color.withValues(alpha: 0.25),
    );
    canvas.drawCircle(
      center,
      radius * (0.72 + 0.08 * t),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = color.withValues(alpha: 0.30 * (1 - t)),
    );

    // The idle controller reverses, so the orbit swings back and forth
    // rather than spinning — calmer, and it never jumps at the loop point.
    final base = t * math.pi * 0.9;
    final dot = Paint()..color = color;
    for (var i = 0; i < 3; i++) {
      final angle = base + i * (2 * math.pi / 3);
      final position =
          center + Offset(math.cos(angle), math.sin(angle)) * radius;
      dot.color = color.withValues(alpha: 0.9 - i * 0.25);
      canvas.drawCircle(position, 4.0 - i, dot);
    }
  }

  @override
  bool shouldRepaint(_OrbitPainter oldDelegate) =>
      oldDelegate.t != t || oldDelegate.color != color;
}
