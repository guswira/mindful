import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindful/shared/widgets/glass_icon_button.dart';

void main() {
  testWidgets('shows its icon and calls onTap when tapped', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GlassIconButton(icon: Icons.add, onTap: () => tapped = true),
        ),
      ),
    );

    expect(find.byIcon(Icons.add), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(tapped, isTrue);
  });
}
