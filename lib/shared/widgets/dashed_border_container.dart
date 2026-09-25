import 'package:flutter/material.dart';

/// A container with a dashed rounded-rect border — Flutter has no built-in
/// dashed [BoxBorder], so this paints one directly.
class DashedBorderContainer extends StatelessWidget {
  const DashedBorderContainer({
    required this.child,
    this.color = Colors.white24,
    this.borderRadius = 12,
    this.padding = const EdgeInsets.all(12),
    super.key,
  });

  final Widget child;
  final Color color;
  final double borderRadius;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedRRectPainter(color: color, radius: borderRadius),
      child: Padding(padding: padding, child: child),
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  _DashedRRectPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  static const double _dashWidth = 6;
  static const double _dashGap = 4;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + _dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + _dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedRRectPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}
