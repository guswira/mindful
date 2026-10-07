import 'dart:ui' show DisplayFeature, DisplayFeatureState, DisplayFeatureType;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindful/core/constants/layout.dart';
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

  testWidgets('caps content width on a wide screen, background fills it', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BlobBackground(child: SizedBox.expand(key: Key('content'))),
        ),
      ),
    );

    expect(
      tester.getSize(find.byKey(const Key('content'))).width,
      AppLayout.maxContentWidth,
    );
    expect(tester.getSize(find.byType(BlobBackground)).width, 1280);
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

  testWidgets('moves single-column content off a hinge, onto the left', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1100, 720);
    tester.view.devicePixelRatio = 1;
    tester.view.displayFeatures = const [
      DisplayFeature(
        bounds: Rect.fromLTWH(540, 0, 20, 720),
        type: DisplayFeatureType.hinge,
        state: DisplayFeatureState.unknown,
      ),
    ];
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BlobBackground(child: SizedBox.expand(key: Key('content'))),
        ),
      ),
    );

    final content = tester.getRect(find.byKey(const Key('content')));
    expect(content.left, 0);
    expect(content.right, 540);
  });
}
