import 'package:flutter/material.dart';

import '../../../../core/constants/spacing.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/glass_theme.dart';
import '../../../../shared/widgets/tinted_pill.dart';
import '../breathing_session_controller.dart';

/// The session's primary actions, at the bottom of the screen: Start,
/// then Pause (Release during an open-ended hold, Resume while paused)
/// next to Finish.
class SessionControls extends StatelessWidget {
  const SessionControls({
    required this.controller,
    required this.onFinish,
    super.key,
  });

  final BreathingSessionController controller;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final primary = _primaryAction(context, glass.exerciseAccent);
        if (controller.status == SessionStatus.idle) {
          return primary;
        }
        return Row(
          children: [
            Expanded(child: primary),
            const SizedBox(width: Spacing.sm),
            Expanded(
              child: _Pill(
                label: context.l10n.breathingFinish,
                color: Colors.white,
                onTap: onFinish,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _primaryAction(BuildContext context, Color accent) {
    final l10n = context.l10n;
    final (label, onTap) = switch (controller.status) {
      SessionStatus.idle => (l10n.breathingStart, controller.start),
      SessionStatus.running when controller.engine.phase.isOpenEnded => (
        l10n.breathingReleaseButton,
        controller.release,
      ),
      SessionStatus.running => (l10n.breathingPause, controller.pause),
      SessionStatus.paused => (l10n.breathingResume, controller.resume),
    };
    return _Pill(label: label, color: accent, onTap: onTap);
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color, required this.onTap});

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TintedPill(label: label, color: color, onTap: onTap),
    );
  }
}
