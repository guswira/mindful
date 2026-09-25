import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mindfull/core/l10n/app_language.dart';
import 'package:mindfull/core/l10n/app_language_controller.dart';
import 'package:mindfull/core/l10n/l10n.dart';
import 'package:mindfull/features/settings/data/settings_repository.dart';

class _MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  setUpAll(() => registerFallbackValue(AppLanguage.system));

  group('resolveAppLocale', () {
    test('keeps supported languages, ignoring the country', () {
      expect(resolveAppLocale(const Locale('id', 'ID')), const Locale('id'));
      expect(resolveAppLocale(const Locale('en', 'GB')), const Locale('en'));
    });

    test('falls back to English for anything else', () {
      expect(resolveAppLocale(const Locale('fr')), const Locale('en'));
      expect(resolveAppLocale(null), const Locale('en'));
    });
  });

  test('AppLanguage.fromStorage round-trips and defaults to system', () {
    for (final language in AppLanguage.values) {
      expect(AppLanguage.fromStorage(language.name), language);
    }
    expect(AppLanguage.fromStorage(null), AppLanguage.system);
    expect(AppLanguage.fromStorage('klingon'), AppLanguage.system);
    expect(AppLanguage.system.locale, isNull);
    expect(AppLanguage.bahasa.locale, const Locale('id'));
  });

  test('setCurrentAppLocale switches currentL10n and intl default', () {
    addTearDown(() => setCurrentAppLocale(const Locale('en')));

    setCurrentAppLocale(const Locale('id', 'ID'));
    expect(currentL10n.localeName, 'id');
    expect(Intl.defaultLocale, 'id');
    expect(currentL10n.commonCancel, 'Batal');

    setCurrentAppLocale(const Locale('en'));
    expect(currentL10n.commonCancel, 'Cancel');
  });

  group('AppLanguageController', () {
    late _MockSettingsRepository repository;
    late ProviderContainer container;

    setUp(() {
      repository = _MockSettingsRepository();
      when(() => repository.writeAppLanguage(any())).thenAnswer((_) async {});
      container = ProviderContainer(
        overrides: [settingsRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);
    });

    test('starts on system and restores the saved choice', () async {
      when(
        () => repository.readAppLanguage(),
      ).thenAnswer((_) async => AppLanguage.bahasa);

      expect(container.read(appLanguageControllerProvider), AppLanguage.system);
      await container.read(appLanguageControllerProvider.notifier).restore();
      expect(container.read(appLanguageControllerProvider), AppLanguage.bahasa);
    });

    test('select switches immediately and persists', () async {
      await container
          .read(appLanguageControllerProvider.notifier)
          .select(AppLanguage.english);

      expect(
        container.read(appLanguageControllerProvider),
        AppLanguage.english,
      );
      verify(() => repository.writeAppLanguage(AppLanguage.english)).called(1);
    });
  });
}
