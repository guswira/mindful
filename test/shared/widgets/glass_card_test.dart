import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindfull/core/theme/glass_theme.dart';
import 'package:mindfull/shared/widgets/glass_card.dart';

void main() {
  Widget buildCard({bool strong = false}) => MaterialApp(
    theme: ThemeData(extensions: [GlassTheme.dark()]),
    home: Scaffold(
      body: GlassCard(strong: strong, child: const Text('Inside the card')),
    ),
  );

  testWidgets('renders its child', (tester) async {
    await tester.pumpWidget(buildCard());

    expect(find.text('Inside the card'), findsOneWidget);
  });

  testWidgets('renders in strong mode without error', (tester) async {
    await tester.pumpWidget(buildCard(strong: true));

    expect(find.text('Inside the card'), findsOneWidget);
  });
}
