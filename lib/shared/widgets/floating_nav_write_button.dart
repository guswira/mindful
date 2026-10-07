import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/glass_theme.dart';
import 'glass_bottom_sheet.dart';
import 'write_options_sheet.dart';

/// The radial arc's slots around [WriteButton], left to right: left,
/// up-left, up-right, right.
enum _WriteDirection { left, upLeft, upRight, right }

/// Which slots a write menu of [count] items fills, in menu order — the
/// upper ones first, so a 2-item menu sits right above the button.
List<_WriteDirection> _slotsFor(int count) => switch (count) {
  1 => const [_WriteDirection.upLeft],
  2 => const [_WriteDirection.upLeft, _WriteDirection.upRight],
  3 => const [
    _WriteDirection.left,
    _WriteDirection.upLeft,
    _WriteDirection.upRight,
  ],
  _ => _WriteDirection.values,
};

/// Gradient write button on the right of [FloatingNavBar], in the current
/// tab's accent (teal on Home — see [writeButtonGradient]).
///
/// Tapping shows a bottom sheet with the write menu of the tab at
/// [tabIndex] (see [writeOptionsFor]). Holding and dragging shows the same
/// items as a radial arc; releasing over one opens it. See SPEC.md
/// Floating Island Nav Bar.
class WriteButton extends StatefulWidget {
  const WriteButton({this.tabIndex, super.key});

  /// The current shell tab, or null for the full menu.
  final int? tabIndex;

  @override
  State<WriteButton> createState() => _WriteButtonState();
}

class _WriteButtonState extends State<WriteButton> {
  _WriteDirection? _dragDirection;
  bool _dragging = false;

  void _showWriteSheet() =>
      showWriteOptionsSheet(context, tabIndex: widget.tabIndex);

  /// The write menu laid onto the arc's slots.
  Map<_WriteDirection, WriteOption> _arcOptions() {
    final options = writeOptionsFor(context, widget.tabIndex);
    final slots = _slotsFor(options.length);
    return {
      for (var i = 0; i < slots.length && i < options.length; i++)
        slots[i]: options[i],
    };
  }

  void _handleLongPressStart(LongPressStartDetails details) {
    setState(() {
      _dragging = true;
      _dragDirection = null;
    });
  }

  void _handleLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    setState(() => _dragDirection = _directionFor(details.offsetFromOrigin));
  }

  void _handleLongPressEnd(LongPressEndDetails details) {
    final option = _arcOptions()[_dragDirection];
    setState(() {
      _dragging = false;
      _dragDirection = null;
    });
    if (option == null) {
      return;
    }
    showGlassBottomSheet<void>(context: context, builder: (_) => option.sheet);
  }

  /// Splits the drag into 4 compass-ish sectors — left, up-left, up-right,
  /// right — by the angle from the button, 0° = right and 90° = up. A
  /// mostly-downward drag matches nothing, and neither does a slot the
  /// current tab's menu leaves empty.
  static _WriteDirection? _directionFor(Offset offset) {
    const threshold = 24.0;
    if (offset.distance < threshold) {
      return null;
    }
    final angle = math.atan2(-offset.dy, offset.dx) * 180 / math.pi;
    if (angle >= -30 && angle <= 30) {
      return _WriteDirection.right;
    }
    if (angle > 30 && angle <= 90) {
      return _WriteDirection.upRight;
    }
    if (angle > 90 && angle <= 150) {
      return _WriteDirection.upLeft;
    }
    if (angle > 150 || angle < -150) {
      return _WriteDirection.left;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final gradient = writeButtonGradient(glass, widget.tabIndex);
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomRight,
      children: [
        if (_dragging)
          for (final MapEntry(key: direction, value: option)
              in _arcOptions().entries)
            _DirectionBadge(
              direction: direction,
              icon: option.icon,
              color: gradient.first,
              active: _dragDirection == direction,
            ),
        GestureDetector(
          onLongPressStart: _handleLongPressStart,
          onLongPressMoveUpdate: _handleLongPressMoveUpdate,
          onLongPressEnd: _handleLongPressEnd,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: gradient.first.withValues(alpha: 0.30),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: FloatingActionButton(
              heroTag: 'floatingNavBarWrite',
              onPressed: _showWriteSheet,
              backgroundColor: Colors.transparent,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(
                Icons.edit_outlined,
                color: const Color(0xFF0A1628),
                size: 22,
                semanticLabel: context.l10n.writeButtonLabel,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DirectionBadge extends StatelessWidget {
  const _DirectionBadge({
    required this.direction,
    required this.icon,
    required this.color,
    required this.active,
  });

  final _WriteDirection direction;
  final IconData icon;

  /// Fill while [active] — the write button's accent.
  final Color color;
  final bool active;

  static const Map<_WriteDirection, ({double right, double bottom})>
  _positions = {
    _WriteDirection.left: (right: 88, bottom: 16),
    _WriteDirection.upLeft: (right: 66, bottom: 66),
    _WriteDirection.upRight: (right: 2, bottom: 82),
    _WriteDirection.right: (right: -44, bottom: 16),
  };

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final position = _positions[direction]!;
    return Positioned(
      right: position.right,
      bottom: position.bottom,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active ? color : glass.strongCardColor,
        ),
        child: Icon(
          icon,
          size: 20,
          color: active ? const Color(0xFF0A1628) : Colors.white,
        ),
      ),
    );
  }
}
