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
/// Long-pressing backspace clears the whole amount. With [onNext], a
/// right-hand column holds backspace and a tall "Next" key (like a number
/// pad's return key) that moves on to the next field; without it,
/// backspace sits next to 0.
class AmountKeypad extends StatelessWidget {
  const AmountKeypad({required this.controller, this.onNext, super.key});

  final TextEditingController controller;

  /// Moves focus on from the amount — e.g. to the note field.
  final VoidCallback? onNext;

  static const _rows = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    ['000', '0'],
  ];

  /// The pad's full height: 4 key rows, each with its padding.
  static const double height = 4 * (_KeypadKey._height + Spacing.xs * 2);

  /// Rows of keys a "Next" key spans in the right-hand column.
  static const int _nextKeyRows = 3;

  void _set(String text) {
    HapticFeedback.selectionClick();
    controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  _KeypadKey _digitKey(String key) => _KeypadKey(
    onTap: () => _set(appendAmountKey(controller.text, key)),
    child: Text(
      key,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  _KeypadKey _backspaceKey(BuildContext context) => _KeypadKey(
    onTap: () => _set(backspaceAmount(controller.text)),
    onLongPress: () => _set(''),
    child: Icon(
      Icons.backspace_outlined,
      color: Theme.of(context).extension<GlassTheme>()!.textSecondary,
      size: 22,
      semanticLabel: context.l10n.moneyKeypadBackspace,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final onNext = this.onNext;
    if (onNext == null) {
      return Column(
        children: [
          for (final row in _rows)
            Row(
              children: [
                for (final key in row) _digitKey(key),
                if (row.length < 3) _backspaceKey(context),
              ],
            ),
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            children: [
              for (final row in _rows)
                Row(children: [for (final key in row) _digitKey(key)]),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Row(children: [_backspaceKey(context)]),
              Row(
                children: [
                  _KeypadKey(
                    onTap: onNext,
                    rows: _nextKeyRows,
                    child: _NextKeyLabel(label: context.l10n.moneyKeypadNext),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// "Next" + an arrow, in the money accent — the keypad's one action key.
class _NextKeyLabel extends StatelessWidget {
  const _NextKeyLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).extension<GlassTheme>()!.moneyAccent;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.keyboard_return_rounded, color: accent, size: 22),
        const SizedBox(height: Spacing.xs),
        Text(
          label,
          style: TextStyle(
            color: accent,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _KeypadKey extends StatelessWidget {
  const _KeypadKey({
    required this.onTap,
    required this.child,
    this.onLongPress,
    this.rows = 1,
  });

  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final Widget child;

  /// How many key rows tall this key is (spacing between them included).
  final int rows;

  static const double _height = 52;

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
            child: SizedBox(
              height: _height * rows + Spacing.xs * 2 * (rows - 1),
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );
  }
}
