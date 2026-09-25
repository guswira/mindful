import 'dart:ui';

/// The user's language choice in Settings. [system] follows the device.
enum AppLanguage {
  system(null),
  english('en'),
  bahasa('id');

  const AppLanguage(this.languageCode);

  /// Null for [system], so MaterialApp resolves from the device locales.
  final String? languageCode;

  /// The explicit locale to force, or null to follow the device.
  Locale? get locale => switch (languageCode) {
    final code? => Locale(code),
    null => null,
  };

  /// Parses a value written by [name]; anything unknown means [system].
  static AppLanguage fromStorage(String? value) => AppLanguage.values
      .firstWhere((language) => language.name == value, orElse: () => system);
}

/// Every locale the app ships copy for. English first — it's the fallback
/// for any device language that isn't supported.
const List<Locale> appSupportedLocales = [Locale('en'), Locale('id')];

/// Maps any locale (device or explicit) onto a supported one by language
/// code only, falling back to English.
Locale resolveAppLocale(Locale? locale) => appSupportedLocales.firstWhere(
  (supported) => supported.languageCode == locale?.languageCode,
  orElse: () => appSupportedLocales.first,
);
