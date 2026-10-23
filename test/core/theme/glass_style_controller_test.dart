import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mindful/core/theme/glass_style.dart';
import 'package:mindful/core/theme/glass_style_controller.dart';
import 'package:mindful/features/settings/data/settings_repository.dart';

class _MockStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late _MockStorage storage;

  ProviderContainer containerWith(String? saved) {
    when(
      () => storage.read(key: 'glass_style'),
    ).thenAnswer((_) async => saved);
    final container = ProviderContainer(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(
          SettingsRepository(storage: storage),
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  setUp(() => storage = _MockStorage());

  test('falls back to the platform default when never set', () async {
    final container = containerWith(null);

    await container.read(glassStyleControllerProvider.notifier).restore();

    // Tests run natively, where the default is liquid (frosted on web).
    expect(GlassStyleController.defaultStyle, GlassStyle.liquid);
    expect(
      container.read(glassStyleControllerProvider),
      GlassStyleController.defaultStyle,
    );
  });

  test('a saved choice wins over the default', () async {
    final container = containerWith('frosted');

    await container.read(glassStyleControllerProvider.notifier).restore();

    expect(container.read(glassStyleControllerProvider), GlassStyle.frosted);
  });
}
