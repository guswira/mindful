import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

import 'package:mindful/features/settings/presentation/background_section.dart';
import 'package:mindful/features/settings/presentation/custom_background_controller.dart';

class _FakeBackground extends CustomBackgroundController {
  _FakeBackground(this._initial);

  final String? _initial;
  var picks = 0;
  var resets = 0;

  @override
  Future<String?> build() async => _initial;

  @override
  Future<bool> pickFromGallery({ImagePicker? picker}) async {
    picks++;
    state = const AsyncData('/tmp/does-not-exist.jpg');
    return true;
  }

  @override
  Future<void> reset() async {
    resets++;
    state = const AsyncData(null);
  }
}

Future<void> _pump(WidgetTester tester, _FakeBackground fake) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [customBackgroundControllerProvider.overrideWith(() => fake)],
      child: const MaterialApp(home: Scaffold(body: BackgroundSection())),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('default background: picking a photo sets it', (tester) async {
    final fake = _FakeBackground(null);
    await _pump(tester, fake);

    expect(find.text('Default'), findsOneWidget);

    await tester.tap(find.text('Background'));
    await tester.pumpAndSettle();
    expect(find.text('Reset to default'), findsNothing);

    await tester.tap(find.text('Choose from gallery'));
    await tester.pumpAndSettle();

    expect(fake.picks, 1);
    expect(find.text('Custom photo'), findsOneWidget);
    expect(find.text('Background updated'), findsOneWidget);
  });

  testWidgets('custom background can be reset to default', (tester) async {
    final fake = _FakeBackground('/tmp/does-not-exist.jpg');
    await _pump(tester, fake);

    expect(find.text('Custom photo'), findsOneWidget);

    await tester.tap(find.text('Background'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reset to default'));
    await tester.pumpAndSettle();

    expect(fake.resets, 1);
    expect(find.text('Default'), findsOneWidget);
  });
}
