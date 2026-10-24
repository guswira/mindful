import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/constants/spacing.dart';
import '../../../shared/widgets/glass_bottom_sheet.dart';
import 'amount_keypad.dart';

/// The space under [AddMoneySheet]'s Save button that the amount keypad and
/// the system keyboard take turns filling: the keypad while [focusNode]
/// (the amount field) has focus, the keyboard's height otherwise.
///
/// Its height is the larger of the two, so moving between the amount and
/// the note hands one over to the other in place — the keypad fades out
/// behind the rising keyboard (and back in as it drops) instead of the
/// sheet collapsing and then riding back up with the keyboard. The sheet
/// must not pad itself for the keyboard on top of this ([OwnsKeyboardInset]).
///
/// Wrapped in a [TextFieldTapRegion] so a key tap counts as a tap inside the
/// amount field: on web and with a mouse, a tap outside a field unfocuses it,
/// which used to close the keypad on the first key press.
class AmountKeypadSlot extends StatefulWidget {
  const AmountKeypadSlot({
    required this.focusNode,
    required this.controller,
    this.onNext,
    super.key,
  });

  final FocusNode focusNode;
  final TextEditingController controller;

  /// See [AmountKeypad.onNext].
  final VoidCallback? onNext;

  @override
  State<AmountKeypadSlot> createState() => _AmountKeypadSlotState();
}

class _AmountKeypadSlotState extends State<AmountKeypadSlot>
    with SingleTickerProviderStateMixin {
  /// The keypad's full height, including its gap under the Save button.
  static const double _keypadExtent = Spacing.md + AmountKeypad.height;

  // Slower out than in: the system keyboard needs a moment to start rising,
  // and the keypad holds the space until it gets there.
  late final AnimationController _reveal = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 250),
    reverseDuration: const Duration(milliseconds: 400),
    value: widget.focusNode.hasFocus ? 1 : 0,
  );
  late final Animation<double> _curve = CurvedAnimation(
    parent: _reveal,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
  );

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(AmountKeypadSlot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode.removeListener(_onFocusChange);
      widget.focusNode.addListener(_onFocusChange);
      _onFocusChange();
    }
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    _reveal.dispose();
    super.dispose();
  }

  void _onFocusChange() =>
      widget.focusNode.hasFocus ? _reveal.forward() : _reveal.reverse();

  @override
  Widget build(BuildContext context) {
    // The sheet's SafeArea keeps the bottom view padding at all times, so
    // only the part of the keyboard above it needs room here.
    final keyboard = math.max(
      0.0,
      MediaQuery.viewInsetsOf(context).bottom -
          MediaQuery.viewPaddingOf(context).bottom,
    );
    return AnimatedBuilder(
      animation: _curve,
      builder: (context, keypad) => _SlotBox(
        height: math.max(keyboard, _keypadExtent * _curve.value),
        keypadExtent: _keypadExtent,
        reveal: _curve.value,
        interactive: widget.focusNode.hasFocus,
        keypad: keypad,
      ),
      child: TextFieldTapRegion(
        child: Padding(
          padding: const EdgeInsets.only(top: Spacing.md),
          child: AmountKeypad(
            controller: widget.controller,
            onNext: widget.onNext,
          ),
        ),
      ),
    );
  }
}

/// The slot at [height], showing the top [keypadExtent] of [keypad] faded
/// to [reveal] — clipped while the slot is shorter than the keypad.
class _SlotBox extends StatelessWidget {
  const _SlotBox({
    required this.height,
    required this.keypadExtent,
    required this.reveal,
    required this.interactive,
    required this.keypad,
  });

  final double height;
  final double keypadExtent;
  final double reveal;

  /// False while the keypad fades out, so a stray tap can't type into an
  /// amount field that no longer has focus.
  final bool interactive;
  final Widget? keypad;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: reveal == 0
          ? null
          : ClipRect(
              child: OverflowBox(
                alignment: Alignment.topCenter,
                minHeight: 0,
                maxHeight: keypadExtent,
                child: IgnorePointer(
                  ignoring: !interactive,
                  child: Opacity(opacity: reveal, child: keypad),
                ),
              ),
            ),
    );
  }
}
