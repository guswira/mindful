import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindfull/features/money/presentation/amount_input_formatter.dart';

void main() {
  group('groupDigits', () {
    test('groups digits into thousands with dots', () {
      expect(groupDigits('4000000'), '4.000.000');
      expect(groupDigits('100'), '100');
      expect(groupDigits('1000'), '1.000');
      expect(groupDigits(''), '');
    });
  });

  group('ungroupDigits', () {
    test('strips dots back to plain digits', () {
      expect(ungroupDigits('4.000.000'), '4000000');
      expect(ungroupDigits('100'), '100');
    });
  });

  group('formatAmountForInput', () {
    test('rounds and groups a double amount', () {
      expect(formatAmountForInput(4000000), '4.000.000');
      expect(formatAmountForInput(100), '100');
    });
  });

  group('ThousandsInputFormatter', () {
    const formatter = ThousandsInputFormatter();

    test('groups typed digits and moves the cursor to the end', () {
      final result = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(
          text: '4000000',
          selection: TextSelection.collapsed(offset: 7),
        ),
      );

      expect(result.text, '4.000.000');
      expect(result.selection.baseOffset, 9);
    });

    test('ignores non-digit characters', () {
      final result = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(text: 'abc123'),
      );

      expect(result.text, '123');
    });
  });
}
