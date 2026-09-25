import 'package:flutter/services.dart';

/// Live thousands-separator formatting for money amount inputs — IDR (the
/// app's default currency) has no minor unit, so amounts are typed and
/// shown as whole numbers grouped with dots (e.g. "4000000" -> "4.000.000")
/// rather than with decimal places.
class ThousandsInputFormatter extends TextInputFormatter {
  const ThousandsInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    final grouped = groupDigits(digits);
    return TextEditingValue(
      text: grouped,
      selection: TextSelection.collapsed(offset: grouped.length),
    );
  }
}

/// Groups a plain digit string into thousands with "." separators, e.g.
/// "4000000" -> "4.000.000". Used both by [ThousandsInputFormatter] and to
/// pre-fill a field from an existing amount.
String groupDigits(String digits) {
  if (digits.isEmpty) {
    return '';
  }
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    final fromEnd = digits.length - i;
    if (i != 0 && fromEnd % 3 == 0) {
      buffer.write('.');
    }
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

/// Formats a whole-number [amount] for display inside an amount input,
/// e.g. 4000000 -> "4.000.000". Rounds to the nearest whole unit, since
/// these fields no longer accept decimal input.
String formatAmountForInput(double amount) =>
    groupDigits(amount.round().toString());

/// Strips grouping dots back to a plain digit string for parsing, e.g.
/// "4.000.000" -> "4000000".
String ungroupDigits(String formatted) => formatted.replaceAll('.', '');
