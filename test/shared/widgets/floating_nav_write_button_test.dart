import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as lg;

import 'package:mindful/core/theme/glass_theme.dart';
import 'package:mindful/shared/widgets/floating_nav_write_button.dart';
import 'package:mindful/shared/widgets/write_options_sheet.dart';

void main() {
  Widget buildButton({int? tabIndex}) => MaterialApp(
    theme: ThemeData(extensions: [GlassTheme.dark()]),
    home: Scaffold(
      body: Align(
        alignment: Alignment.bottomRight,
        child: WriteButton(tabIndex: tabIndex),
      ),
    ),
  );

  // The menu morphs out over a few hundred ms of spring animation.
  Future<void> settleMenu(WidgetTester tester) async {
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  Future<void> openMenu(WidgetTester tester, {int? tabIndex}) async {
    await tester.pumpWidget(buildButton(tabIndex: tabIndex));
    await tester.tap(find.byIcon(Icons.edit_outlined));
    await settleMenu(tester);
  }

  List<String> menuLabels(WidgetTester tester) => [
    for (final item in tester.widgetList<lg.GlassMenuItem>(
      find.byType(lg.GlassMenuItem),
    ))
      item.title,
  ];

  testWidgets('Home shows every item', (tester) async {
    await openMenu(tester, tabIndex: 0);

    expect(menuLabels(tester), [
      'Build new routine',
      'Do new task',
      'Write journal',
      'Record spending',
    ]);
  });

  testWidgets('no tab (home widget pencil) shows every item too', (
    tester,
  ) async {
    await openMenu(tester);

    expect(menuLabels(tester), hasLength(4));
  });

  testWidgets('Tasks & Routines shows routine and task', (tester) async {
    await openMenu(tester, tabIndex: WriteMenuTab.tasks);

    expect(menuLabels(tester), ['Build new routine', 'Do new task']);
  });

  testWidgets('Mindfulness shows the three journal types', (tester) async {
    await openMenu(tester, tabIndex: WriteMenuTab.mindfulness);

    expect(menuLabels(tester), [
      "Write today's plan",
      'Review today',
      'Gratitude journal',
    ]);
  });

  testWidgets('Money shows spending and income', (tester) async {
    await openMenu(tester, tabIndex: WriteMenuTab.money);

    expect(menuLabels(tester), ['Add spending', 'Add income']);
  });

  testWidgets('the menu is closed until the button is used', (tester) async {
    await tester.pumpWidget(buildButton(tabIndex: WriteMenuTab.money));

    expect(find.text('Add spending'), findsNothing);
  });

  testWidgets('holding opens the tab\'s menu under the finger', (tester) async {
    await tester.pumpWidget(buildButton(tabIndex: WriteMenuTab.money));

    final gesture = await tester.startGesture(
      tester.getCenter(find.byIcon(Icons.edit_outlined)),
    );
    await tester.pump(const Duration(milliseconds: 600));
    await settleMenu(tester);

    expect(menuLabels(tester), ['Add spending', 'Add income']);

    await gesture.up();
    await settleMenu(tester);
  });

  test('the button follows the tab accent, Home stays teal', () {
    final glass = GlassTheme.dark();

    expect(writeButtonGradient(glass, 0), [
      glass.writeAccent,
      const Color(0xFF0EB8DF),
    ]);
    expect(writeButtonGradient(glass, null).first, glass.writeAccent);
    expect(
      writeButtonGradient(glass, WriteMenuTab.tasks).first,
      glass.taskAccent,
    );
    expect(
      writeButtonGradient(glass, WriteMenuTab.mindfulness).first,
      glass.journalAccent,
    );
    expect(
      writeButtonGradient(glass, WriteMenuTab.money).first,
      glass.moneyAccent,
    );
    expect(writeButtonGradient(glass, WriteMenuTab.ai).first, glass.aiAccent);
  });
}
