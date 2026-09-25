import 'package:flutter/material.dart';

import 'glass_card.dart';

/// Shows [builder]'s content inside the shared bottom-sheet chrome used by
/// every add/detail sheet in the app: transparent barrier, rounded top
/// corners, keyboard-aware [GlassBottomSheet] fill.
///
/// Uses the root navigator: tab screens each sit in their own nested
/// [Navigator] (from `StatefulShellRoute.indexedStack`), which is painted
/// *below* [FloatingNavBar] in [HomeScreen]'s [Stack]. A sheet pushed onto
/// that nested Navigator would render behind the nav bar; pushing it onto
/// the root Navigator instead puts it above everything.
Future<T?> showGlassBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isDismissible = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    isDismissible: isDismissible,
    enableDrag: isDismissible,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) => GlassBottomSheet(child: builder(context)),
  );
}

/// A drag handle above a strong [GlassCard], riding up with the keyboard.
///
/// Caps its own height to whatever's left of the screen above the keyboard
/// (and below the status bar), rather than letting [child] grow to its
/// natural size unconstrained — a tall sheet (e.g. [AddHabitSheet]) plus an
/// open keyboard could otherwise push the sheet's top, and everything in
/// it above the fold, off the top of the screen with no way to reach it.
/// [Flexible] passes that bound down so [child]'s own scroll view (every
/// add sheet has one) actually scrolls instead of overflowing.
///
/// [MediaQuery.viewInsets] fires several metrics-changed updates over the
/// course of the keyboard's own slide-in animation, not just one at the
/// end — a plain [Padding]/[ConstrainedBox] would jump to each new value
/// immediately, snapping the sheet's height in a few jagged steps instead
/// of following the keyboard smoothly. [AnimatedPadding]/[AnimatedContainer]
/// tween between whatever value they last had and each new target instead,
/// which is what actually produces one continuous motion. See the
/// bottom-sheet design rules in SPEC.md.
class GlassBottomSheet extends StatelessWidget {
  const GlassBottomSheet({required this.child, super.key});

  final Widget child;

  static const Duration _keyboardAnimationDuration = Duration(
    milliseconds: 250,
  );

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final keyboardHeight = mediaQuery.viewInsets.bottom;
    return AnimatedPadding(
      duration: _keyboardAnimationDuration,
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: SafeArea(
        top: false,
        child: AnimatedContainer(
          duration: _keyboardAnimationDuration,
          curve: Curves.easeOut,
          constraints: BoxConstraints(
            maxHeight:
                mediaQuery.size.height -
                mediaQuery.padding.top -
                keyboardHeight,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _DragHandle(),
              Flexible(
                child: GlassCard(strong: true, borderRadius: 28, child: child),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
