import 'package:flutter/material.dart';

/// App-wide scroll behavior that swaps Android's Material 3 stretch
/// overscroll for the classic glow.
///
/// The stretch effect wraps the whole scroll view in a filtered
/// [Transform] while the user pulls past an edge. A [BackdropFilter]
/// inside that layer can only sample the layer itself, not the background
/// behind the list, so every `GlassCard`'s frost vanished until the
/// stretch sprang back. The glow paints over the content instead of
/// transforming it.
class GlassScrollBehavior extends MaterialScrollBehavior {
  const GlassScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    if (getPlatform(context) != TargetPlatform.android) {
      return super.buildOverscrollIndicator(context, child, details);
    }
    return GlowingOverscrollIndicator(
      axisDirection: details.direction,
      color: Theme.of(context).colorScheme.secondary,
      child: child,
    );
  }
}
