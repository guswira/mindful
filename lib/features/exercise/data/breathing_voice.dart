import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/platform/platform_features.dart';
import 'calm_voice_picker.dart';

part 'breathing_voice.g.dart';

/// Speaks each breathing step aloud through the platform's text-to-speech
/// engine, in the app language.
///
/// Best-effort throughout: a device with no TTS voice (or no engine at
/// all) just stays silent rather than interrupting the session.
class BreathingVoice {
  BreathingVoice({FlutterTts? tts}) : _tts = tts ?? FlutterTts();

  final FlutterTts _tts;
  String? _configuredLocale;

  /// Speaks [text] at [volume] (0–1), cutting off anything still being
  /// spoken so a fast pattern never queues up stale words.
  Future<void> speak(String text, {required double volume}) async {
    try {
      await _configure();
      await _tts.stop();
      await _tts.setVolume(volume);
      await _tts.speak(text);
    } catch (error) {
      debugPrint('Breathing voice unavailable: $error');
    }
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (error) {
      debugPrint('Breathing voice stop failed: $error');
    }
  }

  /// (Re)applies the voice whenever the app language changed since the
  /// last call — the calmest natural voice the device has for it (see
  /// [pickCalmVoice]) — and on iOS shares the audio session so speech
  /// plays over the ambience instead of stopping it.
  Future<void> _configure() async {
    final locale = currentL10n.localeName;
    if (_configuredLocale == locale) {
      return;
    }
    final languageCode = locale == 'id' ? 'id' : 'en';
    await _tts.setLanguage(languageCode == 'id' ? 'id-ID' : 'en-US');
    // setLanguage resets the voice on iOS, so the voice goes after it.
    final voicesLoaded = await _applyCalmVoice(languageCode);
    // Web rates are relative to 1.0 normal; iOS/Android (via the plugin)
    // treat 0.5 as normal — both land just under a natural pace.
    await _tts.setSpeechRate(kIsWeb ? 0.85 : 0.42);
    await _tts.setPitch(0.95);
    if (isNativeIOS) {
      await _tts.setSharedInstance(true);
      await _tts.setIosAudioCategory(IosTextToSpeechAudioCategory.playback, [
        IosTextToSpeechAudioCategoryOptions.mixWithOthers,
      ]);
    }
    // Browsers load their voice list lazily — try again on the next word.
    if (voicesLoaded) {
      _configuredLocale = locale;
    }
  }

  /// Sets the voice; false when the engine hasn't listed its voices yet.
  Future<bool> _applyCalmVoice(String languageCode) async {
    final raw = await _tts.getVoices;
    final voices = raw is List
        ? [
            for (final voice in raw)
              if (voice is Map)
                {
                  for (final entry in voice.entries)
                    if (entry.value != null) '${entry.key}': '${entry.value}',
                },
          ]
        : const <TtsVoice>[];
    final voice = pickCalmVoice(voices, languageCode);
    if (voice != null) {
      await _tts.setVoice(voice);
    }
    return voices.isNotEmpty;
  }
}

/// The app-wide [BreathingVoice].
@Riverpod(keepAlive: true)
BreathingVoice breathingVoice(Ref ref) => BreathingVoice();
