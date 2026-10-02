import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/breathing_preferences.dart';

part 'breathing_preferences_repository.g.dart';

/// Persists [BreathingPreferences] as one JSON value in
/// flutter_secure_storage, like the app's other device-local settings.
class BreathingPreferencesRepository {
  const BreathingPreferencesRepository({
    FlutterSecureStorage storage = const FlutterSecureStorage(),
  }) : _storage = storage;

  static const String _key = 'breathing_preferences';

  final FlutterSecureStorage _storage;

  /// The saved preferences, or the defaults if none are saved or they no
  /// longer decode.
  Future<BreathingPreferences> read() async {
    final value = await _storage.read(key: _key);
    if (value == null) {
      return const BreathingPreferences();
    }
    try {
      return BreathingPreferences.fromJson(
        jsonDecode(value) as Map<String, dynamic>,
      );
    } catch (error) {
      debugPrint('Resetting unreadable breathing preferences: $error');
      return const BreathingPreferences();
    }
  }

  Future<void> write(BreathingPreferences preferences) =>
      _storage.write(key: _key, value: jsonEncode(preferences.toJson()));
}

/// The app-wide [BreathingPreferencesRepository].
@Riverpod(keepAlive: true)
BreathingPreferencesRepository breathingPreferencesRepository(Ref ref) =>
    const BreathingPreferencesRepository();
