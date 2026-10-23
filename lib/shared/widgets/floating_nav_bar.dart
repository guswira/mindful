import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as lg;

import '../../core/constants/layout.dart';
import 'floating_nav_write_button.dart';
import 'nav_tabs.dart';

/// Bottom liquid glass tab bar (5 tabs: Home, Tasks & Routines,
/// Mindfulness, Money, AI) + write button — [NavPlacement.bottom].
///
/// A [lg.GlassTabBar.minimizable]: the selected tab sits under a liquid
/// glass droplet that slides between tabs with jelly physics (drag along
/// the bar to scrub it). With a [minimizeController] driving it (iPhone),
/// scrolling down shrinks the bar to the selected tab's circle and the
/// write button with it; scrolling back up or tapping the circle brings it
/// back. See SPEC.md Floating Island Nav Bar.
class FloatingNavBar extends StatelessWidget {
  const FloatingNavBar({
    required this.currentIndex,
    required this.onTabChanged,
    this.minimizeController,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onTabChanged;

  /// Null keeps the bar expanded (tests, Android).
  final lg.GlassTabBarMinimizeController? minimizeController;

  @override
  Widget build(BuildContext context) {
    final controller = minimizeController;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
        // Centered and capped on Mac / Android tablets rather than
        // stretched across the window; a phone is narrower than the cap.
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppLayout.maxNavWidth),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: lg.GlassTabBar.minimizable(
                    tabs: buildNavTabs(context),
                    selectedIndex: currentIndex,
                    onTabSelected: onTabChanged,
                    minimizeController: controller,
                    onMinimizedTabTap: controller?.expand,
                    horizontalPadding: 0,
                    verticalPadding: 0,
                    barHeight: NavBarMetrics.barHeight,
                    minimizedBarHeight: NavBarMetrics.minimizedBarHeight,
                    iconSize: NavBarMetrics.iconSize,
                    settings: navBarGlass,
                    indicatorColor: navIndicatorColor(context, currentIndex),
                  ),
                ),
                const SizedBox(width: 10),
                _MinimizingWriteButton(
                  tabIndex: currentIndex,
                  minimizeController: controller,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The write button, shrinking along with the minimized tab bar — like
/// the trailing circle next to a minimized iOS 26 tab bar.
class _MinimizingWriteButton extends StatelessWidget {
  const _MinimizingWriteButton({
    required this.tabIndex,
    required this.minimizeController,
  });

  final int tabIndex;
  final lg.GlassTabBarMinimizeController? minimizeController;

  @override
  Widget build(BuildContext context) {
    final controller = minimizeController;
    if (controller == null) {
      return WriteButton(tabIndex: tabIndex);
    }
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => WriteButton(
        tabIndex: tabIndex,
        size: controller.minimized
            ? NavBarMetrics.minimizedBarHeight
            : NavBarMetrics.barHeight,
      ),
    );
  }
}
