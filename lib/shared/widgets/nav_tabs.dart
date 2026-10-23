import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as lg;

import '../../core/l10n/l10n.dart';
import '../../core/theme/glass_theme.dart';
import '../../core/theme/liquid_glass_presets.dart';

/// Shared sizing + styling for the shell's liquid glass tab bar, whichever
/// [NavPlacement] it's in.
abstract final class NavBarMetrics {
  /// Tab capsule (and write button) height, expanded.
  static const double barHeight = 56;

  /// Height once minimized on scroll (iPhone).
  static const double minimizedBarHeight = 46;

  static const double iconSize = 22;

  /// Width of one tab in the iPad top bar, which hugs its tabs rather
  /// than spanning the window.
  static const double topTabWidth = 64;

  /// Room the iPad top bar takes below the status bar, so the tab content
  /// starts under it.
  static const double topBarExtent = barHeight + 16;

  /// Inactive tab icons.
  static const Color inactiveIconColor = Color(0x47FFFFFF);
}

/// The 5 tabs in shell order, as `(icon, label, accent)`.
List<({IconData icon, String label, Color accent})> navTabSpecs(
  BuildContext context,
) {
  final glass = Theme.of(context).extension<GlassTheme>()!;
  final l10n = context.l10n;
  return [
    (icon: Icons.home_outlined, label: l10n.navHome, accent: glass.homeAccent),
    (
      icon: Icons.checklist_outlined,
      label: l10n.navTasks,
      accent: glass.taskAccent,
    ),
    (
      icon: Icons.menu_book_outlined,
      label: l10n.navJournal,
      accent: glass.journalAccent,
    ),
    (
      icon: Icons.account_balance_wallet_outlined,
      label: l10n.navMoney,
      accent: glass.moneyAccent,
    ),
    (
      icon: Icons.auto_awesome_outlined,
      label: l10n.navAi,
      accent: glass.aiAccent,
    ),
  ];
}

/// The tabs as [lg.GlassTab]s — icon only (the label is for screen
/// readers), in the tab's accent once selected, with an accent glow.
List<lg.GlassTab> buildNavTabs(BuildContext context) => [
  for (final tab in navTabSpecs(context))
    lg.GlassTab(
      icon: Icon(tab.icon, color: NavBarMetrics.inactiveIconColor),
      activeIcon: Icon(tab.icon, color: tab.accent),
      semanticLabel: tab.label,
      glowColor: tab.accent,
    ),
];

/// The liquid indicator droplet's tint for the tab at [index]: a wash of
/// that tab's accent, so the selected tab still reads in its color.
Color navIndicatorColor(BuildContext context, int index) {
  final specs = navTabSpecs(context);
  final accent = specs[index.clamp(0, specs.length - 1)].accent;
  return accent.withValues(alpha: 0.16);
}

/// Glass material for the tab capsule.
const lg.LiquidGlassSettings navBarGlass = LiquidGlassPresets.chrome;
