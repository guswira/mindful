import 'dart:ui' show DisplayFeatureState, DisplayFeatureType;

import 'package:flutter/widgets.dart';

/// Width caps for big screens (Mac, iPad), so the phone-first layout
/// doesn't stretch edge to edge. A phone is narrower than every cap here,
/// so none of this changes anything on one.
class AppLayout {
  AppLayout._();

  /// Screen content (tabs, full-page screens) is centered at this width;
  /// the background still fills the window.
  static const double maxContentWidth = 720;

  /// Add/detail sheets shown as a centered dialog on wide screens.
  static const double maxSheetWidth = 560;

  /// The floating nav island + write button.
  static const double maxNavWidth = 520;

  /// From this width a bottom sheet would be mostly empty glass, so
  /// sheets open as a centered dialog instead.
  static const double wideMinWidth = maxContentWidth;

  /// Whether [context]'s screen is wide enough for the big-screen layout.
  static bool isWide(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= wideMinWidth;

  /// The narrowest width a list and its selected item's details share —
  /// a phone in landscape and up (list ~3/5, details ~2/5).
  static const double twoPaneMinWidth = 640;

  /// A screen whose shorter side is at least this is a tablet (or a Mac
  /// window sized like one) — Material's compact/medium boundary.
  static const double tabletMinShortestSide = 600;

  /// List + detail screens are centered at this width instead of
  /// [maxContentWidth].
  static const double maxTwoPaneWidth = 1200;

  /// Whether [context]'s screen shows a list and its details side by side:
  /// a tablet in either orientation, or anything in landscape, as long as
  /// it's at least [twoPaneMinWidth] wide — and always on a device split
  /// by a [verticalSeparator], one screen each.
  static bool isTwoPane(BuildContext context) {
    if (verticalSeparator(context) != null) {
      return true;
    }
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= tabletMinShortestSide;
    final isLandscape = size.width > size.height;
    return size.width >= twoPaneMinWidth && (isTablet || isLandscape);
  }

  /// Where the screen is physically split into a left and a right half —
  /// a hinge (dual-screen phones), or a fold that's half open like a book —
  /// in screen coordinates. Null when there's nothing to avoid: no fold, a
  /// fold that's flat (fully unfolded, one continuous screen), or one
  /// running side to side (tabletop).
  static Rect? verticalSeparator(BuildContext context) {
    for (final feature in MediaQuery.displayFeaturesOf(context)) {
      final splits =
          feature.type == DisplayFeatureType.hinge ||
          (feature.type == DisplayFeatureType.fold &&
              feature.state == DisplayFeatureState.postureHalfOpened);
      final runsTopToBottom = feature.bounds.height > feature.bounds.width;
      if (splits && runsTopToBottom) {
        return feature.bounds;
      }
    }
    return null;
  }

  /// How wide a list + detail tab's content may get: the whole window
  /// when split by a [verticalSeparator] (the list and pane line up with
  /// it), [maxTwoPaneWidth] side by side, else [maxContentWidth].
  static double listDetailMaxWidth(BuildContext context) {
    if (verticalSeparator(context) != null) {
      return double.infinity;
    }
    return isTwoPane(context) ? maxTwoPaneWidth : maxContentWidth;
  }
}
