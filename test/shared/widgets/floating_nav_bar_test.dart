import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindfull/core/theme/glass_theme.dart';
import 'package:mindfull/shared/widgets/floating_nav_bar.dart';

void main() {
  Widget buildBar(int currentIndex, ValueChanged<int> onTabChanged) =>
      MaterialApp(
        theme: ThemeData(extensions: [GlassTheme.dark()]),
        home: Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: FloatingNavBar(
              currentIndex: currentIndex,
              onTabChanged: onTabChanged,
            ),
          ),
        ),
      );

  testWidgets('shows the 6 tab icons and the write button', (tester) async {
    await tester.pumpWidget(buildBar(0, (_) {}));

    expect(find.byIcon(Icons.home_outlined), findsOneWidget);
    expect(find.byIcon(Icons.checklist_outlined), findsOneWidget);
    expect(find.byIcon(Icons.calendar_month_outlined), findsOneWidget);
    expect(find.byIcon(Icons.menu_book_outlined), findsOneWidget);
    expect(find.byIcon(Icons.account_balance_wallet_outlined), findsOneWidget);
    expect(find.byIcon(Icons.auto_awesome_outlined), findsOneWidget);
    expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
  });

  testWidgets('tapping a tab icon reports its index', (tester) async {
    int? tapped;
    await tester.pumpWidget(buildBar(0, (index) => tapped = index));

    await tester.tap(find.byIcon(Icons.checklist_outlined));
    await tester.pump();

    expect(tapped, 1);
  });

  testWidgets('tapping the money tab icon reports index 4', (tester) async {
    int? tapped;
    await tester.pumpWidget(buildBar(0, (index) => tapped = index));

    await tester.tap(find.byIcon(Icons.account_balance_wallet_outlined));
    await tester.pump();

    expect(tapped, 4);
  });

  testWidgets('tapping the AI tab icon reports index 5', (tester) async {
    int? tapped;
    await tester.pumpWidget(buildBar(0, (index) => tapped = index));

    await tester.tap(find.byIcon(Icons.auto_awesome_outlined));
    await tester.pump();

    expect(tapped, 5);
  });
}
