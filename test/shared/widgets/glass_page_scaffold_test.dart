import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindful/core/theme/glass_theme.dart';
import 'package:mindful/shared/widgets/blob_background.dart';
import 'package:mindful/shared/widgets/glass_page_scaffold.dart';

void main() {
  testWidgets('draws the background behind a transparent app bar', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: [GlassTheme.dark()]),
        home: const GlassPageScaffold(title: Text('Title'), body: Text('Body')),
      ),
    );

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.extendBodyBehindAppBar, isTrue);
    final appBar = tester.widget<AppBar>(find.byType(AppBar));
    expect(appBar.backgroundColor, Colors.transparent);
    expect(appBar.scrolledUnderElevation, 0);
    expect(find.byType(BlobBackground), findsOneWidget);
    expect(find.text('Title'), findsOneWidget);

    // The body starts below the app bar, not underneath it.
    final barBottom = tester.getBottomLeft(find.byType(AppBar)).dy;
    expect(
      tester.getTopLeft(find.text('Body')).dy,
      greaterThanOrEqualTo(barBottom),
    );
  });
}
