import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/spacing.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/glass_theme.dart';
import 'amount_input_formatter.dart';

/// Most integer digits an amount can hold — `money_entries.amount` is
/// `numeric(12,2)`, so anything longer would be rejected by Supabase.
const int maxAmountDigits = 10;

/// Appends [key] ("0"–"9" or "000") to the grouped amount in [text], e.g.
/// ("4", "000") -> "4.000". Leading zeros are dropped, and input past
/// [maxAmountDigits] is truncated rather than ignored so "000" still fills
/// whatever room is left.
String appendAmountKey(String text, String key) {
  final digits = '${ungroupDigits(text)}$key'.replaceFirst(RegExp('^0+'), '');
  return groupDigits(
    digits.length > maxAmountDigits
        ? digits.substring(0, maxAmountDigits)
        : digits,
  );
}

/// Removes the last digit from the grouped amount in [text].
String backspaceAmount(String text) {
  final digits = ungroupDigits(text);
  return digits.isEmpty
      ? ''
      : groupDigits(digits.substring(0, digits.length - 1));
}

/// In-sheet number pad for money amounts. It stands in for the system
/// keyboard because neither iOS nor Android lets an app add a "000" key to
/// theirs, and whole thousands are how IDR amounts are usually typed.
///
/// Long-pressing backspace clears the whole amount.
class AmountKeypad extends StatelessWidget {
  const AmountKeypad({required this.controller, super.key});

  final TextEditingController controller;

  static const _rows = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    ['000', '0'],
  ];

  void _set(String text) {
    HapticFeedback.selectionClick();
    controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return Column(
      children: [
        for (final row in _rows)
          Row(
            children: [
              for (final key in row)
                _KeypadKey(
                  onTap: () => _set(appendAmountKey(controller.text, key)),
                  child: Text(
                    key,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              if (row.length < 3)
                _KeypadKey(
                  onTap: () => _set(backspaceAmount(controller.text)),
                  onLongPress: () => _set(''),
                  child: Icon(
                    Icons.backspace_outlined,
                    color: glass.textSecondary,
                    size: 22,
                    semanticLabel: context.l10n.moneyKeypadBackspace,
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

/// [AmountKeypad] shown only while [focusNode] (the amount field) has focus,
/// so it gives way to the system keyboard when the note field is tapped.
class FocusedAmountKeypad extends StatelessWidget {
  const FocusedAmountKeypad({
    required this.focusNode,
    required this.controller,
    super.key,
  });

  final FocusNode focusNode;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: focusNode,
      builder: (context, _) => AnimatedSize(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        child: focusNode.hasFocus
            ? Padding(
                padding: const EdgeInsets.only(top: Spacing.md),
                child: AmountKeypad(controller: controller),
              )
            : const SizedBox(width: double.infinity),
      ),
    );
  }
}

class _KeypadKey extends StatelessWidget {
  const _KeypadKey({
    required this.onTap,
    required this.child,
    this.onLongPress,
  });

  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xs),
        child: Material(
          color: glass.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: glass.cardBorder, width: 0.5),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            onLongPress: onLongPress,
            child: SizedBox(height: 52, child: Center(child: child)),
          ),
        ),
      ),
    );
  }
}
