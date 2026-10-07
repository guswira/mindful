import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindful/core/platform/platform_features.dart';

void main() {
  tearDown(() => debugDefaultTargetPlatformOverride = null);

  for (final platform in TargetPlatform.values) {
    final isPhone =
        platform == TargetPlatform.iOS || platform == TargetPlatform.android;
    test('${platform.name} is ${isPhone ? '' : 'not '}a phone platform', () {
      debugDefaultTargetPlatformOverride = platform;
      expect(isPhonePlatform, isPhone);
    });
  }
}
