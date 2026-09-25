import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../l10n/generated/app_localizations.dart';
import 'app_language.dart';

export '../../l10n/generated/app_localizations.dart';

// PlatformDispatcher rather than WidgetsBinding, so this also works in
// plain unit tests that never initialize a binding.
AppLocalizations _current = lookupAppLocalizations(
  resolveAppLocale(PlatformDispatcher.instance.locale),
);

/// Copy in the app's current language, for code with no [BuildContext] —
/// notifications, services, quick actions. Widgets use [BuildContext.l10n].
AppLocalizations get currentL10n => _current;

/// Switches [currentL10n] and intl's default locale (so `DateFormat` /
/// `NumberFormat` without an explicit locale follow the app language).
///
/// Called whenever MaterialApp resolves a locale, which covers both the
/// user changing it in Settings and the device language changing while
/// the app follows the system.
void setCurrentAppLocale(Locale locale) {
  final resolved = resolveAppLocale(locale);
  Intl.defaultLocale = resolved.languageCode;
  _current = lookupAppLocalizations(resolved);
}

/// Shorthand for the app's localized copy.
extension AppLocalizationsContext on BuildContext {
  /// Falls back to [currentL10n] when there's no [AppLocalizations] above
  /// this context — e.g. a widget test pumping a bare `MaterialApp`.
  AppLocalizations get l10n => AppLocalizations.of(this) ?? currentL10n;
}
