import 'package:flutter/material.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/glass_theme.dart';
import '../services/ai_activity.dart';
import 'glass_card.dart';
import 'nav_placement.dart';
import 'nav_tabs.dart';

/// Floats [AiActivityIndicator] at the top of every screen, over [child]
/// (the router — so it also sits above sheets and dialogs). Only the pills
/// themselves take touches; the rest of the strip lets them through.
class AiActivityOverlay extends StatelessWidget {
  const AiActivityOverlay({
    required this.activities,
    required this.onDismiss,
    required this.child,
    super.key,
  });

  final List<AiActivity> activities;

  /// Called with an activity's id when its ready pill is closed unopened.
  final void Function(int id) onDismiss;

  final Widget child;

  /// Below the status bar — and below the iPad's top tab bar, which sits
  /// there too.
  double _top(BuildContext context) {
    final placement = navPlacementOf(context);
    final topBar = placement == NavPlacement.top
        ? NavBarMetrics.topBarExtent
        : 0.0;
    return MediaQuery.paddingOf(context).top + topBar + 8;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned(
          top: _top(context),
          left: 16,
          right: 16,
          child: Center(
            child: AiActivityIndicator(
              activities: activities,
              onDismiss: onDismiss,
            ),
          ),
        ),
      ],
    );
  }
}

/// A small glass pill per AI request: a spinner + what it's doing (and the
/// retry attempt) while it runs, then "ready — tap to view" with a close
/// button once it's done. Never blocks the screen, so the user keeps using
/// the app while Gemini works. Nothing at all while there's no activity.
class AiActivityIndicator extends StatelessWidget {
  const AiActivityIndicator({
    required this.activities,
    required this.onDismiss,
    super.key,
  });

  final List<AiActivity> activities;

  /// Called with an activity's id when its ready pill is closed unopened.
  final void Function(int id) onDismiss;

  static const Duration _duration = Duration(milliseconds: 250);

  static Widget _transition(Widget child, Animation<double> animation) =>
      FadeTransition(
        opacity: animation,
        child: SizeTransition(
          sizeFactor: animation,
          alignment: Alignment.topCenter,
          child: child,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : _duration;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final activity in activities)
            AnimatedSwitcher(
              key: ValueKey(activity.id),
              duration: duration,
              transitionBuilder: _transition,
              child: _AiActivityPill(
                key: ValueKey((activity.id, activity.isReady)),
                activity: activity,
                onDismiss: () => onDismiss(activity.id),
              ),
            ),
        ],
      ),
    );
  }
}

class _AiActivityPill extends StatelessWidget {
  const _AiActivityPill({
    required this.activity,
    required this.onDismiss,
    super.key,
  });

  final AiActivity activity;
  final VoidCallback onDismiss;

  String _label(BuildContext context) {
    final l10n = context.l10n;
    if (activity.isReady) {
      return switch (activity.kind) {
        AiActivityKind.foodScan => l10n.aiActivityFoodReady,
        AiActivityKind.moneyAdvice => l10n.aiActivityAdviceReady,
      };
    }
    final running = switch (activity.kind) {
      AiActivityKind.foodScan => l10n.aiAnalyzingTitle,
      AiActivityKind.moneyAdvice => l10n.moneyAdviceLoading,
    };
    if (activity.attempt <= 1) {
      return running;
    }
    return l10n.aiActivityRetrying(
      running,
      activity.attempt,
      activity.maxAttempts,
    );
  }

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final style = Theme.of(context).textTheme.labelLarge;
    final pill = Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: GlassCard(
        strong: true,
        borderRadius: 22,
        padding: EdgeInsets.fromLTRB(14, 8, activity.isReady ? 4 : 16, 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (activity.isReady)
              Icon(Icons.auto_awesome_outlined, color: glass.aiAccent, size: 16)
            else
              SizedBox.square(
                dimension: 14,
                child: CircularProgressIndicator(
                  color: glass.aiAccent,
                  strokeWidth: 2,
                ),
              ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                _label(context),
                style: style,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (activity.isReady)
              IconButton(
                onPressed: onDismiss,
                tooltip: context.l10n.commonClose,
                visualDensity: VisualDensity.compact,
                iconSize: 16,
                color: glass.textSecondary,
                icon: const Icon(Icons.close_rounded),
              ),
          ],
        ),
      ),
    );
    if (!activity.isReady) {
      // Purely informational — taps go straight through to the screen.
      return IgnorePointer(child: pill);
    }
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: activity.open,
        child: pill,
      ),
    );
  }
}
