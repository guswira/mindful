import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindful/core/theme/app_theme.dart';
import 'package:mindful/features/money/presentation/amount_keypad.dart';
import 'package:mindful/l10n/generated/app_localizations.dart';

void main() {
  group('appendAmountKey', () {
    test('appends digits and regroups', () {
      expect(appendAmountKey('', '5'), '5');
      expect(appendAmountKey('5', '000'), '5.000');
      expect(appendAmountKey('5.000', '000'), '5.000.000');
      expect(appendAmountKey('1.234', '5'), '12.345');
    });

    test('drops leading zeros', () {
      expect(appendAmountKey('', '0'), '');
      expect(appendAmountKey('', '000'), '');
    });

    test('caps at maxAmountDigits, letting "000" fill the remaining room', () {
      expect(appendAmountKey('123.456.789', '000'), '1.234.567.890');
      expect(appendAmountKey('1.234.567.890', '1'), '1.234.567.890');
    });
  });

  group('backspaceAmount', () {
    test('removes the last digit and regroups', () {
      expect(backspaceAmount('12.345'), '1.234');
      expect(backspaceAmount('5'), '');
      expect(backspaceAmount(''), '');
    });
  });

  group('AmountKeypad', () {
    late TextEditingController controller;

    setUp(() => controller = TextEditingController());
    tearDown(() => controller.dispose());

    Widget buildKeypad() => MaterialApp(
      theme: AppTheme.dark,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: AmountKeypad(controller: controller)),
    );

    testWidgets('typing 2 then 000 gives 2.000', (tester) async {
      await tester.pumpWidget(buildKeypad());

      await tester.tap(find.text('2'));
      await tester.tap(find.text('000'));

      expect(controller.text, '2.000');
    });

    testWidgets('backspace removes a digit, long press clears', (
      tester,
    ) async {
      controller.text = '12.345';
      await tester.pumpWidget(buildKeypad());

      await tester.tap(find.byIcon(Icons.backspace_outlined));
      expect(controller.text, '1.234');

      await tester.longPress(find.byIcon(Icons.backspace_outlined));
      expect(controller.text, '');
    });
  });
}
