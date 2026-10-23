import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as lg;

import '../../core/constants/layout.dart';

/// Where the shell's tab bar + write button sit — the iOS 26/27 liquid
/// glass positions. See SPEC.md Floating Island Nav Bar → Placement.
enum NavPlacement {
  /// Floating capsule at the bottom, write button beside it: iPhone,
  /// Android (phones, tablets, foldables), Mac, an iPad in a compact Split
  /// View column. On iPhone it minimizes to the selected tab while
  /// scrolling down.
  bottom,

  /// Floating capsule centered at the top, write button at the trailing
  /// end of the same row — iPadOS's tab bar, at regular width.
  top,

  /// Stacked in iPhone Duo's vertical bar strip beside the content: tabs
  /// at the bottom of the strip, write button at the top.
  verticalStrip,
}

/// Picks the placement for a window of [size] on [platform].
///
/// [hasVerticalBar]: the device reserves a vertical bar strip
/// ([lg.GlassVerticalBar.maybeOf] — iPhone Duo, built against the iOS 27.1
/// SDK). [splitByHinge]: a hinge / half-open fold splits the window
/// ([AppLayout.verticalSeparator]), which keeps the bottom bar on the right
/// half.
NavPlacement resolveNavPlacement({
  required TargetPlatform platform,
  required Size size,
  bool hasVerticalBar = false,
  bool splitByHinge = false,
}) {
  if (hasVerticalBar) {
    return NavPlacement.verticalStrip;
  }
  // iPadOS only moves the tab bar up at regular width; a narrow Split View
  // or Slide Over column keeps it at the bottom, like an iPhone. The window
  // size says which, so no idiom check is needed — an iPhone in landscape
  // is never 600 tall.
  final regularIPad =
      platform == TargetPlatform.iOS &&
      size.shortestSide >= AppLayout.tabletMinShortestSide;
  if (regularIPad && !splitByHinge) {
    return NavPlacement.top;
  }
  return NavPlacement.bottom;
}

/// [resolveNavPlacement] for [context]'s window.
NavPlacement navPlacementOf(BuildContext context) => resolveNavPlacement(
  platform: Theme.of(context).platform,
  size: MediaQuery.sizeOf(context),
  hasVerticalBar: lg.GlassVerticalBar.maybeOf(context) != null,
  splitByHinge: AppLayout.verticalSeparator(context) != null,
);
