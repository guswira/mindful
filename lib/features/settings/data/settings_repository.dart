import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/l10n/app_language.dart';

part 'settings_repository.g.dart';

/// Persists the user's toggleable app preferences.
class SettingsRepository {
  const SettingsRepository({
    FlutterSecureStorage storage = const FlutterSecureStorage(),
  }) : _storage = storage;

  final FlutterSecureStorage _storage;

  static const String _journalMorningReminderKey =
      'journal_morning_reminder_enabled';
  static const String _journalEveningReminderKey =
      'journal_evening_reminder_enabled';
  static const String _appLanguageKey = 'app_language';

  /// Whether the 8:00 AM journal reminder is on. Defaults to true.
  Future<bool> isJournalMorningReminderEnabled() =>
      _readBool(_journalMorningReminderKey);

  /// Whether the 10:00 PM journal reminder is on. Defaults to true.
  Future<bool> isJournalEveningReminderEnabled() =>
      _readBool(_journalEveningReminderKey);

  Future<void> setJournalMorningReminderEnabled(bool enabled) =>
      _storage.write(key: _journalMorningReminderKey, value: '$enabled');

  Future<void> setJournalEveningReminderEnabled(bool enabled) =>
      _storage.write(key: _journalEveningReminderKey, value: '$enabled');

  /// The saved language choice; [AppLanguage.system] if never set.
  Future<AppLanguage> readAppLanguage() async =>
      AppLanguage.fromStorage(await _storage.read(key: _appLanguageKey));

  Future<void> writeAppLanguage(AppLanguage language) =>
      _storage.write(key: _appLanguageKey, value: language.name);

  Future<bool> _readBool(String key) async {
    final value = await _storage.read(key: key);
    return value == null ? true : value == 'true';
  }
}

@Riverpod(keepAlive: true)
SettingsRepository settingsRepository(Ref ref) => const SettingsRepository();
