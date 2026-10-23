import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as lg;

import 'package:mindful/core/theme/glass_style.dart';
import 'package:mindful/core/theme/glass_style_scope.dart';
import 'package:mindful/core/theme/glass_theme.dart';
import 'package:mindful/shared/widgets/glass_card.dart';

void main() {
  Widget buildCard({bool strong = false, GlassStyle? style}) {
    Widget card = GlassCard(
      strong: strong,
      child: const Text('Inside the card'),
    );
    if (style != null) {
      card = GlassStyleScope(style: style, child: card);
    }
    return MaterialApp(
      theme: ThemeData(extensions: [GlassTheme.dark()]),
      home: Scaffold(body: card),
    );
  }

  testWidgets('renders its child', (tester) async {
    await tester.pumpWidget(buildCard());

    expect(find.text('Inside the card'), findsOneWidget);
  });

  testWidgets('renders in strong mode without error', (tester) async {
    await tester.pumpWidget(buildCard(strong: true));

    expect(find.text('Inside the card'), findsOneWidget);
  });

  testWidgets('liquid style draws liquid glass', (tester) async {
    await tester.pumpWidget(buildCard(style: GlassStyle.liquid));

    expect(find.byType(lg.GlassCard), findsOneWidget);
    expect(find.byType(BackdropFilter), findsNothing);
  });

  testWidgets('frosted style draws a blurred card', (tester) async {
    await tester.pumpWidget(buildCard(style: GlassStyle.frosted));

    expect(find.byType(lg.GlassCard), findsNothing);
    expect(find.byType(BackdropFilter), findsOneWidget);
    expect(find.text('Inside the card'), findsOneWidget);
  });
}
