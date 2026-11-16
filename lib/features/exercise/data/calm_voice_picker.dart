/// One text-to-speech voice as flutter_tts reports it (`getVoices`).
///
/// Every key is optional: iOS/macOS add quality, gender and identifier,
/// Android adds quality, network_required and features, the web only has
/// name + locale.
typedef TtsVoice = Map<String, String>;

/// Picks the most natural, calm-sounding voice for [languageCode] ('en' /
/// 'id') out of [voices], or null when none speaks it — the caller then
/// keeps the engine's default voice for the language.
///
/// Ranked so the guide sounds like a person, not a robot:
///   - iOS/macOS: premium → enhanced (neural) → Siri voices → compact; the
///     Eloquence voices (Eddy, Flo, Reed, ...) and the novelty voices
///     (Zarvox, Whisper, Bells, ...) are never picked.
///   - Android: higher quality first; offline voices beat network ones,
///     since a network voice adds a delay that puts the cue behind the
///     breathing circle; voices not installed yet are skipped.
///   - Web: the browsers' neural voices ("Natural", "Online", Google).
///   - Then a soft, warm voice from a short list that's known to sound
///     calm, then female (gentler for a guide on most engines), then the
///     main region (en-US / id-ID).
TtsVoice? pickCalmVoice(Iterable<TtsVoice> voices, String languageCode) {
  TtsVoice? best;
  var bestScore = -1;
  for (final voice in voices) {
    if (!_speaks(voice, languageCode) || _isRobotic(voice)) {
      continue;
    }
    final score = _score(voice, languageCode);
    if (score > bestScore) {
      best = voice;
      bestScore = score;
    }
  }
  return best;
}

bool _speaks(TtsVoice voice, String languageCode) {
  final locale = (voice['locale'] ?? '').toLowerCase().replaceAll('_', '-');
  final language = locale.split('-').first;
  // Older Android/Java report Indonesian as the legacy code "in".
  return language == languageCode || (languageCode == 'id' && language == 'in');
}

bool _isRobotic(TtsVoice voice) {
  final identifier = (voice['identifier'] ?? '').toLowerCase();
  if (identifier.contains('eloquence') ||
      identifier.contains('speech.synthesis.voice')) {
    return true;
  }
  final features = voice['features'] ?? '';
  return features.contains('notInstalled');
}

int _score(TtsVoice voice, String languageCode) {
  final name = (voice['name'] ?? '').toLowerCase();
  final identifier = (voice['identifier'] ?? '').toLowerCase();
  final locale = (voice['locale'] ?? '').toLowerCase().replaceAll('_', '-');
  var score = 0;

  score += switch (voice['quality']) {
    'premium' || 'very high' => 400,
    'enhanced' || 'high' => 300,
    'normal' => 100,
    _ => 0,
  };
  if (identifier.contains('siri')) {
    score += 150;
  }
  if (name.contains('natural') ||
      name.contains('neural') ||
      name.contains('online') ||
      name.startsWith('google')) {
    score += 250;
  }
  if (voice['network_required'] == '1') {
    score -= 120;
  }
  if (_calmNames.any(name.contains)) {
    score += 60;
  }
  if (voice['gender'] == 'female') {
    score += 30;
  }
  final mainRegion = languageCode == 'id'
      ? const ['id-id', 'in-id']
      : const ['en-us'];
  if (mainRegion.contains(locale)) {
    score += 20;
  }
  return score;
}

/// Voices that read softly and warmly — iOS/macOS names (Ava, Zoe,
/// Samantha, Serena, Karen, Moira, Damayanti), Microsoft's neural voices
/// on the web (Aria, Jenny, Gadis), and Google's Android voice codes
/// (sfg / tpc en-US, dfz id-ID).
const _calmNames = [
  'ava',
  'zoe',
  'samantha',
  'serena',
  'karen',
  'moira',
  'damayanti',
  'aria',
  'jenny',
  'gadis',
  '-x-sfg-',
  '-x-tpc-',
  '-x-dfz-',
];
