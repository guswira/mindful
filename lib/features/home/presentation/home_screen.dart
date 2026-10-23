import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as lg;

import '../../../core/constants/layout.dart';
import '../../../core/theme/glass_style.dart';
import '../../../core/theme/glass_style_scope.dart';
import '../../../shared/widgets/adaptive_nav_bars.dart';
import '../../../shared/widgets/floating_nav_bar.dart';
import '../../../shared/widgets/frosted_nav_bar.dart';
import '../../../shared/widgets/nav_placement.dart';
import '../../../shared/widgets/nav_tabs.dart';

/// Shell for the /home/today, /home/tasks (tasks & routines),
/// /home/journal (journal & exercise), /home/money and /home/ai branches,
/// in that order, with the nav overlaid in the user's [GlassStyle]: the
/// liquid glass tab bar where the platform puts it ([navPlacementOf] —
/// bottom on iPhone, Android and Mac, top on iPad, the vertical bar strip
/// on iPhone Duo), or the frosted island, always at the bottom. See SPEC.md Navigation and Floating
/// Island Nav Bar sections.
class HomeScreen extends StatefulWidget {
  const HomeScreen({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _minimize = lg.GlassTabBarMinimizeController();

  @override
  void dispose() {
    _minimize.dispose();
    super.dispose();
  }

  void _goBranch(int index) {
    // Each tab owns its own scroll view, so a new tab starts expanded.
    _minimize.expand();
    widget.navigationShell.goBranch(index);
  }

  /// Feeds the tab's own (outermost, vertical) list to the minimize
  /// controller — the shell can't reach each tab's ScrollController.
  bool _onScroll(ScrollNotification notification) {
    if (notification.depth == 0) {
      _minimize.handleNotification(notification);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final liquid = GlassStyleScope.of(context) == GlassStyle.liquid;
    // The platform positions are part of liquid glass; frosted keeps its
    // bottom island everywhere.
    final placement = liquid ? navPlacementOf(context) : NavPlacement.bottom;
    // Minimizing on scroll is the iPhone liquid tab bar's behavior;
    // Android, Mac and the frosted island stay expanded.
    _minimize.behavior =
        liquid && Theme.of(context).platform == TargetPlatform.iOS
        ? lg.GlassBarMinimizeBehavior.onScrollDown
        : lg.GlassBarMinimizeBehavior.never;
    final shell = widget.navigationShell;
    return Scaffold(
      body: Stack(
        children: [
          // Same widgets around the shell in every placement, so resizing
          // across one (an iPad Split View drag) keeps every tab's state.
          NotificationListener<ScrollNotification>(
            onNotification: _onScroll,
            child: _ContentInset(
              top: placement == NavPlacement.top
                  ? NavBarMetrics.topBarExtent
                  : 0,
              child: shell,
            ),
          ),
          switch (placement) {
            NavPlacement.bottom => Positioned(
              bottom: 0,
              left: _navLeftInset(context),
              right: 0,
              child: liquid
                  ? FloatingNavBar(
                      currentIndex: shell.currentIndex,
                      onTabChanged: _goBranch,
                      minimizeController: _minimize,
                    )
                  : FrostedNavBar(
                      currentIndex: shell.currentIndex,
                      onTabChanged: _goBranch,
                    ),
            ),
            NavPlacement.top => Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: TopNavBar(
                currentIndex: shell.currentIndex,
                onTabChanged: _goBranch,
              ),
            ),
            NavPlacement.verticalStrip => Positioned.fill(
              child: StripNavBar(
                currentIndex: shell.currentIndex,
                onTabChanged: _goBranch,
              ),
            ),
          },
        ],
      ),
    );
  }

  /// On a screen split by a hinge / half-open fold the nav bar sits on the
  /// right half, rather than being cut in two by the split.
  double _navLeftInset(BuildContext context) =>
      AppLayout.verticalSeparator(context)?.right ?? 0;
}

/// Pushes the tabs' content [top] further down — below [TopNavBar] on
/// iPad. Every tab insets itself with a SafeArea, so growing the top
/// padding is enough.
class _ContentInset extends StatelessWidget {
  const _ContentInset({required this.top, required this.child});

  final double top;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return MediaQuery(
      data: media.copyWith(
        padding: media.padding.copyWith(top: media.padding.top + top),
      ),
      child: child,
    );
  }
}
