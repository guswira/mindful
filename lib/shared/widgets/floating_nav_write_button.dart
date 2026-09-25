import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/glass_theme.dart';
import '../../features/habits/presentation/add_habit_sheet.dart';
import '../../features/journal/presentation/add_journal_sheet.dart';
import '../../features/money/presentation/add_money_sheet.dart';
import '../../features/tasks/presentation/add_task_sheet.dart';
import 'glass_bottom_sheet.dart';
import 'write_options_sheet.dart';

/// The four sheets reachable from [WriteButton]'s radial arc, per SPEC.md
/// Money Flow Feature Write menu: left = journal, up-left = task,
/// up-right = habit, right = money (spending).
enum _WriteDirection { left, upLeft, upRight, right }

/// Teal gradient write button on the right of [FloatingNavBar].
///
/// Tapping shows a bottom sheet with all four options. Holding and
/// dragging shows a radial arc of the same four; releasing over one opens
/// it. See SPEC.md Floating Island Nav Bar and Money Flow Feature Write
/// menu.
class WriteButton extends StatefulWidget {
  const WriteButton({super.key});

  @override
  State<WriteButton> createState() => _WriteButtonState();
}

class _WriteButtonState extends State<WriteButton> {
  _WriteDirection? _dragDirection;
  bool _dragging = false;

  void _showWriteSheet() => showWriteOptionsSheet(context);

  void _openJournalSheet() => showGlassBottomSheet(
    context: context,
    builder: (_) => const AddJournalSheet(),
  );

  void _openTaskSheet() => showGlassBottomSheet(
    context: context,
    builder: (_) => const AddTaskSheet(),
  );

  void _openHabitSheet() => showGlassBottomSheet(
    context: context,
    builder: (_) => const AddHabitSheet(),
  );

  void _openMoneySheet() => showGlassBottomSheet(
    context: context,
    builder: (_) => const AddMoneySheet(),
  );

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
    final direction = _dragDirection;
    setState(() {
      _dragging = false;
      _dragDirection = null;
    });
    if (direction == null) {
      return;
    }
    switch (direction) {
      case _WriteDirection.left:
        _openJournalSheet();
      case _WriteDirection.upLeft:
        _openTaskSheet();
      case _WriteDirection.upRight:
        _openHabitSheet();
      case _WriteDirection.right:
        _openMoneySheet();
    }
  }

  /// Splits the drag into 4 compass-ish sectors — left, up-left, up-right,
  /// right — by the angle from the button, 0° = right and 90° = up. A
  /// mostly-downward drag (outside [-150°, 150°] around that reference)
  /// matches nothing, same as the old 3-direction version leaving "down"
  /// unmapped.
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
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomRight,
      children: [
        if (_dragging)
          for (final direction in _WriteDirection.values)
            _DirectionBadge(
              direction: direction,
              icon: switch (direction) {
                _WriteDirection.left => Icons.menu_book_outlined,
                _WriteDirection.upLeft => Icons.checklist_outlined,
                _WriteDirection.upRight => Icons.calendar_month_outlined,
                _WriteDirection.right => Icons.account_balance_wallet_outlined,
              },
              active: _dragDirection == direction,
            ),
        GestureDetector(
          onLongPressStart: _handleLongPressStart,
          onLongPressMoveUpdate: _handleLongPressMoveUpdate,
          onLongPressEnd: _handleLongPressEnd,
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [glass.writeAccent, const Color(0xFF0EB8DF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: glass.writeAccent.withValues(alpha: 0.30),
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
    required this.active,
  });

  final _WriteDirection direction;
  final IconData icon;
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
          color: active ? glass.writeAccent : glass.strongCardColor,
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
