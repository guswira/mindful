import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as lg;

import 'package:mindful/core/theme/glass_theme.dart';
import 'package:mindful/shared/widgets/adaptive_nav_bars.dart';
import 'package:mindful/shared/widgets/floating_nav_write_button.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
    theme: ThemeData(extensions: [GlassTheme.dark()]),
    home: Scaffold(body: child),
  );

  testWidgets('the iPad top bar centers the tabs, write button at the end', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1376, 1032);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    int? tapped;
    await tester.pumpWidget(
      wrap(
        Align(
          alignment: Alignment.topCenter,
          child: TopNavBar(
            currentIndex: 0,
            onTabChanged: (index) => tapped = index,
          ),
        ),
      ),
    );

    final bar = tester.getRect(find.byType(lg.GlassTabBar));
    expect(bar.center.dx, closeTo(1376 / 2, 1));
    // Hugs its 5 tabs rather than spanning the window.
    expect(bar.width, lessThan(1376 / 2));
    expect(
      tester.getRect(find.byType(WriteButton)).right,
      closeTo(1376 - 20, 1),
    );

    await tester.tap(find.byIcon(Icons.account_balance_wallet_outlined).first);
    await tester.pump();
    expect(tapped, 3);
  });

  testWidgets('iPhone Duo puts the write button at the top of the strip', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      wrap(
        lg.GlassVerticalBar(
          data: const lg.GlassVerticalBarData(
            edge: lg.GlassVerticalBarEdge.trailing,
            width: 84,
            top: 170,
          ),
          child: StripNavBar(currentIndex: 0, onTabChanged: (_) {}),
        ),
      ),
    );

    final button = tester.getRect(find.byType(WriteButton));
    expect(button.top, 170);
    // 12 from the content edge, 24 from the screen edge, like the
    // strip's other controls.
    expect(button.right, 402 - 24);
    expect(button.width, lg.GlassVerticalBarMetrics.controlExtent);
    expect(find.byIcon(Icons.home_outlined), findsWidgets);
  });
}
