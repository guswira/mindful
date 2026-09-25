import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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
}
