import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindful/core/theme/glass_theme.dart';
import 'package:mindful/shared/widgets/app_background_scope.dart';
import 'package:mindful/shared/widgets/blob_background.dart';

void main() {
  testWidgets('renders its child above the blob layer', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: BlobBackground(child: Text('Screen content'))),
      ),
    );

    expect(find.text('Screen content'), findsOneWidget);
    expect(find.byType(BlobBackground), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(BlobBackground),
        matching: find.byType(IgnorePointer),
      ),
      findsOneWidget,
    );
  });

  testWidgets('draws a custom photo under a theme-colored scrim', (
    tester,
  ) async {
    final glass = GlassTheme.dark();
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: [glass]),
        home: const AppBackgroundScope(
          // Missing on purpose: the photo layer must fall back quietly.
          imagePath: '/tmp/mindful-missing-background.jpg',
          child: Scaffold(body: BlobBackground(child: Text('Screen content'))),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Screen content'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
    final scrim = tester.widget<ColoredBox>(
      find.byWidgetPredicate(
        (widget) =>
            widget is ColoredBox &&
            widget.color ==
                glass.background.withValues(
                  alpha: customBackgroundScrimOpacity,
                ),
      ),
    );
    expect(scrim, isNotNull);
  });

  testWidgets('shows no photo without a custom background', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: BlobBackground(child: Text('Screen content'))),
      ),
    );

    expect(find.byType(Image), findsNothing);
  });

  testWidgets('puts its content in a shared backdrop group', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: BlobBackground(child: Text('Screen content'))),
      ),
    );

    expect(
      find.ancestor(
        of: find.text('Screen content'),
        matching: find.byType(BackdropGroup),
      ),
      findsOneWidget,
    );
  });
}
