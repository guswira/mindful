import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindfull/shared/widgets/shake_widget.dart';

void main() {
  testWidgets('renders its child untranslated until shaken', (tester) async {
    final key = GlobalKey<ShakeWidgetState>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ShakeWidget(key: key, child: const Text('Name')),
        ),
      ),
    );

    final transformFinder = find.descendant(
      of: find.byType(ShakeWidget),
      matching: find.byType(Transform),
    );

    expect(find.text('Name'), findsOneWidget);
    var transform = tester.widget<Transform>(transformFinder);
    expect(transform.transform.getTranslation().x, 0);

    key.currentState!.shake();
    // The ticker's first frame after starting just establishes its start
    // time (elapsed 0); a second frame is needed to see real elapsed time.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    transform = tester.widget<Transform>(transformFinder);
    expect(transform.transform.getTranslation().x, isNot(0));

    await tester.pumpAndSettle();
    transform = tester.widget<Transform>(transformFinder);
    expect(transform.transform.getTranslation().x, 0);
  });
}
