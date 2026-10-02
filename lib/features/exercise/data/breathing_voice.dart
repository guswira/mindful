import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/l10n/l10n.dart';

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

  /// (Re)applies the voice language whenever the app language changed
  /// since the last call, and on iOS shares the audio session so speech
  /// plays over the ambience instead of stopping it.
  Future<void> _configure() async {
    final locale = currentL10n.localeName;
    if (_configuredLocale == locale) {
      return;
    }
    await _tts.setLanguage(locale == 'id' ? 'id-ID' : 'en-US');
    await _tts.setSpeechRate(0.45);
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await _tts.setSharedInstance(true);
      await _tts.setIosAudioCategory(IosTextToSpeechAudioCategory.playback, [
        IosTextToSpeechAudioCategoryOptions.mixWithOthers,
      ]);
    }
    _configuredLocale = locale;
  }
}

/// The app-wide [BreathingVoice].
@Riverpod(keepAlive: true)
BreathingVoice breathingVoice(Ref ref) => BreathingVoice();
