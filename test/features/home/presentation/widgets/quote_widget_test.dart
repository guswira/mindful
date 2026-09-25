import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindfull/core/theme/glass_theme.dart';
import 'package:mindfull/features/home/presentation/widgets/quote_widget.dart';
import 'package:mindfull/shared/widgets/glass_card.dart';

void main() {
  testWidgets('shows the quote and author, and expands on tap', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: ThemeData(extensions: [GlassTheme.dark()]),
          home: const Scaffold(body: QuoteWidget()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final authorFinder = find.byWidgetPredicate(
      (widget) => widget is Text && (widget.data?.startsWith('— ') ?? false),
    );
    expect(authorFinder, findsOneWidget);
    expect(find.byType(GlassCard), findsNothing);

    final gestureDetectorFinder = find.descendant(
      of: find.byType(QuoteWidget),
      matching: find.byType(GestureDetector),
    );
    tester.widget<GestureDetector>(gestureDetectorFinder).onTap!();
    await tester.pumpAndSettle();

    expect(find.byType(GlassCard), findsOneWidget);
  });
}
