import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A ripple's progress through its lifetime ([t], 0 → 1) and whether it
/// marks a completed cycle.
class RippleState {
  const RippleState({required this.t, required this.strong});

  final double t;
  final bool strong;
}

/// Paints [BreathingCircle]: a soft glowing disc sized by [fullness], the
/// step-progress ring around its largest size, and expanding ripples.
class BreathingCirclePainter extends CustomPainter {
  BreathingCirclePainter({
    required this.fullness,
    required this.progress,
    required this.ripples,
    required this.accent,
    required this.track,
  });

  /// Eased lung fullness, 0 → 1.
  final double fullness;

  /// The current step's progress, 0 → 1 (0 for an open-ended hold).
  final double progress;
  final List<RippleState> ripples;
  final Color accent;
  final Color track;

  /// The disc at empty lungs, as a fraction of its full size.
  static const double _minScale = 0.55;

  /// The disc at full lungs, as a fraction of the shortest side's radius —
  /// what's left outside is room for the ripples to travel.
  static const double _maxRadiusFactor = 0.62;
  static const double _ringGap = 10;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final outer = size.shortestSide / 2;
    final maxRadius = outer * _maxRadiusFactor;
    final radius = maxRadius * (_minScale + (1 - _minScale) * fullness);

    for (final ripple in ripples) {
      _paintRipple(canvas, center, radius, outer, ripple);
    }

    final ringRadius = maxRadius + _ringGap;
    canvas.drawCircle(
      center,
      ringRadius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = track,
    );
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: ringRadius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round
          ..color = accent,
      );
    }

    canvas.drawCircle(
      center,
      radius * 1.08,
      Paint()
        ..color = accent.withValues(alpha: 0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24),
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            accent.withValues(alpha: 0.55),
            accent.withValues(alpha: 0.14),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = accent.withValues(alpha: 0.6),
    );
  }

  void _paintRipple(
    Canvas canvas,
    Offset center,
    double from,
    double to,
    RippleState ripple,
  ) {
    final t = Curves.easeOut.transform(ripple.t);
    final fade = 1 - ripple.t;
    canvas.drawCircle(
      center,
      from + (to - from) * t,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = (ripple.strong ? 3 : 1.5) * fade + 0.5
        ..color = accent.withValues(alpha: (ripple.strong ? 0.6 : 0.35) * fade),
    );
  }

  @override
  bool shouldRepaint(BreathingCirclePainter oldDelegate) => true;
}
