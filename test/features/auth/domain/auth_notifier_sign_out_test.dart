import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:mindful/features/auth/data/auth_repository.dart';
import 'package:mindful/features/auth/domain/auth_state.dart';

class _FakeAuthRepository extends Fake implements AuthRepository {
  @override
  Future<void> initialize() async {}

  @override
  Future<Never?> attemptSilentSignIn() async => null;

  @override
  Future<void> signOut() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const homeWidget = MethodChannel('home_widget');
  final widgetData = <String, Object?>{};
  late Directory hiveDir;

  setUp(() async {
    hiveDir = await Directory.systemTemp.createTemp('mindful_sign_out_test');
    Hive.init(hiveDir.path);
    widgetData.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(homeWidget, (call) async {
          if (call.method == 'saveWidgetData') {
            final args = call.arguments as Map;
            widgetData[args['id'] as String] = args['data'];
          }
          return call.method == 'getWidgetData' ? null : true;
        });
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(homeWidget, null);
    await Hive.close();
    await hiveDir.delete(recursive: true);
  });

  test('sign-out empties every account data box, so the next account '
      'starts with nothing from the previous one', () async {
    for (final name in AuthNotifier.userDataBoxNames) {
      final box = await Hive.openBox<dynamic>(name);
      await box.put('previous-account-row', {'id': 'x'});
    }
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
      ],
    );
    addTearDown(container.dispose);

    await container.read(authNotifierProvider.notifier).signOut();

    for (final name in AuthNotifier.userDataBoxNames) {
      expect(Hive.box<dynamic>(name).isEmpty, isTrue, reason: name);
    }
    expect(container.read(authNotifierProvider), isA<AuthUnauthenticated>());
    // The home screen widgets are redrawn from the now-empty cache.
    expect(widgetData['tasks'], '[]');
    expect(widgetData['habits'], '[]');
  });
}
