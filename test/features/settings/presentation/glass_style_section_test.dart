import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindful/core/theme/glass_style.dart';
import 'package:mindful/core/theme/glass_style_controller.dart';
import 'package:mindful/features/settings/presentation/glass_style_section.dart';

/// Keeps the choice in memory instead of secure storage.
class _FakeGlassStyle extends GlassStyleController {
  final selected = <GlassStyle>[];

  @override
  Future<void> select(GlassStyle style) async {
    selected.add(style);
    state = style;
  }
}

void main() {
  testWidgets('switches from liquid to frosted glass', (tester) async {
    final fake = _FakeGlassStyle();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [glassStyleControllerProvider.overrideWith(() => fake)],
        child: const MaterialApp(home: Scaffold(body: GlassStyleSection())),
      ),
    );

    expect(find.text('Glass style'), findsOneWidget);
    expect(find.text('Liquid glass'), findsOneWidget);

    await tester.tap(find.text('Glass style'));
    await tester.pumpAndSettle();
    expect(find.text('Frosted glass'), findsOneWidget);

    await tester.tap(find.text('Frosted glass'));
    await tester.pumpAndSettle();

    expect(fake.selected, [GlassStyle.frosted]);
    expect(find.text('Frosted glass'), findsOneWidget);
    expect(find.text('Liquid glass'), findsNothing);
  });

  testWidgets('picking the current style changes nothing', (tester) async {
    final fake = _FakeGlassStyle();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [glassStyleControllerProvider.overrideWith(() => fake)],
        child: const MaterialApp(home: Scaffold(body: GlassStyleSection())),
      ),
    );

    await tester.tap(find.text('Glass style'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Liquid glass').last);
    await tester.pumpAndSettle();

    expect(fake.selected, isEmpty);
  });
}
