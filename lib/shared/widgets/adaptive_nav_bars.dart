import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as lg;

import 'floating_nav_write_button.dart';
import 'nav_tabs.dart';

/// iPadOS-style tab bar — [NavPlacement.top]: a liquid glass capsule
/// hugging its tabs, centered in a row just below the status bar, with
/// the write button at the trailing end of that row.
///
/// Never minimizes (iPadOS doesn't). The shell pushes the tab content
/// down by [NavBarMetrics.topBarExtent] so nothing starts under it.
class TopNavBar extends StatelessWidget {
  const TopNavBar({
    required this.currentIndex,
    required this.onTabChanged,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onTabChanged;

  @override
  Widget build(BuildContext context) {
    final tabs = buildNavTabs(context);
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
        child: SizedBox(
          height: NavBarMetrics.barHeight,
          child: Stack(
            children: [
              Center(
                child: SizedBox(
                  width: NavBarMetrics.topTabWidth * tabs.length,
                  child: lg.GlassTabBar.bottom(
                    tabs: tabs,
                    selectedIndex: currentIndex,
                    onTabSelected: onTabChanged,
                    horizontalPadding: 0,
                    verticalPadding: 0,
                    barHeight: NavBarMetrics.barHeight,
                    tabWidth: NavBarMetrics.topTabWidth,
                    iconSize: NavBarMetrics.iconSize,
                    settings: navBarGlass,
                    indicatorColor: navIndicatorColor(context, currentIndex),
                  ),
                ),
              ),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: WriteButton(tabIndex: currentIndex),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// iPhone Duo's vertical bar strip — [NavPlacement.verticalStrip].
///
/// Fills the screen and draws only in the strip: the tab capsule stacks
/// at the strip's bottom (the package lays [lg.GlassTabBar.bottom] out
/// vertically there on its own), the write button at its top, where UIKit
/// puts a screen's bar items. Content is already kept clear of the strip
/// by the system's lateral inset.
class StripNavBar extends StatelessWidget {
  const StripNavBar({
    required this.currentIndex,
    required this.onTabChanged,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onTabChanged;

  @override
  Widget build(BuildContext context) {
    final bar = lg.GlassVerticalBar.maybeOf(context);
    return Stack(
      children: [
        Positioned.fill(
          child: lg.GlassTabBar.bottom(
            tabs: buildNavTabs(context),
            selectedIndex: currentIndex,
            onTabSelected: onTabChanged,
            iconSize: NavBarMetrics.iconSize,
            settings: navBarGlass,
            indicatorColor: navIndicatorColor(context, currentIndex),
          ),
        ),
        if (bar != null) _stripWriteButton(context, bar),
      ],
    );
  }

  /// The write button where the strip's first control goes: [bar].top
  /// down, [lg.GlassVerticalBarMetrics.inset] from the strip's inner edge.
  Widget _stripWriteButton(BuildContext context, lg.GlassVerticalBarData bar) {
    const extent = lg.GlassVerticalBarMetrics.controlExtent;
    final fromScreenEdge =
        bar.width - lg.GlassVerticalBarMetrics.inset - extent;
    // The edge is relative to the reading direction; the strip itself
    // stays on the same physical side.
    final ltr = Directionality.of(context) == TextDirection.ltr;
    final onRight = (bar.edge == lg.GlassVerticalBarEdge.trailing) == ltr;
    return Positioned(
      top: bar.top,
      left: onRight ? null : fromScreenEdge,
      right: onRight ? fromScreenEdge : null,
      child: WriteButton(tabIndex: currentIndex, size: extent),
    );
  }
}
