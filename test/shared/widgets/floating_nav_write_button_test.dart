import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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

  Future<void> openMenu(WidgetTester tester, {int? tabIndex}) async {
    await tester.pumpWidget(buildButton(tabIndex: tabIndex));
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
  }

  List<String> menuLabels(WidgetTester tester) => [
    for (final tile in tester.widgetList<ListTile>(find.byType(ListTile)))
      (tile.title! as Text).data!,
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

  testWidgets('holding shows the tab\'s items as a dial', (tester) async {
    await tester.pumpWidget(buildButton(tabIndex: WriteMenuTab.money));

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(FloatingActionButton)),
    );
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.byIcon(Icons.trending_down_rounded), findsOneWidget);
    expect(find.byIcon(Icons.trending_up_rounded), findsOneWidget);
    expect(find.byIcon(Icons.checklist_outlined), findsNothing);

    await gesture.up();
    await tester.pump();
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
