import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as lg;

import 'package:mindful/core/theme/glass_theme.dart';
import 'package:mindful/shared/widgets/floating_nav_bar.dart';
import 'package:mindful/shared/widgets/floating_nav_write_button.dart';
import 'package:mindful/shared/widgets/nav_tabs.dart';

void main() {
  Widget buildBar(
    int currentIndex,
    ValueChanged<int> onTabChanged, {
    lg.GlassTabBarMinimizeController? minimizeController,
  }) => MaterialApp(
    theme: ThemeData(extensions: [GlassTheme.dark()]),
    home: Scaffold(
      body: Align(
        alignment: Alignment.bottomCenter,
        child: FloatingNavBar(
          currentIndex: currentIndex,
          onTabChanged: onTabChanged,
          minimizeController: minimizeController,
        ),
      ),
    ),
  );

  // The liquid tab bar draws each icon twice — the resting row, and the
  // magnified copy under the indicator droplet — so taps target the first.
  Future<void> tapIcon(WidgetTester tester, IconData icon) async {
    await tester.tap(find.byIcon(icon).first);
    await tester.pump();
  }

  testWidgets('shows the 5 tab icons and the write button', (tester) async {
    await tester.pumpWidget(buildBar(0, (_) {}));

    expect(find.byType(lg.GlassTabBar), findsOneWidget);
    expect(find.byIcon(Icons.home_outlined), findsWidgets);
    expect(find.byIcon(Icons.checklist_outlined), findsWidgets);
    expect(find.byIcon(Icons.calendar_month_outlined), findsNothing);
    expect(find.byIcon(Icons.menu_book_outlined), findsWidgets);
    expect(find.byIcon(Icons.account_balance_wallet_outlined), findsWidgets);
    expect(find.byIcon(Icons.auto_awesome_outlined), findsWidgets);
    // Exercise lives inside the Mindfulness tab now.
    expect(find.byIcon(Icons.self_improvement_outlined), findsNothing);
    expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
  });

  testWidgets('tapping a tab icon reports its index', (tester) async {
    int? tapped;
    await tester.pumpWidget(buildBar(0, (index) => tapped = index));

    await tapIcon(tester, Icons.checklist_outlined);

    expect(tapped, 1);
  });

  testWidgets('tapping the journal tab icon reports index 2', (tester) async {
    int? tapped;
    await tester.pumpWidget(buildBar(0, (index) => tapped = index));

    await tapIcon(tester, Icons.menu_book_outlined);

    expect(tapped, 2);
  });

  testWidgets('tapping the money tab icon reports index 3', (tester) async {
    int? tapped;
    await tester.pumpWidget(buildBar(0, (index) => tapped = index));

    await tapIcon(tester, Icons.account_balance_wallet_outlined);

    expect(tapped, 3);
  });

  testWidgets('tapping the AI tab icon reports index 4', (tester) async {
    int? tapped;
    await tester.pumpWidget(buildBar(0, (index) => tapped = index));

    await tapIcon(tester, Icons.auto_awesome_outlined);

    expect(tapped, 4);
  });

  testWidgets('the write button shrinks with the minimized bar', (
    tester,
  ) async {
    final controller = lg.GlassTabBarMinimizeController(
      behavior: lg.GlassBarMinimizeBehavior.onScrollDown,
    );
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      buildBar(0, (_) {}, minimizeController: controller),
    );

    WriteButton writeButton() =>
        tester.widget<WriteButton>(find.byType(WriteButton));
    expect(writeButton().size, NavBarMetrics.barHeight);

    controller.minimize();
    await tester.pump();

    expect(writeButton().size, NavBarMetrics.minimizedBarHeight);
  });
}
