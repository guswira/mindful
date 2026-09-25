import 'dart:math';

import 'package:flutter/material.dart';

/// Wraps [child] and shakes it horizontally 3 times when [shake] is
/// called on its state — the invalid-input cue used across every add
/// sheet's required field, in place of a SnackBar or dialog. See the
/// bottom-sheet design rules.
///
/// ```dart
/// final _nameShake = GlobalKey<ShakeWidgetState>();
/// ...
/// ShakeWidget(key: _nameShake, child: TextField(...));
/// ...
/// if (name.isEmpty) {
///   _nameShake.currentState?.shake();
///   return;
/// }
/// ```
class ShakeWidget extends StatefulWidget {
  const ShakeWidget({required this.child, super.key});

  final Widget child;

  @override
  State<ShakeWidget> createState() => ShakeWidgetState();
}

class ShakeWidgetState extends State<ShakeWidget>
    with SingleTickerProviderStateMixin {
  static const _cycles = 3;
  static const _amplitude = 8.0;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  );

  /// Plays the shake — safe to call again mid-animation, restarting it.
  void shake() => _controller.forward(from: 0);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final decay = 1 - _controller.value;
        final offset =
            sin(_controller.value * _cycles * 2 * pi) * _amplitude * decay;
        return Transform.translate(offset: Offset(offset, 0), child: child);
      },
      child: widget.child,
    );
  }
}
