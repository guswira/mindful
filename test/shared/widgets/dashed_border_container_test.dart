import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindfull/shared/widgets/dashed_border_container.dart';

void main() {
  testWidgets('renders its child inside the dashed border', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: DashedBorderContainer(child: Text('Empty state'))),
      ),
    );

    expect(find.text('Empty state'), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);
  });
}
