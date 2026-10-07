import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/layout.dart';
import '../../../shared/widgets/floating_nav_bar.dart';

/// Shell for the /home/today, /home/tasks (tasks & routines),
/// /home/journal (journal & exercise), /home/money and /home/ai branches,
/// in that order, with [FloatingNavBar] overlaid at the bottom.
/// See SPEC.md Navigation and Floating Island Nav Bar sections.
class HomeScreen extends StatelessWidget {
  const HomeScreen({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          navigationShell,
          Positioned(
            bottom: 0,
            left: _navLeftInset(context),
            right: 0,
            child: FloatingNavBar(
              currentIndex: navigationShell.currentIndex,
              onTabChanged: navigationShell.goBranch,
            ),
          ),
        ],
      ),
    );
  }

  /// On a screen split by a hinge / half-open fold the nav bar sits on the
  /// right half, rather than being cut in two by the split.
  double _navLeftInset(BuildContext context) =>
      AppLayout.verticalSeparator(context)?.right ?? 0;
}
