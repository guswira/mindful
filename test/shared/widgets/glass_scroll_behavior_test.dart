import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindful/shared/widgets/glass_scroll_behavior.dart';

void main() {
  Widget buildList() => MaterialApp(
    theme: ThemeData(useMaterial3: true),
    scrollBehavior: const GlassScrollBehavior(),
    home: ListView(children: const [Text('row')]),
  );

  testWidgets('Android overscroll glows instead of stretching', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(buildList());

    expect(find.byType(GlowingOverscrollIndicator), findsOneWidget);
    expect(find.byType(StretchingOverscrollIndicator), findsNothing);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('iOS keeps its default bounce (no indicator)', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    await tester.pumpWidget(buildList());

    expect(find.byType(GlowingOverscrollIndicator), findsNothing);
    expect(find.byType(StretchingOverscrollIndicator), findsNothing);
    debugDefaultTargetPlatformOverride = null;
  });
}
