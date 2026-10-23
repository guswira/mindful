import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as lg;

import '../../core/l10n/l10n.dart';
import '../../core/theme/glass_theme.dart';
import '../../core/theme/liquid_glass_presets.dart';
import 'glass_bottom_sheet.dart';
import 'write_options_sheet.dart';

/// Tinted liquid glass write button beside the tab bar, in the current
/// tab's accent (teal on Home — see [writeButtonGradient]).
///
/// Tapping morphs the write menu of the tab at [tabIndex] out of the
/// button ([lg.GlassMenu] — the button empties, a glass droplet inflates
/// into the menu, closing pours it back). Holding opens the same menu and
/// lets the finger slide onto an item; lifting over one opens it, like a
/// long-pressed iOS 26 bar button. See SPEC.md Floating Island Nav Bar.
class WriteButton extends StatefulWidget {
  const WriteButton({this.tabIndex, this.size = 56, super.key});

  /// The current shell tab, or null for the full menu.
  final int? tabIndex;

  /// Width and height — follows the tab bar (smaller while it's
  /// minimized, the strip's control size on iPhone Duo).
  final double size;

  @override
  State<WriteButton> createState() => _WriteButtonState();
}

class _WriteButtonState extends State<WriteButton> {
  final _menu = lg.GlassMenuController();

  /// Holds the menu open until the finger lifts, sliding over items.
  void _handleLongPressStart(LongPressStartDetails details) => _menu.open();

  void _handleLongPressMoveUpdate(LongPressMoveUpdateDetails details) =>
      _menu.glideTo(details.globalPosition);

  /// Lifting over an item opens it; anywhere else leaves the menu open
  /// for a tap, as on iOS.
  void _handleLongPressEnd(LongPressEndDetails details) => _menu.endGlide();

  void _openSheet(WriteOption option) {
    showGlassBottomSheet<void>(context: context, builder: (_) => option.sheet);
  }

  List<Widget> _menuItems() => [
    for (final option in writeOptionsFor(context, widget.tabIndex))
      lg.GlassMenuItem(
        title: option.label,
        icon: Icon(option.icon, color: option.color),
        onTap: () => _openSheet(option),
      ),
  ];

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final accent = writeButtonGradient(glass, widget.tabIndex).first;
    return GestureDetector(
      onLongPressStart: _handleLongPressStart,
      onLongPressMoveUpdate: _handleLongPressMoveUpdate,
      onLongPressEnd: _handleLongPressEnd,
      onLongPressCancel: _menu.cancelGlide,
      child: lg.GlassMenu(
        controller: _menu,
        menuWidth: 240,
        items: _menuItems(),
        triggerBuilder: (context, toggleMenu) => _WriteButtonFace(
          accent: accent,
          size: widget.size,
          onTap: toggleMenu,
        ),
      ),
    );
  }
}

/// The button itself: prominent glass tinted with [accent], easing to a
/// new tab's accent (and size) instead of snapping.
class _WriteButtonFace extends StatelessWidget {
  const _WriteButtonFace({
    required this.accent,
    required this.size,
    required this.onTap,
  });

  final Color accent;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: size),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      builder: (context, size, _) => TweenAnimationBuilder<Color?>(
        tween: ColorTween(end: accent),
        duration: const Duration(milliseconds: 250),
        builder: (context, color, _) {
          final tint = color ?? accent;
          return lg.GlassButton(
            icon: const Icon(Icons.edit_outlined),
            onTap: onTap,
            label: context.l10n.writeButtonLabel,
            width: size,
            height: size,
            iconSize: 22,
            iconColor: const Color(0xFF0A1628),
            shape: lg.LiquidRoundedSuperellipse(borderRadius: size * 0.4),
            settings: LiquidGlassPresets.tinted(tint),
            glowColor: tint.withValues(alpha: 0.5),
          );
        },
      ),
    );
  }
}
