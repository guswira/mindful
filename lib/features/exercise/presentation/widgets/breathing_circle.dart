import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/glass_theme.dart';
import '../breathing_labels.dart';
import '../breathing_session_controller.dart';
import 'breathing_circle_painter.dart';

/// The breathing circle: grows on inhale, holds, shrinks on release, with
/// a ring of the current step's progress and ripples on every step (a
/// stronger one each completed cycle). The current step and its countdown
/// sit in the middle.
class BreathingCircle extends StatelessWidget {
  const BreathingCircle({required this.controller, super.key});

  final BreathingSessionController controller;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    return RepaintBoundary(
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, _) => CustomPaint(
          painter: BreathingCirclePainter(
            fullness: Curves.easeInOut.transform(controller.engine.fullness),
            progress: controller.engine.phaseProgress,
            ripples: reduceMotion ? const [] : _rippleStates(),
            accent: glass.exerciseAccent,
            track: glass.cardBorder,
          ),
          child: Center(child: _CircleLabel(controller: controller)),
        ),
      ),
    );
  }

  List<RippleState> _rippleStates() {
    final now = controller.engine.elapsed;
    final lifetime = BreathingSessionController.rippleLifetime.inMicroseconds
        .toDouble();
    return [
      for (final ripple in controller.ripples)
        RippleState(
          t: math.min(1, (now - ripple.at).inMicroseconds / lifetime),
          strong: ripple.strong,
        ),
    ];
  }
}

class _CircleLabel extends StatelessWidget {
  const _CircleLabel({required this.controller});

  final BreathingSessionController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return switch (controller.status) {
      SessionStatus.idle => Text(
        l10n.breathingReady,
        textAlign: TextAlign.center,
        style: textTheme.bodyMedium?.copyWith(color: glass.textSecondary),
      ),
      SessionStatus.running || SessionStatus.paused => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            controller.status == SessionStatus.paused
                ? l10n.breathingPaused
                : l10n.phaseWord(controller.engine.phase.type),
            textAlign: TextAlign.center,
            style: textTheme.titleLarge?.copyWith(color: Colors.white),
          ),
          Text(
            '${controller.engine.phaseCounter}',
            style: textTheme.displaySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    };
  }
}
