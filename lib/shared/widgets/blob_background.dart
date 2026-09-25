import 'dart:ui';

import 'package:flutter/material.dart';

/// The 3-blob blurred background layer used behind content on every main
/// screen, per the frosted glass dark theme.
class BlobBackground extends StatelessWidget {
  const BlobBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: IgnorePointer(child: _Blobs())),
        child,
      ],
    );
  }
}

class _Blobs extends StatelessWidget {
  const _Blobs();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        Positioned(
          top: -40,
          right: -30,
          child: _Blob(size: 200, color: Color(0xFF14E6AA), opacity: 0.18),
        ),
        Positioned(
          bottom: 200,
          left: -40,
          child: _Blob(size: 160, color: Color(0xFF378ADD), opacity: 0.18),
        ),
        Positioned(
          top: 280,
          right: 20,
          child: _Blob(size: 120, color: Color(0xFF9E9E9E), opacity: 0.12),
        ),
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.size, required this.color, required this.opacity});

  final double size;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withValues(alpha: opacity),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
