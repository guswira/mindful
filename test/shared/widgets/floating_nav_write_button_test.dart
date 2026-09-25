import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindful/core/theme/glass_theme.dart';
import 'package:mindful/shared/widgets/floating_nav_write_button.dart';

void main() {
  Widget buildButton() => MaterialApp(
    theme: ThemeData(extensions: [GlassTheme.dark()]),
    home: const Scaffold(
      body: Align(alignment: Alignment.bottomRight, child: WriteButton()),
    ),
  );

  testWidgets('tapping shows a bottom sheet with all four options', (
    tester,
  ) async {
    await tester.pumpWidget(buildButton());

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('New journal entry'), findsOneWidget);
    expect(find.text('New task'), findsOneWidget);
    expect(find.text('New habit'), findsOneWidget);
    expect(find.text('New money entry'), findsOneWidget);
  });

  testWidgets('holding shows the directional dial', (tester) async {
    await tester.pumpWidget(buildButton());

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(FloatingActionButton)),
    );
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.byIcon(Icons.menu_book_outlined), findsOneWidget);
    expect(find.byIcon(Icons.checklist_outlined), findsOneWidget);
    expect(find.byIcon(Icons.calendar_month_outlined), findsOneWidget);
    expect(find.byIcon(Icons.account_balance_wallet_outlined), findsOneWidget);

    await gesture.up();
    await tester.pump();
  });
}
