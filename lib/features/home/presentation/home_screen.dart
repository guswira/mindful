import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/floating_nav_bar.dart';

/// Shell for the /home/today, /home/tasks, /home/habits and /home/journal
/// branches, in that order, with [FloatingNavBar] overlaid at the bottom.
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
            left: 0,
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
}
