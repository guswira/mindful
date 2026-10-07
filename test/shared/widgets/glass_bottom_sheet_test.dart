import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindful/core/constants/layout.dart';
import 'package:mindful/core/theme/glass_theme.dart';
import 'package:mindful/shared/widgets/glass_bottom_sheet.dart';
import 'package:mindful/shared/widgets/glass_card.dart';

void main() {
  Future<void> openSheet(WidgetTester tester, Size screen) async {
    tester.view.physicalSize = screen;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: [GlassTheme.dark()]),
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showGlassBottomSheet<String>(
              context: context,
              builder: (context) => TextButton(
                onPressed: () => Navigator.pop(context, 'done'),
                child: const Text('Sheet content'),
              ),
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

  testWidgets('opens as a bottom sheet on a phone', (tester) async {
    await openSheet(tester, const Size(390, 844));

    expect(find.byType(GlassBottomSheet), findsOneWidget);
    expect(find.byType(GlassDialog), findsNothing);
  });

  testWidgets('opens as a width-capped dialog on a wide screen', (
    tester,
  ) async {
    await openSheet(tester, const Size(1280, 800));

    expect(find.byType(GlassDialog), findsOneWidget);
    expect(find.byType(GlassBottomSheet), findsNothing);
    expect(
      tester.getSize(find.byType(GlassCard)).width,
      AppLayout.maxSheetWidth,
    );
  });

  testWidgets('the dialog still pops with the content\'s result', (
    tester,
  ) async {
    await openSheet(tester, const Size(1280, 800));

    await tester.tap(find.text('Sheet content'));
    await tester.pumpAndSettle();

    expect(find.byType(GlassDialog), findsNothing);
  });
}
